/************************************************************************//**
 *     PROJECT: SwiftDBC
 *    FILENAME: DataTypes.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 8/25/20
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
/// The labeled types below are currently supported in SwiftDBC. The types
/// '<code>[Array](https://developer.apple.com/documentation/swift/array/)</code>', `DataLink`, `Distinct`, `JavaObject`, `Ref`,
/// `RefCursor`, `RowId`, `SqlXml`, and `Struct` are mostly Oracle specific and don't have an equivalence in other databases. They
/// are not currently supported but may be in the future because of the HUGE popularity of Oracle.
///
public enum DataTypes {
    case Null                  // * - (denotes no datatype (MySQL considers it a numeric))

    case Boolean               // Numeric
    case Bit                   // Numeric
    case BigInt                // Numeric
    case Decimal               // Numeric
    case Double                // Numeric
    case Float                 // Numeric
    case Integer               // Numeric
    case Numeric               // Numeric
    case Real                  // Numeric
    case SmallInt              // Numeric
    case TinyInt               // Numeric

    case Char                  // Text
    case Clob                  // Text
    case LongNVarChar          // Text
    case LongVarChar           // Text
    case NChar                 // Text
    case NClob                 // Text
    case NVarChar              // Text
    case VarChar               // Text

    case Date                  // Date/Time
    case Time                  // Date/Time
    case TimeWithTimeZone      // Date/Time
    case TimeStamp             // Date/Time
    case TimeStampWithTimeZone // Date/Time

    case Binary                // Binary
    case Blob                  // Binary
    case LongVarBinary         // Binary
    case VarBinary             // Binary

    case Array                 //--\
    case DataLink              //   \
    case Distinct              //   |
    case JavaObject            //   |
    case Other                 //   \
    case Ref                   //    +-- These ones are vendor specific types. Mostly for Oracle.
    case RefCursor             //   /
    case RowId                 //   |
    case SqlXml                //   /
    case Struct                //--/
}
