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
import Rubicon

@usableFromInline typealias MySQLPointer = UnsafeMutablePointer<MYSQL>

class MySQLConnection: DBConnection {

    let networkTimeout:   Int  = 30000
    var isClosed:         Bool = true
    var driver:           DBDriver { MySQLDriver.defaultDriver }
    var autoCommit:       Bool { willSet { if isInit { mysql_autocommit(mysql, newValue) } } }
    var lastErrorMessage: String { getString(cStr: mysql_error(mysql)) ?? "Unknown Error" }

    var mysql:    MySQLPointer
    var isInit:   Bool          = false
    var isBusy:   AnyObject?    = nil // Only one statement can be working at once. Other's have to wait.
    let lock:     RecursiveLock = RecursiveLock()
    let cond:     Conditional   = Conditional()
    let host:     String
    let port:     Int
    let username: String?
    let password: String?
    let database: String?

    init(host: String, port: Int, username: String?, password: String?, database: String?, query: [String: String]) throws {
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        self.database = database
        self.autoCommit = false
        self.mysql = try _initializeMySQL(host, port, database)
        try connect()
    }

    func reconnect() throws {
        try lock.withLock {
            _close()
            mysql = try _initializeMySQL(host, port, database)
            try connect()
        }
    }

    deinit { _close() }

    func close() { lock.withLock { _close() } }

    func doWithBusySet<T>(busyObj: AnyObject, body: () throws -> T) rethrows -> T {
        try cond.withLockWait(cond: { (isBusy == nil) }) {
            isBusy = busyObj
            defer { isBusy = nil }
            return try body()
        }
    }

    func createStatement() throws -> DBStatement {
        let stmt = MySQLStatement(self)

        NotificationCenter.default.addObserver(forName: DBStatementWillClose, object: stmt, queue: nil) {
            [weak self] (note: Notification) in
            if let s: MySQLConnection = self {
                s.cond.withLock {
                    if let busy: AnyObject = s.isBusy, busy === (note.object as AnyObject) {
                        s.isBusy = nil
                    }
                }
            }
        }

        return stmt
    }

    func commit() -> Bool {
        doWithBusySet(busyObj: self) { mysql_commit(mysql) }
    }

    func rollback() -> Bool {
        doWithBusySet(busyObj: self) { mysql_rollback(mysql) }
    }

    private func connect() throws {
        var to:   UInt32 = UInt32(networkTimeout / 1000)
        var rc:   Bool   = true
        let opts: UInt   = (CLIENT_MULTI_STATEMENTS | CLIENT_MULTI_RESULTS)

        isInit = true
        mysql_options(mysql, MYSQL_SET_CHARSET_NAME, MySQLDefaultCharacterSet)
        mysql_options(mysql, MYSQL_OPT_CONNECT_TIMEOUT, &to)
        mysql_options(mysql, MYSQL_OPT_RECONNECT, &rc)

        if let _ = mysql_real_connect(mysql, host, username, password, database, UInt32(port), nil, opts) {
            isClosed = false
            autoCommit = true
            mysql_set_character_set(mysql, MySQLDefaultCharacterSet)
        }
        else {
            throw DBError.Connection(description: "Connection failed: \(lastErrorMessage)")
        }
    }

    @inlinable func _close() {
        if isInit {
            // Tell anyone who depends on this connection that it is closing.
            NotificationCenter.default.post(name: DBConnectionWillClose, object: self)
            // Then close it.
            mysql_close(mysql)

            isInit = false
            isClosed = true
        }
    }
}

fileprivate func _initializeMySQL(_ host: String, _ port: Int, _ database: String?) throws -> MySQLPointer {
    if let _mysql = MySQLDriver.lock.withLock(body: { mysql_init(nil) }) { return _mysql }
    else { throw DBError.Connection(description: "Unable to allocate memory for database connection to: \(host):\(port)/\(database ?? "")") }
}
