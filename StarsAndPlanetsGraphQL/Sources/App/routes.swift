import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

  app.get("stars") { req in
    let stars = try await Star.query(on: req.db).with(\.$planets).all()

    return stars.map {
      return Reply(starName: $0.name,
                   planets: $0.planets.map { $0.name } )
    }
  }
}

struct Reply: Content {
  let starName: String
  let planets: [String]
}
