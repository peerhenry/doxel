import gfm.math;
import engine;
import doxel_scene, chunk, limiter;
struct Zone
{
  float loadRange;
  float unloadRange;
  float loadRangeSquared;
  float unloadRangeSquared;
  ChunkScene scene;
  this(float loadRange, float unloadRange, ChunkScene scene)
  {
    assert(unloadRange > loadRange);
    this.loadRange = loadRange;
    loadRangeSquared = loadRange*loadRange;
    this.unloadRange = unloadRange;
    unloadRangeSquared = unloadRange*unloadRange;
    this.scene = scene;
  }
}

class ChunkStageObject: Updatable
{
  private{
    Camera cam;
    int boundZoneIndex; // a higher zone index means closer to the camera
    int newZoneIndex;
    const int innerZoneIndex;
    Zone[int] zones;
    Chunk[] chunks;
    SceneObject sceneObject;
    vec3f min, max, center;
    Limiter modelLimiter;
  }

  this(Camera cam, Zone[int] zones, Chunk[] chunks, Limiter modelLimiter)
  {
    this.cam = cam;
    this.zones = zones;
    this.chunks = chunks.dup;
    this.boundZoneIndex = 0;
    this.modelLimiter = modelLimiter;

    int nextZoneIndex = 1;
    int maxZone = 1;
    while((nextZoneIndex in zones) !is null)
    {
      maxZone = nextZoneIndex;
      nextZoneIndex++;
    }
    innerZoneIndex = maxZone;
    calcMinMax();
  }

  void calcMinMax()
  {
    min = vec3f(float.max, float.max, float.max);
    float FLOAT_MIN = -9999999.0;
    max = vec3f(FLOAT_MIN, FLOAT_MIN, FLOAT_MIN);
    foreach(chunk; chunks)
    {
      vec3f nextPos = chunk.getPosition();
      if(nextPos.x+8 > max.x) max.x = nextPos.x+8;
      if(nextPos.y+8 > max.y) max.y = nextPos.y+8;
      if(nextPos.z+4 > max.z) max.z = nextPos.z+4;
      if(nextPos.x < min.x) min.x = nextPos.x;
      if(nextPos.y < min.y) min.y = nextPos.y;
      if(nextPos.z < min.z) min.z = nextPos.z;
    }
    center = (min+max)*0.5;
  }

  void update(double dt_ms)
  {
    updateZone();
    updateModel();
  }

  private void updateZone()
  {
    float sqDist = squaredDistanceFromCam();
    int nextZoneIndex = boundZoneIndex;
    // check if in loadrange of inward zones
    while(nextZoneIndex < innerZoneIndex && sqDist < zones[nextZoneIndex+1].loadRangeSquared)
    {
      //writeln("chunk stage object is in load range of zone: ", nextZoneIndex+1); // DEBUG
      nextZoneIndex += 1;
    }
    if(nextZoneIndex != boundZoneIndex) newZoneIndex = nextZoneIndex;
    else
    {
      // check if out unloadrange of outward zones
      while(nextZoneIndex > 0 && sqDist > zones[nextZoneIndex].unloadRangeSquared)
      {
        nextZoneIndex -= 1;
      }
      if(nextZoneIndex != boundZoneIndex)
      {
        newZoneIndex = nextZoneIndex;
      }
    }
  }

  private float squaredDistanceFromCam()
  {
    vec3f diff = center - cam.position;
    float sqDistance = diff.x*diff.x + diff.y*diff.y + diff.z*diff.z;
    return sqDistance;
  }

  void updateModel()
  {
    if(newZoneIndex != boundZoneIndex && !modelLimiter.limitReached())
    {
      if(boundZoneIndex > 0) removeFromScene();
      if(newZoneIndex > 0)
      {
        auto scene = zones[newZoneIndex].scene;
        sceneObject = scene.createSceneObject(chunks); 
      }
      boundZoneIndex = newZoneIndex;
    }
  }

  private void removeFromScene()
  {
    auto oldScene = zones[boundZoneIndex].scene;
    oldScene.remove(sceneObject);
    sceneObject.destroy;
    boundZoneIndex = 0;
    sceneObject = null;
  }
}