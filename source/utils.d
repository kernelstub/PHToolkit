module utils;

import std.exception;
import std.typecons;

alias Result(T) = Algebraic!(T, string);

void check(bool condition, string message) @trusted {
    enforce(condition, new Exception(message ~ ". Error Code: " ~ GetLastError().to!string));
}

Result!T checkResult(T)(bool condition, T value, string errorMessage) @trusted {
    if (condition) {
        return Ok!T(value);
    } else {
        return Err!T(errorMessage);
    }
}
