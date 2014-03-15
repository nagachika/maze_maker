# coding: utf-8

require_relative "plloy"

file, = ARGV

unless file
  $stderr.puts("Usage: #{$0} alloy_output.xml")
  exit false
end

instance = Plloy.load(file)

xorder = instance.order("cols/Ord")
yorder = instance.order("rows/Ord")

entrance = [xorder.index(instance.signature("entrance_x").atoms[0]), yorder.index(instance.signature("entrance_y").atoms[0])]
exit_pos = [xorder.index(instance.signature("exit_x").atoms[0]), yorder.index(instance.signature("exit_y").atoms[0])]

paths = instance.signature("this/Col").field("paths").tuples.map do |col1, row1, col2, row2|
  [ xorder.index(col1), yorder.index(row1), xorder.index(col2), yorder.index(row2) ]
end
p entrance
p exit_pos
p paths
