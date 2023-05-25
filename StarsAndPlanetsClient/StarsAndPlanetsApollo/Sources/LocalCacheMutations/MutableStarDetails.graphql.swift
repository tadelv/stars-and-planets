// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct MutableStarDetails: StarsAndPlanetsApollo.MutableSelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment MutableStarDetails on Star {
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

  public var __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { StarsAndPlanetsApollo.Objects.Star }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("id", String?.self),
    .field("name", String.self),
    .field("planets", [Planet].self),
  ] }

  public var id: String? {
    get { __data["id"] }
    set { __data["id"] = newValue }
  }
  public var name: String {
    get { __data["name"] }
    set { __data["name"] = newValue }
  }
  public var planets: [Planet] {
    get { __data["planets"] }
    set { __data["planets"] = newValue }
  }

  public init(
    id: String? = nil,
    name: String,
    planets: [Planet]
  ) {
    self.init(_dataDict: DataDict(data: [
      "__typename": StarsAndPlanetsApollo.Objects.Star.typename,
      "id": id,
      "name": name,
      "planets": planets._fieldData,
      "__fulfilled": Set([
        ObjectIdentifier(Self.self)
      ])
    ]))
  }

  /// Planet
  ///
  /// Parent Type: `Planet`
  public struct Planet: StarsAndPlanetsApollo.MutableSelectionSet {
    public var __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { StarsAndPlanetsApollo.Objects.Planet }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", String?.self),
      .fragment(PlanetDetails.self),
    ] }

    public var id: String? {
      get { __data["id"] }
      set { __data["id"] = newValue }
    }
    public var name: String {
      get { __data["name"] }
      set { __data["name"] = newValue }
    }

    public struct Fragments: FragmentContainer {
      public var __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public var planetDetails: PlanetDetails {
        get { _toFragment() }
        _modify { var f = planetDetails; yield &f; __data = f.__data }
        @available(*, unavailable, message: "mutate properties of the fragment instead.")
        set { preconditionFailure() }
      }
    }

    public init(
      id: String? = nil,
      name: String
    ) {
      self.init(_dataDict: DataDict(data: [
        "__typename": StarsAndPlanetsApollo.Objects.Planet.typename,
        "id": id,
        "name": name,
        "__fulfilled": Set([
          ObjectIdentifier(Self.self),
          ObjectIdentifier(PlanetDetails.self)
        ])
      ]))
    }
  }
}
