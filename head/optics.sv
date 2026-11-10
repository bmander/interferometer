// The bought parts, as plain solids, for the assembly's picture and its clearance claims: the
// beamsplitter cube, the two mirrors, the 532 nm filter, the cube's pad, the pivot ball (as the
// gap it sets), and the camera with its lens.  None of these is printed.

unit mm
use std
use std.solids (union)
use head.prims
use head.dims (cube, h, pad_t, pad_squeeze, press_w, mirror_w, mirror_t, mirror_face,
               carrier_back, kgap, lever, ball, front_out, filter_d, filter_t, board_x, cam_board, cam_ring_d, cam_proud,
               cam_behind, lens_len, lens_d)

component Cube() {
  c := head.prims.Block(x0: -cube / 2, x1: cube / 2, y0: -cube / 2, y1: cube / 2,
                        z0: h - cube / 2, z1: h + cube / 2)
  body := solid(c.body)
}

// the pad between the cube and the lid's post, squeezed
component Pad() {
  p := head.prims.Block(x0: -press_w / 2, x1: press_w / 2, y0: -press_w / 2, y1: press_w / 2,
                        z0: h + cube / 2, z1: h + cube / 2 + pad_t - pad_squeeze)
  body := solid(p.body)
}

// mirror A, in the carrier, facing +y; mirror B, on the boss, facing -x
component MirrorA() {
  m := head.prims.Block(x0: -mirror_w / 2, x1: mirror_w / 2, y0: -mirror_face - mirror_t,
                        y1: -mirror_face, z0: h - mirror_w / 2, z1: h + mirror_w / 2)
  body := solid(m.body)
}
component MirrorB() {
  m := head.prims.Block(x0: mirror_face, x1: mirror_face + mirror_t, y0: -mirror_w / 2,
                        y1: mirror_w / 2, z0: h - mirror_w / 2, z1: h + mirror_w / 2)
  body := solid(m.body)
}

component Filter() {
  f := head.prims.BoreY(x: 0mm, z: h, d: filter_d, y0: front_out - filter_t, y1: front_out - filter_t + 3mm)
  body := solid(f.body)
}

// the pivot ball, drawn as the cylinder of the gap it holds between carrier and wall
component Ball() {
  b := head.prims.BoreY(x: -lever / 2, z: h - lever / 2, d: ball, y0: -carrier_back - kgap,
                        y1: -carrier_back)
  body := solid(b.body)
}

// the Global Shutter Camera: its board and back cover behind the flange face, its back-focus
// ring in front, and the lens on that
component Camera() {
  board := head.prims.Block(x0: board_x - cam_behind, x1: board_x, y0: -cam_board / 2,
                            y1: cam_board / 2, z0: h - cam_board / 2, z1: h + cam_board / 2)
  ring := head.prims.BoreX(y: 0mm, z: h, d: cam_ring_d, x0: board_x - 1mm, x1: board_x + cam_proud)
  lens := head.prims.BoreX(y: 0mm, z: h, d: lens_d, x0: board_x + cam_proud - 1mm,
                           x1: board_x + cam_proud + lens_len)
  body := solid(board.body)
  ring.body union body
  lens.body union body
}
