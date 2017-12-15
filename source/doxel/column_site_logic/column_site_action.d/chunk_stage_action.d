import std.array;
import i_column_site_action, chunkstage, column_site_queue_item, doxel_world;

class StageBuffer
{
  private Appender!(Chunk[]) _chunks;
  @property Chunk[] chunks() { return _chunks.data(); }
  private int _count;
  @property int count(){ return _count; }
  private int _limit;
  private ChunkStage _stage;
  private QueueItemGroup _itemGroup;

  this(ChunkStage stage, int limit)
  {
    _limit = limit;
    _stage = stage;
  }

  void addQueueItem(ColumnSiteQueueItem item)
  {
    if(_count == 0) _itemGroup = new QueueItemGroup();
    _itemGroup.add(item);
    _chunks.put( item.chunks.dup );
    _count++;
    if(_count == _limit) flush(_stage);
  }

  void flush(ChunkStage stage)
  {
    stage.createStageObject( _chunks.data().dup );
    _chunks.clear();
    _count = 0;
  }
}

class ChunkStageAction: IColumnSiteAction
{
  private ChunkStage _stage;
  private World _world;
  private StageBuffer _buffer;
  private StageBuffer _nearBuffer;
  private StageBuffer _mediumBuffer;
  private StageBuffer _farBuffer;
  private float _stageRangeSquared;

  this(ChunkStage stage, World world, float stageRange)
  {
    _stage = stage;
    _world = world;
    _nearBuffer = new StageBuffer(stage, 3);
    _mediumBuffer = new StageBuffer(stage, 5);
    _farBuffer = new StageBuffer(stage, 7);
  }

  void perform(ColumnSiteQueueItem qItem)
  {
    if(qItem.state == ColumnSiteState.ON_STAGE)
    {
      // if its on stage by itself, check if needs to be put in a group.
    }
    else if(qItem.state == ColumnSiteState.IN_GROUP)
    {
      
    }
    else
    {
      auto action = getDistanceAction(qItem);
      action(qItem);
    }
  }

  private void delegate(ColumnSiteQueueItem) getDistanceAction(ColumnSiteQueueItem qItem)
  {
    if(qItem.camDistanceSq > 90000) return getBufferAction(_farBuffer);
    if(qItem.camDistanceSq > 40000) return getBufferAction(_mediumBuffer);
    if(qItem.camDistanceSq > 10000) return getBufferAction(_nearBuffer);
    return getStageAdd();
  }

  private void delegate(ColumnSiteQueueItem) getBufferAction(StageBuffer buffer)
  {
    return delegate void(ColumnSiteQueueItem item){
      buffer.addQueueItem( item );
      item.state = ColumnSiteState.IN_GROUP;
    };
  }

  private void delegate(ColumnSiteQueueItem) getStageAdd()
  {
    return delegate void(ColumnSiteQueueItem item){
      _stage.createStageObject( item.chunks.dup );
      item.state = ColumnSiteState.ON_STAGE;
    };
  }
}