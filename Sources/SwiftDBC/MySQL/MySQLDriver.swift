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
import Rubicon

class MySQLDriver: DBDriver {
    let majorVersion: Int    = 1
    let minorVersion: Int    = 0
    let name:         String = "MySQL"

    static let defaultDriver: MySQLDriver   = MySQLDriver()
    static let lock:          RecursiveLock = RecursiveLock()

    private init() {
        mysql_server_init(0, nil, nil)
        mysql_thread_init()
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
                    let database:   String           = pathStr.substr(from: 1)

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
        MySQLDriver.lock.withLock { driverManager.register(driver: self, deregisterLambda: { mysql_server_end() }) }
    }

    /*===========================================================================================================================*/
    /// We have this method but it's kinda pointless since the constructor for `DBDriverManager` does this part for us.
    ///
    class func register() {
        MySQLDriver.lock.withLock { defaultDriver.register(driverManager: DBDriverManager.manager) }
    }
}
