module imagetovec.imageprocessing;

import std.math;
import std.conv : to;

import imageformats;

ubyte[] thresholding(alias BINARIZE)(IFImage im) {
    import std.algorithm : map;
    import std.parallelism : parallel;
    import std.range : chunks;

    auto RGBpixels = chunks(im.pixels, 3)
        .map!(pixel => RGB(pixel[0], pixel[1], pixel[2]));

    auto HSVpixels = RGBpixels.map!toHSV;

    ubyte[] o = new ubyte[HSVpixels.length];
    foreach(i, HSVpixel; HSVpixels.parallel) {
        o[i] = BINARIZE(HSVpixel.h, HSVpixel.s, HSVpixel.v);
    }
    const th = discriminantAnalysis(o);
    foreach(ref pixel; o.parallel) {
        pixel = ((pixel < th) ? 0 : 255).to!ubyte;
    }
    o = o.gaussian!6(im.h, im.w);
    foreach(ref pixel; o.parallel) {
        pixel = ((pixel < 127) ? 0 : 255).to!ubyte;
    }

    return o;
}

ubyte[] saveBinarized(ubyte[] data, int h, int w) {
    ubyte[] s = new ubyte[data.length * 3];
    foreach(i, p; data) {
        s[i * 3] = p;
        s[i * 3 + 1] = p;
        s[i * 3 + 2] = p;
    }
    write_image("binarized.png", w, h, s, ColFmt.Y);
    return data;
}

struct RGB {
    ubyte r, g, b;
}

struct HSV {
    ushort h;
    ubyte s, v;
}

HSV toHSV(RGB rgb) {
    import std.algorithm : max, min;
    const ubyte MAX = max(rgb.r, rgb.g, rgb.b);
    const ubyte MIN = min(rgb.r, rgb.g, rgb.b);
    if (MAX == 0) return HSV(0, 0, 0);
    int h = (MIN == MAX) ? 0
        : (MIN == rgb.b) ? (60.0 * (rgb.g - rgb.r) / (MAX - MIN) + 60).to!int
        : (MIN == rgb.r) ? (60.0 * (rgb.b - rgb.g) / (MAX - MIN) + 180).to!int
        : (MIN == rgb.g) ? (60.0 * (rgb.r - rgb.b) / (MAX - MIN) + 300).to!int
        : 0;    //error
    const ushort H = ((h < 0) ? h + 360 : h).to!ushort;
    const ubyte S = (255.0 * (MAX - MIN) / MAX).to!ubyte;
    const ubyte V = MAX;
    return HSV(H, S, V);
}

ubyte discriminantAnalysis(ubyte[] src) {
    ubyte t = 0;
    double max = 0.0;
    int[256] hist;
    foreach(num; src) {
        hist[num]++;
    }
    
    foreach (i; 0 .. 256) {
        int w1 = 0;
        int w2 = 0;
        long sum1 = 0;
        long sum2 = 0;
        double m1 = 0.0;
        double m2 = 0.0;
        
        for (int j = 0; j <= i; ++j) {
            w1 += hist[j];
            sum1 += j * hist[j];
        }
        for (int j = i+1; j < 256; ++j) {
            w2 += hist[j];
            sum2 += j * hist[j];
        }
        
        if (w1) m1 = 1.0 * sum1 / w1;
        if (w2) m2 = 1.0 * sum2 / w2;
        double tmp = 1.0 * w1 * w2 * (m1 - m2) * (m1 - m2);
        if (tmp > max) {
            max = tmp;
            t = i.to!ubyte;
        }
    }
    
    return t;
}

ubyte[] gaussian(int RANGE)(const ubyte[] src, int h, int w) {
    import std.parallelism : parallel;

    double[RANGE + 1] kernel;
    enum sigma = RANGE / 3.0;
    enum ca = (1.0 / (sqrt(2.0 * PI) * sigma));
    enum cb = (1.0 / (2 * sigma * sigma));
    for(int x = 0; x <= RANGE; x++) {
        kernel[x]=ca * exp(-cb * x * x);
    }
    
    double[] dst1 = new double[src.length];
    foreach(dstPixelIndex, ref pixel; dst1.parallel) {
        pixel = 0;
        foreach(rangeIndex; RANGE * -1 .. RANGE + 1) {
            auto dstPixelIndexX = dstPixelIndex % w + rangeIndex;
            auto dstPixelIndexY = dstPixelIndex / w;
            if (dstPixelIndexX < 0) dstPixelIndexX = 0;
            if (dstPixelIndexX >= w) dstPixelIndexX = w - 1;
            const srcPixelIndex = dstPixelIndexX + dstPixelIndexY * w;
            const weightIndex = abs(rangeIndex);
            pixel += src[srcPixelIndex] * kernel[weightIndex];
        }
    }

    double[] dst2 = new double[src.length];
    foreach(dstPixelIndex, ref pixel; dst2.parallel) {
        pixel = 0;
        foreach(rangeIndex; RANGE * -1 .. RANGE + 1) {
            auto dstPixelIndexX = dstPixelIndex % w;
            auto dstPixelIndexY = dstPixelIndex / w + rangeIndex;
            if (dstPixelIndexY < 0) dstPixelIndexY = 0;
            if (dstPixelIndexY >= h) dstPixelIndexY = h - 1;
            const srcPixelIndex = dstPixelIndexX + dstPixelIndexY * w;
            const weightIndex = abs(rangeIndex);
            pixel += dst1[srcPixelIndex] * kernel[weightIndex];
        }
    }

    ubyte[] r = new ubyte[src.length];
    foreach(i, ref b; r.parallel) {
        int a = dst2[i].to!int;
        if (a < 0) a = 0;
        if (a > 255) a = 255;
        b = a.to!ubyte;
    }

    return r;
}
