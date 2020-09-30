/************************************************************************//**
 *     PROJECT: SwiftDBC
 *    FILENAME: DBConnection.swift
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

/*===============================================================================================================================*/
/// A connection (session) with a specific database. SQL statements are executed and results are returned within the context of a
/// connection.
///
/// A Connection object's database is able to provide information describing its tables, its supported SQL grammar, its stored
/// procedures, the capabilities of this connection, and so on. This information is obtained with the `metaData` property.
///
/// Note: When configuring a `DBConnection`, SwiftDBC applications should use the appropriate `DBConnection` method such as setting
/// the `autoCommit` property. Applications should not invoke SQL commands directly to change the connection's configuration when
/// there is a SwiftDBC method available. By default a `DBConnection` object is in auto-commit mode, which means that it
/// automatically commits changes after executing each statement. If auto-commit mode has been disabled, the method commit must be
/// called explicitly in order to commit changes; otherwise, database changes will not be saved.
///
/// A new `DBConnection` object created using the SwiftDBC API has an initially empty type map associated with it. A user may enter
/// a custom mapping for a UDT in this type map. When a UDT is retrieved from a data source with the method
/// `DBResultSet.getObject()`, that method will check the connection's type map to see if there is an entry for that UDT. If so,
/// the `DBResultSet.getObject()` method will map the UDT to the class indicated. If there is no entry, the UDT will be mapped
/// using the standard mapping.
///
/// A user may create a new type map, make an entry in it, and pass it to the methods that can perform custom mapping. In this
/// case, the method will use the given type map instead of the one associated with the connection.
///
public protocol DBConnection: Closable, AnyObject {

    var autoCommit:         Bool { get set }
    var networkTimeout:     Int { get }
    var lastErrorMessage:   String { get }
    var lastWarningMessage: String { get }
    var driver:             DBDriver { get }

    func commit() -> Bool

    func rollback() -> Bool

    func reconnect() throws

    func createStatement() throws -> DBStatement

    func currentSchema() throws -> String?

    func setCurrentSchema(_ schema: String) throws

    func clearWarnings()

    func escape(str: String) -> String

    func escape(str: String, quoteChar: CChar) -> String
}

@inlinable public func == (lhs: DBConnection, rhs: DBConnection) -> Bool { (lhs === rhs) }
