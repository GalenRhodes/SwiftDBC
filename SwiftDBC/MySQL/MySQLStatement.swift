/************************************************************************//**
 *     PROJECT: SwiftDBC
 *    FILENAME: MySQLStatement.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 8/26/20
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
import MySQL
import Rubicon

typealias Q<T> = () throws -> T

class MySQLStatement: DBStatement {

    /*===========================================================================================================================*/
    /// The statements will have a dispatch queue to do background work on.
    ///
    static let workQueue: DispatchQueue = DispatchQueue(label: "SwiftDBC_Stmt1_\(UUID().uuidString)", qos: DispatchQoS.utility, attributes: [ DispatchQueue.Attributes.concurrent ])

    var results:   [MultiResultBlock] = []
    var isWorking: Bool               = false
    let cond:      Conditional        = Conditional()
    let conn:      MySQLConnection

    var isClosed: Bool = true

    init(_ conn: MySQLConnection) {
        self.conn = conn
        NotificationCenter.default.addObserver(forName: DBConnectionWillClose, object: self.conn, queue: nil) {
            [weak self] (notice: Notification) in
            if let _self: MySQLStatement = self { _self.close() }
        }
        isClosed = false
        isWorking = false
    }

    deinit { _close() }

    func close() { conn.lock.withLock { _close() } }

    func execute(sql: String) throws -> DBNextResults {
        try conn.lock.withLock {
            guard !isClosed else { throw DBError.StatementClosed }
            guard !isWorking else { throw DBError.Query(description: "Statement is currently busy with another query.") }
            isWorking = true
            MySQLStatement.workQueue.async { self.backgroundLoad(sql) }
        }
        return try hasMoreResults()
    }

    func withAllResults(_ body: AllDBResultsClosure) throws -> Bool {
        var _mrb: MultiResultBlock? = nextMultiResults()
        var _resNum: Int = 0

        while let mrb: MultiResultBlock = _mrb  {
            if let rs: MySQLResultSet = mrb.resultSet {
                if try body(nil, rs, ++_resNum) { return true }
            }
            else if let ud: UInt64 = mrb.updateCount {
                if try body(ud, nil, ++_resNum) { return true }
            }
            else if let e: DBError = mrb.error {
                throw e
            }

            _mrb = nextMultiResults()
        }

        return false
    }

    func withResultSet(_ body: DBResultSet.DBResultSetClosure) throws -> Bool {
        if let rs: DBResultSet = try getResultSet(){
            var rowNumber: Int = 0

            while rs.hasNextRow {
                if try body(rs, ++rowNumber) { return true }
            }
        }

        return false
    }

    func hasMoreResults() throws -> DBNextResults {
        try whenNext {
            if results.count == 0 {
                return .None
            }
            else {
                let r: MultiResultBlock = results[0]
                if let e: DBError = r.error { throw e }
                return ((r.resultSet == nil) ? .UpdateCount : .ResultSet)
            }
        }
    }

    func getUpdateCount() throws -> Int {
        if let mrb: MultiResultBlock = nextMultiResults() {
            if let e: DBError = mrb.error { throw e }
            if let c: UInt64 = mrb.updateCount { return Int(c) }
        }
        return -1
    }

    func getResultSet() throws -> DBResultSet? {
        if let mrb: MultiResultBlock = nextMultiResults() {
            if let e: DBError = mrb.error { throw e }
            if let r: MySQLResultSet = mrb.resultSet { return r }
        }
        return nil
    }

    @inlinable func whenNext<T>(_ body: Q<T>) rethrows -> T { try cond.withLockWait(cond: { (results.count > 0 || !isWorking) }) { try body() } }

    @inlinable func nextMultiResults() -> MultiResultBlock? { whenNext { ((results.count == 0) ? nil : results.removeFirst()) } }

    @inlinable func _close() {
        if !isClosed {
            // Tell anyone who depends on this statement that it is closing.
            NotificationCenter.default.post(name: DBStatementWillClose, object: self)
            // Then close.
            isClosed = true
        }
    }

    /*===========================================================================================================================*/
    /// Execute the SQL `statement(s)` and fetch the results.
    /// 
    /// - Parameter sql: the SQL `statement(s)`
    ///
    private func backgroundLoad(_ sql: String) {
        defer { isWorking = false }

        var status: Int32 = sql.withCString { (p: UnsafePointer<Int8>) -> Int32 in mysql_real_query(conn.mysql, p, UInt(strlen(p))) }

        while status == 0 {
            if let rs: UnsafeMutablePointer<MYSQL_RES> = mysql_use_result(conn.mysql) {
                cond.withLock { results.append(MultiResultBlock(resultSet: MySQLResultSet(self, rs))) }
            }
            else if mysql_field_count(conn.mysql) == 0 {
                cond.withLock { results.append(MultiResultBlock(updateCount: mysql_affected_rows(conn.mysql))) }
            }
            else {
                // There was supposed to be a result set and there wasn't one so something went wrong.
                status = 1
                break
            }
            status = mysql_next_result(conn.mysql)
        }

        if status > 0 {
            cond.withLock { results.append(MultiResultBlock(error: DBError.Query(description: conn.lastErrorMessage))) }
        }
    }

    /*===========================================================================================================================*/
    /// We're going to be returning one of three possible results. But only one.
    ///
    @usableFromInline struct MultiResultBlock {
        let resultSet:   MySQLResultSet?
        let updateCount: UInt64?
        let error:       DBError?

        /*=======================================================================================================================*/
        /// There can...
        ///
        @inlinable init(resultSet: MySQLResultSet) {
            self.resultSet = resultSet
            self.updateCount = nil
            self.error = nil
        }

        /*=======================================================================================================================*/
        /// ...only be...
        ///
        @inlinable init(updateCount: UInt64) {
            self.resultSet = nil
            self.updateCount = updateCount
            self.error = nil
        }

        /*=======================================================================================================================*/
        /// ...one!
        ///
        @inlinable init(error: DBError) {
            self.resultSet = nil
            self.updateCount = nil
            self.error = error
        }
    }
}
