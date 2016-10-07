module imagetovec;

import std.stdio;
import std.string;
import std.conv : to;
import std.algorithm;
import std.range;
import std.array : array;
import std.math;

import imageformats;

public import imagetovec.type;
import imagetovec.imageprocessing;
import imagetovec.imagetrace;
import imagetovec.pathprocessing;

ubyte binarizeOnWhiteSimple(ushort h, ubyte s, ubyte v) {
    return ( s * v / 255 ).to!ubyte;
}
ubyte binarizeOnWhite(ushort h, ubyte s, ubyte v) {
    return ( s * (1-(abs(v - 127)/128.0)^^2) * (359-h)/359 ).to!ubyte;
}
ubyte binarizeOnBlack(ushort h, ubyte s, ubyte v) {
    return ( (v/255.0) * (1 - s/255.0)^^2 * ((359-h) / 359.0) * 255).to!ubyte;
}

Vec!double[][] imageToPathes(IFImage im) {
     return im
        .thresholding!binarizeOnWhiteSimple
        .trace(im.h, im.w)
        .pathesOptimization(30.0 / 800);
}

auto pathesToString(Vec!double[][] pathes) {
    return pathes.map!(path =>
        path.map!(v => v.x.to!string ~ " " ~ v.y.to!string).join(" "));
}

auto pathToString(Vec!double[] path) {
    return path.map!(v => v.x.to!string ~ " " ~ v.y.to!string).join(" ");
}

Vec!double[][] stringToPathes(File file) {
    return file
        .byLine
        .map!(t => t
            .chomp
            .split
            .map!(to!double)
            .chunks(2)
            .map!(v => Vec!double(v[0], v[1]))
            .array)
        .array;
}
