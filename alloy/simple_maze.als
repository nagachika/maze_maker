module maze_maker/simple_maze

open util/ordering[Col] as cols
open util/ordering[Row] as rows

// 迷路のサイズ
fun height : Int {
  3
}
fun width: Int {
  3
}

// 隣接する Cell
fun adjacent (col: Col, row: Row) : Col -> Row {
  col.prev -> row +
  col.next -> row +
  col -> row.prev +
  col -> row.next
}

sig Col {
  paths: Row -> Col -> Row
} {
  // 自分自身との接続はなし
  all row: Row | no (this -> row) & row.paths
  // 接続先は必ず隣接する(4近傍の) Cell
  all row: Row | row.paths in adjacent[this, row]
}
sig Row {}

one sig entrance_x extends Col {}
one sig entrance_y extends Row {}
one sig exit_x extends Col {}
one sig exit_y extends Row {}

//  位置が盤の端
pred edge (col: Col, row: Row) {
  col = cols/first or col = cols/last or row = rows/first or row = rows/last
}

fact {
  // 全ての位置が paths に含まれている
  all col: Col, row: Row | (col -> row) in paths[Col, Row]
  // paths の連結は反射的
  all c1, c2: Col, r1, r2: Row | (c1 -> r1 -> c2 -> r2) in paths => (c2 -> r2 -> c1 -> r1) in paths
  // 入口と出口はいずれも盤面の端に位置する
  edge[entrance_x, entrance_y]
  edge[exit_x, exit_y]
}

run {
  #Col = width[]
  #Row = height[]
} for 3
