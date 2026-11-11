// The hardware: what holds mirror A's carrier in its kinematic mount, and every fastener.
//
// **How mirror A tilts.**  Mirror A's carrier floats `kgap` in front of the back wall, touching it
// at three points only:
//   - the pivot: a Ø4 steel ball in a seat in each face (low, toward the camera);
//   - the horizontal-shear adjuster: an M3 screw `lever` across from the ball, threaded through an
//     insert in the back wall, its tip pushing on the carrier's back;
//   - the vertical-shear adjuster: another, `lever` above the ball.
// Two extension springs, each hooked on a pin across its hole on the carrier's front and another
// on the wall's back, pull the carrier back onto all three.  Turning the lower screw swings the
// carrier about the vertical line through the ball and the upper screw, so mirror A turns about
// z and the shear runs along x; turning the upper screw tips it about the horizontal line through
// the ball and the lower screw, and the shear runs along z.  Screw in, and the carrier's corner
// comes forward; back off, and the springs pull it back.  Mirror B never moves.
//
// Each piece here is a plain solid in assembly coordinates.  The springs are drawn in `head.sv`:
// a coil is a face swept along a helix, which only a document can run.

unit mm
use std
use std.sets
use std.stations
use std.solids (union, cut)
use head.prims
use head.dims (h, top, lid_t, floor_t, foot_t, foot_x, slot_y, lid_x, back_in, back_out, front_in,
               front_out, mirror_face, carrier_back, carrier_relief, kgap, lever, ball, spring_run,
               groove, groove_l, pin_d, cap_head_d, cap_head_h, adj_len, m3_insert_d, m3_insert_l,
               m5_insert_d, m5_insert_l, lid_screw_len, cart_screw_len, washer_d, washer_t,
               board_x, cam_hole, m25_len, cam_stack, mount_dx, mount_dy, mount_cx, mount_cy)

// -- pieces ------------------------------------------------------------------------------------

component SteelBall(x: Length, y: Length, z: Length, d: Length) {
  c := point
  fix((x, y, z)) c
  body := solid(std.sets.Ball(c, r: d / 2))
}

// A socket-head cap screw along y, x or z: its tip at `tip`, the underside of its head at
// `under`, the head beyond it, a socket in the head's end.
component CapScrewY(x: Length, z: Length, tip: Length, under: Length, d: Length, head_d: Length,
                    head_h: Length) {
  sg := (under - tip) / abs(under - tip)
  shank := head.prims.BoreY(x: x, z: z, d: d, y0: min(tip, under + sg * 0.5mm),
                            y1: max(tip, under + sg * 0.5mm))
  cap := head.prims.BoreY(x: x, z: z, d: head_d, y0: min(under, under + sg * head_h),
                          y1: max(under, under + sg * head_h))
  sock := head.prims.BoreY(x: x, z: z, d: head_d / 2, y0: min(under + sg * (head_h - 1.5mm), under + sg * (head_h + 1mm)),
                           y1: max(under + sg * (head_h - 1.5mm), under + sg * (head_h + 1mm)))
  body := solid(cap.body)
  shank.body union body
  sock.body cut body
}
component CapScrewZ(x: Length, y: Length, tip: Length, under: Length, d: Length, head_d: Length,
                    head_h: Length) {
  sg := (under - tip) / abs(under - tip)
  shank := head.prims.BoreZ(x: x, y: y, d: d, z0: min(tip, under + sg * 0.5mm),
                            z1: max(tip, under + sg * 0.5mm))
  cap := head.prims.BoreZ(x: x, y: y, d: head_d, z0: min(under, under + sg * head_h),
                          z1: max(under, under + sg * head_h))
  sock := head.prims.BoreZ(x: x, y: y, d: head_d / 2, z0: min(under + sg * (head_h - 1.5mm), under + sg * (head_h + 1mm)),
                           z1: max(under + sg * (head_h - 1.5mm), under + sg * (head_h + 1mm)))
  body := solid(cap.body)
  shank.body union body
  sock.body cut body
}
component CapScrewX(y: Length, z: Length, tip: Length, under: Length, d: Length, head_d: Length,
                    head_h: Length) {
  sg := (under - tip) / abs(under - tip)
  shank := head.prims.BoreX(y: y, z: z, d: d, x0: min(tip, under + sg * 0.5mm),
                            x1: max(tip, under + sg * 0.5mm))
  cap := head.prims.BoreX(y: y, z: z, d: head_d, x0: min(under, under + sg * head_h),
                          x1: max(under, under + sg * head_h))
  body := solid(cap.body)
  shank.body union body
}

// A heat-set insert, drawn as the tube it leaves: `od` its hole, `id` its thread.
component InsertY(x: Length, z: Length, od: Length, id: Length, y0: Length, y1: Length) {
  o := head.prims.BoreY(x: x, z: z, d: od, y0: y0, y1: y1)
  i := head.prims.BoreY(x: x, z: z, d: id, y0: y0 - 1mm, y1: y1 + 1mm)
  body := solid(o.body)
  i.body cut body
}
component InsertZ(x: Length, y: Length, od: Length, id: Length, z0: Length, z1: Length) {
  o := head.prims.BoreZ(x: x, y: y, d: od, z0: z0, z1: z1)
  i := head.prims.BoreZ(x: x, y: y, d: id, z0: z0 - 1mm, z1: z1 + 1mm)
  body := solid(o.body)
  i.body cut body
}

// One turn of a spring's coil: the wire's round section square to a helix about `base`'s normal.
component Coil(base: plane, r: Length, wire: Length, pitch: Length, turns: Scalar, s: Scalar) {
  st := std.stations.OnHelix(base, r: r, pitch: pitch, turns: turns, s: s)
  in st.n {
    w := circle(center: st.n.origin)
    radius(wire) w
  }
  f := face(w)
}

// -- mirror A's kinematic mount ---------------------------------------------------------------

// Where the mount's springs run, front to back: the low spring along the carrier's bottom edge
// (its carrier pin in the stepped-back face) and the side spring up its camera-side edge.
low_x := -lever / 2 + spring_run
low_z := h - lever / 2
side_x := -lever / 2
side_z := h - lever / 2 + spring_run
low_front := -(mirror_face + carrier_relief + groove / 2)
side_front := -(mirror_face + groove / 2)
wall_pin := -(back_out - groove / 2)

component Mount() {
  pivot := SteelBall(x: -lever / 2, y: -(carrier_back + kgap / 2), z: h - lever / 2, d: ball)

  // the two adjusters, their tips on the carrier's back, their heads behind the wall
  adjust_x := CapScrewY(x: lever / 2, z: h - lever / 2, tip: -carrier_back,
                        under: -carrier_back - adj_len, d: 3mm, head_d: cap_head_d, head_h: cap_head_h)
  adjust_z := CapScrewY(x: -lever / 2, z: h + lever / 2, tip: -carrier_back,
                        under: -carrier_back - adj_len, d: 3mm, head_d: cap_head_d, head_h: cap_head_h)
  insert_x := InsertY(x: lever / 2, z: h - lever / 2, od: m3_insert_d, id: 3mm,
                      y0: -back_out, y1: -back_out + m3_insert_l)
  insert_z := InsertY(x: -lever / 2, z: h + lever / 2, od: m3_insert_d, id: 3mm,
                      y0: -back_out, y1: -back_out + m3_insert_l)

  // the springs' pins: each lies in its groove across a spring hole
  pin_low_c := head.prims.BoreX(y: low_front, z: low_z, d: pin_d, x0: low_x - groove_l / 2 + 0.5mm,
                                x1: low_x + groove_l / 2 - 0.5mm)
  pin_low_w := head.prims.BoreX(y: wall_pin, z: low_z, d: pin_d, x0: low_x - groove_l / 2 + 0.5mm,
                                x1: low_x + groove_l / 2 - 0.5mm)
  pin_side_c := head.prims.BoreZ(x: side_x, y: side_front, d: pin_d, z0: side_z - groove_l / 2 + 0.5mm,
                                 z1: side_z + groove_l / 2 - 0.5mm)
  pin_side_w := head.prims.BoreZ(x: side_x, y: wall_pin, d: pin_d, z0: side_z - groove_l / 2 + 0.5mm,
                                 z1: side_z + groove_l / 2 - 0.5mm)
  pins := solid(pin_low_c.body)
  pin_low_w.body union pins
  pin_side_c.body union pins
  pin_side_w.body union pins
}

// -- every other fastener ---------------------------------------------------------------------

component Fasteners() {
  // the lid: four M3 screws into inserts in the walls' tops
  lid_inserts := solid()
  lid_screws := solid()
  repeat lx in lid_x {
    repeat ly in [-(back_in + back_out) / 2, (front_in + front_out) / 2] {
      li := InsertZ(x: lx, y: ly, od: m3_insert_d, id: 3mm, z0: top - m3_insert_l, z1: top)
      li.body union lid_inserts
      ls := CapScrewZ(x: lx, y: ly, tip: top + lid_t - lid_screw_len, under: top + lid_t,
                      d: 3mm, head_d: cap_head_d, head_h: cap_head_h)
      ls.body union lid_screws
    }
  }

  // the carriage: two M3 screws with washers through its slots into the floor
  cart_inserts := solid()
  cart_screws := solid()
  repeat sy in [-slot_y, slot_y] {
    ci := InsertZ(x: foot_x, y: sy, od: m3_insert_d, id: 3mm, z0: -m3_insert_l, z1: 0mm)
    ci.body union cart_inserts
    cs := CapScrewZ(x: foot_x, y: sy, tip: foot_t + washer_t - cart_screw_len, under: foot_t + washer_t,
                    d: 3mm, head_d: cap_head_d, head_h: cap_head_h)
    cs.body union cart_screws
    cw := InsertZ(x: foot_x, y: sy, od: washer_d, id: 3.2mm, z0: foot_t, z1: foot_t + washer_t)
    cw.body union cart_screws
  }

  // the camera: four M2.5 screws from behind, through its flange and board, tapped into the plate
  cam_screws := solid()
  repeat q in [(-1, -1), (1, -1), (1, 1), (-1, 1)] {
    m := CapScrewX(y: q.x * cam_hole / 2, z: h + q.y * cam_hole / 2, tip: board_x - cam_stack + m25_len,
                   under: board_x - cam_stack, d: 2.5mm, head_d: 4.5mm, head_h: 2.5mm)
    m.body union cam_screws
  }

  // the frame: four M5 inserts in the floor's underside
  frame_inserts := solid()
  repeat mx in [mount_cx - mount_dx / 2, mount_cx + mount_dx / 2] {
    repeat my in [mount_cy - mount_dy / 2, mount_cy + mount_dy / 2] {
      fi := InsertZ(x: mx, y: my, od: m5_insert_d, id: 5mm, z0: -floor_t, z1: -floor_t + m5_insert_l)
      fi.body union frame_inserts
    }
  }
}
