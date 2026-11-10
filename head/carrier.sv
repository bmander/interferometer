// Mirror A's carrier: the moving plate of the kinematic tip/tilt mount.
//
// Mirror A sits face out in a pocket on its front (+y), its surface `gap` off the cube's back
// face.  Behind, the pivot ball rides in a seat matched by one in the housing's back wall; the
// two adjuster screws push on the plain back face, `lever` from the pivot along each edge; and
// two springs, hooked on pins in the grooves across their holes, pull it back onto all three.
// A hole behind the mirror lets you push it out.  Print it face down.

unit mm
use std
use std.solids (union, cut)
use head.prims
use head.dims (h, fit, mirror_w, mirror_t, mirror_face, carrier_w, carrier_back, lever, seat,
               seat_deep, spring_hole, spring_run, groove, groove_l)

component Carrier() {
  y_f := -mirror_face        // the front face: the mirror's surface plane
  y_b := -carrier_back       // the back face, toward the adjusters
  plate := head.prims.Block(x0: -carrier_w / 2, x1: carrier_w / 2, y0: y_b, y1: y_f,
                            z0: h - carrier_w / 2, z1: h + carrier_w / 2)
  body := solid(plate.body)

  pocket := head.prims.Block(x0: -mirror_w / 2 - fit, x1: mirror_w / 2 + fit,
                             y0: y_f - mirror_t, y1: y_f + 1mm,
                             z0: h - mirror_w / 2 - fit, z1: h + mirror_w / 2 + fit)
  pocket.body cut body
  pushout := head.prims.BoreY(x: 0mm, z: h, d: 6mm, y0: y_b - 1mm, y1: y_f)
  pushout.body cut body

  pivot := head.prims.BoreY(x: -lever / 2, z: h - lever / 2, d: seat, y0: y_b - 1mm,
                            y1: y_b + seat_deep)
  pivot.body cut body

  s_low := head.prims.BoreY(x: -lever / 2 + spring_run, z: h - lever / 2, d: spring_hole,
                            y0: y_b - 1mm, y1: y_f + 1mm)
  s_low.body cut body
  g_low := head.prims.Block(x0: -lever / 2 + spring_run - groove_l / 2,
                            x1: -lever / 2 + spring_run + groove_l / 2,
                            y0: y_f - groove, y1: y_f + 1mm,
                            z0: h - lever / 2 - groove / 2, z1: h - lever / 2 + groove / 2)
  g_low.body cut body
  s_side := head.prims.BoreY(x: -lever / 2, z: h - lever / 2 + spring_run, d: spring_hole,
                             y0: y_b - 1mm, y1: y_f + 1mm)
  s_side.body cut body
  g_side := head.prims.Block(x0: -lever / 2 - groove / 2, x1: -lever / 2 + groove / 2,
                             y0: y_f - groove, y1: y_f + 1mm,
                             z0: h - lever / 2 + spring_run - groove_l / 2,
                             z1: h - lever / 2 + spring_run + groove_l / 2)
  g_side.body cut body
}

preview {
  carrier := Carrier()
}
