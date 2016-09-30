module type;

import std.traits;

struct Vec(T) {
    T x, y;

    Vec!T opBinary(string op)(Vec rhs)
    {
        static if (op == "+") return Vec(x + rhs.x, y + rhs.y);
        else static if (op == "-") return Vec(x - rhs.x, y - rhs.y);
        else static assert(0, "Operator "~op~" not implemented");
    }

    auto opBinary(string op, N)(N rhs) if (isNumeric!N)
    {
        auto nx = mixin("x"~op~"rhs");
        auto ny = mixin("y"~op~"rhs");
        return Vec!(typeof(nx))(nx, ny);
    }

    Vec!T conv(T)() const {
        return Vec!T(x, y);
    }

    auto abs() const {
        import std.math : sqrt;
        import std.conv : to;
        return (x * x + y * y).to!double.sqrt;
    }
}
