//
//  ListFeature.swift
//  StarsAndPlanetsClient
//
//  Created by Vid Tadel on 2/16/23.
//

import ComposableArchitecture
import SwiftUI

struct ListFeature: ReducerProtocol {

  struct State: Equatable {
    var stars: IdentifiedArrayOf<Star> = []

    @PresentationState
    var destination: Destination?

    enum Destination: Equatable {
      case detail(DetailFeature.State)
      case alert(AlertState<Action.Alert>)
      case sheet(CreateStarFeature.State)
    }
  }

  enum Action {
    case load
    case starsFetched(TaskResult<[Star]>)
    case createStarTapped
    case createStarConfirmTapped
    case createStarDismissTapped
    case starCreated(TaskResult<Void>)
    case starSelected(Star)
    case destination(PresentationAction<Destination>)

    enum Alert: Equatable {
    }

    enum Destination: Equatable {
      case detail(DetailFeature.Action)
      case alert(Alert)
      case sheet(CreateStarFeature.Action)
    }
  }

  @Dependency(\.client) var client

  var body: some ReducerProtocolOf<Self> {
    Reduce<State, Action> { state, action in
      switch action {
      case .load:
        return .task {
          await .starsFetched(.init(catching: {
            try await client.fetchStars()
          }))
        }.animation()
      case let .starsFetched(result):
        switch result {
        case let .success(stars):
          state.stars = IdentifiedArray(uniqueElements: stars)
          // not sure if this is still needed since we update the star from DetailFeature
          if case let .detail(detailState) = state.destination,
             let found = state.stars[id: detailState.star.id] {
            state.destination = .detail(DetailFeature.State(star: found))
          }
        case let .failure(error):
          state.destination = .alert(.failed(with: error))
        }
        return .none
      case .createStarTapped:
        state.destination = .sheet(CreateStarFeature.State(name: ""))
        return .none

      case .createStarDismissTapped:
        return .send(.destination(.dismiss))

      case .createStarConfirmTapped:
        guard case let .sheet(createState) = state.destination,
              createState.name.isEmpty == false else {
          return .none
        }
        return .merge(
          .send(.destination(.dismiss)),
          .task {
            await .starCreated(.init(catching: {
              _ = try await client.createStar(createState.name)
            }))
          }
        )
      case let .starCreated(result):
        switch result {
        case .success:
          return .task {
            .load
          }
        case let .failure(error):
          state.destination = .alert(.failed(with: error))
          return .none
        }
      case let .starSelected(star):
        state.destination = .detail(DetailFeature.State(star: star))
        return .none
      case let .destination(.presented(.detail(.delegate(.planetAdded(star))))):
        state.stars[id: star.id] = star
        return .none
      case .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: /Action.destination) {
      Scope(state: /State.Destination.alert, action: /Action.Destination.alert) {}
      Scope(state: /State.Destination.sheet, action: /Action.Destination.sheet) {
        CreateStarFeature()
      }
      Scope(state: /State.Destination.detail, action: /Action.Destination.detail) {
        DetailFeature()
      }
    }
  }
}

extension AlertState where Action == ListFeature.Action.Alert {
  static func failed(with error: Error) -> Self {
    AlertState {
      TextState("Something went wrong")
    } message: {
      TextState("Failed with: \(error.localizedDescription)")
    }
  }
}

struct ListView: View {
  let store: StoreOf<ListFeature>

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      NavigationStack {
        List {
          Button {
            viewStore.send(.createStarTapped)
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
            .clipShape(Rectangle())
            .onTapGesture {
              viewStore.send(.starSelected(star))
            }
          }
        }
        .navigationDestination(
          store: self.store.scope(
            state: \.$destination,
            action: ListFeature.Action.destination
          ),
          state: /ListFeature.State.Destination.detail,
          action: ListFeature.Action.Destination.detail
        ) { store in
          DetailView(store: store)
        }
      }
      .onAppear {
        viewStore.send(.load)
      }
      .sheet(
        store: self.store.scope(
          state: \.$destination,
          action: ListFeature.Action.destination
        ),
        state: /ListFeature.State.Destination.sheet,
        action: ListFeature.Action.Destination.sheet
      ) { store in
        NavigationView {
          CreateStarView(store: store)
            .toolbar {
              ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                  viewStore.send(.createStarDismissTapped)
                }
              }
              ToolbarItem(placement: .primaryAction) {
                Button("Add") {
                  viewStore.send(.createStarConfirmTapped)
                }
              }
            }
            .navigationTitle("New Star")
        }
      }
      .alert(
        store: self.store.scope(state: \.$destination, action: ListFeature.Action.destination),
        state: /ListFeature.State.Destination.alert,
        action: ListFeature.Action.Destination.alert
      )
    }
  }
}

struct ListView_Previews: PreviewProvider {
  static var previews: some View {
    ListView(
      store: Store(
        initialState: ListFeature.State(),
        reducer: ListFeature()
      )
    )
  }
}
