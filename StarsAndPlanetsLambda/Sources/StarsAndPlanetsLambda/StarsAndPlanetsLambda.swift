// Import the module
import Foundation
import AWSLambdaRuntime
import AWSLambdaEvents
import Graphiti
import GraphQL
import NIO

@main
struct StarsAndPlanetsLambda: SimpleLambdaHandler {
  func handle(
    _ request: APIGatewayV2Request,
    context: LambdaContext
  ) async throws -> APIGatewayV2Response {

    guard let body = request.body else {
      return .init(statusCode: .badRequest)
    }
    context.logger.log(level: .info, "received: \(body)")
    var query = body
    if request.isBase64Encoded {
      query = String.fromBase64(body) ?? ""
    }
    guard query.isEmpty == false else {
      return .init(statusCode: .badRequest)
    }

    context.logger.log(level: .info, "querying with: \(query)")

    let api = MessageAPI(
      resolver: Resolver(),
      schema: try! Schema<Resolver, Context> {
        Type(Message.self) {
          Field("content", at: \.content)
        }

        Query {
          Field("message", at: Resolver.message)
        }
      }
    )

    let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    defer {
      try? group.syncShutdownGracefully()
    }

    let result = try! await api.asyncExecute(
      request: query,
      context: Context(),
      on: group)
    context.logger.log(level: .info, "\(result)")

    return APIGatewayV2Response(statusCode: .ok, body: result.description)
  }
}

struct Message : Codable {
  let content: String
}

struct Context {
  func message() -> Message {
    Message(content: "Hello, world!")
  }
}

struct Resolver {
  func message(context: Context, arguments: NoArguments) -> Message {
    context.message()
  }
}

struct MessageAPI : API {
  let resolver: Resolver
  let schema: Schema<Resolver, Context>
}

extension API {
  func asyncExecute(request: String,
                    context: ContextType,
                    on group: EventLoopGroup) async throws -> GraphQLResult {
    try await withCheckedThrowingContinuation { continuation in
      do {
        let result = try self
          .execute(request: request,
                   context: context,
                   on: group)
          .wait()
        continuation.resume(returning: result)
      } catch {
        continuation.resume(throwing: error)
      }
    }
  }
}

extension Data {
  /// Same as ``Data(base64Encoded:)``, but adds padding automatically
  /// (if missing, instead of returning `nil`).
  public static func fromBase64(_ encoded: String) -> Data? {
    // Prefixes padding-character(s) (if needed).
    var encoded = encoded;
    let remainder = encoded.count % 4
    if remainder > 0 {
      encoded = encoded.padding(
        toLength: encoded.count + 4 - remainder,
        withPad: "=", startingAt: 0);
    }

    // Finally, decode.
    return Data(base64Encoded: encoded);
  }
}

extension String {
  public static func fromBase64(_ encoded: String) -> String? {
    if let data = Data.fromBase64(encoded) {
      return String(data: data, encoding: .utf8)
    }
    return nil;
  }
}
