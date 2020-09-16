// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.
/************************************************************************//**
*     PROJECT: SwiftDBC
*    FILENAME: DataTypes.swift
*         IDE: AppCode
*      AUTHOR: Galen Rhodes
*        DATE: 8/25/20
*
* Copyright © 2020 Project Galen. All rights reserved.
*
* Permission to use, copy, modify, and distribute this software for any
* purpose with or without fee is hereby granted, provided that the above
* copyright notice and this permission notice appear in all copies.
*
* THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
* WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
* MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
* ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
* WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
* ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
* OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*//************************************************************************/

import PackageDescription

#if swift(>=5.2) && !os(Linux)
    let pkgConfig: String? = nil
#else
    let pkgConfig = "mysqlclient"
#endif

let package = Package(
    name: "SwiftDBC",
    platforms: [ .macOS(.v10_15), .tvOS(.v13), ],
    products: [
        .library(name: "SwiftDBC", targets: [ "SwiftDBC" ]),
        .executable(name: "DocFixer", targets: [ "DocFixer" ]),
    ],
    dependencies: [
        .package(name: "PGDocFixer", url: "https://github.com/GalenRhodes/PGDocFixer.git", from: "1.0.1"),
        .package(name: "Rubicon",    url: "https://github.com/GalenRhodes/Rubicon.git",    from: "0.2.0"),
        .package(name: "BigInt",     url: "https://github.com/attaswift/BigInt.git",       from: "5.2.0"),
    ],
    targets: [
        .target(name: "SwiftDBC",
        		dependencies: [ "Rubicon", "BigInt", "MySQL" ],
        		linkerSettings: [.unsafeFlags(["-L/usr/local/mysql/lib"], .when(platforms: [.macOS,.tvOS]))]
        		),
        .target(name: "DocFixer", dependencies: [ "PGDocFixer" ]),
        .testTarget(name: "SwiftDBCTests", dependencies: [ "SwiftDBC" ]),
        .systemLibrary(name: "MySQL", path: "Modules", pkgConfig: pkgConfig, providers: [ .apt(["libmysqlclient-dev"]), ]),
    ],
    swiftLanguageVersions: [ .version("5.2") ]
)
