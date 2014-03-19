module maze_maker/simple_maze

open util/ordering[Col] as cols
open util/ordering[Row] as rows

// 隣接する Tile
fun adjacent (t: Tile) : Tile {
  let col = tile.t.Row, row = tile.t[Col] |
    tile[col.prev, row] +
    tile[col.next, row] +
    tile[col, row.prev] +
    tile[col, row.next]
}

sig Tile {
  link: some Tile
} {
  // 自分自身との接続はなし
  no this & link
  // 接続先は必ず隣接する(4近傍の) Tile
  link in adjacent[this]
}

one sig Entrance extends Tile {}
one sig Exit extends Tile {}

sig Col {
  tile: Row -> one Tile
}
sig Row {}

//  Tile が盤の端
pred edge (t: Tile) {
  let col = tile.t.Row, row = tile.t[Col] |
    col = cols/first or col = cols/last or row = rows/first or row = rows/last
}

fact {
  // tile に含まれない Tile はなし
  all t: Tile | t in Row.(Col.tile)
  // Row, Col が異なったら Tile も必ず異なる
  all c1, c2: Col, r1, r2: Row | (c1 != c2 or r1 != r2) => no (tile[c1, r1] & tile[c2, r2])
  // link の連結は反射的
  link = ~link
  // 全ての Tile は link で繋がる
  all t: Tile | t.^link = Tile
  // 入口と出口はいずれも盤面の端に位置する
  edge[Entrance]
  edge[Exit]
}

run {
} for exactly 10 Col, exactly 10 Row, exactly 100 Tile
