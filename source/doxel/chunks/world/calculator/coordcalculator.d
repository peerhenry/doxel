import std.math;
import gfm.math;
import worldsettings;
class CoordCalculator
{
  static:

  vec3f worldSiteRelativeTo(vec3i[int] worldSite, vec3i[int] worldSiteRef)
  {
    vec3f relPos = vec3f(0,0,0);
    int nextRank = 1;
    bool RefSiteHasNext, thisSiteHasNext = true;
    while(RefSiteHasNext || thisSiteHasNext)
    {
      RefSiteHasNext = (nextRank in worldSiteRef) !is null;
      thisSiteHasNext = (nextRank in worldSite) !is null;
      vec3i nextRefSite = RefSiteHasNext ? worldSiteRef[nextRank] : regionCenter;
      vec3i nextSite = thisSiteHasNext ? worldSite[nextRank] : regionCenter;
      relPos.x += (nextSite.x - nextRefSite.x)*pow(regionWidth, nextRank);
      relPos.y += (nextSite.y - nextRefSite.y)*pow(regionLength, nextRank);
      relPos.z += (nextSite.z - nextRefSite.z)*pow(regionHeight, nextRank);
      nextRank++;
    }
    return relPos;
  }
}

unittest
{
  import testrunner;

  runtest("worldSiteRelativeTo only separated on rank 1", delegate bool() {
    vec3i[int] worldSite, worldSiteRef;
    worldSite[1] = vec3i(2,2,2);
    worldSite[2] = vec3i(3,4,1);
    worldSiteRef[1] = vec3i(1,1,1);
    worldSiteRef[2] = vec3i(3,4,1);
    vec3f result = CoordCalculator.worldSiteRelativeTo(worldSite, worldSiteRef);
    assertEqual(cast(float)regionWidth, result.x);
    assertEqual(cast(float)regionLength, result.y);
    assertEqual(cast(float)regionHeight, result.z);
    return true;
  });

  runtest("worldSiteRelativeTo separated by rank 1 and rank 2", delegate bool() {
    vec3i[int] worldSite, worldSiteRef;
    worldSite[1] = vec3i(2,2,2);
    worldSite[2] = vec3i(3,4,1);
    worldSiteRef[1] = vec3i(1,1,1);
    worldSiteRef[2] = vec3i(2,3,0);
    vec3f result = CoordCalculator.worldSiteRelativeTo(worldSite, worldSiteRef);
    assertEqual(pow(regionWidth, 2) + cast(float)regionWidth, result.x);
    assertEqual(pow(regionLength, 2) + cast(float)regionLength, result.y);
    assertEqual(pow(regionHeight, 2) + cast(float)regionHeight, result.z);
    return true;
  });

  runtest("worldSiteRelativeTo; one has no rank 2", delegate bool() {
    vec3i[int] worldSite, worldSiteRef;
    worldSite[1] = vec3i(2,2,2);
    worldSiteRef[1] = vec3i(1,1,1);
    worldSiteRef[2] = vec3i(2,3,0);
    vec3f result = CoordCalculator.worldSiteRelativeTo(worldSite, worldSiteRef);
    assertEqual(2*pow(regionWidth, 2) + cast(float)regionWidth, result.x);
    assertEqual(pow(regionLength, 2) + cast(float)regionLength, result.y);
    assertEqual(2*pow(regionHeight, 2) + cast(float)regionHeight, result.z);
    return true;
  });
}