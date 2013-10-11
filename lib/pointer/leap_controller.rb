# Copyright (C) 2012-2013 Leap Motion, Inc. All rights reserved.        *
# Leap Motion proprietary and confidential. Not for distribution.       *
# Use subject to the terms of the Leap Motion SDK Agreement available at*
# https:#developer.leapmotion.com/sdk_agreement, or another agreement  *
# between Leap Motion and you, your company or other organization.      *

java_import 'java.io.IOException'

class SampleListener < LeapMotion::Listener
  attr_accessor :pointer, :screen_size

  def onInit(controller)
    puts "Initialized"
    # @g = Graphics2D.create(0, 0, *screen_size)
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
    return if fingers.count != 1

    tip = fingers.first.tipPosition

    z = avgPos.getZ.to_i

    if z <= -120
      # TODO: normalize this data to teh actual screen size
      pointer.set_panel(tip.getX.to_i, tip.getY.to_i)
    else
      pointer.set_panel(-1, -1)
    end
  end
end

class LeapControl
  def self.main(*args)
    new.run!
  end

  def run!(*args)
    pointer = Transparent.new

    listener = SampleListener.new
    listener.pointer = pointer

    while true do
      # Testing without leap controller
      pointer.set_panel
      sleep 2
    end

  rescue => e
    binding.pry
  ensure
  end
end