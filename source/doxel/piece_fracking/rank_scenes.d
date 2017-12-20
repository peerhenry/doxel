import chunkscene;

interface IRankScenes
{
  IChunkScene[] getScenes(int rank);
}

struct ScenesInRank
{
  int rank;
  IChunkScene[] scenes;
}

class RankScenes: IRankScenes
{
  private IChunkScene[][int] _scenesByRank;

  this(ScenesInRank[] scenesByRank)
  {
    int nextRank = 0;
    foreach(scenesInRank; scenesByRank)
    {
      foreach(i; nextRank..(scenesInRank.rank+1))
      {
        _scenesByRank[i] = scenesInRank.scenes;
      }
      nextRank = scenesInRank.rank+1;
    }
  }

  IChunkScene[] getScenes(int rank)
  {
    return _scenesByRank[rank];
  }

  unittest{
    import testrunner;
    import engine, chunk;

    class MockChunkScene: IChunkScene
    {
      SceneObject createSceneObject(Chunk[] chunks){ return null; }
      void remove(SceneObject so){}
      void draw(){}
    }

    runsuite("RankScenes", delegate void(){

      runtest("test scenes by rank", delegate void(){
        // arrange
        ScenesInRank[] scenesByRank = [ ScenesInRank(2, [new MockChunkScene(), new MockChunkScene()]), ScenesInRank(4, [new MockChunkScene()]) ];
        RankScenes rankScenes = new RankScenes(scenesByRank);
        // act
        IChunkScene[] scenes0 = rankScenes.getScenes(0);
        IChunkScene[] scenes1 = rankScenes.getScenes(1);
        IChunkScene[] scenes2 = rankScenes.getScenes(2);
        IChunkScene[] scenes3 = rankScenes.getScenes(3);
        IChunkScene[] scenes4 = rankScenes.getScenes(4);
        // assert
        assertEqual(2, scenes0.length);
        assertEqual(2, scenes1.length);
        assertEqual(2, scenes2.length); // CHECK THIS
        assertEqual(1, scenes3.length);
        assertEqual(1, scenes4.length);
      });

    });
  }
}