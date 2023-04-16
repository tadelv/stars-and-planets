//
//  File.swift
//  
//
//  Created by Vid Tadel on 4/15/23.
//

import Graphiti
import GraphQL
import NIO

struct StarsResolver {
  func stars(
    context: StarsAndPlanetsContext,
    arguments: NoArguments,
    group: EventLoopGroup
  ) throws -> EventLoopFuture<[Star]> {
    group.next().makeFutureWithTask {
      try await context.stars()
    }
  }

  func planets(
    context: StarsAndPlanetsContext,
    _: NoArguments,
    group: EventLoopGroup
  ) throws -> EventLoopFuture<[Planet]> {
    group.next().makeFutureWithTask {
      try await context.planets()
    }
  }

  struct CreateStarArguments: Codable {
    let name: String
  }

  func createStar(
    context: StarsAndPlanetsContext,
    arguments: CreateStarArguments,
    group: EventLoopGroup
  ) throws -> EventLoopFuture<Star> {
    group.next().makeFutureWithTask {
      try await context.createStar(arguments.name)
    }
  }
}

struct StarsAPI: API {
  let resolver: StarsResolver
  let schema: Schema<StarsResolver, StarsAndPlanetsContext>

  static func create() -> StarsAPI {
    StarsAPI(
      resolver: StarsResolver(),
      schema: try! Schema<StarsResolver, StarsAndPlanetsContext> {
        Type(Planet.self) {
          Field("id", at: \.id)
          Field("name", at: \.name)
          Field("starId", at: \.starId)
        }

        Type(Star.self) {
          Field("id", at: \.id)
          Field("name", at: \.name)
          Field("planets", at: \.planets)
        }

        Query {
          Field("stars", at: StarsResolver.stars)
          Field("planets", at: StarsResolver.planets)
        }

        Mutation {
          Field("createStar", at: StarsResolver.createStar) {
            Argument("name", at: \.name)
          }
        }
      }
    )
  }
}

extension API {
  func asyncExecute(request: String,
                    context: ContextType,
                    on group: EventLoopGroup,
                    variables: [String: Map]?) async throws -> GraphQLResult {
    try await withCheckedThrowingContinuation { continuation in
      do {
        let result = try self
          .execute(request: request,
                   context: context,
                   on: group,
                   variables: variables ?? [:])
          .wait()
        continuation.resume(returning: result)
      } catch {
        continuation.resume(throwing: error)
      }
    }
  }
}
