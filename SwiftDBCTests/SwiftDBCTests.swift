//
//  SwiftDBCTests.swift
//  SwiftDBCTests
//
//  Created by Galen Rhodes on 8/25/20.
//  Copyright © 2020 Project Galen. All rights reserved.
//

import XCTest
@testable import SwiftDBC

class SwiftDBCTests: XCTestCase {

    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}

    private func printRegexResults(_ s: String, _ x: [NSTextCheckingResult]) {
        for tcr: NSTextCheckingResult in x {
            print("> \"\(s)\": \(tcr.range.location), \(tcr.range.length)")
        }
    }

    private func printRegexResults2(_ s: String, _ x: [NSTextCheckingResult]) {
        for tcr: NSTextCheckingResult in x {
            print("> \"\(s)\": \(tcr.range.location), \(tcr.range.length)")

            for i in (1 ..< tcr.numberOfRanges) {
                let r = tcr.range(at: i)

                if r.location == NSNotFound {
                    print("        Range \(i): EMPTY")
                }
                else {
                    print("        Range \(i): \"\(s.substringWith(nsRange: r) ?? "")\"")
                }
            }
        }
    }

    func testIpNumber() throws {
        let regex: NSRegularExpression = try NSRegularExpression(pattern: "^(?:\(_regexIpNumber))$")
        for i: Int in (0 ... 256) {
            let s: String                 = "\(i)"
            let x: [NSTextCheckingResult] = regex.matches(in: s)

            if x.count > 0 {
                //printRegexResults(s, x)
            }
            else {
                print("> \"\(s)\": NO MATCH!")
                break
            }
        }
    }

    func testCredentialsRegex() throws {
        let regex: NSRegularExpression = try NSRegularExpression(pattern: "^(?:\(_regexCredentials))$")
        let strs:  [String]            = [ "galen:rhodes@", "galen@", "galen:@", ":rhodes@", "galen:rhodes", "galen", "@" ]

        for s: String in strs {
            let x: [NSTextCheckingResult] = regex.matches(in: s)

            if x.count > 0 {
                printRegexResults(s, x)
            }
            else {
                print("> \"\(s)\": NO MATCH!")
            }
        }
    }

    func testDBUrlRegex() throws {
        let regex: NSRegularExpression = try NSRegularExpression(pattern: "^(?:\(_regexUrl))$")
        let strs:  [String]            = [
            "swiftdbq:mysql://galen:rhodes@projectgalen.com:2112/testdb?iam=great",
            "swiftdbc:xysql://galen:rhodes@projectgalen.com:2112/testdb?iam=great",
//-----------------------------------------------------------------------------------------------
            "swiftdbc:mysql://galen:rhodes@projectgalen.com:2112/testdb?iam=great",
            "swiftdbc:mysql://galen@projectgalen.com:2112/testdb?iam=great",
            "swiftdbc:mysql://projectgalen.com:2112/testdb?iam=great",
//-----------------------------------------------------------------------------------------------
            "swiftdbc:mysql:galen:rhodes@projectgalen.com:2112/testdb?iam=great",
            "swiftdbc:mysql:galen@projectgalen.com:2112/testdb?iam=great",
            "swiftdbc:mysql:projectgalen.com:2112/testdb?iam=great",
//-----------------------------------------------------------------------------------------------
            "swiftdbc:mysql://galen:rhodes@projectgalen.com/testdb?iam=great",
            "swiftdbc:mysql://galen@projectgalen.com/testdb?iam=great",
            "swiftdbc:mysql://projectgalen.com/testdb?iam=great",

            "swiftdbc:mysql:galen:rhodes@projectgalen.com/testdb?iam=great",
            "swiftdbc:mysql:galen@projectgalen.com/testdb?iam=great",
            "swiftdbc:mysql:projectgalen.com/testdb?iam=great",
//-----------------------------------------------------------------------------------------------
            "swiftdbc:mysql://galen:rhodes@projectgalen.com:2112?iam=great",
            "swiftdbc:mysql://galen@projectgalen.com:2112?iam=great",
            "swiftdbc:mysql://projectgalen.com:2112?iam=great",

            "swiftdbc:mysql:galen:rhodes@projectgalen.com:2112?iam=great",
            "swiftdbc:mysql:galen@projectgalen.com:2112?iam=great",
            "swiftdbc:mysql:projectgalen.com:2112?iam=great",

            "swiftdbc:mysql://galen:rhodes@projectgalen.com?iam=great",
            "swiftdbc:mysql://galen@projectgalen.com?iam=great",
            "swiftdbc:mysql://projectgalen.com?iam=great",

            "swiftdbc:mysql:galen:rhodes@projectgalen.com?iam=great",
            "swiftdbc:mysql:galen@projectgalen.com?iam=great",
            "swiftdbc:mysql:projectgalen.com?iam=great",
//-----------------------------------------------------------------------------------------------
            "swiftdbc:mysql://galen:rhodes@projectgalen.com:2112/testdb",
            "swiftdbc:mysql://galen@projectgalen.com:2112/testdb",
            "swiftdbc:mysql://projectgalen.com:2112/testdb",

            "swiftdbc:mysql:galen:rhodes@projectgalen.com:2112/testdb",
            "swiftdbc:mysql:galen@projectgalen.com:2112/testdb",
            "swiftdbc:mysql:projectgalen.com:2112/testdb",

            "swiftdbc:mysql://galen:rhodes@projectgalen.com/testdb",
            "swiftdbc:mysql://galen@projectgalen.com/testdb",
            "swiftdbc:mysql://projectgalen.com/testdb",

            "swiftdbc:mysql:galen:rhodes@projectgalen.com/testdb",
            "swiftdbc:mysql:galen@projectgalen.com/testdb",
            "swiftdbc:mysql:projectgalen.com/testdb",

            "swiftdbc:mysql://galen:rhodes@projectgalen.com:2112",
            "swiftdbc:mysql://galen@projectgalen.com:2112",
            "swiftdbc:mysql://projectgalen.com:2112",

            "swiftdbc:mysql:galen:rhodes@projectgalen.com:2112",
            "swiftdbc:mysql:galen@projectgalen.com:2112",
            "swiftdbc:mysql:projectgalen.com:2112",

            "swiftdbc:mysql://galen:rhodes@projectgalen.com",
            "swiftdbc:mysql://galen@projectgalen.com",
            "swiftdbc:mysql://projectgalen.com",

            "swiftdbc:mysql:galen:rhodes@projectgalen.com",
            "swiftdbc:mysql:galen@projectgalen.com",
            "swiftdbc:mysql:projectgalen.com",
//-----------------------------------------------------------------------------------------------
            "swiftdbc:mysql://galen:rhodes@192.168.0.100:2112/testdb?iam=great",
            "swiftdbc:mysql://galen@192.168.0.100:2112/testdb?iam=great",
            "swiftdbc:mysql://192.168.0.100:2112/testdb?iam=great",

            "swiftdbc:mysql:galen:rhodes@192.168.0.100:2112/testdb?iam=great",
            "swiftdbc:mysql:galen@192.168.0.100:2112/testdb?iam=great",
            "swiftdbc:mysql:192.168.0.100:2112/testdb?iam=great",

            "swiftdbc:mysql://galen:rhodes@192.168.0.100/testdb?iam=great",
            "swiftdbc:mysql://galen@192.168.0.100/testdb?iam=great",
            "swiftdbc:mysql://192.168.0.100/testdb?iam=great",

            "swiftdbc:mysql:galen:rhodes@192.168.0.100/testdb?iam=great",
            "swiftdbc:mysql:galen@192.168.0.100/testdb?iam=great",
            "swiftdbc:mysql:192.168.0.100/testdb?iam=great",

            "swiftdbc:mysql://galen:rhodes@192.168.0.100:2112?iam=great",
            "swiftdbc:mysql://galen@192.168.0.100:2112?iam=great",
            "swiftdbc:mysql://192.168.0.100:2112?iam=great",

            "swiftdbc:mysql:galen:rhodes@192.168.0.100:2112?iam=great",
            "swiftdbc:mysql:galen@192.168.0.100:2112?iam=great",
            "swiftdbc:mysql:192.168.0.100:2112?iam=great",

            "swiftdbc:mysql://galen:rhodes@192.168.0.100?iam=great",
            "swiftdbc:mysql://galen@192.168.0.100?iam=great",
            "swiftdbc:mysql://192.168.0.100?iam=great",

            "swiftdbc:mysql:galen:rhodes@192.168.0.100?iam=great",
            "swiftdbc:mysql:galen@192.168.0.100?iam=great",
            "swiftdbc:mysql:192.168.0.100?iam=great",

            "swiftdbc:mysql://galen:rhodes@192.168.0.100:2112/testdb",
            "swiftdbc:mysql://galen@192.168.0.100:2112/testdb",
            "swiftdbc:mysql://192.168.0.100:2112/testdb",

            "swiftdbc:mysql:galen:rhodes@192.168.0.100:2112/testdb",
            "swiftdbc:mysql:galen@192.168.0.100:2112/testdb",
            "swiftdbc:mysql:192.168.0.100:2112/testdb",

            "swiftdbc:mysql://galen:rhodes@192.168.0.100/testdb",
            "swiftdbc:mysql://galen@192.168.0.100/testdb",
            "swiftdbc:mysql://192.168.0.100/testdb",

            "swiftdbc:mysql:galen:rhodes@192.168.0.100/testdb",
            "swiftdbc:mysql:galen@192.168.0.100/testdb",
            "swiftdbc:mysql:192.168.0.100/testdb",

            "swiftdbc:mysql://galen:rhodes@192.168.0.100:2112",
            "swiftdbc:mysql://galen@192.168.0.100:2112",
            "swiftdbc:mysql://192.168.0.100:2112",

            "swiftdbc:mysql:galen:rhodes@192.168.0.100:2112",
            "swiftdbc:mysql:galen@192.168.0.100:2112",
            "swiftdbc:mysql:192.168.0.100:2112",

            "swiftdbc:mysql://galen:rhodes@192.168.0.100",
            "swiftdbc:mysql://galen@192.168.0.100",
            "swiftdbc:mysql://192.168.0.100",

            "swiftdbc:mysql:galen:rhodes@192.168.0.100",
            "swiftdbc:mysql:galen@192.168.0.100",
            "swiftdbc:mysql:192.168.0.100",
        ]
        for s: String in strs {
            let x: [NSTextCheckingResult] = regex.matches(in: s)

            if x.count > 0 {
                printRegexResults2(s, x)
            }
            else {
                print("> \"\(s)\": NO MATCH!")
            }
        }
    }

    func testIpAddressRegex() throws {
        let regex: NSRegularExpression = try NSRegularExpression(pattern: "^(?:\(_regexIpAddress))$")
        let s:     String              = "192.168.0.1"

        let x: [NSTextCheckingResult] = regex.matches(in: s)

        if x.count > 0 {
            //printRegexResults(s, x)
        }
        else {
            print("> \"\(s)\": NO MATCH!")
        }
    }

    func testPortRegex() throws {
        let regex: NSRegularExpression = try NSRegularExpression(pattern: "^(?:\(_regexPort))$")
        for i: Int in (0 ..< 65999) {
            let s: String                 = "\(i)"
            let x: [NSTextCheckingResult] = regex.matches(in: s)

            if x.count > 0 {
                //printRegexResults(s, x)
            }
            else {
                print("> \"\(s)\": NO MATCH!")
                break
            }
        }
    }

    func testDriverManager() throws {
        let url:  String        = "swiftdbc:mysql://grhodes-dev:Leising1970!@goober:3306/RHODES"
        let conn: DBConnection  = try DBDriverManager.manager.connect(url: url)
        let stmt: DBStatement   = try conn.createStatement()
        var res:  DBNextResults = try stmt.execute(sql: "select * from person")

        while res != .None {
            if res == .ResultSet {
                if let rs: DBResultSet = try stmt.getResultSet(){
                    print("-----------------------------------------------------------------------")
                    while try rs.hasNextRow() {
                        for i in (0 ..< rs.metaData.columnCount) {
                            print("\(rs.metaData[i].name): \"\((try rs.getString(index: i)) ?? "")\"")
                        }
                        print("-----------------------------------------------------------------------")
                    }
                }
            }
            else if res == .UpdateCount {
                print("Update Count: \((try? stmt.getUpdateCount()) ?? -1)")
            }
            res = try stmt.hasMoreResults()
        }

        print("Success!")
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
//
}
