//
//  File.swift
//  
//
//  Created by Vid Tadel on 4/15/23.
//

import Foundation
import AWSDynamoDB

struct Planet: Codable {
  let id: String
  let name: String
  let starId: String
}

struct Star: Codable {
  let id: String
  let name: String
  let planets: [Planet]
}

struct StarsAndPlanetsContext {
  let client: DynamoDBClient
  let starsTable: String
  let planetsTable: String

  enum ContextError: LocalizedError {
    case starsTableNotFound
    case planetsTableNotFound
    case starsNotFound
    case planetsNotFound
    case starDoesntExist
  }

  init() async throws {
    client = try await DynamoDBClient(region: "eu-central-1")
    guard let starsTable = ProcessInfo.processInfo.environment["STARS_TABLE"] else {
      throw ContextError.starsTableNotFound
    }
    self.starsTable = starsTable

    guard let planetsTable = ProcessInfo.processInfo.environment["PLANETS_TABLE"] else {
      throw ContextError.planetsTableNotFound
    }
    self.planetsTable = planetsTable
  }

  func stars() async throws -> [Star] {
    let planets = try await planets()

    let input = ScanInput(tableName: starsTable)
    let queryResult = try await client.scan(input: input)
    guard let items = queryResult.items else {
      throw ContextError.starsNotFound
    }
    return items.compactMap {
      guard case let .s(id) = $0["starId"],
            case let .s(name) = $0["name"] else {
        return nil
      }
//      Star(id: $0["id"], name: $0["name"], planets: [])
      return Star(id: id, name: name, planets: planets.filter({ $0.starId == id }))
    }
  }

  func planets() async throws -> [Planet] {
    let input = ScanInput(tableName: planetsTable)
    let queryResult = try await client.scan(input: input)
    guard let items = queryResult.items else {
      throw ContextError.planetsNotFound
    }
    return items.compactMap {
      guard case let .s(id) = $0["planetId"],
            case let .s(name) = $0["name"],
            case let .s(starId) = $0["starId"] else {
        return nil
      }
      //      Star(id: $0["id"], name: $0["name"], planets: [])
      return Planet(id: id, name: name, starId: starId)
    }
  }

  func createStar(_ name: String) async throws -> Star {
    let stars = try await stars()
    let newId = stars.reduce(into: 0) { res, element in
      res = Int(element.id)! >= res ? Int(element.id)! + 1 : res
    }
    let newStar = Star(id: "\(newId)", name: name, planets: [])

    let input = PutItemInput(
      item: [
        "starId": .s(newStar.id),
        "name": .s(newStar.name)
      ],
      tableName: starsTable
    )

    _ = try await client.putItem(input: input)

    return newStar
  }

  func createPlanet(_ name: String, starId: String) async throws -> Planet {
    let stars = try await stars()
    let planets = try await planets()
    guard let star = stars.first(where: { $0.id == starId }) else {
      throw ContextError.starDoesntExist
    }
    let starsPlanets = planets.filter {
      $0.starId == star.id
    }
    let newId = starsPlanets.reduce(into: 0) { res, element in
      res = Int(element.id)! >= res ? Int(element.id)! + 1 : res
    }

    let newPlanet = Planet(id: "\(newId)",
                           name: name,
                           starId: star.id)

    let input = PutItemInput(
      item: [
        "planetId": .s(newPlanet.id),
        "name": .s(newPlanet.name),
        "starId": .s(newPlanet.starId)
      ],
      tableName: planetsTable
    )

    _ = try await client.putItem(input: input)

    return newPlanet
  }

  func planetsOfAStar(_ id: String) async throws -> [Planet] {
    let input = ScanInput(
      scanFilter: [
        "starId": .init(attributeValueList: [.s(id)],
                        comparisonOperator: .eq)
      ],
      tableName: planetsTable
    )
    let queryResult = try await client.scan(input: input)
    guard let items = queryResult.items else {
      throw ContextError.planetsNotFound
    }
    return items.compactMap {
      guard case let .s(id) = $0["planetId"],
            case let .s(name) = $0["name"],
            case let .s(starId) = $0["starId"] else {
        return nil
      }
      return Planet(id: id, name: name, starId: starId)
    }
  }
}
