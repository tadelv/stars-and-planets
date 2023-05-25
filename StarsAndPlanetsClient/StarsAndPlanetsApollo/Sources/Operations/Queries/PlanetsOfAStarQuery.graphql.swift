// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class PlanetsOfAStarQuery: GraphQLQuery {
  public static let operationName: String = "PlanetsOfAStar"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query PlanetsOfAStar($starID: String!) {
        starsPlanets(starID: $starID) {
          __typename
          id
          ...PlanetDetails
        }
      }
      """#,
      fragments: [PlanetDetails.self]
    ))

  public var starID: String

  public init(starID: String) {
    self.starID = starID
  }

  public var __variables: Variables? { ["starID": starID] }

  public struct Data: StarsAndPlanetsApollo.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

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
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { StarsAndPlanetsApollo.Objects.Planet }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", String?.self),
        .fragment(PlanetDetails.self),
      ] }

      public var id: String? { __data["id"] }
      public var name: String { __data["name"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var planetDetails: PlanetDetails { _toFragment() }
      }
    }
  }
}
