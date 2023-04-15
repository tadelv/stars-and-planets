// Import the module
import Foundation
import AWSLambdaRuntime
import AWSLambdaEvents
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
      query = body.base64Decoded() ?? ""
    }
    do {
      context.logger.log(level: .info, "trying to decode \(body)")
      if let data = body.data(using: .utf8) {
        context.logger.log(level: .info, "extracting json")
        let queryObject = try JSONDecoder().decode(InputQuery.self, from: data)
        context.logger.log(level: .info, "assigning: \(queryObject.query)")
        query = queryObject.query
      } else {
        context.logger.log(level: .error, "Failed to get data from body")
      }
    } catch {
      context.logger.log(level: .error, "Failed to decode, using raw: \(error)")
    }
    guard query.isEmpty == false else {
      return .init(statusCode: .badRequest)
    }

    context.logger.log(level: .info, "querying with: \(query)")

    let api = StarsAPI.create()

    let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    defer {
      try? group.syncShutdownGracefully()
    }

    do {
      let result = try await api.asyncExecute(
        request: query,
        context: StarsAndPlanetsContext(),
        on: group)
      context.logger.log(level: .info, "\(result)")
      return APIGatewayV2Response(statusCode: .ok, body: result.description)
    } catch {
      context.logger.log(level: .error, "failed: \(error)")
      return .init(statusCode: .internalServerError, body: error.localizedDescription)
    }
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
  let operationName: String
  let query: String
}
