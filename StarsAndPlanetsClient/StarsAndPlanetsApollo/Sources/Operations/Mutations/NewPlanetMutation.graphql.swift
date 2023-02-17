// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class NewPlanetMutation: GraphQLMutation {
  public static let operationName: String = "NewPlanet"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      mutation NewPlanet($name: String!, $starID: UUID!) {
        createPlanet(name: $name, starID: $starID) {
          __typename
          id
        }
      }
      """#
    ))

  public var name: String
  public var starID: UUID

  public init(
    name: String,
    starID: UUID
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
    public init(data: DataDict) { __data = data }

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
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { StarsAndPlanetsApollo.Objects.Planet }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("id", StarsAndPlanetsApollo.UUID?.self),
      ] }

      public var id: StarsAndPlanetsApollo.UUID? { __data["id"] }
    }
  }
}
