/************************************************************************//**
 *     PROJECT: SwiftDBC
 *    FILENAME: DBDriverManager.swift
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

public let SwiftDBCPrefix: String = "swiftdbc"

/*===============================================================================================================================*/
/// Defines a lambda (closure) that is called when a driver is deregistered with the driver manager.
///
public typealias DBDeregisterLambda = () -> Void

/*===============================================================================================================================*/
/// The driver manager. The driver manager maintains a list of currently registered drivers. When a connection to a database is
/// required then a call to the driver manager's `connect(url:username:password:properties:)` method will locate the appropriate
/// driver for the given URL and then create and return a connection object.
/// 
/// Drivers are registered by calling their `DBDriver.register()` class method.
///
open class DBDriverManager {

    /*===========================================================================================================================*/
    /// The shared instance of the driver manager.
    ///
    public static let manager: DBDriverManager = DBDriverManager()

    var driverList: [DriverItem] = []

    /*===========================================================================================================================*/
    /// Registers a driver with the driver manager. You should not call this method directly but, rather, it should be called by
    /// the driver's `DBDriver.register()` class method. If the driver is already registered then this method does nothing.
    /// 
    /// - Parameters:
    ///   - driver: the instance of the driver.
    ///   - deregisterLambda: a lambda (closure) that is called when the driver is deregistered.
    ///
    public func register(driver: DBDriver, deregisterLambda: @escaping DBDeregisterLambda = {}) {
        if !driverList.contains(where: { $0.driver === driver }) {
            driverList.append(DriverItem(driver: driver, lambda: deregisterLambda))
        }
    }

    /*===========================================================================================================================*/
    /// Deregisters the given driver. If the driver is not already registered then this method does nothing.
    /// 
    /// - Parameter driver: the driver.
    ///
    public func deregister(driver: DBDriver) {
        let removed: [DriverItem] = driverList.removeAllGet { $0.driver === driver }
        for item: DriverItem in removed { item.lambda() }
    }

    /*===========================================================================================================================*/
    /// Connect to a database.
    /// 
    /// - Parameters:
    ///   - url: the URL which starts as "SwiftDBC:"
    ///   - username: the username if any.
    ///   - password: the password if any.
    ///   - properties: any properties to be passed to the driver.
    /// - Returns: the connection to the database.
    /// - Throws: if an error occurs.
    ///
    public func connect(url: String, username: String? = nil, password: String? = nil, properties: [String:Any] = [:]) throws -> DBConnection {
        if url.hasPrefix("\(SwiftDBCPrefix):") {
            for item: DriverItem in driverList {
                if item.driver.acceptsURL(url) {
                    return try item.driver.connect(url: url, username: username, password: password, properties: properties)
                }
            }
        }

        throw DBError.Connection(description: "URL not recognized by any registered drivers: \(url)")
    }

    private init() {}
}

class DriverItem {
    let driver: DBDriver
    let lambda: DBDeregisterLambda

    init(driver: DBDriver, lambda: @escaping DBDeregisterLambda) {
        self.driver = driver
        self.lambda = lambda
    }
}
