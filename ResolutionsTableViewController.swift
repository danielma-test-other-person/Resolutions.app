//
//  ResolutionsTableViewController.swift
//  Resolutions
//
//  Created by Daniel Ma on 4/4/17.
//  Copyright © 2017 Daniel Ma. All rights reserved.
//

fileprivate var myContext = 0

import Cocoa

class ResolutionsTableViewController: NSViewController {
  lazy var managedObjectContext: NSManagedObjectContext = {
    return (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
  }()
  
  @IBOutlet var arrayController: NSArrayController!

  static let coordinator: NSMutableDictionary = ["selectedObjects": []]

  override func viewDidLoad() {
    super.viewDidLoad()

    ResolutionsTableViewController.coordinator.addObserver(self, forKeyPath: "selectedObjects", options: .new, context: &myContext)
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if context == &myContext {
      handleSelectedObjectsChanged()
    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }

  internal func handleSelectedObjectsChanged() {
    guard let selectedObjects = ResolutionsTableViewController.coordinator.value(forKey: "selectedObjects") as? Array<Any> else { return }

    if let selectedTreeNodes = selectedObjects as? Array<RepoTreeNode> {
      guard let selectedObject = selectedTreeNodes.first else { return }

      arrayController.filterPredicate = NSPredicate(format: "repo = %@", argumentArray: [selectedObject.repo])
    } else {
      guard let selectedObject = selectedObjects[0] as? NSDictionary,
        let name = selectedObject.value(forKey: "name") as? String
        else { return }

      let lowercaseName = name.lowercased()

      if lowercaseName == "inbox" {
        arrayController.filterPredicate = NSPredicate(format: "completedDate = nil")
      } else if lowercaseName == "complete" {
        arrayController.filterPredicate = NSPredicate(format: "completedDate != nil")
      }
    }
  }
}
