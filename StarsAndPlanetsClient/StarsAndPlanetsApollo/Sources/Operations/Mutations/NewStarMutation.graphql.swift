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
          ...StarDetails
        }
      }
      """#,
      fragments: [StarDetails.self, PlanetDetails.self]
    ))

  public var name: String

  public init(name: String) {
    self.name = name
  }

  public var __variables: Variables? { ["name": name] }

  public struct Data: StarsAndPlanetsApollo.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

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
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { StarsAndPlanetsApollo.Objects.Star }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", String?.self),
        .fragment(StarDetails.self),
      ] }

      public var id: String? { __data["id"] }
      public var name: String { __data["name"] }
      public var planets: [Planet] { __data["planets"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var starDetails: StarDetails { _toFragment() }
      }

      /// CreateStar.Planet
      ///
      /// Parent Type: `Planet`
      public struct Planet: StarsAndPlanetsApollo.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { StarsAndPlanetsApollo.Objects.Planet }

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
}
