class BoundingBox
  attr_reader :width, :height, :left, :right, :top, :bottom

  def initialize(left, right, bottom, top)
    update(left, right, bottom, top)
  end

  def update(left, right, bottom, top)
    @left = left
    @right = right
    @top = top
    @bottom = bottom
    @width = right - left
    @height = top - bottom
  end

  def in_horizontal_range(bounding_box)
    left <= bounding_box.right && bounding_box.left <= right
  end

  def in_vertical_range(bounding_box)
    top >= bounding_box.bottom && bounding_box.top >= bottom
  end

  def in_range(bounding_box)
    in_horizontal_range(bounding_box) &&
    in_vertical_range(bounding_box)
  end
end
