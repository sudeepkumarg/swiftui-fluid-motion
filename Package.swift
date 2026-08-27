// swift-tools-version: 6.0
import PackageDescription

// This package exists so CI can prove the example compiles. It is not something
// you add to your project. Copy references/motion-tokens.swift into your app
// instead, as the README describes.
//
// Package, product and target deliberately share one name. xcodebuild derives
// scheme names from a package and the mapping is not obvious, so making all
// three identical means any scheme it generates resolves to the same string.
//
// Tools version must be 6.0: `.iOS(.v18)` does not exist before
// PackageDescription 6.0. The language mode is pinned to v5 so Swift 6 strict
// concurrency does not fail the build on Sendable rules unrelated to whether
// the motion code is correct.

let package = Package(
    name: "FluidMotionExample",
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
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)
