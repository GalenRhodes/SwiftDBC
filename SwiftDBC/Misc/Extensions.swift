/************************************************************************//**
 *     PROJECT: SwiftDBC
 *    FILENAME: Extensions.swift
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

prefix operator ++
prefix operator --
postfix operator ++
postfix operator --

@inlinable @discardableResult public prefix func ++ <T>(num: inout T) -> T where T: BinaryInteger { num += 1; return num }

@inlinable @discardableResult public prefix func -- <T>(num: inout T) -> T where T: BinaryInteger { num -= 1; return num }

@inlinable @discardableResult public postfix func ++ <T>(num: inout T) -> T where T: BinaryInteger { let _num = num; ++num; return _num }

@inlinable @discardableResult public postfix func -- <T>(num: inout T) -> T where T: BinaryInteger { let _num = num; --num; return _num }

extension String {

    @inlinable func substringWith(nsRange: NSRange) -> String? {
        if nsRange.location != NSNotFound {
            if let r: Range<Index> = getRange(nsRange: nsRange) {
                return String(self[r])
            }
        }
        return nil
    }

    @inlinable func getRange(nsRange: NSRange) -> Range<Index>? { Range<Index>(nsRange, in: self) }

    @inlinable func getNSRange(range: Range<Index>) -> NSRange { NSRange(range, in: self) }

    @inlinable func fullRange() -> Range<Index> { (startIndex ..< endIndex) }

    @inlinable func fullNSRange() -> NSRange { NSRange(fullRange(), in: self) }

    @inlinable func substring(fromOffset: Int) -> String { String(self[index(startIndex, offsetBy: fromOffset) ..< endIndex]) }

    @inlinable func substring(toOffset: Int) -> String { String(self[startIndex ..< index(startIndex, offsetBy: toOffset)]) }

    @inlinable subscript(_ intRange: Range<Int>) -> String {
        let aIndex: Index = index(startIndex, offsetBy: intRange.lowerBound)
        let bIndex: Index = index(startIndex, offsetBy: intRange.upperBound)
        return String(self[aIndex ..< bIndex])
    }

    @inlinable var maxOffset: Int { distance(from: startIndex, to: endIndex) }
}

extension NSRegularExpression {

    @inlinable func firstMatch(in str: String, options: NSRegularExpression.MatchingOptions = []) -> NSTextCheckingResult? {
        firstMatch(in: str, options: options, range: str.fullNSRange())
    }

    @inlinable func matches(in str: String, options: NSRegularExpression.MatchingOptions = []) -> [NSTextCheckingResult] {
        matches(in: str, options: options, range: str.fullNSRange())
    }
}

extension Array {

    @inlinable func indexesOf(where lambda: (Element) -> Bool) -> [Int] {
        var indexList: [Int] = []
        for (i, item): (Int, Element) in enumerated() {
            if lambda(item) { indexList.append(i) }
        }
        return indexList
    }

    @inlinable mutating func removeAllGet(where lambda: (Element) throws -> Bool) rethrows -> [Element] {
        var list: [Element] = []
        try removeAll { (item: Element) -> Bool in
            let f: Bool = try lambda(item)
            if f { list.append(item) }
            return f
        }
        return list
    }
}

public extension NSRecursiveLock {

    @inlinable func withLock<T>(_ lambda: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try lambda()
    }
}
