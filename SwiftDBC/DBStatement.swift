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

public protocol DBStatement: Closable {

    /*===========================================================================================================================*/
    /// Executes the given SQL statement, which may return multiple results. In some (uncommon) situations, a single SQL statement
    /// may return multiple result sets and/or update counts. Normally you can ignore this unless you are (1) executing a stored
    /// procedure that you know may return multiple results or (2) you are dynamically executing an unknown SQL string.
    /// 
    /// The execute method executes an SQL statement and indicates the form of the first result. You must then use the methods
    /// getResultSet or getUpdateCount to retrieve the result, and getMoreResults to move to any subsequent `result(s)`.
    /// 
    /// Note: This method cannot be called on a PreparedStatement or CallableStatement.
    /// 
    /// - Parameter sql: any SQL statement
    /// - Returns: `true` if the first result is a ResultSet object; `false` if it is an update count or there are no results
    /// - Throws: if the SQL statement was invalid, the server encountered an error, or there was an I/O error communicating with
    ///           the server.
    ///
    func execute(sql: String) throws -> DBNextResults

    func getResultSet() throws -> DBResultSet?

    func getUpdateCount() throws -> Int

    func hasMoreResults() throws -> DBNextResults
}
