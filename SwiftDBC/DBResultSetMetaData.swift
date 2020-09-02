/************************************************************************//**
 *     PROJECT: SwiftDBC
 *    FILENAME: DBResultSetMetaData.swift
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

/*===============================================================================================================================*/
/// An object that can be used to get information about the types and properties of the columns in a `DBResultSet` object. The
/// following code fragment creates the `DBResultSet` object rs, creates the `DBResultSetMetaData` object rsmd, and uses rsmd to
/// find out how many columns rs has and whether the first column in rs can hold a `NULL` value.
/// 
/// <pre>
///      let rs: DBResultSet = stmt.executeQuery(sql: "SELECT a, b, c FROM TABLE2")
///      let rsmd: DBResultSetMetaData = rs.metaData
///      let numberOfColumns: Int = rsmd.columnCount
///      let b: Bool = rsmd[0].isNullable
/// </pre>
///
public protocol DBResultSetMetaData: AnyObject {

    var columnCount: Int { get }

    subscript(name: String) -> DBColumnMetaData? { get }
    subscript(index: Int) -> DBColumnMetaData { get }
}

public protocol DBColumnMetaData: AnyObject {
    var index:           Int { get }
    var dataType:        DataTypes { get }
    var name:            String { get }
    var orgName:         String { get }
    var tableName:       String { get }
    var orgTableName:    String { get }
    var database:        String { get }
    var catalog:         String { get }
    var length:          UInt { get }
    var maxLength:       UInt { get }
    var decimalCount:    UInt { get }
    var hasDefault:      Bool { get }
    var isAutoIncrement: Bool { get }
    var isBinary:        Bool { get }
    var isIndexed:       Bool { get }
    var isNullable:      Bool { get }
    var isNumeric:       Bool { get }
    var isPrimaryKey:    Bool { get }
    var isReadOnly:      Bool { get }
    var isUniqueKey:     Bool { get }
    var isUnsigned:      Bool { get }
    var isText:          Bool { get }
    var isDate:          Bool { get }
}

public extension DBColumnMetaData {
    @inlinable var isBinary:  Bool { isType(dataType, inTypes: .Binary, .Blob, .LongVarBinary, .VarBinary) }
    @inlinable var isNumeric: Bool { isType(dataType, inTypes: .Boolean, .Bit, .BigInt, .Decimal, .Double, .Float, .Integer, .Numeric, .Real, .SmallInt, .TinyInt) }
    @inlinable var isText:    Bool { isType(dataType, inTypes: .Char, .Clob, .LongNVarChar, .LongVarChar, .NChar, .NClob, .NVarChar, .VarChar) }
    @inlinable var isDate:    Bool { isType(dataType, inTypes: .Date, .Time, .TimeWithTimeZone, .TimeStamp, .TimeStampWithTimeZone) }
}
