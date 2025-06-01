// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "potatodo",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "potatodo",
            targets: ["potatodo"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0")
    ],
    targets: [
        .target(
            name: "potatodo",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk")
            ]),
    ]
) 