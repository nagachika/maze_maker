# coding: utf-8

require "cairo"
require_relative "plloy"

def draw_maze(png, width, height, entrance_pos, exit_pos, paths, scale: 10, margin: 10)
  canvas_x = width * scale + margin * 2
  canvas_y = height * scale + margin * 2
  format = Cairo::FORMAT_ARGB32
  surface = Cairo::ImageSurface.new(format, canvas_x, canvas_y)
  context = Cairo::Context.new(surface)

  # background
  context.set_source_color(Cairo::Color::WHITE)
  context.rectangle(0, 0, canvas_x, canvas_y)
  context.fill

  wall_x = ->(x, y) do
    context.save do
      context.translate(x * scale, y * scale)
      context.stroke do
        context.move_to(0, 0)
        context.line_to(scale, 0)
      end
    end
  end
  wall_y = ->(x, y) do
    context.save do
      context.translate(x * scale, y * scale)
      context.stroke do
        context.move_to(0, 0)
        context.line_to(0, scale)
      end
    end
  end

  # exterior wall
  context.set_source_color(Cairo::Color::BLACK)
  context.translate(margin, margin)
  width.times do |ix|
    # upper
    wall_x[ix, 0] unless (1..(width-2)).include?(ix) and [entrance_pos, exit_pos].include?([ix, 0])
    # bottom
    wall_x[ix, height] unless (1..(width-2)).include?(ix) and [entrance_pos, exit_pos].include?([ix, height-1])
  end
  height.times do |iy|
    # left
    wall_y[0, iy] unless [entrance_pos, exit_pos].include?([0, iy])
    # right
    wall_y[width, iy] unless [entrance_pos, exit_pos].include?([width-1, iy])
  end

  height.times do |iy|
    width.times do |ix|
      unless ix == width-1 or paths[[ix, iy]].include?([ix+1, iy])
        wall_y.call(ix + 1, iy)
      end
      unless iy == height-1 or paths[[ix, iy]].include?([ix, iy+1])
        wall_x.call(ix, iy+1)
      end
    end
  end

  surface.write_to_png(png)
end

xml, png = ARGV

unless xml and png
  $stderr.puts("Usage: #{$0} alloy_output.xml output.png")
  exit false
end

instance = Plloy.load(xml)

xorder = instance.order("cols/Ord")
yorder = instance.order("rows/Ord")

entrance_col, entrance_row, = instance.signature("this/Col").field("tile").tuples.find{|col, row, t| t == instance.signature("Entrance").atoms[0]}
entrance_pos = [xorder.index(entrance_col), yorder.index(entrance_row)]
exit_col, exit_row, = instance.signature("this/Col").field("tile").tuples.find{|col, row, t| t == instance.signature("Exit").atoms[0]}
exit_pos = [xorder.index(exit_col), yorder.index(exit_row)]

paths = instance.signature("this/Tile").field("link").tuples.each_with_object({}) do |(t1, t2), tbl|
  col1, row1, = instance.signature("this/Col").field("tile").tuples.find{|col, row, t| t == t1}
  col2, row2, = instance.signature("this/Col").field("tile").tuples.find{|col, row, t| t == t2}
  pos1 = [xorder.index(col1), yorder.index(row1)].freeze
  pos2 = [xorder.index(col2), yorder.index(row2)].freeze
  tbl[pos1] ||= []
  tbl[pos1] << pos2
end

draw_maze(png, xorder.size, yorder.size, entrance_pos, exit_pos, paths)
p entrance_pos
p exit_pos
p paths
