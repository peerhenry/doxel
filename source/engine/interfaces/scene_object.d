import gfm.math:mat4f;
import drawable, i_bounding_box_container;
interface SceneObject : Drawable, IBoundingBoxContainer
{
  @property mat4f modelMatrix();
}