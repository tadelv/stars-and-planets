// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct PlanetDetails: StarsAndPlanetsApollo.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment PlanetDetails on Planet {
      __typename
      id
      name
    }
    """ }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { StarsAndPlanetsApollo.Objects.Planet }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", String?.self),
    .field("name", String.self),
  ] }

  public var id: String? { __data["id"] }
  public var name: String { __data["name"] }
}
