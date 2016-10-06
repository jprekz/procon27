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

    Vec!int[] p = inputPath;
    p = p.pathClean(0.12 / scale);
    p = p.pathClean(0.18 / scale);
    
    return p.map!(v => Vec!double(v.x, v.y)).array;
}

Vec!int[] pathClean(Vec!int[] inputPath, double th) {
    import std.math;
    import std.range : cycle;

    if (inputPath.length < 4) return inputPath;

    auto cyclePath = inputPath.cycle;

    Vec!int[] path;

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
