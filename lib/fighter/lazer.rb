class Laser
  attr_reader :energy

  def initialize
    @energy = 100.0
  end


  def resetEnergy
    @energy = 100.0
  end

  def isDepleted
    energy == 0.0
  end

  def canFire
    energy > 20.0
  end

  def deplete
    @energy = [energy - 4.0, 0.0].max
  end

  def regen
    @energy = [energy + 0.1, 100.0].min
  end
end
