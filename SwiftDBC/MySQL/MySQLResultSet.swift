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
    let metaData: DBResultSetMetaData

    init(_ stmt: MySQLStatement, _ rs: UnsafeMutablePointer<MYSQL_RES>) throws {
        self.stmt = stmt
        self.rs = rs
        self.metaData = MySQLResultSetMetaData(rs: rs)

        NotificationCenter.default.addObserver(forName: DBStatementWillClose, object: self.stmt, queue: nil) {
            [weak self] (notice: Notification) in
            if let _self: MySQLResultSet = self { _self.close() }
        }

        let numFields: Int        = Int(mysql_num_fields(rs))
        var row:       MYSQL_ROW? = mysql_fetch_row(rs)

        defer {
            while let _ = row { row = mysql_fetch_row(rs) }
            mysql_free_result(rs)
        }

        while let _row: MYSQL_ROW = row {
            if let lens: UnsafeMutablePointer<UInt> = mysql_fetch_lengths(rs) {
                let rawRow = MySQLRow(row: _row, lengths: lens, colCount: numFields)
                rawData.append(rawRow)
            }
            row = mysql_fetch_row(rs)
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

    func getBigInt(name: String) throws -> BigInt? { fatalError("getBigInt(name:) has not been implemented") }

    func getBool(index: Int) throws -> String? { fatalError("getBool(index:) has not been implemented") }

    func getBool(name: String) throws -> String? { fatalError("getBool(name:) has not been implemented") }

    func getDate(index: Int) throws -> Date? { fatalError("getDate(index:) has not been implemented") }

    func getDate(name: String) throws -> Date? { fatalError("getDate(name:) has not been implemented") }

    func getTime(index: Int) throws -> Date? { fatalError("getTime(index:) has not been implemented") }

    func getTime(name: String) throws -> Date? { fatalError("getTime(name:) has not been implemented") }

    func getTimestamp(index: Int) throws -> Date? { fatalError("getTimestamp(index:) has not been implemented") }

    func getTimestamp(name: String) throws -> Date? { fatalError("getTimestamp(name:) has not been implemented") }

    func getFloat(index: Int) throws -> Float? { fatalError("getFloat(index:) has not been implemented") }

    func getFloat(name: String) throws -> Float? { fatalError("getFloat(name:) has not been implemented") }

    func getDouble(index: Int) throws -> Double? { fatalError("getDouble(index:) has not been implemented") }

    func getDouble(name: String) throws -> Double? { fatalError("getDouble(name:) has not been implemented") }

    func getBigDecimal(index: Int) throws -> Decimal? { fatalError("getBigDecimal(index:) has not been implemented") }

    func getBigDecimal(name: String) throws -> Decimal? { fatalError("getBigDecimal(name:) has not been implemented") }

    func getSmall(index: Int) throws -> Int32? { fatalError("getSmall(index:) has not been implemented") }

    func getSmall(name: String) throws -> Int32? { fatalError("getSmall(name:) has not been implemented") }

    func getUByte(index: Int) throws -> UInt8? { fatalError("getUByte(index:) has not been implemented") }

    func getUByte(name: String) throws -> UInt8? { fatalError("getUByte(name:) has not been implemented") }

    func getUShort(index: Int) throws -> UInt16? { fatalError("getUShort(index:) has not been implemented") }

    func getUShort(name: String) throws -> UInt16? { fatalError("getUShort(name:) has not been implemented") }

    func getUSmall(index: Int) throws -> UInt32? { fatalError("getUSmall(index:) has not been implemented") }

    func getUSmall(name: String) throws -> UInt32? { fatalError("getUSmall(name:) has not been implemented") }

    func getUInt(index: Int) throws -> UInt? { fatalError("getUInt(index:) has not been implemented") }

    func getUInt(name: String) throws -> UInt? { fatalError("getUInt(name:) has not been implemented") }

    func getULong(index: Int) throws -> UInt64? { fatalError("getULong(index:) has not been implemented") }

    func getULong(name: String) throws -> UInt64? { fatalError("getULong(name:) has not been implemented") }

    func getUBigInt(index: Int) throws -> BigUInt? { fatalError("getUBigInt(index:) has not been implemented") }

    func getUBigInt(name: String) throws -> BigUInt? { fatalError("getUBigInt(name:) has not been implemented") }
}

class MySQLColumnMetaData: DBColumnMetaData {
    let index:           Int
    let dataType:        DataTypes
    let name:            String
    let orgName:         String
    let tableName:       String
    let orgTableName:    String
    let database:        String
    let catalog:         String
    let length:          UInt
    let maxLength:       UInt
    let decimalCount:    UInt
    let isNullable:      Bool
    let hasDefault:      Bool
    let isAutoIncrement: Bool
    let isUnsigned:      Bool
    let isPrimaryKey:    Bool
    let isUniqueKey:     Bool
    let isIndexed:       Bool
    let isReadOnly:      Bool
    let charSetId:       Int

    init(index idx: Int) {
        catalog = ""
        charSetId = 0
        dataType = .VarChar
        database = ""
        decimalCount = 0
        hasDefault = false
        index = idx
        isAutoIncrement = false
        isIndexed = false
        isNullable = true
        isPrimaryKey = false
        isReadOnly = false
        isUniqueKey = false
        isUnsigned = false
        length = 0
        maxLength = 0
        name = ""
        orgName = ""
        orgTableName = ""
        tableName = ""
    }

    init(field fld: MYSQL_FIELD, index idx: Int) {
        let flags: UInt32 = fld.flags

        catalog = getString(cStr: fld.catalog)
        charSetId = Int(fld.charsetnr)
        decimalCount = UInt(fld.decimals)
        dataType = getDataType(id: fld.type, charSetId: charSetId, decDigits: decimalCount)
        database = getString(cStr: fld.db)
        hasDefault = !testFlag(fieldValue: flags, flag: NO_DEFAULT_VALUE_FLAG)
        index = idx
        isAutoIncrement = testFlag(fieldValue: flags, flag: AUTO_INCREMENT_FLAG)
        isIndexed = testFlag(fieldValue: flags, flag: MULTIPLE_KEY_FLAG)
        isNullable = !testFlag(fieldValue: flags, flag: NOT_NULL_FLAG)
        isPrimaryKey = testFlag(fieldValue: flags, flag: PRI_KEY_FLAG)
        isReadOnly = false
        isUniqueKey = testFlag(fieldValue: flags, flag: UNIQUE_KEY_FLAG)
        isUnsigned = testFlag(fieldValue: flags, flag: UNSIGNED_FLAG)
        length = UInt(fld.length)
        maxLength = UInt(fld.max_length)
        name = getString(cStr: fld.name)
        orgName = getString(cStr: fld.org_name)
        orgTableName = getString(cStr: fld.org_table)
        tableName = getString(cStr: fld.table)
    }
}

class MySQLResultSetMetaData: DBResultSetMetaData {

    let columnCount: Int
    var columnInfo:  [MySQLColumnMetaData] = []

    init(rs: UnsafeMutablePointer<MYSQL_RES>) {
        columnCount = Int(mysql_num_fields(rs))

        for i in (0 ..< columnCount) {
            if let fld: UnsafeMutablePointer<MYSQL_FIELD> = mysql_fetch_field_direct(rs, UInt32(i)) {
                columnInfo.append(MySQLColumnMetaData(field: fld.pointee, index: i))
            }
            else {
                columnInfo.append(MySQLColumnMetaData(index: i))
            }
        }
    }

    subscript(name: String) -> DBColumnMetaData? { fatalError("subscript(_:) has not been implemented") }
    subscript(index: Int) -> DBColumnMetaData { fatalError("subscript(_:) has not been implemented") }
}

class MySQLRow {

    init(row: MYSQL_ROW, lengths: UnsafeMutablePointer<UInt>, colCount: Int) {
    }
}
