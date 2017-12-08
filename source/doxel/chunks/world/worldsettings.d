import gfm.math;

immutable static int regionWidth = 16;
immutable static int regionLength = 16;
immutable static int regionHeight = 8;
immutable static int regionCount = regionWidth*regionLength*regionHeight;
immutable static vec3i regionSize = vec3i(regionWidth, regionLength, regionHeight);
immutable static vec3i siteMax = vec3i(regionWidth-1, regionLength-1, regionHeight-1);
immutable static vec3i regionCenter = regionSize/2;

unittest{
  import testrunner;
  runsuite("world settiings", delegate void(){
    runtest("regionCenter", delegate void(){
      assertEqual(regionWidth/2, regionCenter.x);
      assertEqual(regionLength/2, regionCenter.y);
      assertEqual(regionHeight/2, regionCenter.z);
    });

    runtest("siteMax", delegate void(){
      assertEqual(regionWidth-1, siteMax.x);
      assertEqual(regionLength-1, siteMax.y);
      assertEqual(regionHeight-1, siteMax.z);
    });
  });
}