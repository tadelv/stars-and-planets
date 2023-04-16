// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "StarsAndPlanetsLambda",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "StarsAndPlanetsLambda", targets: ["StarsAndPlanetsLambda"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", from: "1.0.0-alpha"),
        .package(url: "https://github.com/swift-server/swift-aws-lambda-events.git", branch: "main"),
        .package(url: "https://github.com/GraphQLSwift/Graphiti.git", from: "0.24.0"),
        .package(url: "https://github.com/awslabs/aws-sdk-swift", exact: "0.10.0"),
    ],
    targets: [
        .executableTarget(name: "StarsAndPlanetsLambda", dependencies: [
          .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
          .product(name: "AWSLambdaEvents", package: "swift-aws-lambda-events"),
          .product(name: "Graphiti", package: "Graphiti"),
          .product(name: "AWSDynamoDB", package: "aws-sdk-swift")
        ]),
    ]
)

