//
//  AppRecord.swift
//  Resolutions
//
//  Created by Daniel Ma on 12/19/16.
//  Copyright © 2016 Daniel Ma. All rights reserved.
//

import Foundation
import GRDB

class AppRecord: Record {
  var id: Int64?
  var createdAt: Date?
  var updatedAt: Date?

  required init(row: Row) {
    id = row.value(named: "id")
    createdAt = row.value(named: "createdAt")
    updatedAt = row.value(named: "updatedAt")
    super.init(row: row)
  }

  override init() {
    super.init()
  }

  override func didInsert(with rowID: Int64, for column: String?) {
    id = rowID
  }

  override func insert(_ db: Database) throws {
    createdAt = Date()
    updatedAt = Date()
    try super.insert(db)
  }

  override func update(_ db: Database, columns: Set<String>) throws {
    updatedAt = Date()
    try super.update(db, columns: columns)
  }

  final override var persistentDictionary: [String: DatabaseValueConvertible?] {
    var dictionary: [String: DatabaseValueConvertible?] = [
      "id": id,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      ]

    appRecordDictionary.forEach {
      dictionary[$0] = $1
    }

    return dictionary
  }

  var appRecordDictionary: [String: DatabaseValueConvertible?] {
    return [:]
  }
}