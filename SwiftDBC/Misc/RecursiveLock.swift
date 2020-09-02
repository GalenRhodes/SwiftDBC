/************************************************************************//**
 *     PROJECT: SwiftDBC
 *    FILENAME: RecursiveLock.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 9/2/20
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

open class RecursiveLock: NSLocking {

    @usableFromInline let rLock: NSRecursiveLock = NSRecursiveLock()

    public init() {}

    @inlinable public func lock() { rLock.lock() }

    @inlinable public func lock(before: Date) -> Bool { rLock.lock(before: before) }

    @inlinable public func unlock() { rLock.unlock() }

    @inlinable public func `try`() -> Bool { rLock.try() }

    @inlinable func withLock<T>(_ lambda: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try lambda()
    }

}
