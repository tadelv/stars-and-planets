//
//  Client.swift
//  StarsAndPlanetsClient
//
//  Created by Vid Tadel on 2/16/23.
//

import Apollo
import Dependencies
import Foundation
import StarsAndPlanetsApollo

struct Client {
  let fetchStars: () async throws -> [Star]
  let createStar: (String) async throws -> Bool // ?
}

extension Client: DependencyKey {
  static var previewValue: Client {
    var stars: [Star] = [
      .init(id: "1", name: "Sun", planets: [.init(id: "11", name: "Earth")]),
      .init(id: "2", name: "Proxima Centauri", planets: [.init(id: "21", name: "Unknown")])
    ]
    return Self {
      try await Task.sleep(nanoseconds: NSEC_PER_SEC)
      return stars
    } createStar: { name in
      try await Task.sleep(nanoseconds: NSEC_PER_SEC)
      stars.append(.init(id: String(Int.random(in: 0...1000)), name: name, planets: []))
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
    } createStar: { name in
      try await withCheckedThrowingContinuation { continuation in
        apolloClient.perform(mutation: NewStarMutation(name: name)) { result in
          continuation.resume(with:
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

