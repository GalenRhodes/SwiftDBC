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

public enum DataTypes {
    case Array
    case Bit
    case Binary
    case BigInt
    case Blob
    case Boolean
    case Char
    case Clob
    case DataLink
    case Date
    case Decimal
    case Distinct
    case Double
    case Float
    case Integer
    case JavaObject
    case LongNVarChar
    case LongVarChar
    case LongVarBinary
    case NChar
    case NClob
    case Null
    case Numeric
    case NVarChar
    case Other
    case Real
    case Ref
    case RefCursor
    case RowId
    case SmallInt
    case SqlXml
    case Struct
    case Time
    case TimeWithTimeZone
    case TimeStamp
    case TimeStampWithTimeZone
    case TinyInt
    case VarBinary
    case VarChar
}

public enum DBError: Error {
    case Connection(description: String)
    case Query(description: String)
}

public protocol DBDriver: AnyObject {

    var majorVersion: Int { get }
    var minorVersion: Int { get }

    func acceptsURL(_ url: String) -> Bool

    func connect(url: String, username: String?, password: String?, properties: [String: Any]) throws -> DBConnection

    static func register()
}

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
public protocol DBConnection {

    var autoCommit:       Bool { get set }
    var networkTimeout:   Int { get }
    var isClosed:         Bool { get }
    var lastErrorMessage: String { get }
    var metaData:         DBDatabaseMetaData? { get }

    func close()

    func commit() throws

    func createStatement() throws -> DBStatement
}

public protocol DBStatement {

    /*===========================================================================================================================*/
    /// `true` if the statement is closed.
    ///
    var isClosed: Bool { get }

    /*===========================================================================================================================*/
    /// Closes the statement. Closing the statements automatically closes any open result sets created by this statement.
    ///
    func close()

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
    func execute(sql: String) throws -> Bool
}

public protocol DBDatabaseMetaData {
}

public protocol DBResultSetMetaData {

}
