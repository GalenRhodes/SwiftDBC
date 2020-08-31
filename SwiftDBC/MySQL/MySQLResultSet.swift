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

/*===============================================================================================================================*/
/// The result set from a query against the database.
///
class MySQLResultSet: DBResultSet {

    /*===========================================================================================================================*/
    /// `true` if the result set is closed.
    ///
    var isClosed: Bool       = false

    /*===========================================================================================================================*/
    /// The rows of data returned from the database.
    ///
    var rawData:  [MySQLRow] = []

    /*===========================================================================================================================*/
    /// The statement this result set belongs to.
    ///
    let stmt:     MySQLStatement

    /*===========================================================================================================================*/
    /// The result set metadata.
    ///
    let metaData: DBResultSetMetaData

    /*===========================================================================================================================*/
    /// The current row being read. `nil` if `next()` has not yet been called or there are no more rows.
    ///
    var currentRow: MySQLRow? = nil

    /*===========================================================================================================================*/
    /// Initializes this result set by reading all of the rows returned by the database.
    ///
    /// - Parameters:
    ///   - stmt: the statement that this result set belongs to.
    ///   - rs: the result set structure returned by the database.
    ///
    init(_ stmt: MySQLStatement, _ rs: UnsafeMutablePointer<MYSQL_RES>) {
        self.stmt = stmt
        metaData = MySQLResultSetMetaData(rs: rs)
        defer { mysql_free_result(rs) }

        var row: MYSQL_ROW? = mysql_fetch_row(rs)
        while let r: MYSQL_ROW = row {
            if let lens: UnsafeMutablePointer<UInt> = mysql_fetch_lengths(rs) {
                rawData.append(MySQLRow(row: r, lengths: lens, colCount:
                metaData.columnCount))
            }
            row = mysql_fetch_row(rs)
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

    /*===========================================================================================================================*/
    /// Get the next row of data.
    ///
    /// - Returns: `true` if there is another row of data or `false` if there are no more rows.
    /// - Throws: if an error occurs of if the result set has been closed.
    ///
    func next() throws -> Bool {
        fatalError("next() has not been implemented")
    }

    func getString(index: Int) throws -> String? {
        fatalError("getString(index:) has not been implemented")
    }

    func getString(name: String) throws -> String? {
        fatalError("getString(name:) has not been implemented")
    }

    func getByte(index: Int) throws -> Int8? {
        fatalError("getByte(index:) has not been implemented")
    }

    func getByte(name: String) throws -> Int8? {
        fatalError("getByte(name:) has not been implemented")
    }

    func getShort(index: Int) throws -> Int16? {
        fatalError("getShort(index:) has not been implemented")
    }

    func getShort(name: String) throws -> Int16? {
        fatalError("getShort(name:) has not been implemented")
    }

    func getInt(index: Int) throws -> Int? {
        fatalError("getInt(index:) has not been implemented")
    }

    func getInt(name: String) throws -> Int? {
        fatalError("getInt(name:) has not been implemented")
    }

    func getLong(index: Int) throws -> Int64? {
        fatalError("getLong(index:) has not been implemented")
    }

    func getLong(name: String) throws -> Int64? {
        fatalError("getLong(name:) has not been implemented")
    }

    func getBigInt(index: Int) throws -> BigInt? {
        fatalError("getBigInt(index:) has not been implemented")
    }

    func getBigInt(name: String) throws -> BigInt? {
        fatalError("getBigInt(name:) has not been implemented")
    }

    func getBool(index: Int) throws -> String? {
        fatalError("getBool(index:) has not been implemented")
    }

    func getBool(name: String) throws -> String? {
        fatalError("getBool(name:) has not been implemented")
    }

    func getDate(index: Int) throws -> Date? {
        fatalError("getDate(index:) has not been implemented")
    }

    func getDate(name: String) throws -> Date? {
        fatalError("getDate(name:) has not been implemented")
    }

    func getTime(index: Int) throws -> Date? {
        fatalError("getTime(index:) has not been implemented")
    }

    func getTime(name: String) throws -> Date? {
        fatalError("getTime(name:) has not been implemented")
    }

    func getTimestamp(index: Int) throws -> Date? {
        fatalError("getTimestamp(index:) has not been implemented")
    }

    func getTimestamp(name: String) throws -> Date? {
        fatalError("getTimestamp(name:) has not been implemented")
    }

    func getFloat(index: Int) throws -> Float? {
        fatalError("getFloat(index:) has not been implemented")
    }

    func getFloat(name: String) throws -> Float? {
        fatalError("getFloat(name:) has not been implemented")
    }

    func getDouble(index: Int) throws -> Double? {
        fatalError("getDouble(index:) has not been implemented")
    }

    func getDouble(name: String) throws -> Double? {
        fatalError("getDouble(name:) has not been implemented")
    }

    func getBigDecimal(index: Int) throws -> Decimal? {
        fatalError("getBigDecimal(index:) has not been implemented")
    }

    func getBigDecimal(name: String) throws -> Decimal? {
        fatalError("getBigDecimal(name:) has not been implemented")
    }

    func getSmall(index: Int) throws -> Int32? {
        fatalError("getSmall(index:) has not been implemented")
    }

    func getSmall(name: String) throws -> Int32? {
        fatalError("getSmall(name:) has not been implemented")
    }

    func getUByte(index: Int) throws -> UInt8? {
        fatalError("getUByte(index:) has not been implemented")
    }

    func getUByte(name: String) throws -> UInt8? {
        fatalError("getUByte(name:) has not been implemented")
    }

    func getUShort(index: Int) throws -> UInt16? {
        fatalError("getUShort(index:) has not been implemented")
    }

    func getUShort(name: String) throws -> UInt16? {
        fatalError("getUShort(name:) has not been implemented")
    }

    func getUSmall(index: Int) throws -> UInt32? {
        fatalError("getUSmall(index:) has not been implemented")
    }

    func getUSmall(name: String) throws -> UInt32? {
        fatalError("getUSmall(name:) has not been implemented")
    }

    func getUInt(index: Int) throws -> UInt? {
        fatalError("getUInt(index:) has not been implemented")
    }

    func getUInt(name: String) throws -> UInt? {
        fatalError("getUInt(name:) has not been implemented")
    }

    func getULong(index: Int) throws -> UInt64? {
        fatalError("getULong(index:) has not been implemented")
    }

    func getULong(name: String) throws -> UInt64? {
        fatalError("getULong(name:) has not been implemented")
    }

    func getUBigInt(index: Int) throws -> BigUInt? {
        fatalError("getUBigInt(index:) has not been implemented")
    }

    func getUBigInt(name: String) throws -> BigUInt? {
        fatalError("getUBigInt(name:) has not been implemented")
    }
}

/*===============================================================================================================================*/
/// A class that holds one row of data returned by the database.
///
class MySQLRow {

    /*===========================================================================================================================*/
    /// MySQL sends us data as strings regardless of the underlying data type in the database. It's up to the client to convert
    /// that string data to the appropriate data type.
    ///
    var columns: [String?] = []

    /*===========================================================================================================================*/
    /// Initializes the row with the data from the database.
    ///
    /// - Parameters:
    ///   - row: the row from the database as an array of pointers to `nil`-terminated C strings encoded using UTF-8.
    ///   - lengths: the lengths of each column
    ///   - colCount: the number of columns.
    ///
    init(row: MYSQL_ROW, lengths: UnsafeMutablePointer<UInt>, colCount: Int) {
        for i: Int in (0 ..< colCount) {
            let cData: UnsafeMutablePointer<Int8>? = row[i]
            columns.append((cData == nil) ? nil : getString(cStr: cData!, length: Int(lengths[i])))
        }
    }

}
