//
//  StarsAndPlanetsClientApp.swift
//  StarsAndPlanetsClient
//
//  Created by Vid Tadel on 2/15/23.
//

import ComposableArchitecture
import SwiftUI

@main
struct StarsAndPlanetsClientApp: App {
  var isUnitTesting: Bool {
    if NSClassFromString("XCTestCase") != nil {
      return true
    }
    return false
  }

  var body: some Scene {
    WindowGroup {
      if isUnitTesting {
        EmptyView()
      } else {
        ListView(
          store: Store(
            initialState: ListFeature.State(),
            reducer: ListFeature()._printChanges()
          )
        )
      }
    }
  }
}
