// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "DataSource",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13)
    ],
    products: [
        .library(name: "DataSource", targets: ["DataSource"])
    ],
    targets: [
        .target(name: "DataSource", dependencies: [], path: "DataSource"),
    ],
    swiftLanguageVersions: [
        .version("5.1")
    ]
)