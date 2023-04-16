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
//    [
//      Star(
//        id: "1",
//        name: "Sol",
//        planets: [
//          Planet(
//            id: "10",
//            name: "Earth",
//            starId: "1"
//          )
//        ]
//      )
//    ]
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
      return Star(id: id, name: name, planets: [])
    }
  }
}
