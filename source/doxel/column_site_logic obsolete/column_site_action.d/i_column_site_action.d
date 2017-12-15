import column_site_queue_item;

interface IColumnSiteAction
{
  void perform(ColumnSiteQueueItem qItem);
}