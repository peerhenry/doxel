import gfm.math;
import engine;
import doxel_scene, chunk, worldsettings, limiter;
struct Zone
{
  float loadRange;
  float unloadRange;
  float loadRangeSquared;
  float unloadRangeSquared;
  ChunkScene[] scenes;
  
  this(float loadRange, float unloadRange, ChunkScene[] scenes)
  {
    assert(unloadRange > loadRange);
    this.loadRange = loadRange;
    loadRangeSquared = loadRange*loadRange;
    this.unloadRange = unloadRange;
    unloadRangeSquared = unloadRange*unloadRange;
    this.scenes = scenes;
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
    SceneObject[] sceneObjects;
    vec3f min, max, center;
    Limiter modelLimiter;
    bool validToModel;
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
    sceneObjects = [null, null];
  }

  void calcMinMax()
  {
    min = vec3f(float.max, float.max, float.max);
    float FLOAT_MIN = -9999999.0;
    max = vec3f(FLOAT_MIN, FLOAT_MIN, FLOAT_MIN);
    foreach(chunk; chunks)
    {
      vec3f nextPos = chunk.getPosition();
      if(nextPos.x+regionWidth > max.x) max.x = nextPos.x+regionWidth;
      if(nextPos.y+regionLength > max.y) max.y = nextPos.y+regionLength;
      if(nextPos.z+regionHeight > max.z) max.z = nextPos.z+regionHeight;
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
    validateModel();
    if(newZoneIndex != boundZoneIndex && !modelLimiter.limitReached())
    {
      if(boundZoneIndex > 0) removeFromScene();
      if(newZoneIndex > 0 && validToModel)
      {
        foreach(i, scene; zones[newZoneIndex].scenes)
        {
          sceneObjects[i] = zones[newZoneIndex].scenes[i].createSceneObject(chunks);
          modelLimiter.increment();
        }
      }
      boundZoneIndex = newZoneIndex;
    }
  }

  void validateModel()
  {
    validToModel = false;
    foreach(chunk; chunks)
    {
      if(chunk.hasAnyVisisbleBlocks)
      {
        validToModel = true;
        break;
      }
    }
  }

  private void removeFromScene()
  {
    foreach(i, scene; zones[boundZoneIndex].scenes)
    {
      auto oldScene = zones[boundZoneIndex].scenes[i];
      if(sceneObjects[i] !is null)
      {
        oldScene.remove(sceneObjects[i]);
        sceneObjects[i].destroy;
        sceneObjects[i] = null;
      }
    }
    boundZoneIndex = 0;
  }
}