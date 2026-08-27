// swift-tools-version: 5.10
import PackageDescription

// This package exists so CI can prove the example compiles. It is not something
// you add to your project. Copy references/motion-tokens.swift into your app
// instead, as the README describes.
//
// Tools version is 5.10 rather than 6.0 deliberately. Swift 6 language mode
// turns on strict concurrency checking, which would make this package fail on
// Sendable rules that have nothing to do with whether the motion code is
// correct. The point here is to compile the SwiftUI, not to audit concurrency.

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
            exclude: [
                "README.md",
                "SKILL.md",
                "CHANGELOG.md",
                "LICENSE",
                "for-gpt",
                "swiftui-fluid-motion.skill",
                "references/patterns.md",
                "references/antipatterns.md",
                "example/baseline.swift"
            ],
            sources: [
                "references/motion-tokens.swift",
                "example/Support.swift",
                "example/with-skill.swift"
            ]
        )
    ]
)
