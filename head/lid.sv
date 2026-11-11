// The lid: a plate over the housing's walls, rounded as the box is, held by four M3 screws into
// the inserts in the walls' tops.  Under it a lip drops `lip_d` into the walls all the way round,
// `fit` inside them and round the fixed mirror's boss, so the lid finds its own place, and no
// light leaks round the joint; the lip's outside lower edge is rounded to lead it in.  A post
// presses the beamsplitter cube down into its recess through a pad.  Print it upside down, the
// lip up.

unit mm
use std
use std.solids (union, cut)
use head.prims
use head.dims (h, cube, pad_t, pad_squeeze, press_w, fit, wall_t, top, lid_t, x_in, side_in,
               front_in, front_out, back_in, back_out, boss_w, mirror_face, lid_x, m3_clear,
               corner_r, edge_r, inner_r, lip_d, lip_w, lip_lead)

component Lid() {
  // the plate: the box's corners in plan, its top edges rounded, flat underneath (a body's
  // unions come before its cuts, so it is shaped as a solid of its own before the lip joins it)
  soft := head.prims.SoftBox(x0: x_in - wall_t, x1: side_in + wall_t, y0: -back_out, y1: front_out,
                             z0: top - 2 * corner_r, z1: top + lid_t, r: corner_r, e: edge_r)
  below := head.prims.Block(x0: x_in - wall_t - 1mm, x1: side_in + wall_t + 1mm, y0: -back_out - 1mm,
                            y1: front_out + 1mm, z0: top - 3 * corner_r, z1: top)
  plate := solid(soft.body)
  below.body cut plate
  body := solid(plate)

  // the lip: a ring `fit` inside the walls, its corners concentric with theirs, and a
  // collar round the boss
  xa := x_in + fit
  xb := side_in - fit
  ya := -back_in + fit
  yb := front_in - fit
  ring := head.prims.SoftBox(x0: xa, x1: xb, y0: ya, y1: yb, z0: top - lip_d, z1: top + lid_t / 2,
                             r: inner_r - fit, e: lip_lead)
  // what the ring leaves hollow: all inside it but the collar's room round the boss
  inside := head.prims.Block(x0: xa + lip_w, x1: xb - lip_w, y0: ya + lip_w, y1: yb - lip_w,
                             z0: top - lip_d - 1mm, z1: top + lid_t)
  collar := head.prims.Block(x0: mirror_face - fit - lip_w, x1: xb, y0: -boss_w / 2 - fit - lip_w,
                             y1: boss_w / 2 + fit + lip_w, z0: top - lip_d - 2mm, z1: top + lid_t + 1mm)
  hollow := solid(inside.body)
  collar.body cut hollow
  boss_room := head.prims.Block(x0: mirror_face - fit, x1: side_in + 1mm, y0: -boss_w / 2 - fit,
                                y1: boss_w / 2 + fit, z0: top - lip_d - 1mm, z1: top + lid_t)
  lip := solid(ring.body)
  hollow cut lip
  boss_room.body cut lip
  lip union body

  // the post that holds the cube down in its recess, through a pad `pad_t` thick squeezed by
  // `pad_squeeze` as the lid's screws pull it home
  press := head.prims.Block(x0: -press_w / 2, x1: press_w / 2, y0: -press_w / 2, y1: press_w / 2,
                            z0: h + cube / 2 + pad_t - pad_squeeze, z1: top + 1mm)
  press.body union body

  repeat lx in lid_x {
    repeat ly in [-(back_in + back_out) / 2, (front_in + front_out) / 2] {
      screw := head.prims.BoreZ(x: lx, y: ly, d: m3_clear, z0: top - 1mm, z1: top + lid_t + 1mm)
      screw.body cut body
    }
  }
}

preview {
  lid := Lid()
}
