# SwiftDBC
SwiftDBC is _very_ loosely based on the Java JDBC library. It's aim is to provide a Swift interface to different databases by having an abstraction layer away from vendor specific differences in
database access libraries.

# API Documentation
Documentation of the API can be found here: [SwiftDBC API](http://galenrhodes.com/SwiftDBC/)

# Arbitrary Width Integers (aka: BigInt)
For support of very large integers of arbitrary size I came across [BigInt](https://github.com/attaswift/BigInt). I like it because it's 100% pure swift without the need for external library
dependencies and it doesn't use any Apple macOS specific APIs so it will build on Linux without modification.

It is licensed under the [MIT License](https://github.com/attaswift/BigInt/blob/master/LICENSE.md) and I am using it as-is without modification.

It has been added to this project as a package dependency.

# MySQL Implementation
The first database system that is implemented is MySQL.

