//
//  GithubAdvancedPreferencesViewController.swift
//  Resolutions
//
//  Created by Daniel Ma on 1/3/17.
//  Copyright © 2017 Daniel Ma. All rights reserved.
//

import Cocoa

class GithubAdvancedPreferencesViewController: NSViewController {
  @IBOutlet weak var ignoredEventsTableView: NSTableView!

  let ignorableEvents = GithubPoller.ignorableEvents

  override func viewDidLoad() {
    super.viewDidLoad()

    ignoredEventsTableView.delegate = self
    ignoredEventsTableView.dataSource = self
  }
}

extension GithubAdvancedPreferencesViewController: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return ignorableEvents.count
  }
}

extension GithubAdvancedPreferencesViewController: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let cell = tableView.make(withIdentifier: "cell", owner: self) as! GithubIgnoredEventsTableCellView

    cell.configure(ignorableEvents[row])

    return cell
  }
}

class GithubIgnoredEventsTableCellView: NSTableCellView {
  var event: (String, String)!

  let dictKey = GithubPoller.ignoredEventsKey

  @IBOutlet weak var checkboxButton: NSButton!
  @IBAction func checkboxButtonClicked(_ sender: NSButton) {
    var dict = dictionary
    dict[event.0] = sender.state == NSOnState

    UserDefaults.standard.setValue(dict, forKey: dictKey)
  }

  func configure(_ event: (String, String)) {
    self.event = event
    checkboxButton.title = event.1
    let ignored = dictionary[event.0] as Bool!
    checkboxButton.state = (ignored ?? false) ? NSOnState : NSOffState
  }

  var dictionary: Dictionary<String, Bool> {
    let savedValue = UserDefaults.standard.value(forKey: dictKey) as? Dictionary<String, Bool>

    if let savedValue = savedValue {
      return savedValue
    } else {
      return GithubPoller.ignoredEventsDefaultValue
    }
  }
}
