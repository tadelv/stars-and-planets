import Vapor
import GraphQLKit

let starsSchema = try! Schema<StarsController, Request> {
  Scalar(UUID.self)

  Type(Star.self) {
    Field("id", at: \.id)
    Field("name", at: \.name)
    Field("planets", with: \.$planets)
  }

  Type(Planet.self) {
    Field("id", at: \.id)
    Field("name", at: \.name)
    Field("star", with: \.$star)
  }

  Query {
    Field("stars", at: StarsController.fetchStars)
    Field("planets", at: StarsController.fetchPlanets)
  }

  Mutation {
    Field("createStar", at: StarsController.createStar) {
      Argument("name", at: \.name)
    }

    Field("deleteStar", at: StarsController.deleteStar) {
      Argument("id", at: \.id)
    }

    Field("createPlanet", at: StarsController.createPlanet) {
      Argument("name", at: \.name)
      Argument("starID", at: \.starID)
    }

    Field("deletePlanet", at: StarsController.deletePlanet) {
      Argument("id", at: \.id)
    }
  }
}
