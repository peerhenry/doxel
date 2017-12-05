 import gfm.math;
 import engine;

 interface IBoundingBoxContainer
 {
    box3f getBoundingBox();

    vec3f[8] getBBCorners();
 }