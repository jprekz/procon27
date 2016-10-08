module imagetovec.pathprocessing;

import imagetovec.type;

// scale[cm/px]
Vec!double[][] pathesOptimization(Vec!int[][] inputPathes, double scale) {
    Vec!double[][] pathes;
    foreach(path; inputPathes) {
        auto _p = pathOptimization(path, scale);
        if (_p.length >= 3) pathes ~= _p;
    }
    return pathes;
}

Vec!double[] pathOptimization(Vec!int[] inputPath, double scale) {
    import std.array : array;
    import std.algorithm : map;
    if (inputPath.length < 3) return inputPath.map!(v => Vec!double(v.x, v.y)).array;

    Vec!double[] p = inputPath.map!(v => Vec!double(v.x, v.y)).array;
    p = p.pathClean(0.1 / scale);
    p = p.pathClean(0.1 / scale);
    p = p.pathClean(0.1 / scale);
    p = p.pathSharp(0.9 / scale, 1.1);
    p = p.pathSharp(0.9 / scale, 1.1);
    p = p.pathSharp(0.9 / scale, 1.2);
    p = p.pathSharp(0.9 / scale, 1.2);
    p = p.pathSharp(1.0 / scale, 1.4);
    p = p.pathSharp(1.0 / scale, 1.4);
    p = p.pathClean(0.16 / scale);
    p = p.pathClean(0.16 / scale);
    p = p.pathSharp(0.9 / scale, 1.1);
    p = p.pathSharp(0.9 / scale, 1.1);
    return p;
}

Vec!double[] pathClean(Vec!double[] inputPath, double th) {
    import std.math;
    import std.range : cycle;

    if (inputPath.length < 4) return inputPath;

    auto cyclePath = inputPath.cycle;

    Vec!double[] path;

    size_t firstAlpha = 0;
    LOOP1 : foreach(omega; 2 .. inputPath.length) {
        const vecA = inputPath[omega] - inputPath[0];
        foreach(i; 1 .. omega) {
            const vecB = inputPath[i] - inputPath[0];
            const d = abs(vecA.x * vecB.y - vecA.y * vecB.x) / vecA.abs;
            if (d > th) {
                firstAlpha = omega - 1;
                break LOOP1;
            }
        }
    }
    size_t alpha = firstAlpha;
    path ~= cyclePath[alpha];
    LOOP2 : foreach(omega; firstAlpha + 2 .. firstAlpha + inputPath.length + 1) {
        const vecA = cyclePath[omega] - cyclePath[alpha];
        foreach(i; alpha + 1 .. omega) {
            const vecB = cyclePath[i] - cyclePath[alpha];
            const d = abs(vecA.x * vecB.y - vecA.y * vecB.x) / vecA.abs;
            if (d > th) {
                alpha = omega - 1;
                path ~= cyclePath[alpha];
                continue LOOP2;
            }
        }
    }

    return path;
}

Vec!double[] pathSharp(Vec!double[] inputPath, double th, double thd) {
    import std.range : cycle;

    if (inputPath.length < 4) return inputPath;

    Vec!double[] path;

    auto p = inputPath.cycle;
    foreach(ref i; 0 .. inputPath.length) {
        if ((p[i+1] - p[i]).abs < th) {
            auto pA = p[i - 1];
            auto pB = p[i + 2];
            auto vecA = p[i] - p[i - 1];
            auto vecB = p[i + 1] - p[i + 2];
            double t = (vecB.x * (pB.y - pA.y) + vecB.y * (pA.x - pB.x)) / (vecB.x * vecA.y - vecB.y * vecA.x);
            if (t < thd && t > 1.0) {
                auto pnew = pA + (vecA * t);
                path ~= pnew;
                i++;
                continue;
            }
        }
        path ~= p[i];
    }
    return path;
}
