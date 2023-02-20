//
//  Client.swift
//  StarsAndPlanetsClient
//
//  Created by Vid Tadel on 2/16/23.
//

import Apollo
import Dependencies
import Foundation
import IdentifiedCollections
import StarsAndPlanetsApollo

struct Client {
  let fetchStars: () async throws -> [Star]
  var starsPlanets: (Star) async throws -> [Planet]
  let createStar: (String) async throws -> Bool // ?
  var createPlanet: (Star, String) async throws -> Bool
}

extension Client: DependencyKey {
  static var testValue: Client {
    Self(fetchStars: unimplemented(),
         starsPlanets: unimplemented(),
         createStar: unimplemented(),
         createPlanet: unimplemented())
  }

  static var previewValue: Client {
    var stars: IdentifiedArrayOf<Star> = [
      .init(id: "1", name: "Sun", planets: [.init(id: "11", name: "Earth")]),
      .init(id: "2", name: "Proxima Centauri", planets: [.init(id: "21", name: "Unknown")])
    ]
    return Self {
      try await Task.sleep(nanoseconds: NSEC_PER_SEC)
      return Array(stars)
    } starsPlanets: { star in
      guard let parentStar = stars[id: star.id] else {
        struct NotFound: Error {}
        throw NotFound()
      }
      return parentStar.planets
    } createStar: { name in
      try await Task.sleep(nanoseconds: NSEC_PER_SEC)
      stars.append(.init(id: String(Int.random(in: 0...1000)), name: name, planets: []))
      return true
    } createPlanet: { star, name in
      try await Task.sleep(nanoseconds: NSEC_PER_SEC)
      let copy = Star(id: star.id,
                      name: star.name,
                      planets: star.planets + [
                        .init(id: String(Int.random(in: 0...1000)), name: name)
                      ])
      stars[id: star.id] = copy
      return true
    }
  }

  static var liveValue: Client {
    let apolloClient = ApolloClient(url: URL(string: "http://localhost:8080/graphql")!)

    return Self {
      try await withCheckedThrowingContinuation { continuation in
        apolloClient.fetch(query: StarsQuery(), cachePolicy: .fetchIgnoringCacheData) { result in
          continuation.resume(with: result.map { data in
            guard let innerData = data.data else {
              print(data.errors!.first!)
              return []
            }
            return innerData.stars.map { star in
              Star(id: star.id!,
                   name: star.name,
                   planets: star.planets.map { .init(id: $0.id!, name: $0.name) })
            }
          })
        }
      }
    } starsPlanets: { star in
      try await withCheckedThrowingContinuation { continuation in
        apolloClient.fetch(query: PlanetsOfAStarQuery(starID: star.id),
                           cachePolicy: .fetchIgnoringCacheData) { result in
          continuation.resume(with: result.map { data in
            guard let innerData = data.data else {
              return []
            }
            return innerData.starsPlanets.map {
              Planet(id: $0.id!, name: $0.name)
            }
          })
        }
      }
    } createStar: { name in
      try await withCheckedThrowingContinuation { continuation in
        apolloClient.perform(mutation: NewStarMutation(name: name)) { result in
          continuation.resume(
            with:
              result.map { _ in
                true
              }
          )
        }
      }
    } createPlanet: { star, name in
      try await withCheckedThrowingContinuation { continuation in
        apolloClient.perform(mutation: NewPlanetMutation(name: name,
                                                         starID: UUID(stringLiteral: star.id))) { result in
          continuation.resume(
            with:
              result.map { _ in
                true
              }
          )
        }
      }
    }
  }
}

extension DependencyValues {
  var client: Client {
    get { self[Client.self] }
    set { self[Client.self] = newValue }
  }
}

