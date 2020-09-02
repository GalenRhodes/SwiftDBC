/************************************************************************//**
 *     PROJECT: SwiftDBC
 *    FILENAME: Conditional.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 8/27/20
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

public class Conditional: NSLocking {

    @usableFromInline let condition: NSCondition = NSCondition()

    public var name: String? {
        get { condition.name }
        set { condition.name = newValue }
    }

    public init() {}

    @inlinable public func withLock<T>(lambda: () throws -> T) rethrows -> T {
        lock()
        defer {
            signal()
            unlock()
        }
        return try lambda()
    }

    @inlinable public func withLockWait<T>(cond: () -> Bool, _ lambda: () throws -> T) rethrows -> T {
        lock()
        defer {
            signal()
            unlock()
        }
        while !cond() { wait() }
        return try lambda()
    }

    @inlinable public func lock() { condition.lock() }

    @inlinable public func unlock() { condition.unlock() }

    @inlinable public func wait() { condition.wait() }

    @inlinable public func wait(until: Date) -> Bool { condition.wait(until: until) }

    @inlinable public func signal() { condition.signal() }

    @inlinable public func broadcast() { condition.broadcast() }
}
