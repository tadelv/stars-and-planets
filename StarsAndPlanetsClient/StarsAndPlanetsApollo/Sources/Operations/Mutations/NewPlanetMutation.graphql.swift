// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class NewPlanetMutation: GraphQLMutation {
  public static let operationName: String = "NewPlanet"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      mutation NewPlanet($name: String!, $starID: String!) {
        createPlanet(name: $name, starID: $starID) {
          __typename
          id
          ...PlanetDetails
        }
      }
      """#,
      fragments: [PlanetDetails.self]
    ))

  public var name: String
  public var starID: String

  public init(
    name: String,
    starID: String
  ) {
    self.name = name
    self.starID = starID
  }

  public var __variables: Variables? { [
    "name": name,
    "starID": starID
  ] }

  public struct Data: StarsAndPlanetsApollo.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { StarsAndPlanetsApollo.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createPlanet", CreatePlanet.self, arguments: [
        "name": .variable("name"),
        "starID": .variable("starID")
      ]),
    ] }

    public var createPlanet: CreatePlanet { __data["createPlanet"] }

    /// CreatePlanet
    ///
    /// Parent Type: `Planet`
    public struct CreatePlanet: StarsAndPlanetsApollo.SelectionSet {
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
