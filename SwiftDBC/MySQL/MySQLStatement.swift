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
    /// Each statement will have it's own dispatch queue to do background work on.
    ///
    let wQueue:    DispatchQueue      = DispatchQueue(label: "SwiftDBC_Stmt1_\(UUID().uuidString)", qos: DispatchQoS.utility, attributes: [ DispatchQueue.Attributes.concurrent ])
    var rslts:     [MultiResultBlock] = []
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
    }

    deinit {
        close()
    }

    func close() {
        if !isClosed {
            // Tell anyone who depends on this statement that it is closing.
            NotificationCenter.default.post(name: DBStatementWillClose, object: self)
            // Then close.
            isClosed = true
        }
    }

    func execute(sql: String) throws -> DBNextResults {
        guard !isClosed else { throw DBError.StatementClosed }
        guard !isWorking else { throw DBError.Query(description: "Statement is currently busy with another query.") }
        isWorking = true

        let res: UnsafeMutablePointer<MYSQL_RES>? = try doStatement(sql: sql, resultSetType: .Use)
        let mrb: MultiResultBlock                 = processStatementResults(result: res)
        if let e: DBError = mrb.error { throw e }

        addResults(mrb)
        wQueue.async { self.backgroundLoad() }
        return ((mrb.updateCount == nil) ? ((mrb.resultSet == nil) ? .None : .ResultSet) : .UpdateCount)
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

    func hasMoreResults() throws -> DBNextResults {
        try cond.withLockWait(cond: { !(rslts.count == 0 && isWorking) }) {
            () throws -> DBNextResults in
            if rslts.count == 0 { return .None }
            let mrb: MultiResultBlock = rslts[0]
            if let e: DBError = mrb.error { throw e }
            if let _ = mrb.updateCount { return .UpdateCount }
            return .ResultSet
        }
    }

    @inlinable func addResults(_ mrb: MultiResultBlock) {
        cond.withLock { rslts.append(mrb) }
    }

    @inlinable func getNextMultiResult() -> MultiResultBlock? {
        cond.withLockWait(cond: { !(rslts.count == 0 && isWorking) }, { ((rslts.count == 0) ? nil : rslts.removeFirst()) })
    }

    private func backgroundLoad() {
        var status: Int32 = mysql_next_result(conn.mysql)

        while status == 0 {
            addResults(processStatementResults(result: mysql_use_result(conn.mysql)))
            status = mysql_next_result(conn.mysql)
        }

        if status > 0 {
            addResults(MultiResultBlock(error: DBError.Query(description: conn.lastErrorMessage)))
        }
        cond.withLock { isWorking = false }
    }

    private func processStatementResults(result: UnsafeMutablePointer<MYSQL_RES>?) -> MultiResultBlock {
        if let result: UnsafeMutablePointer<MYSQL_RES> = result {
            return MultiResultBlock(resultSet: MySQLResultSet(self, result))
        }
        else if mysql_field_count(conn.mysql) == 0 {
            return MultiResultBlock(updateCount: mysql_affected_rows(conn.mysql))
        }
        else {
            return MultiResultBlock(error: DBError.Query(description: conn.lastErrorMessage))
        }
    }

    private func doStatement(sql: String, resultSetType: MySQLResultSetType) throws -> UnsafeMutablePointer<MYSQL_RES>? {
        try sql.utf8CString.withUnsafeBufferPointer { (bp: UnsafeBufferPointer<CChar>) in
            guard let p: UnsafePointer<CChar> = bp.baseAddress else {
                throw DBError.Query(description: "Invalid Query String: \(sql)")
            }
            guard mysql_real_query(conn.mysql, p, UInt(bp.count)) == 0 else {
                throw DBError.Query(description: conn.lastErrorMessage)
            }

            return ((resultSetType == .Use) ? mysql_use_result(conn.mysql) : mysql_store_result(conn.mysql))
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

    enum MySQLResultSetType {
        case Use
        case Store
    }
}
