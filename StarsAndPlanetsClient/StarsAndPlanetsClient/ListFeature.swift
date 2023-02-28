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
    var selectedStar: DetailFeature.State?
    @PresentationState
    var alert: AlertState<Action.Alert>?
    @PresentationState
    var newStarSheet: CreateStarFeature.State?
  }

  enum Action {
    case load
    case starssFetched(TaskResult<[Star]>)
    case createStarTapped
    case newStarSheet(PresentationAction<CreateStarFeature.Action>)
    case createStarConfirmTapped
    case createStarDismissTapped
    case starCreated(TaskResult<Void>)
    case starSelected(Star)
    case detail(PresentationAction<DetailFeature.Action>)
    case alert(PresentationAction<Alert>)

    enum Alert: Equatable {
    }
  }

  @Dependency(\.client) var client

  var body: some ReducerProtocolOf<Self> {
    Reduce<State, Action> { state, action in
      switch action {
      case .alert:
        return .none
      case .load:
        return .task {
          await .starssFetched(.init(catching: {
            try await client.fetchStars()
          }))
        }.animation()
      case let .starssFetched(result):
        switch result {
        case let .success(stars):
          state.stars = IdentifiedArray(uniqueElements: stars)
          if let selected = state.selectedStar?.star,
             let found = state.stars[id: selected.id] {
            state.selectedStar = DetailFeature.State(star: found)
          }
        case let .failure(error):
          state.alert = .failed(with: error)
        }
        return .none
      case .createStarTapped:
        state.newStarSheet = .init(name: "")
        return .none

      case .createStarDismissTapped:
        return .send(.newStarSheet(.dismiss))

      case .createStarConfirmTapped:
        guard let name = state.newStarSheet?.name,
              name.isEmpty == false else {
          return .none
        }
        return .merge(
          .send(.newStarSheet(.dismiss)),
          .task {
            await .starCreated(.init(catching: {
              _ = try await client.createStar(name)
            }))
          }
        )
      case .newStarSheet:
        return .none
      case let .starCreated(result):
        switch result {
        case .success:
          return .task {
            .load
          }
        case let .failure(error):
          state.alert = .failed(with: error)
          return .none
        }
      case let .starSelected(star):
        state.selectedStar = DetailFeature.State(star: star)
        return .none
      case let .detail(.presented(.delegate(.planetAdded(star)))):
        state.stars[id: star.id] = star
        return .none
      case .detail:
        return .none
      }
    }
    .ifLet(\.$alert, action: /Action.alert)
    .ifLet(\.$newStarSheet, action: /Action.newStarSheet) {
      CreateStarFeature()
    }
    .ifLet(\.$selectedStar, action: /Action.detail) {
      DetailFeature()
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
            state: \.$selectedStar,
            action: ListFeature.Action.detail
          )
        ) { store in
          DetailView(store: store)
        }
      }
      .onAppear {
        viewStore.send(.load)
      }
      .sheet(
        store: self.store.scope(
          state: \.$newStarSheet,
          action: ListFeature.Action.newStarSheet
        )
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
        store: self.store.scope(
          state: \.$alert,
          action: ListFeature.Action.alert
        )
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
