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
    var selectedStar: DetailFeature.State?
    @PresentationState
    var alert: AlertState<Action.Alert>?
    @PresentationState
    var newStar: CreateStarFeature.State?
  }

  enum Action {
    case load
    case resultsFetched(TaskResult<[Star]>)
    case createStarTapped
    case dismissCreateStarTapped
    case newStar(PresentationAction<CreateStarFeature.Action>)
    case createStarConfirmTapped
    case starCreated(TaskResult<Void>)
    case starSelected(Star)
    case navigateBack
    case detail(DetailFeature.Action)
    case alert(PresentationAction<Alert>)

    enum Alert: Equatable {
    }
  }

  @Dependency(\.client) var client

  var body: some ReducerProtocol<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .alert:
        return .none
      case .load:
        return .task {
          await .resultsFetched(.init(catching: {
            try await client.fetchStars()
          }))
        }.animation()
      case let .resultsFetched(result):
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
        state.newStar = .init(name: "")
        return .none

      case .dismissCreateStarTapped:
        return .send(.newStar(.dismiss))

      case .createStarConfirmTapped:
        guard let name = state.newStar?.name,
              name.isEmpty == false else {
          return .none
        }
        return .merge(
          .send(.newStar(.dismiss)),
          .task {
            await .starCreated(.init(catching: {
              _ = try await client.createStar(name)
            }))
          }
        )
      case .newStar:
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
      case .navigateBack:
        state.selectedStar = nil
        return .none
      case let .detail(.delegate(.planetAdded(star))):
        state.stars[id: star.id] = star
        return .none
      case .detail:
        return .none
      }
    }
    .ifLet(\.$alert, action: /Action.alert)
    .ifLet(\.$newStar, action: /Action.newStar) {
      CreateStarFeature()
    }
    .ifLet(\.selectedStar, action: /Action.detail) {
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
            .navigationDestination(
              isPresented: viewStore.binding(get: { $0.selectedStar != nil },
                                             send: .navigateBack)
            ) {
              IfLetStore(store.scope(
                state: \.selectedStar,
                action: ListFeature.Action.detail
              )) {
                DetailView(store: $0)
              }
            }
          }
        }
      }
      .onAppear {
        viewStore.send(.load)
      }
      .sheet(
        store: self.store.scope(
          state: \.$newStar,
          action: ListFeature.Action.newStar
        )
      ) { store in
        NavigationView {
          CreateStarView(store: store)
            .toolbar {
              ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                  viewStore.send(.dismissCreateStarTapped)
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
