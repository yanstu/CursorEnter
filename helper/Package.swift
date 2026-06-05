// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "cursor-enter-helper",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "cursor_enter_helper",
            targets: ["cursor_enter_helper"]
        ),
        .executable(
            name: "cursor-enter-helper",
            targets: ["cursor-enter-helper-bin"]
        ),
        .executable(
            name: "CursorEnter",
            targets: ["CursorEnterApp"]
        )
    ],
    targets: [
        .target(
            name: "CAXShim",
            publicHeadersPath: "include"
        ),
        .target(
            name: "cursor_enter_helper",
            dependencies: ["CAXShim"]
        ),
        .executableTarget(
            name: "cursor-enter-helper-bin",
            dependencies: ["cursor_enter_helper"]
        ),
        .executableTarget(
            name: "CursorEnterApp",
            dependencies: ["cursor_enter_helper"]
        ),
        .testTarget(
            name: "CursorEnterHelperTests",
            dependencies: ["cursor_enter_helper"]
        )
    ]
)
