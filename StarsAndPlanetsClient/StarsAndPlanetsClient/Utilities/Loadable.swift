// https://gist.github.com/ibrahimkteish/9c3d87a61e74b63b17c67e5edbb940c1
// Loadable.swift

import ComposableArchitecture
import SwiftUI

public enum Loadable<T> {
  case idle
  case loading
  case success(T)
  case failed(Error)
}

public extension Loadable {
  var isLoading: Bool {
    switch self {
    case .loading:
      return true
    default:
      return false
    }
  }

  var hasInitialized: Bool {
    switch self {
    case .idle:
      return false
    default:
      return true
    }
  }

  var finished: Bool {
    switch self {
    case .failed, .success:
      return true
    default:
      return false
    }
  }

  var successful: Bool {
    switch self {
    case .success:
      return true
    default:
      return false
    }
  }

  var failed: Bool {
    switch self {
    case .failed:
      return true
    default:
      return false
    }
  }

  var value: T? {
    if case let .success(value) = self {
      return value
    }
    return nil
  }

  func map<N>(_ mapped: @escaping (T) -> N) -> Loadable<N> {
    switch self {
    case .idle:
      return .idle
    case .loading:
      return .loading
    case let .success(item):
      return .success(mapped(item))
    case let .failed(error):
      return .failed(error)
    }
  }
}

func equals(_ lhs: Any, _ rhs: Any) -> Bool {
  func open<A: Equatable>(
    _ lhs: A,
    _ rhs: Any
  ) -> Bool {
    lhs == (rhs as? A)
  }

  guard
    let lhs = lhs as? any Equatable,
    let rhs = rhs as? any Equatable
  else {
    fatalError(
      "trying to compare \(type(of: lhs.self)) with \(type(of: rhs.self)) which is not equatable"
    )
  }

  return open(lhs, rhs)
}

extension Loadable: Equatable where T: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case let (.success(lhs), .success(rhs)):
      return lhs == rhs
    case let (.failed(lhs), .failed(rhs)):
      return equals(lhs, rhs)
    case (.idle, .idle), (.loading, .loading):
      return true
    default:
      return false
    }
  }
}

public extension Loadable {
  init(capture body: @Sendable () async throws -> T) async {
    do {
      self = .success(try await body())
    } catch {
      self = .failed(error)
    }
  }
}


//  LoadableView.swift


//func equals(_ lhs: Any, _ rhs: Any) -> Bool {
//  func open<A: Equatable>(
//    _ lhs: A,
//    _ rhs: Any
//  ) -> Bool {
//    lhs == (rhs as? A)
//  }
//
//  guard
//    let lhs = lhs as? any Equatable,
//    let rhs = rhs as? any Equatable
//  else {
//    fatalError(
//      "trying to compare \(type(of: lhs.self)) to \(type(of: rhs.self)) which is not equatable"
//    )
//  }
//
//  return open(lhs, rhs)
//}

public struct LoadableView<T, Loaded: View, Failed: View, Loading: View, Idle: View>: View {
  let loadable: Loadable<T>
  let loadedView: (T) -> Loaded
  let failedView: () -> Failed
  let loadingView: () -> Loading
  let idleView: () -> Idle

  var asGroup = false

  public init(
    loadable: Loadable<T>,
    @ViewBuilder loadedView: @escaping (T) -> Loaded,
    @ViewBuilder failedView: @escaping () -> Failed,
    @ViewBuilder loadingView: @escaping () -> Loading,
    @ViewBuilder idleView: @escaping () -> Idle
  ) {
    self.loadable = loadable
    self.loadedView = loadedView
    self.failedView = failedView
    self.loadingView = loadingView
    self.idleView = idleView
  }

  public var body: some View {
    if asGroup {
      Group {
        buildViews()
      }
    } else {
      buildViews()
    }
  }

  @ViewBuilder
  private func buildViews() -> some View {
    switch self.loadable {
    case .idle:
      self.idleView()
    case .loading:
      self.loadingView()
    case let .success(value):
      self.loadedView(value)
    case .failed:
      self.failedView()
    }
  }
}

public extension LoadableView {
  func asGroup(_ group: Bool) -> Self {
    var view = self
    view.asGroup = group
    return view
  }
}

public extension LoadableView where Loading == EmptyView, Failed == EmptyView, Idle == EmptyView {
  init(
    loadable: Loadable<T>,
    @ViewBuilder loadedView: @escaping (T) -> Loaded
  ) {
    self.init(
      loadable: loadable,
      loadedView: loadedView,
      failedView: { EmptyView() },
      loadingView: { EmptyView() },
      idleView: { EmptyView() }
    )
  }
}

public extension LoadableView where Loading == Idle {
  init(
    loadable: Loadable<T>,
    @ViewBuilder loadedView: @escaping (T) -> Loaded,
    @ViewBuilder failedView: @escaping () -> Failed,
    @ViewBuilder waitingView: @escaping () -> Idle
  ) {
    self.init(
      loadable: loadable,
      loadedView: loadedView,
      failedView: failedView,
      loadingView: waitingView,
      idleView: waitingView
    )
  }
}

public struct LoadableStore<T: Equatable, Action, Loaded: View, Failed: View, Loading: View, Idle: View>: View {
  let store: Store<Loadable<T>, Action>
  let loadedView: (Store<T, Action>) -> Loaded
  let failedView: (Store<Error, Action>) -> Failed
  let loadingView: (Store<Void, Action>) -> Loading
  let idleView: (Store<Void, Action>) -> Idle

  public init(
    store: Store<Loadable<T>, Action>,
    @ViewBuilder loadedView: @escaping (Store<T, Action>) -> Loaded,
    @ViewBuilder failedView: @escaping (Store<Error, Action>) -> Failed,
    @ViewBuilder loadingView: @escaping (Store<Void, Action>) -> Loading,
    @ViewBuilder idleView: @escaping (Store<Void, Action>) -> Idle
  ) {
    self.store = store
    self.loadedView = loadedView
    self.failedView = failedView
    self.loadingView = loadingView
    self.idleView = idleView
  }

  public var body: some View {
    SwitchStore(self.store) {
      CaseLet(state: /Loadable<T>.success, then: loadedView)
      CaseLet(state: /Loadable<T>.failed, then: failedView)
      CaseLet(state: /Loadable<T>.loading, then: loadingView)
      CaseLet(state: /Loadable<T>.idle, then: idleView)
    }
  }
}

public extension LoadableStore where Loading == EmptyView, Failed == EmptyView, Idle == EmptyView {
  init(
    store: Store<Loadable<T>, Action>,
    @ViewBuilder loadedView: @escaping (Store<T, Action>) -> Loaded
  ) {
    self.store = store
    self.loadedView = loadedView
    self.failedView = { _ in EmptyView() }
    self.loadingView = { _ in EmptyView() }
    self.idleView = { _ in EmptyView() }
  }
}

public extension LoadableStore where Loading == Idle {
  init(
    store: Store<Loadable<T>, Action>,
    @ViewBuilder loadedView: @escaping (Store<T, Action>) -> Loaded,
    @ViewBuilder failedView: @escaping (Store<Error, Action>) -> Failed,
    @ViewBuilder waitingView: @escaping (Store<Void, Action>) -> Idle
  ) {
    self.store = store
    self.loadedView = loadedView
    self.failedView = failedView
    self.loadingView = waitingView
    self.idleView = waitingView
  }
}

public struct LoadableViewStore<T: Equatable, Action, Loaded: View, Failed: View, Loading: View, Idle: View>: View {
  let store: Store<Loadable<T>, Action>
  let loadedView: (ViewStore<T, Action>) -> Loaded
  let failedView: (ViewStore<Error, Action>) -> Failed
  let loadingView: (ViewStore<Void, Action>) -> Loading
  let idleView: (ViewStore<Void, Action>) -> Idle

  public var body: some View {
    LoadableStore(
      store: store
    ) { store in
      WithViewStore(
        store,
        observe: { $0 },
        content: loadedView
      )
    } failedView: { store in
      WithViewStore(
        store,
        observe: { $0 },
        removeDuplicates: equals,
        content: failedView
      )
    } loadingView: { store in
      WithViewStore(
        store,
        observe: { $0 },
        removeDuplicates: { _, _ in false },
        content: loadingView
      )
    } idleView: { store in
      WithViewStore(
        store,
        observe: { $0 },
        removeDuplicates: { _, _ in false },
        content: idleView
      )
    }
  }
}

public extension LoadableViewStore where Loading == EmptyView, Failed == EmptyView, Idle == EmptyView {
  init(
    loadable: Store<Loadable<T>, Action>,
    @ViewBuilder loadedView: @escaping (ViewStore<T, Action>) -> Loaded
  ) {
    self.init(
      store: loadable,
      loadedView: loadedView,
      failedView: { _ in EmptyView() },
      loadingView: { _ in EmptyView() },
      idleView: { _ in EmptyView() }
    )
  }
}

public extension LoadableViewStore where Loading == Idle {
  init(
    loadable: Store<Loadable<T>, Action>,
    @ViewBuilder loadedView: @escaping (ViewStore<T, Action>) -> Loaded,
    @ViewBuilder failedView: @escaping (ViewStore<Error, Action>) -> Failed,
    @ViewBuilder waitingView: @escaping (ViewStore<Void, Action>) -> Idle
  ) {
    self.init(
      store: loadable,
      loadedView: loadedView,
      failedView: failedView,
      loadingView: waitingView,
      idleView: waitingView
    )
  }
}

// Reducer
//
//public struct ScoresReducer: ReducerProtocol {
//
//  // MARK: - State
//
//  public struct State: Equatable {
//    var scores: Loadable<ScoresEntity> = .idle
//
//    public init() { }
//  }
//
//  // MARK: - Action
//
//  public enum Action: Equatable {
//    case onAppear
//    case onScoresResponse(TaskResult<Scores>)
//  }
//
//  // MARK: - Dependencies
//  @Dependency(\.mainQueue) var mainQueue
//
//  public init() {}
//
//  // MARK: - Body
//
//  public var body: some ReducerProtocol<State, Action> {
//    self.core
//  }
//
//  private var core: some ReducerProtocol<State, Action> {
//    Reduce { state, action in
//      switch action {
//      case .onAppear:
//        state.scores = .loading
//        return .run { send in
//          await send(
//            .onScoresResponse(
//              await TaskResult {
//                try await // get scores from backend
//              }
//            ),
//            animation: .spring(response: 0.3, dampingFraction: 0.3, blendDuration: 0.2)
//          )
//        }
//      case let .onScoresResponse(.success(scores)):
//        state.scores = .success(.fromScore(scores, using: formatter))
//        return .none
//      case let .onScoresResponse(.failure(error)):
//        state.scores = .failed(error)
//        return .none
//      }
//    }
//  }
//}

// Usage in view

//LoadableViewStore(
//  loadable: self.store.scope(state: \.scores), //  scores: Loadable<ScoresEntity>
//  loadedView: { viewStore in
//    LoadedView()
//  },
//  failedView: { viewStore in
//    FailedView()
//  },
//  waitingView: { _ in  WaitingView()
//  }
