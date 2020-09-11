/************************************************************************//**
 *     PROJECT: SwiftDBC
 *    FILENAME: MySQLColumn.swift
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
import BigInt

class MySQLColumn: DBColumn {

    let            row:      DBRow
    let            metaData: DBColumnMetaData
    let            asData:   Data?
    @inlinable var asString: String? { getString(encode: true) }
    @inlinable var isNull:   Bool { asData == nil }

    init(_ row: DBRow, _ data: Data?, _ metaData: DBColumnMetaData) {
        self.row = row
        self.asData = data
        self.metaData = metaData
    }

    func getString(encode: Bool = true) -> String? {
        guard let data: Data = asData else { return nil }
        switch metaData.dataType {
            case .Blob, .Binary, .VarBinary, .LongVarBinary: return (encode ? data.base64EncodedString() : nil)
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

    var asInputStream: InputStream? {
        guard let data: Data = asData else { return nil }
        return InputStream(data: data)
    }

    var asByte: UInt8? {
        guard let data = asData else { return nil }
        if metaData.isBinary { return data.count > 0 ? data[0] : nil }
        else if let str: String = getString(encode: false) { return UInt8(str) }
        return nil
    }

    var asShort: Int16? {
        if let str: String = getString(encode: false) { return Int16(str) }
        return nil
    }

    var asInt: Int? {
        if let str: String = getString(encode: false) { return Int(str) }
        return nil
    }

    var asLong: Int64? {
        if let str: String = getString(encode: false) { return Int64(str) }
        return nil
    }

    var asBigInt: BigInt? {
        if let str: String = getString(encode: false) { return BigInt(str) }
        return nil
    }

    var asBool: Bool? {
        if let s: String = getString(encode: false) {
            if metaData.isNumeric {
                if let b: Int64 = Int64(s) { return (b != 0) }
                else if let b: Double = Double(s) { return (b != 0.0) }
            }
            else if let rx: NSRegularExpression = try? NSRegularExpression(pattern: "^\\s*(true|yes|y|t|on)\\s*$", options: [ NSRegularExpression.Options.caseInsensitive ]) {
                return (rx.matches(in: s).count == 1)
            }
        }
        return nil
    }

    var asDate: Date? {
        guard let s: String = getString(encode: false) else { return nil }
        return DateFormatter(format: "yyyy-MM-dd").date(from: s)
    }

    var asTime: Date? {
        guard let s: String = getString(encode: false) else { return nil }
        return DateFormatter(format: "HH:mm:ssZZZZZ").date(from: s)
    }

    var asTimestamp: Date? {
        guard let s: String = getString(encode: false) else { return nil }
        return DateFormatter(format: "yyyy-MM-dd HH:mm:ssZZZZZ").date(from: s)
    }

    var asFloat: Float? {
        if let str: String = getString(encode: false) { return Float(str) }
        return nil
    }

    var asDouble: Double? {
        if let str: String = getString(encode: false) { return Double(str) }
        return nil
    }

    var asBigDecimal: Decimal? {
        if let str: String = getString(encode: false) { return Decimal(string: str) }
        return nil
    }

    var asSmall: Int32? {
        if let str: String = getString(encode: false) { return Int32(str) }
        return nil
    }

    var asUShort: UInt16? {
        if let str: String = getString(encode: false) { return UInt16(str) }
        return nil
    }

    var asUSmall: UInt32? {
        if let str: String = getString(encode: false) { return UInt32(str) }
        return nil
    }

    var asUInt: UInt? {
        if let str: String = getString(encode: false) { return UInt(str) }
        return nil
    }

    var asULong: UInt64? {
        if let str: String = getString(encode: false) { return UInt64(str) }
        return nil
    }

    var asBigUInt: BigUInt? {
        if let str: String = getString(encode: false) { return BigUInt(str) }
        return nil
    }
}
