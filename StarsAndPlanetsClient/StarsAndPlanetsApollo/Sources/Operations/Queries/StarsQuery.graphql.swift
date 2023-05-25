// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class StarsQuery: GraphQLQuery {
  public static let operationName: String = "Stars"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query Stars {
        stars {
          __typename
          id
          ...StarDetails
        }
      }
      """#,
      fragments: [StarDetails.self, PlanetDetails.self]
    ))

  public init() {}

  public struct Data: StarsAndPlanetsApollo.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { StarsAndPlanetsApollo.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("stars", [Star].self),
    ] }

    public var stars: [Star] { __data["stars"] }

    /// Star
    ///
    /// Parent Type: `Star`
    public struct Star: StarsAndPlanetsApollo.SelectionSet {
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

      /// Star.Planet
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
