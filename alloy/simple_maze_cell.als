module maze_maker/simple_maze

open util/ordering[Col] as cols
open util/ordering[Row] as rows

// 隣接する Cell
fun adjacent (c: Cell) : Cell {
  let col = cell.c.Row, row = cell.c[Col] |
    cell[col.prev, row] +
    cell[col.next, row] +
    cell[col, row.prev] +
    cell[col, row.next]
}

sig Cell {
  link: some Cell
} {
  // 自分自身との接続はなし
  no this & link
  // 接続先は必ず隣接する(4近傍の) Cell
  link in adjacent[this]
}

one sig Entrance extends Cell {}
one sig Exit extends Cell {}

sig Col {
  cell: Row -> one Cell
}
sig Row {}

//  Cell が盤の端
pred edge (c: Cell) {
  let col = cell.c.Row, row = cell.c[Col] |
    col = cols/first or col = cols/last or row = rows/first or row = rows/last
}

fact {
  // cell に含まれない Cell はなし
  all c: Cell | c in Row.(Col.cell)
  // Row, Col が異なったら Cell も必ず異なる
  all c1, c2: Col, r1, r2: Row | (c1 != c2 or r1 != r2) => no (cell[c1, r1] & cell[c2, r2])
  // link の連結は反射的
  link = ~link
  // 全ての Cell は link で繋がる
  all c: Cell | c.^link = Cell
  // 入口と出口はいずれも盤面の端に位置する
  edge[Entrance]
  edge[Exit]
}

run {
  #Col = 3
  #Row = 3
} for 3 but 9 Cell
