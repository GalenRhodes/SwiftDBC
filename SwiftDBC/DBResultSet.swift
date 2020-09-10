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

public protocol DBResultSet: Closable {

    typealias DBResultSetClosure = (DBResultSet, Int) throws -> Bool

    var hasNextRow: Bool { get }

    var metaData: DBResultSetMetaData { get }

    subscript(index: Int) -> DBColumn { get }

    subscript(name: String) -> DBColumn? { get }
}

public extension DBResultSet {

    @inlinable func getColumnIndexFor(name: String) throws -> Int {
        guard let index: Int = metaData[name]?.index else { throw DBError.ResultSet(description: "Column \"\(name)\" not found.") }
        return index
    }

    @inlinable subscript(name: String) -> DBColumn? {
        guard let index: Int = metaData[name]?.index else { return nil }
        return self[index]
    }
}
