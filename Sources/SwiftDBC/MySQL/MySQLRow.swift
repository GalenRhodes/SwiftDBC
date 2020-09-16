/************************************************************************//**
 *     PROJECT: SwiftDBC
 *    FILENAME: MySQLRow.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 9/10/20
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
import Rubicon
import MySQL

/*===============================================================================================================================*/
/// A class that holds one row of data returned by the database.
///
class MySQLRow: DBRow {

    let rs:         MySQLResultSet
    var columnList: [DBColumn]         = []
    var columnMap:  [String: DBColumn] = [:]

    @inlinable var resultSet: DBResultSet { rs }
    let            rowNumber: Int

    /*===========================================================================================================================*/
    /// Initializes the row with the data from the database.
    /// 
    /// - Parameters:
    ///   - row: the row from the database as an array of pointers to `nil`-terminated C strings encoded using UTF-8.
    ///   - lengths: the lengths of each column
    ///   - metaData: the metaData for the result set creating this row.
    ///   - rowNumber: the number of this row.
    ///
    init(resultSet rs: MySQLResultSet, row: MYSQL_ROW, lengths: UnsafeMutablePointer<UInt>, rowNumber: Int) {
        self.rowNumber = rowNumber
        self.rs = rs

        for i: Int in (0 ..< rs.metaData.columnCount) {
            let cData:  CCharPointer? = row[i]
            let column: MySQLColumn   = MySQLColumn(self, ((cData == nil) ? nil : getData(bytes: cData!, length: Int(lengths[i]))), rs.metaData[i])

            columnList.append(column);
            columnMap[column.name.uppercased()] = column
        }
    }

    func withColumns(do body: (DBColumn) throws -> Bool) throws -> Bool {
        for c: DBColumn in columnList {
            if try body(c) { return true }
        }
        return false
    }

    @inlinable subscript(idx: Int) -> DBColumn { columnList[idx] }

    @inlinable subscript(name: String) -> DBColumn? { columnMap[name.uppercased()] }
}
