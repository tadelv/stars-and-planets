import Vapor
import GraphQLKit

final class StarsController {
  func fetchStars(request: Request,
                  _: NoArguments,
                  group: EventLoopGroup) throws -> EventLoopFuture<[Star]> {
    group.next().makeFutureWithTask {
      return try await Star.query(on: request.db).with(\.$planets).all()
    }
  }

  struct CreateStarArguments: Codable {
    let name: String
  }

  func createStar(request: Request,
                  arguments: CreateStarArguments,
                  group: EventLoopGroup) throws -> EventLoopFuture<Star> {
    group.next().makeFutureWithTask {
      let star = Star(name: arguments.name)
      try await star.create(on: request.db)
      return star
    }
  }

  struct DeleteStarArguments: Codable {
    let id: UUID
  }

  func deleteStar(request: Request,
                  arguments: DeleteStarArguments,
                  group: EventLoopGroup) throws -> EventLoopFuture<Bool> {
    group.next().makeFutureWithTask {
      guard let star = try await Star.find(arguments.id, on: request.db) else {
        throw Abort(.notFound)
      }
      try await star.delete(on: request.db)
      return true
    }
  }

  func fetchPlanets(request: Request, _: NoArguments, group: EventLoopGroup) throws -> EventLoopFuture<[Planet]> {
    group.next().makeFutureWithTask {
      try await Planet.query(on: request.db).all()
    }
  }

  struct CreatePlanetArguments: Codable {
    let name: String
    let starID: UUID
  }

  func createPlanet(request: Request,
                    arguments: CreatePlanetArguments,
                    group: EventLoopGroup) throws -> EventLoopFuture<Planet> {
    group.next().makeFutureWithTask {
      let planet = Planet(name: arguments.name, starID: arguments.starID)
      try await planet.create(on: request.db)
      return planet
    }
  }

  struct DeletePlanetArguments: Codable {
    let id: UUID
  }

  func deletePlanet(request: Request,
                  arguments: DeletePlanetArguments,
                  group: EventLoopGroup) throws -> EventLoopFuture<Bool> {
    group.next().makeFutureWithTask {
      guard let planet = try await Planet.find(arguments.id, on: request.db) else {
        throw Abort(.notFound)
      }
      try await planet.delete(on: request.db)
      return true
    }
  }
}
