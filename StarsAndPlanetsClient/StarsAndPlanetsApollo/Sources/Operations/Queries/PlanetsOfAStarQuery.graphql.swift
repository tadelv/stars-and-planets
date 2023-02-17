// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class PlanetsOfAStarQuery: GraphQLQuery {
  public static let operationName: String = "PlanetsOfAStar"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query PlanetsOfAStar($starID: UUID!) {
        starsPlanets(starID: $starID) {
          __typename
          id
          name
        }
      }
      """#
    ))

  public var starID: UUID

  public init(starID: UUID) {
    self.starID = starID
  }

  public var __variables: Variables? { ["starID": starID] }

  public struct Data: StarsAndPlanetsApollo.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { StarsAndPlanetsApollo.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("starsPlanets", [StarsPlanet].self, arguments: ["starID": .variable("starID")]),
    ] }

    public var starsPlanets: [StarsPlanet] { __data["starsPlanets"] }

    /// StarsPlanet
    ///
    /// Parent Type: `Planet`
    public struct StarsPlanet: StarsAndPlanetsApollo.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { StarsAndPlanetsApollo.Objects.Planet }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("id", StarsAndPlanetsApollo.UUID?.self),
        .field("name", String.self),
      ] }

      public var id: StarsAndPlanetsApollo.UUID? { __data["id"] }
      public var name: String { __data["name"] }
    }
  }
}
