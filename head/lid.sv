// The lid: a plate over the housing's walls, four M3 screws into the inserts in the walls' tops,
// a shallow lip just inside the walls so no light leaks round the joint, and a post that
// presses the beamsplitter cube down into its recess through a pad.  The lip breaks
// where the fixed mirror's boss stands.  Print it upside down, the lip up.

unit mm
use std
use std.solids (union, cut)
use head.prims
use head.dims (h, cube, pad_t, pad_squeeze, press_w, fit, wall_t, top, lid_t, x_in, side_in,
               front_in, front_out, back_in, back_out, boss_w, lid_x, m3_clear)

lip_w := 2mm
lip_d := 2mm

component Lid() {
  plate := head.prims.Block(x0: x_in - wall_t, x1: side_in + wall_t, y0: -back_out, y1: front_out,
                            z0: top, z1: top + lid_t)
  body := solid(plate.body)

  xa := x_in + fit
  xb := side_in - fit
  ya := -back_in + fit
  yb := front_in - fit
  z0 := top - lip_d
  z1 := top + 1mm
  back := head.prims.Block(x0: xa, x1: xb, y0: ya, y1: ya + lip_w, z0: z0, z1: z1)
  front := head.prims.Block(x0: xa, x1: xb, y0: yb - lip_w, y1: yb, z0: z0, z1: z1)
  left := head.prims.Block(x0: xa, x1: xa + lip_w, y0: ya, y1: yb, z0: z0, z1: z1)
  right_b := head.prims.Block(x0: xb - lip_w, x1: xb, y0: ya, y1: -boss_w / 2 - fit, z0: z0, z1: z1)
  right_f := head.prims.Block(x0: xb - lip_w, x1: xb, y0: boss_w / 2 + fit, y1: yb, z0: z0, z1: z1)
  back.body union body
  front.body union body
  left.body union body
  right_b.body union body
  right_f.body union body

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
