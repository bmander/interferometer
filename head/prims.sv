// Primitives for a printed housing: boxes square to the world's axes, round bores along each
// axis, and a slot.  Each is a closed figure of numbers (1.8), drawn about its own frame's
// datums, so two calls with the same numbers are one figure placed twice.
//
// The views and their normals: `std.top` (u x, v y) sweeps along +z; `std.side` (u y, v z) along
// +x; `std.front` (u x, v z) along -y, so a front sweep's ordinates are -y.

unit mm
use std
use std.place (coords)
use std.solids (union)

// The box [x0, x1] × [y0, y1] × [z0, z1]: its outline walked counter-clockwise as four runs,
// each a signed ordinate from the top's origin, so every corner has one place and no seed.
component Block(x0: Length, x1: Length, y0: Length, y1: Length, z0: Length, z1: Length) {
  in std.top {
    loop := step(u: x1, v: y0) (ab := line) -> step(v: y1) (bc := line) ->
            step(u: x0) (cd := line) -> step(v: y0) (da := line) -> close
  }
  body := solid(std.solids.Prism(loop, from: z0, to: z1))
}

// A round bore of diameter `d` along z, at (x, y), from z0 to z1.
component BoreZ(x: Length, y: Length, d: Length, z0: Length, z1: Length) {
  in std.top {
    c := point
    c coords(du: x, dv: y) std.top
    k := radius(d / 2) circle(center: c)
  }
  body := solid(std.solids.Prism(face(k), from: z0, to: z1))
}

// Along x, at (y, z), from x0 to x1.
component BoreX(y: Length, z: Length, d: Length, x0: Length, x1: Length) {
  in std.side {
    c := point
    c coords(du: y, dv: z) std.side
    k := radius(d / 2) circle(center: c)
  }
  body := solid(std.solids.Prism(face(k), from: x0, to: x1))
}

// Along y, at (x, z), from y0 to y1.
component BoreY(x: Length, z: Length, d: Length, y0: Length, y1: Length) {
  in std.front {
    c := point
    c coords(du: x, dv: z) std.front
    k := radius(d / 2) circle(center: c)
  }
  body := solid(std.solids.Prism(face(k), from: -y1, to: -y0))
}

// A slot `w` wide running along x from x0 to x1 (centre to centre of its round ends), at y,
// through z0 to z1: a box between two bores.
component SlotX(x0: Length, x1: Length, y: Length, w: Length, z0: Length, z1: Length) {
  mid := Block(x0: x0, x1: x1, y0: y - w / 2, y1: y + w / 2, z0: z0, z1: z1)
  e0 := BoreZ(x: x0, y: y, d: w, z0: z0, z1: z1)
  e1 := BoreZ(x: x1, y: y, d: w, z0: z0, z1: z1)
  body := solid(mid.body)
  e0.body union body
  e1.body union body
}
