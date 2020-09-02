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
    var isClosed:   Bool       = false

    /*===========================================================================================================================*/
    /// The rows of data returned from the database.
    ///
    var rawData:    [MySQLRow] = []

    /*===========================================================================================================================*/
    /// The statement this result set belongs to.
    ///
    let stmt:       MySQLStatement

    /*===========================================================================================================================*/
    /// The result set metadata.
    ///
    let metaData:   DBResultSetMetaData

    /*===========================================================================================================================*/
    /// The current row being read. `nil` if `next()` has not yet been called or there are no more rows.
    ///
    var currentRow: MySQLRow?  = nil

    var wasNextCalled: Bool = false

    let lock: RecursiveLock = RecursiveLock()

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
        NotificationCenter.default.addObserver(forName: DBStatementWillClose, object: stmt, queue: nil) { [weak self] (notice: Notification) in if let s: MySQLResultSet = self { s.close() } }

        var _row: MYSQL_ROW? = mysql_fetch_row(rs)
        let _cc:  Int        = metaData.columnCount

        while let row: MYSQL_ROW = _row {
            if let dataLengths: UnsafeMutablePointer<UInt> = mysql_fetch_lengths(rs) {
                let rowObj = MySQLRow(row: row, lengths: dataLengths, colCount: _cc)
                rawData.append(rowObj)
            }
            _row = mysql_fetch_row(rs)
        }
    }

    /*===========================================================================================================================*/
    /// Close the result set when this object is disposed of by the system.
    ///
    deinit {
        _close()
    }

    /*===========================================================================================================================*/
    /// Close the result set.
    ///
    func close() {
        lock.withLock { _close() }
    }

    @inlinable func _close() {
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
    func hasNextRow() throws -> Bool {
        lock.withLock {
            wasNextCalled = true
            if rawData.count == 0 { currentRow = nil }
            else { currentRow = rawData.removeFirst() }
            return (currentRow != nil)
        }
    }

    func getData(index: Int) throws -> Data? { try lock.withLock { try _getData(index: index) } }

    func getInputStream(index: Int) throws -> InputStream? {
        guard let data: Data = try getData(index: index) else { return nil }
        return InputStream(data: data)
    }

    func getString(index: Int) throws -> String? {
        guard let data: Data = try getData(index: index) else { return nil }

        switch metaData[index].dataType {
            case .Blob, .Binary, .VarBinary, .LongVarBinary: return data.base64EncodedString()
            case .Null: return nil
            case .Array: return nil
            case .DataLink: return nil
            case .Distinct: return nil
            case .JavaObject: return nil
            case .Other: return nil
            case .Ref: return nil
            case .RefCursor: return nil
            case .RowId: return nil
            case .SqlXml: return nil
            case .Struct: return nil
            default: return String(bytes: data, encoding: String.Encoding.utf8)
        }
    }

    func getByte(index: Int) throws -> UInt8? {
        guard let data: Data = try getData(index: index) else { return nil }
        if metaData[index].isBinary { return data.count > 0 ? data[0] : nil }
        else if let str: String = String(bytes: data, encoding: String.Encoding.utf8) { return UInt8(str) }
        else { return nil }
    }

    func getShort(index: Int) throws -> Int16? {
        guard let data: Data = try getData(index: index) else { return nil }
        if !metaData[index].isBinary, let str: String = String(bytes: data, encoding: String.Encoding.utf8) { return Int16(str) }
        else { return nil }
    }

    func getInt(index: Int) throws -> Int? {
        guard let data: Data = try getData(index: index) else { return nil }
        if !metaData[index].isBinary, let str: String = String(bytes: data, encoding: String.Encoding.utf8) { return Int(str) }
        else { return nil }
    }

    func getLong(index: Int) throws -> Int64? {
        guard let data: Data = try getData(index: index) else { return nil }
        if !metaData[index].isBinary, let str: String = String(bytes: data, encoding: String.Encoding.utf8) { return Int64(str) }
        else { return nil }
    }

    func getBigInt(index: Int) throws -> BigInt? {
        guard let data: Data = try getData(index: index) else { return nil }
        if !metaData[index].isBinary, let str: String = String(bytes: data, encoding: String.Encoding.utf8) { return BigInt(str) }
        else { return nil }
    }

    func getBool(index: Int) throws -> Bool? {
        try lock.withLock {
            if let data: Data = try _getData(index: index) {
                let md: DBColumnMetaData = metaData[index]

                if md.dataType != .Null, !md.isBinary, let s: String = String(bytes: data, encoding: String.Encoding.utf8) {
                    if md.isNumeric {
                        if let b: Int64 = Int64(s) { return (b != 0) }
                        else if let b: Double = Double(s) { return (b != 0.0) }
                    }
                    else if let rx: NSRegularExpression = try? NSRegularExpression(pattern: "^\\s*(true|yes|y|t|on)\\s*$", options: [ NSRegularExpression.Options.caseInsensitive ]) {
                        return (rx.matches(in: s).count == 1)
                    }
                }
            }

            return nil
        }
    }

    func getDate(index: Int) throws -> Date? {
        guard !metaData[index].isBinary, let str: String = try getString(index: index) else { return nil }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.date(from: str)
    }

    func getTime(index: Int) throws -> Date? {
        guard !metaData[index].isBinary, let str: String = try getString(index: index) else { return nil }
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm:ssZZZZZ"
        return fmt.date(from: str)
    }

    func getTimestamp(index: Int) throws -> Date? {
        guard !metaData[index].isBinary, let str: String = try getString(index: index) else { return nil }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return fmt.date(from: str)
    }

    func getFloat(index: Int) throws -> Float? {
        guard let data: Data = try getData(index: index) else { return nil }
        if !metaData[index].isBinary, let str: String = String(bytes: data, encoding: String.Encoding.utf8) { return Float(str) }
        else { return nil }
    }

    func getDouble(index: Int) throws -> Double? {
        guard let data: Data = try getData(index: index) else { return nil }
        if !metaData[index].isBinary, let str: String = String(bytes: data, encoding: String.Encoding.utf8) { return Double(str) }
        else { return nil }
    }

    /*===========================================================================================================================*/
    /// TODO: We're going to have to revisit this because we need a Swift version of Java's BigDecimal class.
    /// 
    /// - Parameter index: the column number.
    /// - Returns: an instance of Decimal or `nil` if the column had a NULL value.
    /// - Throws: if an error occurs.
    ///
    func getBigDecimal(index: Int) throws -> Decimal? {
        guard let data: Data = try getData(index: index) else { return nil }
        if !metaData[index].isBinary, let str: String = String(bytes: data, encoding: String.Encoding.utf8) {
            if let dec: Decimal = Decimal(string: str) {
                return dec
            }
        }
        return nil
    }

    func getSmall(index: Int) throws -> Int32? {
        guard let data: Data = try getData(index: index) else { return nil }
        if !metaData[index].isBinary, let str: String = String(bytes: data, encoding: String.Encoding.utf8) { return Int32(str) }
        else { return nil }
    }

    func getUShort(index: Int) throws -> UInt16? {
        guard let data: Data = try getData(index: index) else { return nil }
        if !metaData[index].isBinary, let str: String = String(bytes: data, encoding: String.Encoding.utf8) { return UInt16(str) }
        else { return nil }
    }

    func getUSmall(index: Int) throws -> UInt32? {
        guard let data: Data = try getData(index: index) else { return nil }
        if !metaData[index].isBinary, let str: String = String(bytes: data, encoding: String.Encoding.utf8) { return UInt32(str) }
        else { return nil }
    }

    func getUInt(index: Int) throws -> UInt? {
        guard let data: Data = try getData(index: index) else { return nil }
        if !metaData[index].isBinary, let str: String = String(bytes: data, encoding: String.Encoding.utf8) { return UInt(str) }
        else { return nil }
    }

    func getULong(index: Int) throws -> UInt64? {
        guard let data: Data = try getData(index: index) else { return nil }
        if !metaData[index].isBinary, let str: String = String(bytes: data, encoding: String.Encoding.utf8) { return UInt64(str) }
        else { return nil }
    }

    func getBigUInt(index: Int) throws -> BigUInt? {
        guard let data: Data = try getData(index: index) else { return nil }
        if !metaData[index].isBinary, let str: String = String(bytes: data, encoding: String.Encoding.utf8) { return BigUInt(str) }
        else { return nil }
    }
}

extension MySQLResultSet {
    @inlinable func _getData(index: Int) throws -> Data? {
        guard !isClosed else { throw DBError.ResultSetClosed }
        guard wasNextCalled else { throw DBError.ResultSet(description: "hasNextRow() was never called.") }
        guard index >= 0 && index < metaData.columnCount else { throw DBError.ResultSet(description: "Index out of bounds.") }
        guard let row: MySQLRow = currentRow else { throw DBError.ResultSet(description: "No more rows.") }
        return row.columns[index]
    }

    @inlinable func _getString(index: Int) throws -> String? {
        guard let data: Data = try _getData(index: index) else { return nil }
        return representableAsText(dataType: metaData[index].dataType) ? String(bytes: data, encoding: String.Encoding.utf8) : nil
    }
}

/*===============================================================================================================================*/
/// A class that holds one row of data returned by the database.
///
class MySQLRow {

    /*===========================================================================================================================*/
    /// MySQL sends us data as `nil`-terminated C strings unless the underlying type is binary, varbinary, or blob in which case we
    /// have to depend on the lengths that the system reported to us. We will just assume that they are all binary fields and
    /// convert them to strings as needed.
    ///
    var columns: [Data?] = []

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
            columns.append((cData == nil) ? nil : getData(bytes: cData!, length: Int(lengths[i])))
        }
    }
}
