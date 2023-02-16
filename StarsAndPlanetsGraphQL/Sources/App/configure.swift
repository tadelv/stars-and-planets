import Fluent
import FluentSQLiteDriver
import GraphiQLVapor
import GraphQLKit
import Graphiti
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
  app.databases.use(.sqlite(.memory), as: .sqlite)


  app.migrations.add(CreateStars())
  app.migrations.add(CreatePlanets())
  try await app.autoMigrate()

    // register routes
  try routes(app)
  app.register(graphQLSchema: starsSchema, withResolver: StarsController())

  app.enableGraphiQL(on: "explore")
}
