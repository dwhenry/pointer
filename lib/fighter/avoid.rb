
class Avoid < Slick::BasicGame

  # Window Size============================================
  SCREEN_W = 1280
  SCREEN_H = 768

  # Mouse Control (for testing)=============================
  attr_accessor :mouse

  attr_reader :gameOver

  private

  # Images=================================================
  attr_reader :playerImage, :enemyImage, :spacebackground

  # Game Object============================================
  attr_reader :game

  # Player=================================================
  attr_reader :player, :playerX, :playerY, :playerWidth, :playerHeight

  # Enemy==================================================
  attr_reader :enemyWidth, :enemyHeight

  # Level==================================================
  attr_reader :level, :threshold

  # Draws bounding boxes if true=========================
  attr_reader :diagnostics

  attr_reader :countdown

  # Lasers=================================================
  attr_reader :laser, :curLaserTime
  # width of the laser in pixels
  LASER_W = 100
  # whether or not the laser is firing
  attr_reader :laserFiring


  # Pausing================================================
  # reference time for pausing
  attr_reader :curPauseTime, :paused

  # High Score=============================================
  # Preferences to store high score
  attr_reader :prefs
  # Key for high score for preferences
  HighScoreKey = "highscore"

  attr_reader :menu, :inGame, :resuming

  # Strings=================================================
  # Font to use
  attr_reader :font

  # Static Text
  Title = "Avoid Game"
  PausedMessage = "<Space> to Resume. <Enter> for Menu."
  StartFromMenu = "<Enter> to Start"
  attr_reader :titleWidth, :pausedMessageWidth, :startFromMenuWidth

  # Dynamic Text
  attr_reader :inGameOptions, :countdownTime, :gameOverMessage, :highScoreMessage
  attr_reader :inGameOptionsWidth, :countdownTimeWidth, :gameOverMessageWidth, :highScoreMessageWidth

  public

  def initialize(title, leap, diagnose)
    super(title)
    # Initialize preferences for high score
    @prefs = Preferences.userRoot().node(getClass.getName)
    @mouse = !leap
    @diagnostics = diagnose

    # Game States============================================
    @gameOver = true
    @menu = true

    @laser = Laser.new
    @level = 1
    @threshold = 200
  end

  def init(game_container)# throws SlickException {
                          # Load font (used to center the text)
    @font = Slick::UnicodeFont.new("fonts/font.ttf", 44, false, false)
    font.addAsciiGlyphs
    font.getEffects.add(Slick::ColorEffect.new)
    font.loadGlyphs

    # Load the sprite images
    @playerImage = Slick::Image.new("res/jet.png")
    @spacebackground = Slick::Image.new("res/spacebackground.png")
    @enemyImage = Slick::Image.new("res/enemy.png")

    # Set the dimensions of the internal representation of planes
    @enemyWidth = enemyImage.getWidth()
    @enemyHeight = enemyImage.getHeight()
    @playerWidth = playerImage.getWidth()
    @playerHeight = playerImage.getHeight()

    # Player
    @playerX = (SCREEN_W - playerWidth) / 2
    @playerY = SCREEN_H - (1.5 * playerHeight)
    # create a new player plane object
    @player = Plane.new(playerX, playerY, playerWidth, playerHeight, -1, false)

    # Game object for enemy planes
    @game = Game.new(level, enemyWidth, enemyHeight)

    # Initialize text
    @highScoreMessage = "High Score: #{prefs.getInt(HighScoreKey, 0)}"
    @inGameOptions = " Score: 0 <Space> for Pause"
    @countdownTime = "3"

    # Update text width
    @highScoreMessageWidth = font.getWidth(highScoreMessage)
    @inGameOptionsWidth = font.getWidth(inGameOptions)
    @pausedMessageWidth = font.getWidth(PausedMessage)
    @startFromMenuWidth = font.getWidth(StartFromMenu)
    @countdownTimeWidth = font.getWidth(countdownTime)
    @titleWidth = font.getWidth(Title)

  end

  # This moves the player plane
  def movePlayer(x, y)
    # makes sure you dont move it while the game
    # is in a pause state
    if (!paused && !resuming)
      # makes sure the player doesn't move past the game window
      # both horizontally and vertically
      x = 0 if x < 0
      x = SCREEN_W - playerWidth if x > SCREEN_W - playerWidth

      y = 0 if y < 0
      y = SCREEN_H - playerHeight if y > SCREEN_H - playerHeight

      # updates the x and y coordinates for the sprite
      @playerX = x
      @playerY = y
      # updates the player plane position in the internal game
      player.updatePlayer(playerX, playerY)
    end
  end

  # This shoots a laser
  def shootLaser
    if laser.canFire && !laserFiring
      @laserFiring = true
      startLaserCountdown
    end
  end

  # stops the laser from shooting
  def stopShootLaser
    @laserFiring = false
  end

  # Levels up the game
  def levelUp
    @level += 1
    # every level requires a higher score threshhold score to advance
    @threshold += level * 150

    # after 9 planes, stop adding planes to make it possible to have
    # somewhere to go to dodge the planes if there is not laser
    game.add_plane if level < 9
  end

  # resets the levels back to 1
  def resetLevels
    @level = 1
    @threshold = 200
  end

  # creates a new game
  def reset
    @game = Game.new(level, enemyWidth, enemyHeight)
    resetLevels
    @laserFiring = false
    laser.resetEnergy
    # reset the text to indicate 0 score
    # (used for width to center text)
    inGameOptions = "Score: 0 <Space> for Pause"
    inGameOptionsWidth = font.getWidth(inGameOptions)
  end

  # Resume/Start Game Countdown==========================
  # the countdown by setting a reference timepoint
  def startCountdown
    # get the current time in milliseconds for reference use
    @curPauseTime = Time.now
    # this tells the program to start counting
    @countdown = true
  end

  # checks the number of seconds left until game starts
  def countDown
    # how many seconds left from 3 second countdown
    timeRemaining = 3 - (Time.now - curPauseTime).to_i
    # updates the countdown time string to render
    @countdownTime = timeRemaining.to_s
    @countdownTimeWidth = font.getWidth(countdownTime)
    # countdown is done
    if timeRemaining < 1
      # starting over after a game over
      if (!resuming)
        reset
        @gameOver = false
      else # resuming from a pause
        @resuming = false
        @gameOver = false
      end
      # this tells the program to stop counting
      @countdown = false
    end
  end

  # Laser Countdown=======================================
  # starts the countdown by setting a reference time point
  def startLaserCountdown
    # get the current time in milliseconds for reference use
    @curLaserTime = Time.now.to_f * 1000
  end

  # this manages the laser/every 10 ms depletes the laser by the set amount
  def laserCount
    # the number of seconds since you last fired the laser
    laserElapsedTime = (Time.now.to_f * 1000 - curLaserTime).to_i
    # laser is depleted, stop firing
    if laser.isDepleted
      @laserFiring = false

      # every 10 milliseconds, the laser depletes by the set amount defined
      # in the Laser class
    elsif (laserFiring && laserElapsedTime > 10)
      # update the reference time to detect the next 10 ms
      startLaserCountdown
      # deplete the laser by the amount
      laser.deplete
    end
  end

  def renderPause(game_container, graphics)
    # draw the background image
    spacebackground.draw(0, 0)
    # set the text color to white
    graphics.setColor(Slick::Color.white)
    # draw the pause screen text
    font.drawString(game_container.getWidth() / 2 - pausedMessageWidth / 2,
                    game_container.getHeight() / 2, PausedMessage)
  end

  def renderMenu(game_container, graphics)
    # draw the background image
    spacebackground.draw(0, 0)
    # set the text color to white
    graphics.setColor(Slick::Color.white)
    # Draw the title, start option, and high score text
    font.drawString(SCREEN_W / 2 - titleWidth / 2, SCREEN_H / 2 - 100, Title)
    font.drawString(SCREEN_W / 2 - startFromMenuWidth / 2, SCREEN_H / 2, StartFromMenu)
    font.drawString(SCREEN_W / 2 - highScoreMessageWidth / 2, 480, highScoreMessage)

  end

  def renderGame(game_container, graphics)
    # draw the background
    spacebackground.draw(0, 0)
    # Draw the level number
    font.drawString(0, 0, "Level : #{level}")
    # green for laser
    graphics.setColor(Slick::Color.green)
    playerImage.draw(playerX, playerY)
    # Diagnostics for Bounding Box
    if (diagnostics)
      # Draw bounding boxes
      graphics.drawRect(player.body.left, player.body.bottom, player.body.width, player.body.height)
      graphics.drawRect(player.wings.left, player.wings.bottom, player.wings.width, player.wings.height)
    end
    # draw the laser if firing
    if laserFiring
      graphics.fillRect(playerX, 0, LASER_W, SCREEN_H - (SCREEN_H - playerY))
    end
    # go through all the enemy planes
    game.planes.each do |plane|
      # draw the planes in their current positions
      enemyImage.draw(plane.x, plane.y)

      # Diagnostics for Bounding Box
      if (diagnostics)
        # Draw bounding boxes
        graphics.drawRect(plane.body.left, plane.body.bottom, plane.body.width, plane.body.height)
        graphics.drawRect(plane.wings.left, plane.wings.bottom, plane.wings.width, plane.wings.height)
      end
    end
    # draw the countdown number
    if ((resuming || gameOver) && countdown)
      font.drawString(SCREEN_W / 2 - countdownTimeWidth / 2, SCREEN_H / 3, countdownTime)
    end
    # if there is enough energy to shoot laser, make the laser
    # energy bar green
    if (laser.canFire())
      graphics.setColor(Slick::Color.green)
    else  # red for not enough energy
      graphics.setColor(Slick::Color.red)
    end
    # draw the energy bar for laser
    graphics.fillRect(0, SCREEN_H - 50, laser.energy() * 3, 50)
    # game over message
    if (gameOver && gameOverMessage)
      font.drawString(SCREEN_W / 2 - gameOverMessageWidth / 2, SCREEN_H / 2, gameOverMessage)
    else # draw the current score and the option to pause
      font.drawString(SCREEN_W / 2 - inGameOptionsWidth / 2, 0, inGameOptions)
    end
  end

  def render(game_container, graphics)
    if (paused)
      # Draw paused screen
      renderPause(game_container, graphics)
    elsif (inGame)
      # Draw the game
      renderGame(game_container, graphics)
    elsif (menu)
      # Draw the menu
      renderMenu(game_container, graphics)
    end
    # Limit to 60 fps
    Lwjgl::Display.sync(60)
  end

  def keyPressed(key, char)
    case key
    when Slick::Input::KEY_ENTER
      # go from menu to start a new game
      if (menu)
        reset()
        startCountdown()
        @menu = false
        @inGame = true

      elsif (paused || (gameOver && !countdown))
        # leave from pause screen to menu
        reset()
        @inGame = false
        @gameOver = true
        @menu = true
        @paused = false
      end

    when Slick::Input::KEY_SPACE
      # restart after game over
      if (inGame && gameOver && !countdown)
        startCountdown()
      elsif (inGame)
        @paused = true
        @inGame = false
      elsif (paused)
        # unpause
        @menu = false
        @inGame = true
        @paused = false
        @resuming = true
        startCountdown()
      end
    end
  end

  def update(game_container, delta)
    # if you are in a game and you are resuming/starting a new game after
    # game over, count down to when the game start
    countDown() if (inGame && (gameOver || resuming) && countdown)


    if (!gameOver && inGame && !paused)
      # manages the laser depletion
      laserFiring ? laserCount : laser.regen

      # Mouse control
      if (mouse)
        # Get the mouse input
        input = game_container.getInput()
        movePlayer(input.getMouseX, input.getMouseY)

        if input.isMouseButtonDown(Slick::Input::MOUSE_LEFT_BUTTON)
          shootLaser
        else
          stopShootLaser
        end

      end

      # Move enemy planes (the parameters wont do anything if
      # no lasers are firing (laserFiring == false)
      game.move_planes(laserFiring, playerX, LASER_W, SCREEN_H - (SCREEN_H - playerY))

      # Update the score text and its width
      @inGameOptions = "Score: #{game.score()}. <Space> for Pause"
      @inGameOptionsWidth = font.getWidth(inGameOptions)
      # Check for level up
      if (game.score() > threshold)
         levelUp()
      end

      # Check for loss
      if (game.check_lose(player))
        # set game over to be true to stop the game
        @gameOver = true
        # If you have broken a high score, update it (stored
        # persistently)
        curHighScore = prefs.getInt(HighScoreKey, 0)
        curGameScore = game.score()
        if (curGameScore > curHighScore)
          prefs.putInt(HighScoreKey, curGameScore)
          @highScoreMessage = "High Score: #{prefs.getInt(HighScoreKey, 0)}"
          @highScoreMessageWidth = font.getWidth(highScoreMessage)
        end

        # Update the game over text and its width
        @gameOverMessage = "Game Over. Score: #{game.score()}. <Space> to restart and <Enter> to menu"
        @gameOverMessageWidth = font.getWidth(gameOverMessage)
        # You are done, so just reutn
      end
    end

  end

  def self.main(*args)
    # Creates a new game
    app = Slick::AppGameContainer.new(Avoid.new("Avoid Game", false, true))
    # set the dimensions of the game
    app.setDisplayMode(1280, 768, false)
    # don't show the diagnostic FPS
    app.setShowFPS(true)
    # launch the game
    app.start()
  end
end