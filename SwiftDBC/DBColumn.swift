/************************************************************************//**
 *     PROJECT: SwiftDBC
 *    FILENAME: DBColumn.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 9/3/20
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

public protocol DBColumn {
    var metaData:      DBColumnMetaData { get }
    var isNull:        Bool { get }
    var asData:        Data? { get }
    var asInputStream: InputStream? { get }
    var asDate:        Date? { get }
    var asTime:        Date? { get }
    var asTimestamp:   Date? { get }
    var asFloat:       Float? { get }
    var asDouble:      Double? { get }
    /*===========================================================================================================================*/
    /// TODO: We're going to have to revisit this because we need a Swift version of Java's BigDecimal class.
    /// 
    /// - Parameter index: the column number.
    /// - Returns: an instance of Decimal or `nil` if the column had a NULL value.
    /// - Throws: if an error occurs.
    ///
    var asBigDecimal:  Decimal? { get }
    var asBool:        Bool? { get }
    var asString:      String? { get }
    var asByte:        UInt8? { get }
    var asShort:       Int16? { get }
    var asSmall:       Int32? { get }
    var asInt:         Int? { get }
    var asLong:        Int64? { get }
    var asBigInt:      BigInt? { get }
    var asUShort:      UInt16? { get }
    var asUSmall:      UInt32? { get }
    var asUInt:        UInt? { get }
    var asULong:       UInt64? { get }
    var asBigUInt:     BigUInt? { get }
}

public extension DBColumn {
    var name:  String { metaData.name }
    var index: Int { metaData.index }
}
