/************************************************************************//**
 *     PROJECT: SwiftDBC
 *    FILENAME: MySQL_Connection.swift
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

class MySQLConnection: DBConnection {

    let networkTimeout:   Int                 = 30000
    var isClosed:         Bool                = true
    var metaData:         DBDatabaseMetaData? = nil
    var driver:           DBDriver { MySQLDriver.defaultDriver }
    var lastErrorMessage: String {
        if let msg: UnsafePointer<CChar> = mysql_error(mysql) {
            return String(cString: msg, encoding: String.Encoding.utf8) ?? "Unknown"
        }
        else {
            return ""
        }
    }
    var autoCommit:       Bool {
        get { _autoCommit }
        set {
            _autoCommit = newValue
            mysql_autocommit(mysql, _autoCommit)
        }
    }

    var mysql:    UnsafeMutablePointer<MYSQL>
    let host:     String
    let port:     Int
    let username: String?
    let password: String?
    let database: String?
    var isInit:   Bool = false

    private var _autoCommit: Bool = false

    init(host: String, port: Int, username: String?, password: String?, database: String?, query: [String: String]) throws {
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        self.database = database

        if let _mysql: UnsafeMutablePointer<MYSQL> = mysql_init(nil) {
            self.mysql = _mysql
            try connect()
        }
        else {
            throw DBError.Connection(description: "Unable to allocate memory for database connection to: \(host):\(port)/\(database ?? "")")
        }
    }

    func reconnect() throws {
        close()
        if let m0: UnsafeMutablePointer<MYSQL> = mysql_init(nil) {
            self.mysql = m0
            try connect()
        }
        else {
            throw DBError.Connection(description: "Unable to allocate memory for database connection to: \(host):\(port)/\(database ?? "")")
        }
    }

    private func connect() throws {
        var to: UInt32 = UInt32(networkTimeout / 1000)
        var rc: Bool   = true

        isInit = true
        mysql_options(mysql, MYSQL_SET_CHARSET_NAME, MySQLDefaultCharacterSet)
        mysql_options(mysql, MYSQL_OPT_CONNECT_TIMEOUT, &to)
        mysql_options(mysql, MYSQL_OPT_RECONNECT, &rc)

        if let _ = mysql_real_connect(mysql, host, username, password, database, UInt32(port), nil, CLIENT_MULTI_STATEMENTS | CLIENT_MULTI_RESULTS) {
            isClosed = false
            autoCommit = true
            mysql_set_character_set(mysql, MySQLDefaultCharacterSet)
        }
        else {
            throw DBError.Connection(description: "Connection failed: \(lastErrorMessage)")
        }
    }

    deinit {
        close()
    }

    func close() {
        if isInit {
            // Tell anyone who depends on this connection that it is closing.
            NotificationCenter.default.post(name: DBConnectionWillClose, object: self)
            // Then close it.
            mysql_close(mysql)
            isInit = false
            isClosed = true
            _autoCommit = false
        }
    }

    func commit() throws {
        if !mysql_commit(mysql) {
            throw DBError.Commit
        }
    }

    func rollback() throws {
        if !mysql_rollback(mysql) {
            throw DBError.Rollback
        }
    }

    func createStatement() throws -> DBStatement {
        MySQLStatement(self)
    }
}
