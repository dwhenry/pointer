
class Transparent
  attr_reader :frame

  def initialize
    Swing::JFrame.setDefaultLookAndFeelDecorated(true)
    @frame = Swing::JFrame.new("Test")
    frame.setAlwaysOnTop(true)
    frame.setUndecorated(true)

    frame.setDefaultCloseOperation(Swing::JFrame::EXIT_ON_CLOSE)
    frame.pack()
    frame.setVisible(true)
    SunAwt::AWTUtilities.setWindowOpaque(frame, false)

    frame.setLocation(Awt::Point.new(0, 0));
  end

  def width
    @width ||= begin
      screenSize = Awt::Toolkit.getDefaultToolkit.getScreenSize
      @height = screenSize.getHeight()
      screenSize.getWidth()
    end
  end

  def height
    @height ||= begin
      screenSize = Awt::Toolkit.getDefaultToolkit.getScreenSize
      @width = screenSize.getWidth()
      screenSize.getHeight()
    end
  end

  class JPanelComponent < Swing::JPanel
    def initialize(width, height, x, y)
      @width, @height = width, height
      @x, @y = x, y
      super()
    end

    def paintComponent(g)
      g2 = g.create

      # g2.setColor(Awt::Color.gray)
      # g2.fillRect(0, 0, width, height)
      g2.setComposite(Awt::AlphaComposite::Clear)
      g2.fillRect(0, 0, width, height)

      return if @x == -1 or @y == -1
      g2.setComposite(Awt::AlphaComposite::Src)
      g2.setColor(Awt::Color.red)
      g2.fillOval(@x, @y, 50, 50)
    end
  end

  def set_panel(x=nil, y=nil)
    x ||= rand(width)
    y ||= rand(height)

    panel = JPanelComponent.new(width, height, x, y)

    panel.setPreferredSize(Awt::Dimension.new(width, height))
    frame.getContentPane.add(panel)
    frame.pack
  end
end


