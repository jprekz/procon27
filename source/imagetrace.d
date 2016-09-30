module imagetrace;

import type;

// data ... 二値化(0または255)済みのラスタデータ
Vec!int[][] trace(const ubyte[] inputData, int height, int width) {
    assert(inputData.length == height * width);

    ubyte getPixel(int x, int y) { return inputData[x + y * width]; }

    Vec!int[][] pathes;

    bool[] usedVertices = new bool[inputData.length];
    foreach(const y; 1 .. height) foreach(const x; 1 .. width) {
        // find vertex
        if (getPixel(x - 1, y - 1) == getPixel(x, y - 1) &&
            getPixel(x - 1, y - 1) == getPixel(x - 1, y) &&
            getPixel(x - 1, y - 1) == getPixel(x, y)) continue;
        if (usedVertices[x + y * width]) continue;

        //trace Path
        Vec!int[] path;
        auto pos = Vec!int(x, y);
        while(!usedVertices[pos.x + pos.y * width]) {
            path ~= pos;
            usedVertices[pos.x + pos.y * width] = true;

            ubyte[4] fourPixels = [
                getPixel(pos.x - 1, pos.y - 1), getPixel(pos.x    , pos.y - 1),
                getPixel(pos.x - 1, pos.y    ), getPixel(pos.x    , pos.y    )
            ];
            if (fourPixels[2] == 0 && fourPixels[3] == 255) {
                pos = Vec!int(pos.x, pos.y + 1);
            } else if (fourPixels[1] == 255 && fourPixels[3] == 0) {
                pos = Vec!int(pos.x + 1, pos.y);
            } else if (fourPixels[0] == 255 && fourPixels[1] == 0) {
                pos = Vec!int(pos.x, pos.y - 1);
            } else {
                pos = Vec!int(pos.x - 1, pos.y);
            }
        }

        pathes ~= path;
    }

    return pathes;
}
