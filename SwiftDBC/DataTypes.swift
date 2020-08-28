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

public enum DBError: Error {
    case Connection(description: String)
    case Query(description: String)
    case ConnectionClosed
    case StatementClosed
    case ResultSetClosed
    case Commit
    case Rollback
}

/*===============================================================================================================================*/
/// The labeled types below are currently supported in SwiftDBC. The types
/// '<code>[Array](https://developer.apple.com/documentation/swift/array/)</code>', `DataLink`, `Distinct`, `JavaObject`, `Ref`,
/// `RefCursor`, `RowId`, `SqlXml`, and `Struct` are mostly Oracle specific and don't have an equivalence in other databases. They
/// are not currently supported but may be in the future because of the HUGE popularity of Oracle.
///
public enum DataTypes {
    case Array                 //
    case Bit                   // Numeric
    case Binary                // Binary
    case BigInt                // Numeric
    case Blob                  // Binary
    case Boolean               // *Numeric  (some people consider it a numeric; others don't)
    case Char                  // Text
    case Clob                  // Text
    case DataLink              //
    case Date                  // Date/Time
    case Decimal               // Numeric
    case Distinct              //
    case Double                // Numeric
    case Float                 // Numeric
    case Integer               // Numeric
    case JavaObject            //
    case LongNVarChar          // Text
    case LongVarChar           // Text
    case LongVarBinary         // Binary
    case NChar                 // Text
    case NClob                 // Text
    case Null                  // * - (denotes no datatype)
    case Numeric               // Numeric
    case NVarChar              // Text
    case Other                 //
    case Real                  // Numeric
    case Ref                   //
    case RefCursor             //
    case RowId                 //
    case SmallInt              // Numeric
    case SqlXml                //
    case Struct                //
    case Time                  // Date/Time
    case TimeWithTimeZone      // Date/Time
    case TimeStamp             // Date/Time
    case TimeStampWithTimeZone // Date/Time
    case TinyInt               // Numeric
    case VarBinary             // Binary
    case VarChar               // Text
}

public protocol Closable: AnyObject {

    /*===========================================================================================================================*/
    /// `true` if the statement is closed.
    ///
    var isClosed: Bool { get }

    /*===========================================================================================================================*/
    /// Closes the statement. Closing the statements automatically closes any open result sets created by this statement.
    ///
    func close()
}

public protocol DBDriver: AnyObject {

    var majorVersion: Int { get }
    var minorVersion: Int { get }

    func acceptsURL(_ url: String) -> Bool

    func connect(url: String, username: String?, password: String?, database: String?, properties: [String: Any]) throws -> DBConnection

    static func register()
}

public extension DBDriver {
    func connect(url: String, username: String? = nil, password: String? = nil, database: String? = nil) throws -> DBConnection {
        try connect(url: url, username: username, password: password, database: database, properties: [:])
    }
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
public protocol DBConnection: Closable {

    var autoCommit:       Bool { get set }
    var networkTimeout:   Int { get }
    var lastErrorMessage: String { get }
    var metaData:         DBDatabaseMetaData? { get }
    var driver:           DBDriver { get }

    func commit() throws

    func rollback() throws

    func reconnect() throws

    func createStatement() throws -> DBStatement
}

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

public enum DBNextResults {
    case None
    case ResultSet
    case UpdateCount
}

public protocol DBDatabaseMetaData: AnyObject {
}

public protocol DBColumnMetaData: AnyObject {
    var index:           Int { get }
    var dataType:        DataTypes { get }
    var name:            String { get }
    var orgName:         String { get }
    var tableName:       String { get }
    var orgTableName:    String { get }
    var database:        String { get }
    var catalog:         String { get }
    var length:          UInt { get }
    var maxLength:       UInt { get }
    var decimalCount:    UInt { get }
    var isNullable:      Bool { get }
    var hasDefault:      Bool { get }
    var isAutoIncrement: Bool { get }
    var isUnsigned:      Bool { get }
    var isPrimaryKey:    Bool { get }
    var isUniqueKey:     Bool { get }
    var isIndexed:       Bool { get }
    var isReadOnly:      Bool { get }
}

/*===============================================================================================================================*/
/// An object that can be used to get information about the types and properties of the columns in a `DBResultSet` object. The
/// following code fragment creates the `DBResultSet` object rs, creates the `DBResultSetMetaData` object rsmd, and uses rsmd to
/// find out how many columns rs has and whether the first column in rs can hold a `NULL` value.
/// 
/// <pre>
///      let rs: DBResultSet = stmt.executeQuery(sql: "SELECT a, b, c FROM TABLE2")
///      let rsmd: DBResultSetMetaData = rs.metaData
///      let numberOfColumns: Int = rsmd.columnCount
///      let b: Bool = rsmd[0].isNullable
/// </pre>
///
public protocol DBResultSetMetaData: AnyObject {

    var columnCount: Int { get }

    subscript(name: String) -> DBColumnMetaData? { get }
    subscript(index: Int) -> DBColumnMetaData { get }
}

public protocol DBResultSet: Closable {

    var metaData: DBResultSetMetaData { get }

    func next() throws -> Bool

    func getDate(index: Int) throws -> Date?

    func getDate(name: String) throws -> Date?

    func getTime(index: Int) throws -> Date?

    func getTime(name: String) throws -> Date?

    func getTimestamp(index: Int) throws -> Date?

    func getTimestamp(name: String) throws -> Date?

    func getFloat(index: Int) throws -> Float?

    func getFloat(name: String) throws -> Float?

    func getDouble(index: Int) throws -> Double?

    func getDouble(name: String) throws -> Double?

    func getBigDecimal(index: Int) throws -> Decimal?

    func getBigDecimal(name: String) throws -> Decimal?

    func getBool(index: Int) throws -> String?

    func getBool(name: String) throws -> String?

    func getString(index: Int) throws -> String?

    func getString(name: String) throws -> String?

    func getByte(index: Int) throws -> Int8?

    func getByte(name: String) throws -> Int8?

    func getShort(index: Int) throws -> Int16?

    func getShort(name: String) throws -> Int16?

    func getSmall(index: Int) throws -> Int32?

    func getSmall(name: String) throws -> Int32?

    func getInt(index: Int) throws -> Int?

    func getInt(name: String) throws -> Int?

    func getLong(index: Int) throws -> Int64?

    func getLong(name: String) throws -> Int64?

    func getBigInt(index: Int) throws -> BigInt?

    func getBigInt(name: String) throws -> BigInt?

    func getUByte(index: Int) throws -> UInt8?

    func getUByte(name: String) throws -> UInt8?

    func getUShort(index: Int) throws -> UInt16?

    func getUShort(name: String) throws -> UInt16?

    func getUSmall(index: Int) throws -> UInt32?

    func getUSmall(name: String) throws -> UInt32?

    func getUInt(index: Int) throws -> UInt?

    func getUInt(name: String) throws -> UInt?

    func getULong(index: Int) throws -> UInt64?

    func getULong(name: String) throws -> UInt64?

    func getUBigInt(index: Int) throws -> BigUInt?

    func getUBigInt(name: String) throws -> BigUInt?
}
