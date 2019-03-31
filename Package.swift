// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Nic",
    dependencies: [
		.package(url: "https://github.com/llvm-swift/LLVMSwift.git", from: "0.5.0")
    ],
    targets: [
        .target(
            name: "Nic",
            dependencies: ["LLVM"]),
        .testTarget(
            name: "NicTests",
            dependencies: ["Nic"]),
    ]
)
