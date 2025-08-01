// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdelsonAuthManager",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AdelsonAuthManager",
            targets: ["AdelsonAuthManager"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.2")),
        .package(url: "https://github.com/Ahmed23Adel/AdelsonValidator", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AdelsonAuthManager",
            dependencies: ["Alamofire","AdelsonValidator"]
        ),
        .testTarget(
            name: "AdelsonAuthManagerTests",
            dependencies: ["AdelsonAuthManager"]
        ),
    ]
)
