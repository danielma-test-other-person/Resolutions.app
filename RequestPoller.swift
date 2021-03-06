//
//  RequestPoller.swift
//  Resolutions
//
//  Created by Daniel Ma on 12/20/16.
//  Copyright © 2016 Daniel Ma. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import PromiseKit
import PMKAlamofire

typealias Requestor = (HTTPURLResponse?) -> DataRequest

fileprivate func defaultCallback(_ value: JSON) { }

class RequestPoller {
  static let defaultInterval = 60

  let request: Requestor
  var pollInterval: Int
  var running = false
  var callback: (JSON) -> Void = defaultCallback
  var cancelNext = false
  var lastResponse: HTTPURLResponse?

  init(pollInterval: Int = RequestPoller.defaultInterval, request: @escaping Requestor) {
    self.pollInterval = pollInterval
    self.request = request
  }

  @discardableResult
  func map(_ callback: @escaping (JSON) -> Void) -> RequestPoller {
    self.callback = callback

    return self
  }

  @discardableResult
  func start() -> RequestPoller {
    running = true

    iteration()

    return self
  }

  func forceRequest() {
    cancelNext = true

    iteration()
  }

  func stop() {
    print("stopping poll")
    running = false
  }

  internal func enqueueNextIteration() {
    _ = after(interval: TimeInterval(self.pollInterval)).then { _ -> Void in
      if self.cancelNext {
        self.cancelNext = false
        return
      }

      if self.running { self.iteration() }
    }
  }

  internal func iteration() {
    _ = request(self.lastResponse)
      .response()
      .then { (request, response, data) -> Void in
        self.handleRequestResponse(request: request, response: response, data: data)
    }
  }

  internal func handleRequestResponse(request: URLRequest, response: HTTPURLResponse, data: Data) {
    lastResponse = response
    updateIntervalFromResponse(response)
    enqueueNextIteration()
    if (shouldExecuteCallback(request: request, response: response, data: data)) {
      callback(JSON(data: data))
    }
  }

  internal func updateIntervalFromResponse(_ response: HTTPURLResponse) {
  }

  internal func shouldExecuteCallback(request: URLRequest, response: HTTPURLResponse, data: Data) -> Bool {
    return true
  }
}
