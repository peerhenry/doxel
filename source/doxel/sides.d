import gfm.math;

enum Side
{
  Top,
  Bottom,
  North,
  South,
  East,
  West
}

struct SideDetails
{
  Side side;
  vec3f normal;
}

immutable SideDetails[] allSides = [
  SideDetails(Side.Top, vec3f(0,0,1)),
  SideDetails(Side.Bottom, vec3f(0,0,-1)),
  SideDetails(Side.North, vec3f(0,1,0)),
  SideDetails(Side.South, vec3f(0,-1,0)),
  SideDetails(Side.East, vec3f(1,0,0)),
  SideDetails(Side.West, vec3f(-1,0,0))
];