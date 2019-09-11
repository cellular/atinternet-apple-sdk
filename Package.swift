// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "ATInternetTracker",
    platforms: [
        .iOS("8.0"), .tvOS("9.0"), .watchOS("2.0")
    ],
    products: [
        .library(name: "Tracker", targets: ["Tracker"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Tracker",
            dependencies: ["ObjC"],
            path: "ATInternetTracker/Sources/swift"
        //    exclude:["Crash.h", "Crash.m", "Hash.h", "Hash.m" ]
        ),
        .target(
            name: "ObjC",
            dependencies: [],
            path: "ATInternetTracker/Sources/objc"
        ),

        .testTarget(
            name: "TrackerTests",
            dependencies: ["Tracker", "ObjC"],
            path: "ATInternetTracker/Tests"
            // exclude:["Crash.h", "Crash.m", "Hash.h", "Hash.m"]
        )
    ]
)
