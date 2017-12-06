import std.math;
import gfm.math;
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
      vec3i nextRefSite = RefSiteHasNext ? worldSiteRef[nextRank] : vec3i(4,4,2);
      vec3i nextSite = thisSiteHasNext ? worldSite[nextRank] : vec3i(4,4,2);
      relPos.x += (nextSite.x - nextRefSite.x)*pow(8, nextRank);
      relPos.y += (nextSite.y - nextRefSite.y)*pow(8, nextRank);
      relPos.z += (nextSite.z - nextRefSite.z)*pow(4, nextRank);
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
    assertEqual(8.0, result.x);
    assertEqual(8.0, result.y);
    assertEqual(4.0, result.z);
    return true;
  });

  runtest("worldSiteRelativeTo separated by rank 1 and rank 2", delegate bool() {
    vec3i[int] worldSite, worldSiteRef;
    worldSite[1] = vec3i(2,2,2);
    worldSite[2] = vec3i(3,4,1);
    worldSiteRef[1] = vec3i(1,1,1);
    worldSiteRef[2] = vec3i(2,3,0);
    vec3f result = CoordCalculator.worldSiteRelativeTo(worldSite, worldSiteRef);
    assertEqual(64+8.0, result.x);
    assertEqual(64+8.0, result.y);
    assertEqual(16+4.0, result.z);
    return true;
  });

  runtest("worldSiteRelativeTo; one has no rank 2", delegate bool() {
    vec3i[int] worldSite, worldSiteRef;
    worldSite[1] = vec3i(2,2,2);
    worldSiteRef[1] = vec3i(1,1,1);
    worldSiteRef[2] = vec3i(2,3,0);
    vec3f result = CoordCalculator.worldSiteRelativeTo(worldSite, worldSiteRef);
    assertEqual(128+8.0, result.x);
    assertEqual(64+8.0, result.y);
    assertEqual(32+4.0, result.z);
    return true;
  });
}