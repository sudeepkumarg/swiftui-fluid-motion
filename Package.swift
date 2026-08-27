// swift-tools-version: 6.0
import PackageDescription

// This package exists so CI can prove the example compiles. It is not something
// you add to your project. Copy references/motion-tokens.swift into your app
// instead, as the README describes.

let package = Package(
    name: "SwiftUIFluidMotion",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "FluidMotionExample", targets: ["FluidMotionExample"])
    ],
    targets: [
        .target(
            name: "FluidMotionExample",
            path: ".",
            sources: [
                "references/motion-tokens.swift",
                "example/Support.swift",
                "example/with-skill.swift"
            ]
        )
    ]
)
