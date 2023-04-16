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
        }
      }
    )
  }
}

extension API {
  func asyncExecute(request: String,
                    context: ContextType,
                    on group: EventLoopGroup) async throws -> GraphQLResult {
    try await withCheckedThrowingContinuation { continuation in
      do {
        let result = try self
          .execute(request: request,
                   context: context,
                   on: group)
          .wait()
        continuation.resume(returning: result)
      } catch {
        continuation.resume(throwing: error)
      }
    }
  }
}
