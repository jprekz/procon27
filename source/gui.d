module gui;

import meu2d;

import imagetovec;
import projection;

import imageformats;

import std.algorithm;
import std.range;
import std.conv : to;

class GUI : GameObject {
    MeuLogger meuLogger;
    Vec!double[][] pathes;
    Texture image;

    Vec!double pos = Vec!double(0, 0);
    double scale = 1.0;

    Vec!double mouse;
    Vec!double beforeMouse;

    bool click;
    bool beforeClick;
    bool clickR;
    bool keyA;
    bool beforeKeyA;

    this() {
        import std.stdio : File;
        import std.string;
        meuLogger = new MeuLogger(30, "mplus-1p-regular.ttf");
        global.add(meuLogger.getGameObject, int.max);
        IFImage im = read_image("testimg/DSC_0023_820.jpg", ColFmt.RGB);
        pathes = imageToPathes(im);
        image = Texture(im.pixels.chunks(3).map!(c => c ~ 255).joiner.array, im.w, im.h);
        /*
        auto params = calcProjParams(
            [[0.0,0.0],[0.0,100.0],[100.0,100.0],[100.0,0.0]],
            [[0.0,0.0],[0.0,100.0],[95.0,95.0],[100.0,0.0]]
        );
        foreach(ref path; pathes) {
            foreach(ref vec; path) {
                vec = vec.projectionTrans(params);
            }
        }
        */
    }

    long ti, tj;
    override void update() {
        beforeMouse = mouse;
        mouse = Vec!double(Mouse.x, Mouse.y);
        beforeClick = click;
        click = Mouse.L || Key!"F";
        clickR = Mouse.R || Key!"SPACE";
        beforeKeyA = keyA;
        keyA = Key!"A".isPressed;

        if (Mouse.wheelY != 0) {
            scale *= 1 + (Mouse.wheelY * 0.05);
        }
        if (clickR) {
            pos = pos + mouse - beforeMouse;
        }

        foreach(i, path; pathes) foreach(j, vec; path) {
            const vi = vec * scale + pos;
            if (Mouse.x > vi.x.to!int - 4 && Mouse.x < vi.x.to!int + 4 &&
                Mouse.y > vi.y.to!int - 4 && Mouse.y < vi.y.to!int + 4) {
                if (click && !beforeClick) {
                    ti = i;
                    tj = j;
                }
            }
            if (click && i == ti && j == tj) {
                pathes[i][j] = (mouse - pos) / scale;
                if (Key!"D") {
                    ti = -1;
                    tj = -1;
                    pathes[i] = pathes[i][0 .. j] ~ pathes[i][j+1 .. $];
                    if (pathes[i].length == 0) {
                        pathes = pathes[0 .. i] ~ pathes[i+1 .. $];
                    }
                } else if (keyA && !beforeKeyA) {
                    pathes[i] = pathes[i][0 .. j] ~ pathes[i][j] ~ pathes[i][j .. $];
                }
            }
        }

        if (!click) {
            ti = -1;
            tj = -1;
        }
    }

    override void draw() {
        image.draw(pos.x.to!int, pos.y.to!int, (image.width * scale).to!int, (image.height * scale).to!int);
        foreach(ref path; pathes) {
            auto before = path[$ - 1] * scale + pos;
            foreach(i, vec; path) {
                vec = vec * scale + pos;
                setDrawColor(Color(255, 255, 255, 127));
                drawLine(before.x.to!int, before.y.to!int, vec.x.to!int, vec.y.to!int);
                before = vec;

                if (Mouse.x > vec.x.to!int - 4 && Mouse.x < vec.x.to!int + 4 &&
                    Mouse.y > vec.y.to!int - 4 && Mouse.y < vec.y.to!int + 4) {
                    setDrawColor(Color(0, 0, 255, 127));
                    drawRect(vec.x.to!int - 5, vec.y.to!int - 5, 11, 11);
                } else {
                    setDrawColor(Color(255, 0, 0, 255));
                    drawRect(vec.x.to!int - 3, vec.y.to!int - 3, 7, 7);
                }
            }
        }
    }
}
