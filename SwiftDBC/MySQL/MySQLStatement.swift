/************************************************************************//**
 *     PROJECT: SwiftDBC
 *    FILENAME: MySQLStatement.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 8/26/20
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

class MySQLStatement: DBStatement {

    let conn:        MySQLConnection
    var isClosed:    Bool                             = true
    var queryResult: UnsafeMutablePointer<MYSQL_RES>? = nil
    var insideQuery: Bool                             = false

    init(_ conn: MySQLConnection) throws {
        self.conn = conn
        NotificationCenter.default.addObserver(forName: DBConnectionWillClose, object: self.conn, queue: nil) { notice in self.close() }
    }

    func close() {
        if !isClosed {
            // Tell anyone who depends on this statement that it is closing.
            NotificationCenter.default.post(name: DBStatementWillClose, object: self)
            // Then close.
            isClosed = true
        }
    }

    func execute(sql: String) throws -> Bool {
        try sql.utf8CString.withUnsafeBufferPointer { bp in
            guard let p: UnsafePointer<CChar> = bp.baseAddress else { throw DBError.Query(description: "Invalid Query String: \(sql)") }
            guard mysql_real_query(conn.mysql, p, UInt(bp.count)) == 0 else { throw DBError.Query(description: conn.lastErrorMessage) }

            queryResult = mysql_store_result(conn.mysql)

            if queryResult != nil {
                insideQuery = true
                return true
            }
            else if mysql_field_count(conn.mysql) != 0 {
                throw DBError.Query(description: conn.lastErrorMessage)
            }
            else {
                insideQuery = true
                return false
            }
        }
    }
}
