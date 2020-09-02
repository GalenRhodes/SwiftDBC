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
            MySQLStatement.workQueue.async {
                defer { self.isWorking = false }
                var status: Int32 = mysql_real_query(self.conn.mysql, sql, UInt(sql.utf8.count))

                while status == 0 {
                    if let rs: UnsafeMutablePointer<MYSQL_RES> = mysql_use_result(self.conn.mysql) {
                        self.addResults(MultiResultBlock(resultSet: MySQLResultSet(self, rs)))
                    }
                    else if mysql_field_count(self.conn.mysql) == 0 {
                        self.addResults(MultiResultBlock(updateCount: mysql_affected_rows(self.conn.mysql)))
                    }
                    else {
                        status = 1
                        break
                    }
                    status = mysql_next_result(self.conn.mysql)
                }

                if status > 0 {
                    self.addResults(MultiResultBlock(error: DBError.Query(description: self.conn.lastErrorMessage)))
                }
            }
        }

        return try hasMoreResults()
    }

    func hasMoreResults() throws -> DBNextResults {
        try cond.withLockWait(cond: { (results.count > 0 || !isWorking) }) {
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
        if let mrb: MultiResultBlock = getNextMultiResult() {
            if let e: DBError = mrb.error { throw e }
            if let c: UInt64 = mrb.updateCount { return Int(c) }
        }
        return -1
    }

    func getResultSet() throws -> DBResultSet? {
        if let mrb: MultiResultBlock = getNextMultiResult() {
            if let e: DBError = mrb.error { throw e }
            if let r: MySQLResultSet = mrb.resultSet { return r }
        }
        return nil
    }

    @inlinable func addResults(_ mrb: MultiResultBlock) {
        cond.withLock { results.append(mrb) }
    }

    @inlinable func getNextMultiResult() -> MultiResultBlock? {
        cond.withLockWait(cond: { (results.count > 0 || !isWorking) }, { ((results.count == 0) ? nil : results.removeFirst()) })
    }

    @inlinable func _close() {
        if !isClosed {
            // Tell anyone who depends on this statement that it is closing.
            NotificationCenter.default.post(name: DBStatementWillClose, object: self)
            // Then close.
            isClosed = true
        }
    }

    class MultiResultBlock {
        let resultSet:   MySQLResultSet?
        let updateCount: UInt64?
        let error:       DBError?

        init(resultSet: MySQLResultSet) {
            self.resultSet = resultSet
            self.updateCount = nil
            self.error = nil
        }

        init(updateCount: UInt64) {
            self.resultSet = nil
            self.updateCount = updateCount
            self.error = nil
        }

        init(error: DBError) {
            self.resultSet = nil
            self.updateCount = nil
            self.error = error
        }
    }
}
