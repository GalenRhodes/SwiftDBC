/************************************************************************//**
 *     PROJECT: SwiftDBC
 *    FILENAME: DBStatement.swift
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

public enum DBResultType {
    case ResultSet
    case UpdateCount
    case Error
}

public protocol DBStatement: Closable, AnyObject {

    var connection: DBConnection { get }

    func withSQLStatement(sql: String, do body: (UInt64?, DBResultSet?, Int) throws -> Bool) throws -> Bool
}

@inlinable public func == (lhs: DBStatement, rhs: DBStatement) -> Bool { (lhs === rhs) }
