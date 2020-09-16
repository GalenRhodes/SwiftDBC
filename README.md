# SwiftDBC
SwiftDBC is _very_ loosely based on the Java JDBC library. It's aim is to provide a Swift interface to different databases by having an abstraction layer away from vendor specific differences in database access libraries.

# API Documentation
Documentation of the API can be found here: [SwiftDBC API](http://galenrhodes.com/SwiftDBC/)

# Arbitrary Width Integers (aka: BigInt)
For support of very large integers of arbitrary size I came across [BigInt](https://github.com/attaswift/BigInt). I like it because it's 100% pure swift without the need for external library dependencies and it doesn't use any Apple macOS specific APIs so it will build on Linux without modification.

It is licensed under the [MIT License](https://github.com/attaswift/BigInt/blob/master/LICENSE.md) and I am using it as-is without modification.

It has been added to this project as a package dependency.

# MySQL Implementation
The first database system that is implemented is MySQL.

## MySQL Dependency
Naturally there is a dependency on the MySQL client libraries. If you're building this on MacOS then I recommend downloading the installer directly from [MySQL Community Downloads](https://dev.mysql.com/downloads/mysql/) because this package assumes file locations (header and lib) based on where their installer puts them.

If you're building this on Linux you'll need to install the client library:
```
sudo apt install libmysqlclient-dev
```

# Help Appreciated!
If some industrious folks want to fork this project and start working on support for other databases such as _(but not limited to)_ Oracle, Postgre, Microsoft SQL Server, etc. Please feel free and I'll gladly consider your pull requests! 😎

