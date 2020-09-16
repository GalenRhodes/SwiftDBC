/************************************************************************//**
 *     PROJECT: SwiftDBC
 *    FILENAME: MySQLResultSet.swift
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
import BigInt
import Rubicon

/*===============================================================================================================================*/
/// The result set from a query against the database.
///
class MySQLResultSet: DBResultSet {
    var            isClosed:  Bool    = false
    @inlinable var count:     Int { rows.count }
    @inlinable var statement: DBStatement { stmt }
    let            metaData:  DBResultSetMetaData
    let            stmt:      MySQLStatement
    var            rows:      [DBRow] = []

    /*===========================================================================================================================*/
    /// Initializes this result set by reading all of the rows returned by the database.
    /// 
    /// - Parameters:
    ///   - stmt: the statement that this result set belongs to.
    ///   - rs: the result set structure returned by the database.
    ///
    init(_ stmt: MySQLStatement, _ rs: UnsafeMutablePointer<MYSQL_RES>) {
        defer { mysql_free_result(rs) }
        self.stmt = stmt
        self.metaData = MySQLResultSetMetaData(rs: rs)

        var _rowNum: Int        = 0
        var _row:    MYSQL_ROW? = mysql_fetch_row(rs)

        while let row: MYSQL_ROW = _row {
            if let dataLengths: UnsafeMutablePointer<UInt> = mysql_fetch_lengths(rs) {
                rows.append(MySQLRow(resultSet: self, row: row, lengths: dataLengths, rowNumber: _rowNum++))
            }
            _row = mysql_fetch_row(rs)
        }

        NotificationCenter.default.addObserver(forName: DBStatementWillClose, object: stmt, queue: nil) {
            [weak self] (notice: Notification) in
            if let s: MySQLResultSet = self { s.close() }
        }
    }

    /*===========================================================================================================================*/
    /// Close the result set when this object is disposed of by the system.
    ///
    deinit {
        close()
    }

    subscript(rowNumber: Int) -> DBRow { rows[rowNumber] }

    /*===========================================================================================================================*/
    /// Close the result set.
    ///
    func close() {
        if !isClosed {
            // Tell anyone who depends on this result set that it is closing.
            NotificationCenter.default.post(name: DBResultSetWillClose, object: self)
            // Then close.
            isClosed = true
        }
    }

    func withRows(do body: (DBRow) throws -> Bool) throws -> Bool {
        for row: DBRow in rows {
            if try body(row) { return true }
        }
        return false
    }
}
