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
import Rubicon
import BigInt

public protocol DBResultSet: Closable, AnyObject {

    var metaData:  DBResultSetMetaData { get }
    var count:     Int { get }
    var statement: DBStatement { get }

    func withRows(do body: (DBRow) throws -> Bool) throws -> Bool

    subscript(rowNumber: Int) -> DBRow { get }
}

@inlinable public func == (lhs: DBResultSet, rhs: DBResultSet) -> Bool { lhs === rhs }
