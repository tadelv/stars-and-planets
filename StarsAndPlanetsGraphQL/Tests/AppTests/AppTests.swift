@testable import App
import XCTVapor

final class AppTests: XCTestCase {
  var app: Application!

  override func setUp() async throws {
    app = Application(.testing)
    try await configure(app)
  }

  override func tearDown() async throws {
    app.shutdown()
  }

  func testStarsAndPlanets() async throws {
    try app.test(.GET, "stars") { res in
      XCTAssertEqual(res.status, .ok)
      let data = try res.content.decode([Reply].self)
      XCTAssertEqual(data[0].starName, "Sun")
      XCTAssertEqual(data[0].planets[0], "Earth")
    }
  }
}
