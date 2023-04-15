// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class NewStarMutation: GraphQLMutation {
  public static let operationName: String = "NewStar"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      mutation NewStar($name: String!) {
        createStar(name: $name) {
          __typename
          id
        }
      }
      """#
    ))

  public var name: String

  public init(name: String) {
    self.name = name
  }

  public var __variables: Variables? { ["name": name] }

  public struct Data: StarsAndPlanetsApollo.SelectionSet {
    public let __data: DataDict
    public init(_dataDict data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { StarsAndPlanetsApollo.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createStar", CreateStar.self, arguments: ["name": .variable("name")]),
    ] }

    public var createStar: CreateStar { __data["createStar"] }

    /// CreateStar
    ///
    /// Parent Type: `Star`
    public struct CreateStar: StarsAndPlanetsApollo.SelectionSet {
      public let __data: DataDict
      public init(_dataDict data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { StarsAndPlanetsApollo.Objects.Star }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("id", StarsAndPlanetsApollo.UUID?.self),
      ] }

      public var id: StarsAndPlanetsApollo.UUID? { __data["id"] }
    }
  }
}
