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
    var star: Star
  }

  enum Action: Equatable {
    case addPlanet(String)
    case planetAdded(TaskResult<Bool>)
    case loadPlanets
    case planetsFetched(TaskResult<[Planet]>)
    case delegate(Delegate)

    enum Delegate: Equatable {
      case planetAdded(Star)
    }
  }

  @Dependency(\.client) var client

  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case let .addPlanet(name):
      return .task { [star = state.star] in
        await .planetAdded(.init(catching: {
          try await client.createPlanet(star, name)
        }))
      }
    case let .planetAdded(result):
      switch result {
      case .failure:
        // TODO: show error
        return .none
      case .success:
        return .send(.loadPlanets)
      }
    case .delegate:
      return .none
    case .loadPlanets:
      return .task { [star = state.star] in
        await .planetsFetched(.init(catching: {
          try await client.starsPlanets(star)
        }))
      }.animation()
    case let .planetsFetched(result):
      switch result {
      case let .success(planets):
        state.star.planets = planets
        return .send(.delegate(.planetAdded(state.star)))
      case let .failure(error):
        break
      }
      return .none
    }
  }
}

struct DetailView: View {
  let store: StoreOf<DetailFeature>

  @State var newPlanetName: String = ""

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        ForEach(viewStore.star.planets) { planet in
          Text(planet.name)
        }
        TextField("New planet name", text: $newPlanetName)
          .onSubmit {
            viewStore.send(.addPlanet(newPlanetName))
            newPlanetName = ""
          }
      }
    }
  }
}

struct DetailViewPreview: PreviewProvider {
  static var previews: some View {
    DetailView(store: StoreOf<DetailFeature>(initialState: DetailFeature.State(star: .init(id: "1", name: "Sun", planets: [.init(id: "1", name: "Earth")])),
                              reducer: DetailFeature()))
  }
}
