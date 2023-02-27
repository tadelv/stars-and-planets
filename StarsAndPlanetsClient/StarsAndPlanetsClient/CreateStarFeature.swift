//
//  CreateStarFeature.swift
//  StarsAndPlanetsClient
//
//  Created by Vid Tadel on 2/27/23.
//

import ComposableArchitecture
import SwiftUI

struct CreateStarFeature: ReducerProtocol {
  struct State: Equatable {
    @BindingState var name: String
  }

  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
  }

  var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    EmptyReducer()
  }
}

struct CreateStarView: View {
  let store: StoreOf<CreateStarFeature>

  @FocusState
  var focused

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      Form {
        Section("Star name") {
          TextField("Enter name", text: viewStore.binding(\.$name))
            .focused($focused)
            .onAppear {
              focused = true
            }
        }
      }
    }
  }
}
