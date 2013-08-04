# Copyright (C) 2012-2013 Leap Motion, Inc. All rights reserved.        *
# Leap Motion proprietary and confidential. Not for distribution.       *
# Use subject to the terms of the Leap Motion SDK Agreement available at*
# https:#developer.leapmotion.com/sdk_agreement, or another agreement  *
# between Leap Motion and you, your company or other organization.      *

java_import 'java.io.IOException'
#import org.newdawn.slick.AppGameContainer
#import org.newdawn.slick.SlickException


class SampleListener < LeapMotion::Listener
  attr_accessor :avoid

  #def initialize(avoid)
  #  @avoid = avoid
  #  avoid.mouse = false
  #end

  def onInit(controller)
    puts "Initialized"
  end

  def onConnect(controller)
    puts "Connected"
  end

  def onDisconnect(controller)
    puts "Disconnected"
  end

  def onExit(controller)
    puts "Exited"
  end

  def onFrame(controller)
    # Get the most recent frame and report some basic information
    frame = controller.frame()

    return if frame.hands.empty
    # Get the first hand
    hand = frame.hands.first

    # Check if the hand has any fingers
    fingers = hand.fingers
    return if fingers.empty

    # Calculate the hand's average finger tip position
    avgPos = LeapMotion::Vector.zero
    fingers.each do |finger|
      # add the position vectors up for each finger
      avgPos = avgPos.plus(finger.tipPosition)
    end

    # divide the position vectors by the number of fingers
    avgPos = avgPos.divide(fingers.count)

    # scale the x position to the game resolution
    x = (avgPos.getX.to_f + 100) * 6

    # scale the y position to the game resolution
    y = 1000 - (3.0 * avgPos.getY)

    x, y = normalize(x, y)

    # z-axis value for the laser
    z = avgPos.getZ.to_f

    if (!avoid.gameOver)
      # move the player to the position
      avoid.movePlayer(x, y)

      # if you lean your hand forward enough,
      # this will shoot the laser
      if (z <= -120)
        avoid.shootLaser
      else  # stop shooting the laser if the hand does
        # not goin far enough
        avoid.stopShootLaser()
      end
    end
  end


  MIN_DIST = 5
  MAX_DIST = 20
  def normalize(x, y)
    @prev_y ||= y
    @prev_x ||= x

    change_y = y - @prev_y
    change_x = x - @prev_x

    dir_y = change_y / change_y.abs
    dir_x = change_x / change_x.abs

    calc_y = [y, MAX_DIST * dir_y].max
    calc_y = 0 if calc_y < (MIN_DIST * dir_y)

    calc_x = [x, MAX_DIST * dir_x].max
    calc_x = 0 if calc_x < (MIN_DIST * dir_x)

    #puts "normalized: [#{x}, #{y}], [#{calc_x}, #{calc_y}], [#{x - calc_x}, #{y - calc_y}]"

    @prev_y = calc_y
    @prev_x = calc_x

    [calc_x, calc_y]
  end
end

class LeapControl
  def self.main(*args)

    avoid = Avoid.new("Avoid Game", true, false)
    # Create a sample listener and controller
    listener = SampleListener.new
    listener.avoid = avoid
    app = Slick::AppGameContainer.new(avoid)

    controller = LeapMotion::Controller.new

    # Have the sample listener receive events from the controller
    controller.addListener(listener)
    app.setDisplayMode(1280, 768, false)
    app.setShowFPS(false)
    app.start

    # Keep this process running until Enter is pressed
    System.out.println("Press Enter to quit...")
    begin
      gets
    rescue IOException => e
      binding.pry
      puts "========= Error =========="
      puts e.backtrace
    end

    # Remove the sample listener when done
    controller.removeListener(listener)
  end
end