/************************************************************************//**
 *     PROJECT: SwiftDBC
 *    FILENAME: DBResultSet.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 9/1/20
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
import BigInt

public enum DBNextResults {
    case None
    case ResultSet
    case UpdateCount
}

public protocol DBResultSet: Closable {

    var metaData: DBResultSetMetaData { get }

    func hasNextRow() throws -> Bool

    func getData(index: Int) throws -> Data?

    func getData(name: String) throws -> Data?

    func getInputStream(index: Int) throws -> InputStream?

    func getInputStream(name: String) throws -> InputStream?

    func getDate(index: Int) throws -> Date?

    func getDate(name: String) throws -> Date?

    func getTime(index: Int) throws -> Date?

    func getTime(name: String) throws -> Date?

    func getTimestamp(index: Int) throws -> Date?

    func getTimestamp(name: String) throws -> Date?

    func getFloat(index: Int) throws -> Float?

    func getFloat(name: String) throws -> Float?

    func getDouble(index: Int) throws -> Double?

    func getDouble(name: String) throws -> Double?

    /*===========================================================================================================================*/
    /// TODO: We're going to have to revisit this because we need a Swift version of Java's BigDecimal class.
    /// 
    /// - Parameter index: the column number.
    /// - Returns: an instance of Decimal or `nil` if the column had a NULL value.
    /// - Throws: if an error occurs.
    ///
    func getBigDecimal(index: Int) throws -> Decimal?

    /*===========================================================================================================================*/
    /// TODO: We're going to have to revisit this because we need a Swift version of Java's BigDecimal class.
    /// 
    /// - Parameter name: the column name.
    /// - Returns: an instance of Decimal or `nil` if the column had a NULL value.
    /// - Throws: if an error occurs.
    ///
    func getBigDecimal(name: String) throws -> Decimal?

    func getBool(index: Int) throws -> Bool?

    func getBool(name: String) throws -> Bool?

    func getString(index: Int) throws -> String?

    func getString(name: String) throws -> String?

    func getByte(index: Int) throws -> UInt8?

    func getByte(name: String) throws -> UInt8?

    func getShort(index: Int) throws -> Int16?

    func getShort(name: String) throws -> Int16?

    func getSmall(index: Int) throws -> Int32?

    func getSmall(name: String) throws -> Int32?

    func getInt(index: Int) throws -> Int?

    func getInt(name: String) throws -> Int?

    func getLong(index: Int) throws -> Int64?

    func getLong(name: String) throws -> Int64?

    func getBigInt(index: Int) throws -> BigInt?

    func getBigInt(name: String) throws -> BigInt?

    func getUShort(index: Int) throws -> UInt16?

    func getUShort(name: String) throws -> UInt16?

    func getUSmall(index: Int) throws -> UInt32?

    func getUSmall(name: String) throws -> UInt32?

    func getUInt(index: Int) throws -> UInt?

    func getUInt(name: String) throws -> UInt?

    func getULong(index: Int) throws -> UInt64?

    func getULong(name: String) throws -> UInt64?

    func getBigUInt(index: Int) throws -> BigUInt?

    func getBigUInt(name: String) throws -> BigUInt?
}

public extension DBResultSet {

    @inlinable func getIndexFor(name: String) throws -> Int {
        guard let index: Int = metaData[name]?.index else { throw DBError.ResultSet(description: "Column \"\(name)\" not found.") }
        return index
    }

    func getData(name: String) throws -> Data? { try getData(index: try getIndexFor(name: name)) }

    func getInputStream(name: String) throws -> InputStream? { try getInputStream(index: try getIndexFor(name: name)) }

    func getString(name: String) throws -> String? { try getString(index: try getIndexFor(name: name)) }

    func getByte(name: String) throws -> UInt8? { try getByte(index: try getIndexFor(name: name)) }

    func getShort(name: String) throws -> Int16? { try getShort(index: try getIndexFor(name: name)) }

    func getInt(name: String) throws -> Int? { try getInt(index: try getIndexFor(name: name)) }

    func getLong(name: String) throws -> Int64? { try getLong(index: try getIndexFor(name: name)) }

    func getBigInt(name: String) throws -> BigInt? { try getBigInt(index: try getIndexFor(name: name)) }

    func getBool(name: String) throws -> Bool? { try getBool(index: try getIndexFor(name: name)) }

    func getDate(name: String) throws -> Date? { try getDate(index: try getIndexFor(name: name)) }

    func getTime(name: String) throws -> Date? { try getTime(index: try getIndexFor(name: name)) }

    func getTimestamp(name: String) throws -> Date? { try getTimestamp(index: try getIndexFor(name: name)) }

    func getFloat(name: String) throws -> Float? { try getFloat(index: try getIndexFor(name: name)) }

    func getDouble(name: String) throws -> Double? { try getDouble(index: try getIndexFor(name: name)) }

    /*===========================================================================================================================*/
    /// TODO: We're going to have to revisit this because we need a Swift version of Java's BigDecimal class.
    /// 
    /// - Parameter name: the column name.
    /// - Returns: an instance of Decimal or `nil` if the column had a NULL value.
    /// - Throws: if an error occurs.
    ///
    func getBigDecimal(name: String) throws -> Decimal? { try getBigDecimal(index: try getIndexFor(name: name)) }

    func getSmall(name: String) throws -> Int32? { try getSmall(index: try getIndexFor(name: name)) }

    func getUShort(name: String) throws -> UInt16? { try getUShort(index: try getIndexFor(name: name)) }

    func getUSmall(name: String) throws -> UInt32? { try getUSmall(index: try getIndexFor(name: name)) }

    func getUInt(name: String) throws -> UInt? { try getUInt(index: try getIndexFor(name: name)) }

    func getULong(name: String) throws -> UInt64? { try getULong(index: try getIndexFor(name: name)) }

    func getBigUInt(name: String) throws -> BigUInt? { try getBigUInt(index: try getIndexFor(name: name)) }
}
