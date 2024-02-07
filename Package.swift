// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "WordGrid",
    products: [
        .library(name: "WordGrid", targets: ["WordGrid"]),
        .executable(name: "WordGridRenderer", targets: ["WordGridRenderer"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/fwcd/swift-gif",
            from: "2.0.0"
        ),
        .package(
            url: "https://github.com/fwcd/swift-graphics",
            from: "2.0.0"
        ),
        .package(
            url: "https://github.com/fwcd/swift-utils",
            from: "2.0.0"
        )
    ],
    targets: [
        .target(name: "WordGrid"),
        .target(name: "WordGridRenderer", dependencies: [
            .product(name: "Graphics", package: "swift-graphics"),
            .product(name: "PlatformGraphics", package: "swift-graphics"),
            .product(name: "GIF", package: "swift-gif"),
            .product(name: "Utils", package: "swift-utils"),
            .target(name: "WordGrid")
        ])
    ]
)
