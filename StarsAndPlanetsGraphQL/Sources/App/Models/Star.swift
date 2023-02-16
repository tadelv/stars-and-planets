import Fluent
import Vapor

final class Star: Model {
  static let schema = "stars"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "name")
  var name: String

  @Children(for: \.$star)
  var planets: [Planet]

  init() {}

  init(id: UUID? = nil, name: String) {
    self.id = id
    self.name = name
  }
}

struct CreateStars: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema(Star.schema)
      .id()
      .field("name", .string, .required)
      .create()
  }

  func revert(on database: Database) async throws {
    try await database.schema(Star.schema).delete()
  }
}
