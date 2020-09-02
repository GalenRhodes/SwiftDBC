/************************************************************************//**
 *     PROJECT: SwiftDBC
 *    FILENAME: DBTools.swift
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

@inlinable func isType(_ dataType: DataTypes, inTypes list: DataTypes...) -> Bool {
    for aType: DataTypes in list { if dataType == aType { return true } }
    return false
}

@inlinable public func representableAsText(dataType: DataTypes) -> Bool {
    !isType(dataType, inTypes: .Null, .Binary, .Blob, .LongVarBinary, .VarBinary, .Array, .DataLink, .Distinct, .JavaObject, .Other, .Ref, .RefCursor, .RowId, .SqlXml, .Struct)
}
