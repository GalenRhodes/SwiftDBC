/************************************************************************//**
 *     PROJECT: SwiftDBC
 *    FILENAME: DBDriver.swift
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
