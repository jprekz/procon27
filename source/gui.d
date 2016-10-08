module gui;

import meu2d;

import imagetovec;
import projection;

import imageformats;

import std.algorithm;
import std.range;
import std.array;
import std.conv : to;

class GUI : GameObject {
    MeuLogger meuLogger;
    Vec!double[][] pathes;
    Texture image;
    Texture[] numLabel;

    int[] pathType = new int[64];
    int[4] outerPathOrder = [-1, -1, -1, -1];

    Vec!double pos = Vec!double(0, 0);
    double scale = 1.0;

    Vec!double mouse;
    Vec!double beforeMouse;

    bool click;
    bool beforeClick;
    bool clickR;
    bool keyA;
    bool beforeKeyA;
    bool keyRETURN;
    bool beforeKeyRETURN;

    this() {
        import std.string;
        meuLogger = new MeuLogger(24, "mplus-1p-regular.ttf");
        global.add(meuLogger.getGameObject, int.max);
        IFImage im = read_image("input.jpg", ColFmt.RGB);
        pathes = imageToPathes(im);
        image = Texture(im.pixels.chunks(3).map!(c => c ~ 255).joiner.array, im.w, im.h);
        numLabel ~= renderText("1", 20, "mplus-1p-regular.ttf", Color(0, 0, 0));
        numLabel ~= renderText("2", 20, "mplus-1p-regular.ttf", Color(0, 0, 0));
        numLabel ~= renderText("3", 20, "mplus-1p-regular.ttf", Color(0, 0, 0));
        numLabel ~= renderText("4", 20, "mplus-1p-regular.ttf", Color(0, 0, 0));
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
        beforeKeyRETURN = keyRETURN;
        keyRETURN = Key!"RETURN".isPressed;

        if (Mouse.wheelY != 0) {
            scale *= 1 + (Mouse.wheelY * 0.05);
        }
        if (clickR) {
            pos = pos + mouse - beforeMouse;
        }

        foreach(i, path; pathes) foreach(j, vec; path) {
            const vi = vec * scale + pos;
            if (Mouse.x > vi.x.to!int - 5 && Mouse.x < vi.x.to!int + 5 &&
                Mouse.y > vi.y.to!int - 5 && Mouse.y < vi.y.to!int + 5) {
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
                } else if (Key!"1" || Key!"2" || Key!"3" || Key!"4") {
                    int order = Key!"1" ? 1 : Key!"2" ? 2 : Key!"3" ? 3 : 4;
                    foreach(ti, t; pathType) {
                        if (t == 1) {
                            if (ti == i) break;
                            pathType[ti] = 0;
                            outerPathOrder = [-1, -1, -1, -1];
                            break;
                        }
                    }
                    pathType[i] = 1;
                    outerPathOrder[order - 1] = j.to!int;
                } else if (Key!"Q") {
                    pathType[i] = 0;
                } else if (Key!"W") {
                    pathType[i] = 2;
                }
            }
        }

        if (!click) {
            ti = -1;
            tj = -1;
            if (keyA && !beforeKeyA) {
                Vec!double[] path = [(mouse - pos) / scale];
                pathes ~= path;
            }
        }

        if (keyRETURN && !beforeKeyRETURN) {
            output();
        }
    }

    override void draw() {
        image.draw(pos.x.to!int, pos.y.to!int, (image.width * scale).to!int, (image.height * scale).to!int);
        foreach(i, ref path; pathes) {
            auto before = path[$ - 1] * scale + pos;
            foreach(j, vec; path) {
                vec = vec * scale + pos;
                setDrawColor(
                    (pathType[i] == 2) ? Color(0, 255, 0, 127)
                    : (pathType[i] == 1) ? Color(0, 0, 255, 127)
                    : Color(255, 255, 255, 127)
                );
                drawLine(before.x.to!int, before.y.to!int, vec.x.to!int, vec.y.to!int);
                before = vec;

                if (j == 0 || j == 1) {
                    numLabel[j].draw(vec.x.to!int, vec.y.to!int);
                }

                if (Mouse.x > vec.x.to!int - 4 && Mouse.x < vec.x.to!int + 4 &&
                    Mouse.y > vec.y.to!int - 4 && Mouse.y < vec.y.to!int + 4) {
                    setDrawColor(Color(0, 0, 255, 127));
                    drawRect(vec.x.to!int - 5, vec.y.to!int - 5, 11, 11);
                } else {
                    setDrawColor(Color(255, 0, 0, 255));
                    drawRect(vec.x.to!int - 3, vec.y.to!int - 3, 7, 7);
                }

                if (pathType[i] == 1) {
                    int order = (j == outerPathOrder[0]) ? 1
                        : (j == outerPathOrder[1]) ? 2
                        : (j == outerPathOrder[2]) ? 3
                        : (j == outerPathOrder[3]) ? 4
                        : -1;
                    if (order != -1) {
                        numLabel[order - 1].draw(vec.x.to!int - 10, vec.y.to!int - 20);
                    }
                }
            }
        }
    }

    private void output() {
        import std.datetime;
        import std.stdio : File;

        if (pathType.count(1) != 1 || pathType.count(2) == 0 || !outerPathOrder.to!(int[]).find(-1).empty) {
            meuLogger.log("[", Clock.currTime.toSimpleString, "] ", "Write error!");
            return;
        }
        auto f = File("output.txt", "w");
        int outerPath;
        foreach(ti, t; pathType) {
            if (t == 1) {
                outerPath = ti.to!int;
                break;
            }
        }
        Vec!double[] op = iota(4).map!(i => pathes[outerPath][outerPathOrder[i]]).array;
        const params = calcProjParams(
            [[op[0].x,op[0].y],[op[1].x,op[1].y],[op[2].x,op[2].y],[op[3].x,op[3].y]],
            [[-1.0,-1.0],[-1.0,1.0],[1.0,1.0],[1.0,-1.0]]
        );
        f.writeln(pathes[outerPath].map!(v => v.projectionTrans(params)).array.pathToString);
        f.writeln;
        foreach(i, path; pathes) {
            if (pathType[i] != 2) continue;
            f.writeln(path.map!(v => v.projectionTrans(params)).array.pathToString);
        }
        f.writeln;
        foreach(i, path; pathes) {
            if (pathType[i] != 0) continue;
            f.writeln(path.map!(v => v.projectionTrans(params)).array.pathToString);
        }
        meuLogger.log("[", Clock.currTime.toSimpleString, "] ", "Write! ", pathes.length);
    }
}
