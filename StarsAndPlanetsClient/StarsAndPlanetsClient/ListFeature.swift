//
//  ListFeature.swift
//  StarsAndPlanetsClient
//
//  Created by Vid Tadel on 2/16/23.
//

import ComposableArchitecture
import SwiftUI

struct ListFeature: Reducer {
  struct State: Equatable {
    var stars: [Star] = []
    var errorMessage: String?
  }

  enum Action {
    case load
    case resultsFetched(TaskResult<[Star]>)
    case newStar(String)
    case starCreated(TaskResult<Void>)
    case okTapped
  }

  @Dependency(\.client) var client

  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .load:
      return .task {
        await .resultsFetched(.init(catching: {
          try await client.fetchStars()
        }))
      }.animation()
    case let .resultsFetched(result):
      switch result {
      case let .success(stars):
        state.errorMessage = nil
        state.stars = stars
      case let .failure(error):
        state.errorMessage = "Failed with: \(error.localizedDescription)"
      }
      return .none
    case let .newStar(name):
      return .task {
        await .starCreated(.init(catching: {
          _ = try await client.createStar(name)
        }))
      }
    case let .starCreated(result):
      switch result {
      case .success:
        return .task {
          .load
        }
      case let .failure(error):
        state.errorMessage = "Failed with: \(error.localizedDescription)"
        return .none
      }
    case .okTapped:
      state.errorMessage = nil
      return .none
    }
  }
}

struct ListView: View {
  let store: StoreOf<ListFeature>

  @State var isShowingSheet = false

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      NavigationStack {
        List {
          Button {
            isShowingSheet = true
          } label: {
            HStack {
              Image(systemName: "plus")
              Text("Add star")
            }
          }
          ForEach(viewStore.stars) { star in
            VStack(alignment: .leading) {
              Text(star.name)
              Text("\(star.planets.count) planets")
            }
          }
        }
      }
      .onAppear {
        viewStore.send(.load)
      }
      .sheet(isPresented: $isShowingSheet) {
        AddStarView { name in
          viewStore.send(.newStar(name))
          isShowingSheet = false
        }
      }
      .alert("Something went wrong",
             isPresented: viewStore.binding(get: {
        $0.errorMessage != nil
      }, send: .okTapped),
             actions: { EmptyView() }) {
        Text(viewStore.errorMessage ?? "")
      }
    }
  }
}

struct AddStarView: View {
  @State var name = ""

  let action: (String) -> Void

  @FocusState
  var focused

  var body: some View {
    Form {
      Section("Star name") {
        TextField("Enter name", text: $name)
          .focused($focused)
          .onAppear {
            focused = true
          }
        Button {
          action(name)
        } label: {
          Text("Done")
        }
      }
    }
  }
}

struct ListView_Previews: PreviewProvider {
  static var previews: some View {
    ListView(store: Store(initialState: ListFeature.State(), reducer: ListFeature()))
  }
}
