import gfm.math:vec2i;

interface IColumnSiteProvider
{
  vec2i[] getColumnSites(vec2i center);
}