// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct StarDetails: StarsAndPlanetsApollo.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment StarDetails on Star {
      __typename
      id
      name
      planets {
        __typename
        id
        ...PlanetDetails
      }
    }
    """ }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { StarsAndPlanetsApollo.Objects.Star }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", String?.self),
    .field("name", String.self),
    .field("planets", [Planet].self),
  ] }

  public var id: String? { __data["id"] }
  public var name: String { __data["name"] }
  public var planets: [Planet] { __data["planets"] }

  /// Planet
  ///
  /// Parent Type: `Planet`
  public struct Planet: StarsAndPlanetsApollo.SelectionSet {
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
