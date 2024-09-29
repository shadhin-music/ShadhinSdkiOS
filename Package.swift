// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ShadhinGpSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13) // Adjust to your minimum supported iOS version
    ],
    products: [
        .library(
            name: "Shadhin_Gp",
            targets: ["Shadhin_Gp"]
        )
    ],
    dependencies: [
        // Add dependencies here if needed
    ],
    targets: [
        .target(
            name: "Shadhin_Gp",
            dependencies: ["ShadhinGPObjec"],
            path: "Sources/Shadhin_Gp",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "ShadhinGPObjec",
            dependencies: [],
            path: "Sources/ShadhinGPObjec",
            publicHeadersPath: "Include"
        ),
    ]
)
