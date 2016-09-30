module app;

import std.stdio;
import std.string;
import std.conv : to;
import std.algorithm;
import std.range;
import std.array : array;
import std.datetime : StopWatch;
import std.math;

import imageformats;

import imageprocessing;
import imagetrace;
import pathprocessing;
import type;

ubyte binarizeOnWhiteSimple(ushort h, ubyte s, ubyte v) {
    return ( s * v / 255 ).to!ubyte;
}
ubyte binarizeOnWhite(ushort h, ubyte s, ubyte v) {
    return ( s * (1-(abs(v - 127)/128.0)^^2) * (359-h)/359 ).to!ubyte;
}
ubyte binarizeOnBlack(ushort h, ubyte s, ubyte v) {
    return ( (v/255.0) * (1 - s/255.0)^^2 * ((359-h) / 359.0) * 255).to!ubyte;
}

void main() {
    StopWatch sw;

    write("input filename: ");
    IFImage im = read_image(readln.chomp, ColFmt.RGB);
    writeln("input scale[px]");
    write("  30cm = ");
    double scalepx = readln.chomp.to!double;

    sw.start;

    const pathes = im
        .thresholding!binarizeOnWhiteSimple
        .saveBinarized(im.h, im.w)
        .trace(im.h, im.w)
        .pathesOptimization(30.0 / scalepx);

    sw.stop;
    sw.peek.msecs.writeln;

    auto f = File("output.txt", "w");
    foreach(path; pathes) {
        f.writeln(path.map!(v => v.x.to!string ~ " " ~ v.y.to!string).join(" "));
    }
}
