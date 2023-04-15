//
//  File.swift
//  
//
//  Created by Vid Tadel on 4/15/23.
//

import Foundation

struct Message : Codable {
  let content: String
}

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
  func stars() -> [Star] {
    [
      Star(
        id: "1",
        name: "Sol",
        planets: [
          Planet(
            id: "10",
            name: "Earth",
            starId: "1"
          )
        ]
      )
    ]
  }
}

struct Context {
  func message() -> Message {
    Message(content: "Hello, world!")
  }
}
