//
//  DetailFeatureTests.swift
//  StarsAndPlanetsClientTests
//
//  Created by Vid Tadel on 2/16/23.
//

import ComposableArchitecture
@testable import StarsAndPlanetsClient
import XCTest

@MainActor
final class DetailFeatureTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

  func testAddingPlanetSucceeds() async throws {
    var star = Star(id: "1", name: "A", planets: [])
    let store = TestStore(initialState: DetailFeature.State(star: star),
                          reducer: DetailFeature())
    store.dependencies.client.createPlanet = { _, _ in
      true
    }

    let planets: [Planet] = [.init(id: "1", name: "a"),
                             .init(id: "2", name: "b")]
    store.dependencies.client.starsPlanets = { _ in
      planets
    }

    await store.send(.addPlanet("test"))
    await store.receive(.planetAdded(.success(true)))
    await store.receive(.loadPlanets)
    await store.receive(.planetsFetched(.success(planets))) {
      $0.star.planets = planets
    }

    star.planets = planets
    await store.receive(.delegate(.planetAdded(star)))
  }

  func testAddingPlanetFails() async throws {
    let star = Star(id: "1", name: "A", planets: [])
    let store = TestStore(initialState: DetailFeature.State(star: star),
                          reducer: DetailFeature())

    struct TestError: Error, Equatable {}

    store.dependencies.client.createPlanet = { _, _ in
      throw TestError()
    }

    await store.send(.addPlanet("test"))
    await store.receive(.planetAdded(.failure(TestError())))
  }
}
