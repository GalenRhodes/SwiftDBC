/************************************************************************//**
 *     PROJECT: SwiftDBC
 *    FILENAME: SwiftDBC_MySQL.swift
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

import Foundation
import MySQL

let MySQLDefaultCharacterSet: String = "utf8mb4"
let MySQLDBCPrefix:           String = "\(SwiftDBCPrefix):mysql"

let _regexPfx:           String = NSRegularExpression.escapedPattern(for: MySQLDBCPrefix)
let _regexHostNameLabel: String = "(?:[^.:?/]+)"
let _regexHostName:      String = "\(_regexHostNameLabel)(?:\\.\(_regexHostNameLabel))*"
let _regexIpNumber:      String = "(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2(?:[0-4][0-9]|5[0-5]))"
let _regexIpAddress:     String = "\(_regexIpNumber)(?:\\.\(_regexIpNumber)){3}"
let _regexPort:          String = "(?:0|[1-9]|[1-9][0-9]{1,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])"
let _regexCredentials:   String = "([^:@]+)(?:\\:([^@]+))?@"

/*===============================================================================================================================*/
/// - Group 1: username
/// - Group 2: password
/// - Group 3: host name/ip address
/// - Group 4: port
/// - Group 5: path
/// - Group 6: query
///
let _regexUrl:           String = "(?:\(_regexPfx):)(?://)?(?:\(_regexCredentials))?((?:\(_regexIpAddress))|(?:\(_regexHostName)))(?:\\:(\(_regexPort)))?(/[^?]*)?(?:\\?(.+))?"

@inlinable func _get(str: String, result: NSTextCheckingResult, group: Int) -> String? { ((group < result.numberOfRanges) ? str.substringWith(nsRange: result.range(at: group)) : nil) }

class MySQLDriver: DBDriver {
    private(set) var majorVersion: Int = 1
    private(set) var minorVersion: Int = 0

    static let defaultDriver: MySQLDriver = MySQLDriver()

    private init() {
        mysql_server_init(0, nil, nil)
    }

    deinit {
        print("MySQLDriver is dying...")
    }

    func releaseClientLibrary() {
        // Release any resources used by the library.
        mysql_server_end()
    }

    func acceptsURL(_ url: String) -> Bool {
        url.hasPrefix("\(MySQLDBCPrefix):")
    }

    public func connect(url: String, username: String?, password: String?, database: String?, properties: [String: Any]) throws -> DBConnection {
        do {
            let regex: NSRegularExpression = try NSRegularExpression(pattern: "^(?:\(_regexUrl))$")

            if let m: NSTextCheckingResult = regex.firstMatch(in: url) {
                if let host: String = _get(str: url, result: m, group: 3) {
                    var query:      [String: String] = try getQueryString(_get(str: url, result: m, group: 6))
                    let portNumber: Int              = (Int(_get(str: url, result: m, group: 4) ?? (query["port"] ?? "0")) ?? 0)
                    let username:   String?          = _get(str: url, result: m, group: 1) ?? query["username"]
                    let password:   String?          = _get(str: url, result: m, group: 2) ?? query["password"]
                    let pathStr:    String           = _get(str: url, result: m, group: 5) ?? ("/\(query["database"] ?? "")")
                    let database:   String           = pathStr.substring(fromOffset: 1)

                    query.removeValue(forKey: "username")
                    query.removeValue(forKey: "password")
                    query.removeValue(forKey: "database")
                    query.removeValue(forKey: "port")

                    return try MySQLConnection(host: host, port: portNumber, username: username, password: password, database: database, query: query)
                }
            }
        }
        catch let e as DBError {
            throw e // rethrow it
        }
        catch {
            // Do Nothing...
        }
        throw DBError.Connection(description: "Malformed URL: \(url)")
    }

    private func getQueryString(_ s: String?) throws -> [String: String] {
        var query: [String: String] = [:]

        if let queryStr: String = s {
            let queryStr: String                 = "&\(queryStr)"
            let regex2:   NSRegularExpression    = try NSRegularExpression(pattern: "\\&(?:amp;)?([^=&]+)(?:\\=([^&]+))?")
            let matches:  [NSTextCheckingResult] = regex2.matches(in: queryStr)

            for match: NSTextCheckingResult in matches {
                if let key: String = _get(str: queryStr, result: match, group: 1) {
                    query[key] = (_get(str: queryStr, result: match, group: 2) ?? "")
                }
            }
        }
        return query
    }

    func register(driverManager: DBDriverManager) {
        driverManager.register(driver: self, deregisterLambda: { self.releaseClientLibrary() })
    }

    /*===========================================================================================================================*/
    /// We have this method but it's kinda pointless since the constructor for `DBDriverManager` does this part for us.
    ///
    class func register() {
        defaultDriver.register(driverManager: DBDriverManager.manager)
    }
}
