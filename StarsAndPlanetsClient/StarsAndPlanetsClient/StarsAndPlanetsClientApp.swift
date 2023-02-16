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
    var body: some Scene {
        WindowGroup {
//          ContentView()
          ListView(store: Store(initialState: ListFeature.State(),
                                reducer: ListFeature()))
        }
    }
}
