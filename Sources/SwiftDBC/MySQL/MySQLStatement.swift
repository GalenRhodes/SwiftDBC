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

class MySQLStatement: DBStatement {

    /*===========================================================================================================================*/
    /// The statements will have a dispatch queue to do background work on.
    ///
    static let workQueue: DispatchQueue = DispatchQueue(label: "SwiftDBC_Stmt1_\(UUID().uuidString)", qos: DispatchQoS.utility, attributes: [ DispatchQueue.Attributes.concurrent ])

    var _isClosed: Bool               = false
    var isWorking: Bool               = false
    var results:   [MultiResultBlock] = []
    let cond:      Conditional        = Conditional()
    let conn:      MySQLConnection

    @inlinable var connection: DBConnection { conn }
    @inlinable var isClosed:   Bool {
        get { _isClosed || conn.isClosed }
        set { _isClosed = newValue }
    }

    init(_ conn: MySQLConnection) {
        self.conn = conn
        NotificationCenter.default.addObserver(forName: DBConnectionWillClose, object: conn, queue: nil) {
            [weak self] (notice: Notification) in
            if let s: MySQLStatement = self { s.close() }
        }
    }

    deinit {
        _close()
    }

    func close() {
        cond.withLockWait(forCondition: { ((results.isEmpty) && !isWorking) }) { _close() }
    }

    @inlinable func nextMultiResults() -> MultiResultBlock? {
        cond.withLockWait(forCondition: { ((results.count > 0) || !isWorking) }) {
            () -> MultiResultBlock? in
            ((results.count > 0) ? results.removeFirst() : nil)
        }
    }

    func withSQLStatement(sql: String, do body: (UInt64?, DBResultSet?, Int) throws -> Bool) throws -> Bool {
        try conn.lock.withLock {
            guard !isClosed else { throw DBError.StatementClosed }
            guard !isWorking else { throw DBError.Query(description: "Connection is currently busy with another query.") }

            isWorking = true
            MySQLStatement.workQueue.async { self.backgroundLoad(sql) }

            var resultBlock:  MultiResultBlock? = nextMultiResults()
            var resultNumber: Int               = 0

            while let mrb: MultiResultBlock = resultBlock {
                switch mrb.type {
                    case .ResultSet:   if try body(nil, mrb.resultSet!, resultNumber++) { return true }
                    case .UpdateCount: if try body(mrb.updateCount!, nil, resultNumber++) { return true }
                    case .Error:        throw mrb.error!
                }
                resultBlock = nextMultiResults()
            }

            return false
        }
    }

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

        var status: Int32 = sql.withCString {
            (p: CCharROPointer) -> Int32 in
            let l: Int = strlen(p)
            return mysql_real_query(conn.mysql, p, UInt(l))
        }

        while status == 0 {
            if let rs: UnsafeMutablePointer<MYSQL_RES> = mysql_use_result(conn.mysql) {
                addResult(MultiResultBlock(resultSet: MySQLResultSet(self, rs)))
            }
            else if mysql_field_count(conn.mysql) == 0 {
                addResult(MultiResultBlock(updateCount: mysql_affected_rows(conn.mysql)))
            }
            else {
                status = 1
                break
            }
            status = mysql_next_result(conn.mysql)
        }

        if status > 0 { addResult(MultiResultBlock(error: DBError.Query(description: conn.lastErrorMessage))) }
    }

    @inlinable func addResult(_ mrb: MultiResultBlock) {
        cond.withLock {
            results.append(mrb)
        }
    }

    /*===========================================================================================================================*/
    /// We're going to be returning one of three possible results. But only one.
    ///
    class MultiResultBlock {
        let resultSet:   MySQLResultSet?
        let updateCount: UInt64?
        let error:       DBError?
        let type:        DBResultType

        /*=======================================================================================================================*/
        /// There can...
        ///
        init(resultSet: MySQLResultSet) {
            self.resultSet = resultSet
            self.updateCount = nil
            self.error = nil
            self.type = .ResultSet
        }

        /*=======================================================================================================================*/
        /// ...only be...
        ///
        init(updateCount: UInt64) {
            self.resultSet = nil
            self.updateCount = updateCount
            self.error = nil
            self.type = .UpdateCount
        }

        /*=======================================================================================================================*/
        /// ...one!
        ///
        init(error: DBError) {
            self.resultSet = nil
            self.updateCount = nil
            self.error = error
            self.type = .Error
        }
    }
}
