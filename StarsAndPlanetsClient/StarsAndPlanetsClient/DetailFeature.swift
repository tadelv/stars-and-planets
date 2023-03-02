//
//  DetailFeature.swift
//  StarsAndPlanetsClient
//
//  Created by Vid Tadel on 2/16/23.
//

import ComposableArchitecture
import SwiftUI

struct DetailFeature: ReducerProtocol {
  struct State: Equatable {
    var loadableStar: Loadable<Star>
  }

  enum Action: Equatable {
    case addPlanet(String)
    case planetAdded(Star, TaskResult<Bool>)
    case loadPlanets(Star)
    case planetsFetched(Star, TaskResult<[Planet]>)
    case delegate(Delegate)

    enum Delegate: Equatable {
      case planetAdded(Star)
    }
  }

  @Dependency(\.client) var client

  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case let .addPlanet(name):
      guard let star = state.loadableStar.value else {
        return .none
      }
      state.loadableStar = .loading
      return .task {
        await .planetAdded(star, .init(catching: {
          try await client.createPlanet(star, name)
        }))
      }
    case let .planetAdded(star, result):
      switch result {
      case let .failure(error):
        state.loadableStar = .failed(error)
        return .none
      case .success:
        return .send(.loadPlanets(star))
      }
    case .delegate:
      return .none
    case let .loadPlanets(star):
      return .task {
        await .planetsFetched(star, .init(catching: {
          try await client.starsPlanets(star)
        }))
      }.animation()
    case let .planetsFetched(star, .success(planets)):
      var mutableStar = star
      mutableStar.planets = planets
      state.loadableStar = .success(mutableStar)
      return .send(.delegate(.planetAdded(mutableStar)))

    case let .planetsFetched(_, .failure(error)):
      state.loadableStar = .failed(error)
      return .none
    }
  }
}

struct DetailView: View {
  let store: StoreOf<DetailFeature>

  @State var newPlanetName: String = ""

  var body: some View {
    LoadableViewStore(loadable: self.store.scope(state: \.loadableStar)) { viewStore in
      List {
        ForEach(viewStore.planets) { planet in
          Text(planet.name)
        }
        TextField("New planet name", text: $newPlanetName)
          .onSubmit {
            viewStore.send(.addPlanet(newPlanetName))
            newPlanetName = ""
          }
      }
    } failedView: { viewStore in
      Text("Failure: \(viewStore.state.localizedDescription)")
    } waitingView: { viewStore in
      ProgressView("Loading")
    }
//    WithViewStore(store, observe: { $0 }) { viewStore in
//      List {
//        ForEach(viewStore.star.planets) { planet in
//          Text(planet.name)
//        }
//        TextField("New planet name", text: $newPlanetName)
//          .onSubmit {
//            viewStore.send(.addPlanet(newPlanetName))
//            newPlanetName = ""
//          }
//      }
//    }
  }
}

struct DetailViewPreview: PreviewProvider {
  static var previews: some View {
    DetailView(
      store: StoreOf<DetailFeature>(
        initialState: DetailFeature.State(
          loadableStar: .success(.init(id: "1", name: "Star", planets: []))
          ),
        reducer: DetailFeature()
      )
    )
  }
}
