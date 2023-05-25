// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class NewStarLocalCacheMutation: LocalCacheMutation {
  public static let operationType: GraphQLOperationType = .mutation

  public var name: String

  public init(name: String) {
    self.name = name
  }

  public var __variables: GraphQLOperation.Variables? { ["name": name] }

  public struct Data: StarsAndPlanetsApollo.MutableSelectionSet {
    public var __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { StarsAndPlanetsApollo.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createStar", CreateStar.self, arguments: ["name": .variable("name")]),
    ] }

    public var createStar: CreateStar {
      get { __data["createStar"] }
      set { __data["createStar"] = newValue }
    }

    public init(
      createStar: CreateStar
    ) {
      self.init(_dataDict: DataDict(data: [
        "__typename": StarsAndPlanetsApollo.Objects.Mutation.typename,
        "createStar": createStar._fieldData,
        "__fulfilled": Set([
          ObjectIdentifier(Self.self)
        ])
      ]))
    }

    /// CreateStar
    ///
    /// Parent Type: `Star`
    public struct CreateStar: StarsAndPlanetsApollo.MutableSelectionSet {
      public var __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { StarsAndPlanetsApollo.Objects.Star }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", String?.self),
        .fragment(MutableStarDetails.self),
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

      public struct Fragments: FragmentContainer {
        public var __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var mutableStarDetails: MutableStarDetails {
          get { _toFragment() }
          _modify { var f = mutableStarDetails; yield &f; __data = f.__data }
          @available(*, unavailable, message: "mutate properties of the fragment instead.")
          set { preconditionFailure() }
        }
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
            ObjectIdentifier(Self.self),
            ObjectIdentifier(MutableStarDetails.self)
          ])
        ]))
      }

      /// CreateStar.Planet
      ///
      /// Parent Type: `Planet`
      public struct Planet: StarsAndPlanetsApollo.MutableSelectionSet {
        public var __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { StarsAndPlanetsApollo.Objects.Planet }

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
  }
}
