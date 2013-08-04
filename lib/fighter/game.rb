#import java.util.ArrayList
#import java.util.Random

class Game
  attr_reader :planes
  attr_reader :score, :height, :width

  def initialize(num_planes, width, height)
    @width = width
    @height = height
    x = width
    @score = 0
    @planes = []
    @planes += num_planes.times.map do |_|
      Plane.new(
        gen_location,
        -height,
        width,
        height,
        gen_speed,
        true
      )
    end
  end

    # Adds a new plane to the game by adding it to list of planes
  def add_plane()
    planes << Plane.new(
      gen_location,
      0,
      width,
      height,
      gen_speed(),
      true
    )
  end

  def reset_score
    score = 0
  end

  # Generates a random speed for a plane
  def gen_speed
    rand + 15.0
  end

  # Checks to see if you can place a plane so that this x coordinate
  # does not collide horizontally with any plane
  def can_place(position)
    planes.none? do |plane|
      plane.wings.in_horizontal_range(BoundingBox.new(position, position + width, 0, 0))
    end
  end

   # Generates a valid x position in a horizontal range that is not
   #  occupied by a current plane
  def gen_location
    while true do
      position = rand(Avoid::SCREEN_W - height)
      return position if can_place(position)
    end
  end

  def move_planes(laser, laserX, laserWidth, laserHeight)
    # Create a bounding box for the laser if there is a laser.
    # Otherwise, the bounding box reference is null
    laser_range = laser ? BoundingBox.new(laserX, laserX +  laserWidth, 0, laserHeight) : nil

    #binding.pry if laser_range
    planes.each do |plane|
      # Check if the plane is hit by a laser or
      # if this plane is below is below the bottom of the screen

      if (laser_range && laser_range.in_range(plane.wings)) || plane.y > Avoid::SCREEN_H
        # moves plane to the top with new x coordinate/speed
        plane.updateEnemy(gen_location, -plane.height, gen_speed)
      else
        @advanced = true if plane.advance
      end
    end
    @score += 1 if @advanced
  end

  def check_lose(player)
    planes.any? { |plane| plane.isColliding(player) }
  end
end