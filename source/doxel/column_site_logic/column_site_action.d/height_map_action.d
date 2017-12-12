import gfm.math:vec2i;
import column_site_queue_item, i_column_site_action, height_provider, worldsettings;

class HeightMapAction: IColumnSiteAction
{
  private HeightProvider _heightProvider;

  this(HeightProvider heightProvider)
  {
    _heightProvider = heightProvider;
  }

  void perform(ColumnSiteQueueItem qitem)
  {
    generateHeights(qitem.site);
    qitem.state = ColumnSiteState.HAS_HEIGHT;
  }

  private void generateHeights(vec2i site)
  {
    int imin = site.x*regionWidth;
    int imax = imin + regionHeight;
    int jmin = site.y*regionLength;
    int jmax = jmin + regionLength;
    foreach(ii; imin..imax)
      foreach(jj; jmin..jmax)
      {
        _heightProvider.getHeight(ii,jj); //generates heights
      }
  }
}