import Fluent
import Vapor

final class Planet: Model {
  static var schema = "planets"

  @ID(key: .id)
  var id: UUID?

  @Parent(key: "star_id")
  var star: Star

  @Field(key: "name")
  var name: String

  init() {}

  init(id: UUID? = nil, name: String, starID: Star.IDValue) {
    self.id = id
    self.name = name
    self.$star.id = starID
  }
}

struct CreatePlanets: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema(Planet.schema)
      .id()
      .field("name", .string, .required)
      .field("star_id", .uuid, .required, .references(Star.schema, "id"))
      .create()

    let sun = Star(name: "Sun")
    try await sun.create(on: database)
    let earth = Planet(name: "Earth", starID: sun.id!)
    try await sun.$planets.create(earth, on: database)
  }

  func revert(on database: Database) async throws {
    try await database.schema(Planet.schema).delete()
  }
}
