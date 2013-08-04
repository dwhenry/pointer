class Plane
  attr_reader :x, :y, :width, :height, :speed
  attr_reader :body, :wings, :enemy

  def initialize(x, y, width, height, speed, enemy)
    @x = x
    @y = y
    @width = width
    @height = height
    @speed = speed
    @enemy = enemy
    build_bounding_boxes
  end

  def advance
    if @last_advance != (Time.now.to_f * 40).to_i
      @last_advance = (Time.now.to_f * 40).to_i
      @y += speed
      build_bounding_boxes
    end
  end

  def isColliding(plane)
    body.in_range(plane.body) || body.in_range(plane.wings) ||
    wings.in_range(plane.body) || wings.in_range(plane.wings)
  end

  def updatePlayer(x, y)
    @x = x
    @y = y
    body.update(x + width / 2 - 5, x + width / 2 + 5, y, y + height)
    wings.update(x, x + width, y + height / 2, y + height - 20)
  end

  def updateEnemy(x, y, speed)
    @x = x
    @y = y
    @speed = speed
    body.update(x + width / 2 - 5, x + width / 2 + 5, y, y + height)
    wings.update(x, x + width, y + 20, y + height / 2)
  end

private

  def build_bounding_boxes
    # Horizontal Coordinates
    # Body
    bodyLeft = x + (width / 2) - 5
    bodyRight = x + (width / 2) + 5
    # Wing
    wingLeft = x
    wingRight = x + width

    bodyTop = y + height
    bodyBottom = y

    wingBottom = (enemy) ? (y + 50) : y + (height / 2)
    wingTop = (enemy) ? y + (height / 2) : (y + height)

    @body = BoundingBox.new(bodyLeft, bodyRight, bodyBottom, bodyTop)
    @wings = BoundingBox.new(wingLeft, wingRight, wingBottom, wingTop)
  end
end
