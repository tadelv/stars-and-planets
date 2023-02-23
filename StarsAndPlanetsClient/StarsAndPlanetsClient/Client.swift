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
      let response = try await apolloClient.fetchAsync(query: StarsQuery())
      return response.stars.map { star in
        Star(id: star.id!,
             name: star.name,
             planets: star.planets.map { .init(id: $0.id!, name: $0.name) })

      }
    } starsPlanets: { star in
      let response = try await apolloClient.fetchAsync(query: PlanetsOfAStarQuery(starID: star.id))
      return response.starsPlanets.map {
        Planet(id: $0.id!, name: $0.name)
      }
    } createStar: { name in
      _ = try await apolloClient.performAsync(mutation: NewStarMutation(name: name))
      return true
    } createPlanet: { star, name in
      _ = try await apolloClient.performAsync(mutation: NewPlanetMutation(name: name, starID: star.id))
      return true
    }
  }
}

extension DependencyValues {
  var client: Client {
    get { self[Client.self] }
    set { self[Client.self] = newValue }
  }
}

extension ApolloClient {
  struct NoData: Error {}

  func fetchAsync<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .fetchIgnoringCacheData) async throws -> Query.Data {
    try await withCheckedThrowingContinuation { continuation in
      self.fetch(query: query, cachePolicy: cachePolicy) { result in
        continuation.resume(
          with: result.flatMap {
            if let error = $0.errors?.first {
              return .failure(error)
            }
            guard let data = $0.data else {
              return .failure(NoData())
            }
            return .success(data)
          }
        )
      }
    }
  }

  func performAsync<Mutation: GraphQLMutation>(mutation: Mutation) async throws -> Mutation.Data {
    try await withCheckedThrowingContinuation { continuation in
      self.perform(mutation: mutation) { result in
        continuation.resume(
          with: result.flatMap {
            if let error = $0.errors?.first {
              return .failure(error)
            }
            guard let data = $0.data else {
              return .failure(NoData())
            }
            return .success(data)
          }
        )
      }
    }
  }
}
