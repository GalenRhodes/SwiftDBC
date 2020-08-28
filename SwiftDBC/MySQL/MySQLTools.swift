/************************************************************************//**
 *     PROJECT: SwiftDBC
 *    FILENAME: MySQLTools.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 8/28/20
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

let DBConnectionWillClose = Notification.Name("DBConnectionWillClose")
let DBStatementWillClose  = Notification.Name("DBStatementWillClose")
let DBResultSetWillClose  = Notification.Name("DBResultSetWillClose")

let MySQLDefaultCharacterSet: String = "utf8mb4"
let MySQLDBCPrefix:           String = "\(SwiftDBCPrefix):mysql"

@inlinable func _get(str: String, result: NSTextCheckingResult, group: Int) -> String? { ((group < result.numberOfRanges) ? str.substringWith(nsRange: result.range(at: group)) : nil) }

@inlinable func testFlag(fieldValue: UInt32, flag: Int32) -> Bool {
    let i: UInt32 = UInt32(flag)
    return ((fieldValue & i) == i)
}

@inlinable func getString(cStr: UnsafeMutablePointer<Int8>) -> String {
    String(cString: UnsafePointer<CChar>(cStr), encoding: String.Encoding.utf8) ?? ""
}

func getDataType(id: enum_field_types, charSetId: Int, decDigits dc: UInt) -> DataTypes {
    //---------------------------------------------
    // Try to get as close to a match as possible.
    //---------------------------------------------
    switch id { //@f:0
        case MYSQL_TYPE_STRING    : return charSetId == 63 ? DataTypes.Binary    : DataTypes.Char    // CHAR or BINARY field
        case MYSQL_TYPE_VAR_STRING: return charSetId == 63 ? DataTypes.VarBinary : DataTypes.VarChar // VARCHAR or VARBINARY field
        case MYSQL_TYPE_BLOB      : return charSetId == 63 ? DataTypes.Blob      : DataTypes.Clob    // BLOB or TEXT field (use max_length to determine the maximum length)
        case MYSQL_TYPE_DECIMAL   : return dc == 0         ? DataTypes.BigInt    : DataTypes.Decimal // DECIMAL or NUMERIC field
        case MYSQL_TYPE_NEWDECIMAL: return dc == 0         ? DataTypes.BigInt    : DataTypes.Decimal // Precision math DECIMAL or NUMERIC
        case MYSQL_TYPE_TINY      : return DataTypes.TinyInt   // TINYINT field
        case MYSQL_TYPE_SHORT     : return DataTypes.SmallInt  // SMALLINT field
        case MYSQL_TYPE_LONG      : return DataTypes.Integer   // INTEGER field
        case MYSQL_TYPE_INT24     : return DataTypes.Integer   // MEDIUMINT field
        case MYSQL_TYPE_LONGLONG  : return DataTypes.BigInt    // BIGINT field
        case MYSQL_TYPE_FLOAT     : return DataTypes.Float     // FLOAT field
        case MYSQL_TYPE_DOUBLE    : return DataTypes.Double    // DOUBLE or REAL field
        case MYSQL_TYPE_BIT       : return DataTypes.Bit       // BIT field
        case MYSQL_TYPE_TIMESTAMP : return DataTypes.TimeStamp // TIMESTAMP field
        case MYSQL_TYPE_DATE      : return DataTypes.Date      // DATE field
        case MYSQL_TYPE_TIME      : return DataTypes.Time      // TIME field
        case MYSQL_TYPE_DATETIME  : return DataTypes.TimeStamp // DATETIME field
        case MYSQL_TYPE_YEAR      : return DataTypes.Date      // YEAR field
        case MYSQL_TYPE_SET       : return DataTypes.VarChar   // SET field
        case MYSQL_TYPE_ENUM      : return DataTypes.VarChar   // ENUM field
        case MYSQL_TYPE_GEOMETRY  : return DataTypes.Other     // Spatial field
        case MYSQL_TYPE_NULL      : return DataTypes.Null      // NULL-type field
        default                   : return DataTypes.VarChar   // VARCHAR field
    } //@f:1
}

let _regexPfx:           String = NSRegularExpression.escapedPattern(for: MySQLDBCPrefix)
let _regexHostNameLabel: String = "(?:[^.:?/]+)"
let _regexHostName:      String = "\(_regexHostNameLabel)(?:\\.\(_regexHostNameLabel))*"
let _regexIpNumber:      String = "(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2(?:[0-4][0-9]|5[0-5]))"
let _regexIpAddress:     String = "\(_regexIpNumber)(?:\\.\(_regexIpNumber)){3}"
let _regexPort:          String = "(?:0|[1-9]|[1-9][0-9]{1,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])"
let _regexCredentials:   String = "([^:@]+)(?:\\:([^@]+))?@"

/*===============================================================================================================================*/
/// - Group 1: username
/// - Group 2: password
/// - Group 3: host name/ip address
/// - Group 4: port
/// - Group 5: path
/// - Group 6: query
///
let _regexUrl:           String = "(?:\(_regexPfx):)(?://)?(?:\(_regexCredentials))?((?:\(_regexIpAddress))|(?:\(_regexHostName)))(?:\\:(\(_regexPort)))?(/[^?]*)?(?:\\?(.+))?"
