// The housing: one print holding the beamsplitter cube, both mirrors and the camera carriage.
//
// A floor with four walls, open at the top for the lid.  On the floor, the cube's pedestal with
// two low ledges it is pushed against (camera side and front), so its faces land square to the
// world's axes.  The +x wall thickens into a boss whose face carries the fixed mirror B `gap` off
// the cube.  The back wall is thick: it takes mirror A's pivot ball and the two adjuster screws'
// inserts, from behind, where you stand.  The front wall has the square window and, outside it,
// the pocket for the 2" 532 nm filter.  The camera's ribbon leaves through a slot low in the -x
// wall, and four M5 inserts underneath bolt the head to its frame.

unit mm
use std
use std.solids (union, cut)
use head.prims
use head.dims (cube, h, gap, mirror_w, mirror_t, mirror_face, fit, floor_t, wall_t, front_in,
               front_out, back_in, back_out, side_in, x_in, top, lip_t, lip_h, boss_w, window,
               filter_d, filter_t, lever, seat, seat_deep, spring_hole, spring_run, groove,
               groove_l, m3_insert_d, m3_insert_l, m3_clear, m5_insert_d, m5_insert_l, foot_x,
               slot_y, lid_x, mount_dx, mount_dy, mount_cx, mount_cy)

component Housing() {
  // -- material ---------------------------------------------------------------------------------
  // Each piece overlaps its neighbours by 1 so no two meet face to face.
  base := head.prims.Block(x0: x_in - wall_t, x1: side_in + wall_t, y0: -back_out, y1: front_out,
                           z0: -floor_t, z1: 0mm)
  wall_l := head.prims.Block(x0: x_in - wall_t, x1: x_in, y0: -back_out, y1: front_out,
                             z0: -1mm, z1: top)
  wall_r := head.prims.Block(x0: side_in, x1: side_in + wall_t, y0: -back_out, y1: front_out,
                             z0: -1mm, z1: top)
  wall_b := head.prims.Block(x0: x_in - 1mm, x1: side_in + 1mm, y0: -back_out, y1: -back_in,
                             z0: -1mm, z1: top)
  wall_f := head.prims.Block(x0: x_in - 1mm, x1: side_in + 1mm, y0: front_in, y1: front_out,
                             z0: -1mm, z1: top)
  // the cube stands on the pedestal with its bottom face `h - cube / 2` up, its camera face and
  // its object face against the two ledges
  pedestal := head.prims.Block(x0: -cube / 2 - lip_t, x1: cube / 2, y0: -cube / 2, y1: front_in + 1mm,
                               z0: -1mm, z1: h - cube / 2)
  ledge_cam := head.prims.Block(x0: -cube / 2 - lip_t, x1: -cube / 2, y0: -cube / 2, y1: front_in + 1mm,
                                z0: h - cube / 2 - 1mm, z1: h - cube / 2 + lip_h)
  ledge_obj := head.prims.Block(x0: -cube / 2 - lip_t, x1: cube / 2, y0: cube / 2, y1: front_in + 1mm,
                                z0: h - cube / 2 - 1mm, z1: h - cube / 2 + lip_h)
  // mirror B's boss: its face is the mirror's surface plane, `gap` off the cube's +x face
  boss := head.prims.Block(x0: mirror_face, x1: side_in + 1mm, y0: -boss_w / 2, y1: boss_w / 2,
                           z0: -1mm, z1: top)

  body := solid(base.body)
  wall_l.body union body
  wall_r.body union body
  wall_b.body union body
  wall_f.body union body
  pedestal.body union body
  ledge_cam.body union body
  ledge_obj.body union body
  boss.body union body

  // -- mirror B, the window and the filter ------------------------------------------------------
  // the mirror drops into its pocket face out, flush with the boss, and is held by three dots of
  // RTV in the pocket's floor
  mirror_b := head.prims.Block(x0: mirror_face - 1mm, x1: mirror_face + mirror_t,
                               y0: -mirror_w / 2 - fit, y1: mirror_w / 2 + fit,
                               z0: h - mirror_w / 2 - fit, z1: h + mirror_w / 2 + fit)
  mirror_b.body cut body
  win := head.prims.Block(x0: -window / 2, x1: window / 2, y0: front_in - 0.5mm, y1: front_out + 1mm,
                          z0: h - window / 2, z1: h + window / 2)
  win.body cut body
  filter := head.prims.BoreY(x: 0mm, z: h, d: filter_d + 2 * fit, y0: front_out - filter_t,
                             y1: front_out + 1mm)
  filter.body cut body

  // -- mirror A's kinematic mount, in the back wall --------------------------------------------
  // Seen from behind: the pivot ball's seat low and toward the camera; the horizontal-shear
  // adjuster `lever` across from it, the vertical-shear one `lever` above it.  Each adjuster is
  // an M3 heat-set insert pressed in from behind, its screw running through to push the carrier.
  pivot := head.prims.BoreY(x: -lever / 2, z: h - lever / 2, d: seat, y0: -back_in - seat_deep,
                            y1: -back_in + 1mm)
  pivot.body cut body
  repeat a in [(lever / 2, -lever / 2), (-lever / 2, lever / 2)] {
    insert := head.prims.BoreY(x: a.x, z: h + a.y, d: m3_insert_d, y0: -back_out - 1mm,
                               y1: -back_out + m3_insert_l)
    insert.body cut body
    through := head.prims.BoreY(x: a.x, z: h + a.y, d: m3_clear, y0: -back_out - 1mm,
                                y1: -back_in + 1mm)
    through.body cut body
  }
  // the springs: one along the bottom edge from the pivot, one up the side; each passes through
  // the wall and hooks on a pin lying in a groove across its hole outside
  s_low := head.prims.BoreY(x: -lever / 2 + spring_run, z: h - lever / 2, d: spring_hole,
                            y0: -back_out - 1mm, y1: -back_in + 1mm)
  s_low.body cut body
  g_low := head.prims.Block(x0: -lever / 2 + spring_run - groove_l / 2,
                            x1: -lever / 2 + spring_run + groove_l / 2,
                            y0: -back_out - 1mm, y1: -back_out + groove,
                            z0: h - lever / 2 - groove / 2, z1: h - lever / 2 + groove / 2)
  g_low.body cut body
  s_side := head.prims.BoreY(x: -lever / 2, z: h - lever / 2 + spring_run, d: spring_hole,
                             y0: -back_out - 1mm, y1: -back_in + 1mm)
  s_side.body cut body
  g_side := head.prims.Block(x0: -lever / 2 - groove / 2, x1: -lever / 2 + groove / 2,
                             y0: -back_out - 1mm, y1: -back_out + groove,
                             z0: h - lever / 2 + spring_run - groove_l / 2,
                             z1: h - lever / 2 + spring_run + groove_l / 2)
  g_side.body cut body

  // -- the camera: its carriage's two inserts, and the ribbon's way out --------------------------
  repeat sy in [-slot_y, slot_y] {
    cam_insert := head.prims.BoreZ(x: foot_x, y: sy, d: m3_insert_d, z0: -m3_insert_l, z1: 1mm)
    cam_insert.body cut body
  }
  ribbon := head.prims.Block(x0: x_in - wall_t - 1mm, x1: x_in + 1mm, y0: -9mm, y1: 9mm,
                             z0: 1mm, z1: 7mm)
  ribbon.body cut body

  // -- the lid's inserts, in the tops of the front and back walls -------------------------------
  repeat lx in lid_x {
    repeat ly in [-(back_in + back_out) / 2, (front_in + front_out) / 2] {
      lid_insert := head.prims.BoreZ(x: lx, y: ly, d: m3_insert_d, z0: top - m3_insert_l, z1: top + 1mm)
      lid_insert.body cut body
    }
  }

  // -- the frame's M5 inserts, from underneath -------------------------------------------------
  repeat mx in [mount_cx - mount_dx / 2, mount_cx + mount_dx / 2] {
    repeat my in [mount_cy - mount_dy / 2, mount_cy + mount_dy / 2] {
      m5 := head.prims.BoreZ(x: mx, y: my, d: m5_insert_d, z0: -floor_t - 1mm,
                             z1: -floor_t + m5_insert_l)
      m5.body cut body
    }
  }
}

preview {
  housing := Housing()
}
