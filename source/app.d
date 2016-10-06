module app;

import meu2d;
import gui;
mixin gameMain!(() {
    init(640, 480, "test", WindowStatus.resizable);
    global.add(new GUI());
    start();
});
