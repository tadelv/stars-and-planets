//
//  Models.swift
//  StarsAndPlanetsClient
//
//  Created by Vid Tadel on 2/16/23.
//

import Foundation

struct Star: Identifiable, Equatable {
  let id: String
  let name: String
  let planets: [Planet]
}

struct Planet: Identifiable, Equatable {
  let id: String
  let name: String
}
