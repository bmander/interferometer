// The camera carriage: an upright plate the Global Shutter Camera bolts to, on a foot that
// slides along the housing floor so any lens length brings the lens's front rim to `lens_gap`
// off the cube.
//
// The camera's board sits against the plate's -x face, its Ø36 back-focus ring through the
// plate's bore; four M2.5 screws come from behind the board's back cover and tap into the
// plate (no inserts: the web between bore and hole is under 2 mm).  The foot's two slots take
// M3 screws into inserts in the floor.  Set the camera's back focus on the bench before
// mounting it.  Print it standing on its foot.

unit mm
use std
use std.solids (union, cut)
use std.rounds (round)
use head.prims
use head.dims (h, fit, board_x, plate_t, plate_w, foot_l, foot_t, rib_t, rib_h, foot_x, travel,
               slot_y, cam_ring_d, cam_hole, m25_tap_d, m3_clear, foot_fillet)

component Carriage() {
  plate := head.prims.Block(x0: board_x, x1: board_x + plate_t, y0: -plate_w / 2, y1: plate_w / 2,
                            z0: 0mm, z1: h + plate_w / 2)
  foot := head.prims.Block(x0: board_x + plate_t - 1mm, x1: board_x + plate_t + foot_l,
                           y0: -plate_w / 2, y1: plate_w / 2, z0: 0mm, z1: foot_t)
  body := solid(plate.body)
  foot.body union body
  // two ribs brace the plate on the foot, outboard of the lens
  repeat sgn in [-1, 1] {
    rib := head.prims.Block(x0: board_x + plate_t - 1mm, x1: board_x + plate_t + foot_l,
                            y0: sgn * plate_w / 2 - rib_t / 2 - sgn * rib_t / 2,
                            y1: sgn * plate_w / 2 + rib_t / 2 - sgn * rib_t / 2,
                            z0: 0mm, z1: rib_h)
    rib.body union body
  }
  // fillets where the foot and the ribs stand on the plate and the ribs on the foot (the
  // foot's fillet stops flush either side of each slot), and the plate's top corners rounded
  body.foot round(r: foot_fillet) body.plate
  body.rib round(r: 1mm) body.foot
  body.rib round(r: 2mm) body.plate
  repeat f in [body.plate.body.ab, body.plate.body.cd] {
    body.plate.body.near round(r: 4mm) f
  }

  bore := head.prims.BoreX(y: 0mm, z: h, d: cam_ring_d + 2 * fit, x0: board_x - 1mm,
                           x1: board_x + plate_t + 1mm)
  bore.body cut body
  repeat q in [(-1, -1), (1, -1), (1, 1), (-1, 1)] {
    screw := head.prims.BoreX(y: q.x * cam_hole / 2, z: h + q.y * cam_hole / 2, d: m25_tap_d,
                              x0: board_x - 1mm, x1: board_x + plate_t + 1mm)
    screw.body cut body
  }
  repeat sy in [-slot_y, slot_y] {
    slot := head.prims.SlotX(x0: foot_x - travel, x1: foot_x + travel, y: sy, w: m3_clear,
                             z0: -1mm, z1: foot_t + 1mm)
    slot.body cut body
  }
}

preview {
  carriage := Carriage()
}
