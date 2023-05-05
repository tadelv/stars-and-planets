// Import the module
import Foundation
import AWSLambdaRuntime
import AWSLambdaEvents
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
    context.logger.info("received: \(body)")

    guard let bodyData = body.data(using: .utf8) else {
      context.logger.error("failed to get data from body")
      return .init(statusCode: .internalServerError)
    }

    let query: InputQuery
    do {
      query = try JSONDecoder().decode(InputQuery.self, from: bodyData)
    } catch {
      return .init(statusCode: .badRequest, body: "\(error)")
    }

    context.logger.info("querying with: \(query)")

    let api = StarsAPI.create()

//    let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
//    defer {
//      try? group.syncShutdownGracefully()
//    }

    let apiContext = try await StarsAndPlanetsContext()

    let result = try await api.asyncExecute(
      request: query.query,
      context: apiContext,
      on: context.eventLoop,
      variables: query.variables)
    context.logger.info("returning: \(result)")
    if result.errors.isEmpty == false {
      return APIGatewayV2Response(statusCode: .badRequest, body: result.description)
    }
    return APIGatewayV2Response(statusCode: .ok, body: result.description)
  }
}

// https://stackoverflow.com/a/46969102
extension String {
  func base64Decoded() -> String? {
    guard let data = Data(base64Encoded: self) else { return nil }
    return String(data: data, encoding: .utf8)
  }
}

struct InputQuery: Codable {
  let operationName: String?
  let query: String
  let variables: [String: Map]?
}
