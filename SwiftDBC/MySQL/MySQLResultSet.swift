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

class MySQLResultSet: DBResultSet {
    var isClosed: Bool       = false
    var rawData:  [MySQLRow] = []
    let stmt:     MySQLStatement
    let rs:       UnsafeMutablePointer<MYSQL_RES>

    init(_ stmt: MySQLStatement, _ rs: UnsafeMutablePointer<MYSQL_RES>) throws {
        self.stmt = stmt
        self.rs = rs

        NotificationCenter.default.addObserver(forName: DBStatementWillClose, object: self.stmt, queue: nil) {
            [weak self] (notice: Notification) in
            if let _self: MySQLResultSet = self { _self.close() }
        }

        let numFields: Int        = Int(mysql_num_fields(rs))
        var row:       MYSQL_ROW? = mysql_fetch_row(self.rs)

        defer {
            while let _ = row { row = mysql_fetch_row(self.rs) }
            mysql_free_result(self.rs)
        }

        for fieldNum in (0 ..< numFields) {
            if let f: UnsafeMutablePointer<MYSQL_FIELD> = mysql_fetch_field_direct(rs, UInt32(fieldNum)) {
            }
        }

        while let _row: MYSQL_ROW = row {
            if let lens: UnsafeMutablePointer<UInt> = mysql_fetch_lengths(rs) {
                let rawRow = MySQLRow(row: _row, lengths: lens, colCount: numFields)
                rawData.append(rawRow)
            }
            row = mysql_fetch_row(self.rs)
        }
    }

    deinit {
        close()
    }

    func close() {
        if !isClosed {
            // Tell anyone who depends on this result set that it is closing.
            NotificationCenter.default.post(name: DBResultSetWillClose, object: self)
            // Then close.
            isClosed = true
        }
    }

    private(set) var metaData: DBResultSetMetaData

    func next() throws -> Bool { fatalError("next() has not been implemented") }

    func getString(index: Int) throws -> String? { fatalError("getString(index:) has not been implemented") }

    func getString(name: String) throws -> String? { fatalError("getString(name:) has not been implemented") }

    func getByte(index: Int) throws -> Int8? { fatalError("getByte(index:) has not been implemented") }

    func getByte(name: String) throws -> Int8? { fatalError("getByte(name:) has not been implemented") }

    func getShort(index: Int) throws -> Int16? { fatalError("getShort(index:) has not been implemented") }

    func getShort(name: String) throws -> Int16? { fatalError("getShort(name:) has not been implemented") }

    func getInt(index: Int) throws -> Int? { fatalError("getInt(index:) has not been implemented") }

    func getInt(name: String) throws -> Int? { fatalError("getInt(name:) has not been implemented") }

    func getLong(index: Int) throws -> Int64? { fatalError("getLong(index:) has not been implemented") }

    func getLong(name: String) throws -> Int64? { fatalError("getLong(name:) has not been implemented") }

    func getBigInt(index: Int) throws -> BigInt? { fatalError("getBigInt(index:) has not been implemented") }

    func getBitInt(name: String) throws -> BigInt? { fatalError("getBitInt(name:) has not been implemented") }

    func getBool(index: Int) throws -> String? { fatalError("getBool(index:) has not been implemented") }

    func getBool(name: String) throws -> String? { fatalError("getBool(name:) has not been implemented") }
}

@inlinable func testFlag(fieldValue: UInt32, flag: Int32) -> Bool { ((fieldValue & UInt32(flag)) == UInt32(flag)) }

@inlinable func getString(cStr: UnsafeMutablePointer<Int8>) -> String { String(cString: cStr, encoding: String.Encoding.utf8) ?? "" }

class MySQLResultSetMetaData: DBResultSetMetaData {

    private(set) var columnCount:     Int         = 0
    private(set) var name:            [String]    = []
    private(set) var orgName:         [String]    = []
    private(set) var tableName:       [String]    = []
    private(set) var orgTableName:    [String]    = []
    private(set) var database:        [String]    = []
    private(set) var catalog:         [String]    = []
    private(set) var length:          [UInt]      = []
    private(set) var maxLength:       [UInt]      = []
    private(set) var isNullable:      [Bool]      = []
    private(set) var hasDefault:      [Bool]      = []
    private(set) var isAutoIncrement: [Bool]      = []
    private(set) var isUnsigned:      [Bool]      = []
    private(set) var isPrimaryKey:    [Bool]      = []
    private(set) var isUniqueKey:     [Bool]      = []
    private(set) var isIndexed:       [Bool]      = []
    private(set) var dataType:        [DataTypes] = []
    private(set) var charSetId:       [Int]       = []
    private(set) var decimalCount:    [Int]       = []

    init(rs: UnsafeMutablePointer<MYSQL_RES>) {
        self.columnCount = Int(mysql_num_fields(rs))

        for idx: Int in (0 ..< self.columnCount) {
            if let f: UnsafeMutablePointer<MYSQL_FIELD> = mysql_fetch_field_direct(rs, UInt32(idx)) {
                let fld:   MYSQL_FIELD = f.pointee
                let chrId: Int         = Int(fld.charsetnr)

                charSetId.append(chrId)
                length.append(UInt(fld.length))
                maxLength.append(UInt(fld.max_length))
                decimalCount.append(Int(fld.decimals))
                isNullable.append(!testFlag(fieldValue: fld.flags, flag: NOT_NULL_FLAG))
                hasDefault.append(!testFlag(fieldValue: fld.flags, flag: NO_DEFAULT_VALUE_FLAG))
                isUnsigned.append(testFlag(fieldValue: fld.flags, flag: UNSIGNED_FLAG))
                isPrimaryKey.append(testFlag(fieldValue: fld.flags, flag: PRI_KEY_FLAG))
                isUniqueKey.append(testFlag(fieldValue: fld.flags, flag: UNIQUE_KEY_FLAG))
                isIndexed.append(testFlag(fieldValue: fld.flags, flag: MULTIPLE_KEY_FLAG))
                dataType.append(getDataType(id: fld.type, charSetId: chrId))

                name.append(getString(cStr: fld.name))
                orgName.append(getString(cStr: fld.org_name))
                tableName.append(getString(cStr: fld.table))
                orgTableName.append(getString(cStr: fld.org_table))
                database.append(getString(cStr: fld.db))
                catalog.append(getString(cStr: fld.catalog))
            }
        }
    }

    private func getDataType(id: enum_field_types, charSetId: Int) -> DataTypes {
        //---------------------------------------------
        // Try to get as close to a match as possible.
        //---------------------------------------------
        switch id { //@f:0
            case MYSQL_TYPE_STRING    : return charSetId == 63 ? DataTypes.Binary    : DataTypes.Char    // CHAR or BINARY field
            case MYSQL_TYPE_VAR_STRING: return charSetId == 63 ? DataTypes.VarBinary : DataTypes.VarChar // VARCHAR or VARBINARY field
            case MYSQL_TYPE_BLOB      : return charSetId == 63 ? DataTypes.Blob      : DataTypes.Clob    // BLOB or TEXT field (use max_length to determine the maximum length)
            case MYSQL_TYPE_TINY      : return DataTypes.TinyInt   // TINYINT field
            case MYSQL_TYPE_SHORT     : return DataTypes.SmallInt  // SMALLINT field
            case MYSQL_TYPE_LONG      : return DataTypes.Integer   // INTEGER field
            case MYSQL_TYPE_INT24     : return DataTypes.Integer   // MEDIUMINT field
            case MYSQL_TYPE_LONGLONG  : return DataTypes.BigInt    // BIGINT field
            case MYSQL_TYPE_DECIMAL   : return DataTypes.Decimal   // DECIMAL or NUMERIC field
            case MYSQL_TYPE_NEWDECIMAL: return DataTypes.Decimal   // Precision math DECIMAL or NUMERIC
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
}

class MySQLRow {

    init(row: MYSQL_ROW, lengths: UnsafeMutablePointer<UInt>, colCount: Int) {
    }
}
