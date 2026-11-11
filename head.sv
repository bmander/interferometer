// The shearography head, assembled.
//
// A Michelson shearing interferometer in front of a Raspberry Pi Global Shutter Camera, for
// modal analysis of guitar soundboards: the camera images a 500 mm square of soundboard from
// about 1.07 m through a 40 mm beamsplitter cube; mirror B (fixed) and mirror A (tip/tilt, from
// behind) return two copies of the image, and tilting A shears one against the other.
//
// Printed: the housing, mirror A's carrier, the camera carriage and the lid (`make stl`).  The
// rest is bought (`head.optics` stands in for it here).  Every number is in `head.dims`, whose
// claims judge the optics: the field's footprint against the cube's, the mirrors', the window's
// and the filter's apertures, and the speckle against the pixels.  The claims here judge the
// parts against one another.

unit mm
use std
use head.dims
use head.housing
use head.carrier
use head.carriage
use head.lid
use head.optics
use head.hardware
use head.dims (spring_r, spring_wire, spring_turns, spring_len, spring_max, spring_f0, spring_k,
               pin_d)

housing := head.housing.Housing()
carrier := head.carrier.Carrier()
carriage := head.carriage.Carriage()
lid := head.lid.Lid()

cube := head.optics.Cube()
mirror_a := head.optics.MirrorA()
mirror_b := head.optics.MirrorB()
filter := head.optics.Filter()
pad := head.optics.Pad()
ball := head.optics.Ball()
camera := head.optics.Camera()

// the hardware: mirror A's pivot ball, adjusters, inserts and spring pins (`head.hardware`
// says how the mount works), and every other fastener
mount := head.hardware.Mount()
fasteners := head.hardware.Fasteners()

// mirror A's two springs, each a coil from its pin on the carrier to its pin on the back wall:
// a wire swept along a helix about a plane's normal, which runs -y here
param s: Scalar over (0, 1)
low_base := plane
fix(origin == (head.hardware.low_x, head.hardware.low_front, head.hardware.low_z)) low_base
fix(dir == (1, 0, 0)) low_base.u
fix(dir == (0, 0, 1)) low_base.v
low_pitch := (head.hardware.low_front - head.hardware.wall_pin) / spring_turns
spring_low := solid({ p | some s: p in head.hardware.Coil(low_base, r: spring_r, wire: spring_wire,
                                                          pitch: low_pitch, turns: spring_turns).f at s })
side_base := plane
fix(origin == (head.hardware.side_x, head.hardware.side_front, head.hardware.side_z)) side_base
fix(dir == (1, 0, 0)) side_base.u
fix(dir == (0, 0, 1)) side_base.v
side_pitch := (head.hardware.side_front - head.hardware.wall_pin) / spring_turns
spring_side := solid({ p | some s: p in head.hardware.Coil(side_base, r: spring_r, wire: spring_wire,
                                                           pitch: side_pitch, turns: spring_turns).f at s })

// the moving carrier clears everything round it by more than its tilt can take up
claim carrier.body clear(1.5mm) housing.body
claim carrier.body clear(0.5mm) lid.body
claim carrier.body clear(2mm) camera.body
claim carrier.body clear(2mm) carriage.body
// the camera clears the housing, and its lens stands `lens_gap` off the cube
claim camera.body clear(1mm) housing.body
claim camera.body clear(1mm) lid.body
claim camera.body clear(2.5mm) cube.body
claim carriage.body clear(1mm) lid.body
// the cube sits in its recess clear of both mirrors, and the lid's post stands the squeezed
// pad's thickness above it
claim lid.body clear(1mm) cube.body
claim cube.body clear(1.5mm) mirror_a.body
claim cube.body clear(1.5mm) mirror_b.body
// each spring, inside its loops, stretched past its free length but short of its maximum with
// 1.5 mm to spare for the adjusters to push the carrier forward; and what each pulls
low_span := head.hardware.low_front - head.hardware.wall_pin - pin_d
side_span := head.hardware.side_front - head.hardware.wall_pin - pin_d
claim low_span >= spring_len + 1mm and side_span >= spring_len + 1mm
claim low_span <= spring_max - 1.5mm and side_span <= spring_max - 1.5mm
low_pull := spring_f0 + spring_k * (low_span - spring_len)
side_pull := spring_f0 + spring_k * (side_span - spring_len)
// the springs run clear inside their holes
claim spring_low clear(0.1mm) housing.body
claim spring_side clear(0.1mm) housing.body
claim spring_low clear(0.1mm) carrier.body
claim spring_side clear(0.1mm) carrier.body

