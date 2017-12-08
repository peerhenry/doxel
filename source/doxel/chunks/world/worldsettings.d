import gfm.math;

immutable static int regionWidth = 8;
immutable static int regionLength = 8;
immutable static int regionHeight = 4;
immutable static int regionCount = regionWidth*regionLength*regionHeight;
immutable static vec3i regionSize = vec3i(regionWidth, regionLength, regionHeight);
immutable static vec3i siteMax = vec3i(regionWidth-1, regionLength-1, regionHeight-1);
immutable static vec3i regionCenter = regionSize/2;