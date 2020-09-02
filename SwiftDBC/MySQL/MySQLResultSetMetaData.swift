/************************************************************************//**
 *     PROJECT: SwiftDBC
 *    FILENAME: MySQLResultSetMetaData.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 8/30/20
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

class MySQLResultSetMetaData: DBResultSetMetaData {

    let columnCount: Int
    var columnInfo:  [MySQLColumnMetaData]         = []
    var columnMap:   [String: MySQLColumnMetaData] = [:]

    init(rs: UnsafeMutablePointer<MYSQL_RES>) {
        columnCount = Int(mysql_num_fields(rs))

        for i: Int in (0 ..< columnCount) {
            if let fld: UnsafeMutablePointer<MYSQL_FIELD> = mysql_fetch_field_direct(rs, UInt32(i)) {
                let col = MySQLColumnMetaData(field: fld.pointee, index: i)
                columnInfo.append(col)
                columnMap[col.name.uppercased()] = col
            }
            else {
                columnInfo.append(MySQLColumnMetaData(index: i))
            }
        }
    }

    @inlinable subscript(name: String) -> DBColumnMetaData? { columnMap[name.uppercased()] }

    @inlinable subscript(index: Int) -> DBColumnMetaData { columnInfo[index] }
}

class MySQLColumnMetaData: DBColumnMetaData {

    let charSetId:       Int
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
    let hasDefault:      Bool
    let isAutoIncrement: Bool
    let isIndexed:       Bool
    let isNullable:      Bool
    let isPrimaryKey:    Bool
    let isReadOnly:      Bool
    let isUniqueKey:     Bool
    let isUnsigned:      Bool

    init(index idx: Int) {
        // @f:0
        index           = idx
        charSetId       = 0
        dataType        = .VarChar

        name            = ""
        orgName         = ""
        tableName       = ""
        orgTableName    = ""
        catalog         = ""
        database        = ""

        length          = 0
        maxLength       = 0
        decimalCount    = 0

        hasDefault      = false
        isAutoIncrement = false
        isIndexed       = false
        isNullable      = true
        isPrimaryKey    = false
        isReadOnly      = false
        isUniqueKey     = false
        isUnsigned      = false
        // @f:1
    }

    init(field fld: MYSQL_FIELD, index idx: Int) {
        let _flags:         UInt32           = fld.flags
        let _dataType:      enum_field_types = fld.type
        let _charSetId:     Int              = Int(fld.charsetnr)
        let _decimalDigits: UInt             = UInt(fld.decimals)

        // @f:0
        index           = idx
        charSetId       = _charSetId
        decimalCount    = _decimalDigits
        isReadOnly      = false
        dataType        = getDataType(id: _dataType, charSetId: _charSetId, decDigits: _decimalDigits)

        name            = getString(cStr: fld.name,      length: Int(fld.name_length)     )
        orgName         = getString(cStr: fld.org_name,  length: Int(fld.org_name_length) )
        tableName       = getString(cStr: fld.table,     length: Int(fld.table_length)    )
        orgTableName    = getString(cStr: fld.org_table, length: Int(fld.org_table_length))
        catalog         = getString(cStr: fld.catalog,   length: Int(fld.catalog_length)  )
        database        = getString(cStr: fld.db,        length: Int(fld.db_length)       )

        length          = UInt(fld.length    )
        maxLength       = UInt(fld.max_length)

        hasDefault      = !testFlag(fieldValue: _flags, flag: NO_DEFAULT_VALUE_FLAG)
        isNullable      = !testFlag(fieldValue: _flags, flag: NOT_NULL_FLAG        )
        isAutoIncrement =  testFlag(fieldValue: _flags, flag: AUTO_INCREMENT_FLAG  )
        isIndexed       =  testFlag(fieldValue: _flags, flag: MULTIPLE_KEY_FLAG    )
        isPrimaryKey    =  testFlag(fieldValue: _flags, flag: PRI_KEY_FLAG         )
        isUniqueKey     =  testFlag(fieldValue: _flags, flag: UNIQUE_KEY_FLAG      )
        isUnsigned      =  testFlag(fieldValue: _flags, flag: UNSIGNED_FLAG        )
        // @f:1
    }
}
