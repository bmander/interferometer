// The shearography head's dimension table.
//
// A Michelson shearing interferometer in front of a Raspberry Pi Global Shutter Camera (IMX296,
// 1/2.9", 3.45 µm pixels), looking at a guitar soundboard lit by a 532 nm laser.  Every number is
// stated here once and read by the parts as a constant of their own definitions.  The optics come
// first because they size everything else: the cube, the mirrors and the window are what the
// field of view needs, and the claims at the end of the optics section say whether it gets it.
//
// World frame (`std`): x right, y forward toward the guitar, z up, origin at the centre of the
// beamsplitter cube's footprint on the housing floor.  The optical axis runs `h` above the floor.
//
//   top view                      +y  (to the soundboard)
//                                  ^
//                    window / 532 nm filter
//                   +----------------------+
//      camera  ===> |  [cube]   | mirror B |  (fixed, on the +x boss)
//      (-x)         |  mirror A (tip/tilt) |
//                   +----------------------+
//                     adjusters, from behind (-y)
//
// The cube's 50:50 hypotenuse runs from its (-x, +y) corner to its (+x, -y) corner, so light from
// the soundboard (+y) splits to mirror A (-y) and mirror B (+x), and both return to the camera
// (-x).  Tilting mirror A shears one image against the other.

unit mm

// -- the camera and the field ------------------------------------------------------------------
pixel := 0.00345mm         // IMX296 pixel pitch
crop_px := 1088            // the sensor's short side, used whole; the long side is cropped square
crop := pixel * crop_px    // the square field's side on the sensor: 3.754
field := 500mm             // the square of soundboard imaged
f_lens := 8mm              // C-mount lens, on the camera's CS mount through a 5 mm spacer
f_number := 8              // stopped down for speckle; see `speckle` below
lambda := 0.000532mm       // 532 nm
mag := crop / field
work := f_lens * (1 + 1 / mag)        // lens to soundboard: about 1.07 m
tan_half := crop / 2 / f_lens         // the half-field's slope in object space, either axis
pupil := f_lens / f_number            // entrance pupil diameter

// Where the lens's entrance pupil sits behind its front rim.  Not published for most CCTV
// lenses: look into the lens from the front at arm's length; the aperture's image appears to
// float at the pupil.  Measure it, set it here and run solventc: the claims below re-judge it.
pupil_depth := 12mm

// -- the interferometer ------------------------------------------------------------------------
n_glass := 1.519           // N-BK7 at 532 nm
cube := 40mm               // non-polarizing 50:50 beamsplitter cube, VIS coated
cube_ca := 0.9 * cube      // clear aperture: the coating's usable 90%
gap := 2mm                 // cube face to each mirror's surface: both arms the same
mirror_w := 30mm           // square first-surface mirrors (round would need 30 mm across the corners anyway)
mirror_t := 3mm
mirror_ca := 0.9 * mirror_w
lens_gap := 3mm            // the lens's front rim to the cube's camera face

// The field's footprint, traced back from the pupil: through `lens_gap` of air into the cube, to
// a mirror and back, and out of the cube's object face.  In glass the field's slope is cut by
// the index.  The widest crossing is at the object face, after two cube lengths of glass.
reach := pupil_depth + lens_gap
mirror_spot := pupil + 2 * tan_half * (reach + gap) + 2 * tan_half * cube / n_glass
exit_spot := pupil + 2 * tan_half * (reach + 2 * gap) + 4 * tan_half * cube / n_glass

claim exit_spot <= cube_ca          // the cube vignettes nothing
claim mirror_spot <= mirror_ca      // nor do the mirrors

// Speckle should span at least two pixels, or the fringes wash out: its size at the sensor is
// about 2.44 λ (1 + m) F#.
speckle := 2.44 * lambda * (1 + mag) * f_number
claim speckle >= 2 * pixel

// -- the 532 nm filter, outside the front window -----------------------------------------------
// Out here it costs the cube nothing: a filter between lens and cube would push the pupil back
// and vignette the field.
filter_d := 50.8mm         // 2" round bandpass, unmounted
filter_t := 5mm            // pocket depth: the filter's thickness or a little more
front_gap := 1mm           // cube's object face to the front wall's inside
front_t := 3mm + filter_t  // the front wall: a 3 mm web behind the filter pocket
window := cube - 2mm       // the square window through the web
window_spot := exit_spot + 2 * tan_half * (front_gap + 3mm)
filter_spot := exit_spot + 2 * tan_half * (front_gap + front_t)
claim window_spot <= window
claim filter_spot <= 0.9 * filter_d

// -- printing ----------------------------------------------------------------------------------
fit := 0.2mm               // clearance per side on every pocket that takes a bought part
m3_insert_d := 4.0mm       // heat-set inserts: hole diameter and depth
m3_insert_l := 6mm
m3_clear := 3.4mm
m3_head_d := 6.2mm
m25_tap_d := 2.2mm         // M2.5 screws tapped straight into the print
m5_insert_d := 6.4mm
m5_insert_l := 6.5mm

// -- the housing -------------------------------------------------------------------------------
h := 40mm                  // optical axis above the floor: room under the camera for its ribbon
floor_t := 8mm
wall_t := 4mm
back_t := 8mm              // the back wall carries the adjusters' inserts
mirror_face := cube / 2 + gap        // each mirror's surface from the cube's centre
front_in := cube / 2 + front_gap
front_out := front_in + front_t
lip_t := 1.5mm             // the two ledges the cube is pushed against: camera side and front
lip_h := 0.8mm

// -- mirror A's kinematic carrier --------------------------------------------------------------
// A pivot ball and two adjuster screws at three corners of a square, `lever` apart; two
// extension springs pull the carrier back onto them.  Seen from behind, the pivot is low and
// toward the camera, the horizontal-shear screw low and away from it, the vertical-shear screw
// above the pivot.
carrier_w := 50mm
carrier_t := 8mm
lever := 38mm
ball := 4mm                // steel ball at the pivot, in a seat in each face
seat := 3.2mm
seat_deep := 1.5mm
sink := ball / 2 - sqrt((ball / 2)^2 - (seat / 2)^2)   // how far the ball drops into each seat
kgap := ball - 2 * sink                               // carrier to back wall, set by the ball
spring_hole := 4mm
spring_run := 25mm         // each spring this far from the pivot, along an edge: their pull falls inside the three contacts
groove := 1.6mm            // a slot across each spring hole for a 1.5 mm pin to hook on
groove_l := 10mm
carrier_back := mirror_face + carrier_t
back_in := carrier_back + kgap      // the back wall's inside, from the cube's centre
back_out := back_in + back_t
adjust_pitch := 0.5mm      // M3 coarse; 0.35 for M3 fine, 0.3175 for 1/4-80
shear_per_turn := 2 * adjust_pitch / lever * work     // shear on the soundboard, per turn

// -- the camera and its carriage ---------------------------------------------------------------
// Raspberry Pi Global Shutter Camera (its mechanical drawing): a 38 mm board, four Ø2.5 holes on
// a 30 mm square through the mount's flange, a Ø36 back-focus ring standing 10.35 proud of the
// flange, and 14.72 behind it to the back cover; the ribbon leaves the bottom edge.
cam_board := 38mm
cam_hole := 30mm
cam_ring_d := 36mm
cam_proud := 10.35mm
cam_behind := 14.72mm
cam_tab := 6.49mm          // the ribbon connector's drop below the board
lens_len := 35mm           // lens plus its C–CS spacer: measure yours, the carriage slides ±travel
lens_d := 34mm
travel := 12mm
plate_t := 6mm
plate_w := 40mm
foot_l := 22mm
foot_t := 6mm
rib_t := 3mm
rib_h := 18mm
slot_y := 12mm             // the foot's two slots, either side of the axis
board_x := -(cube / 2 + lens_gap + lens_len + cam_proud)   // the flange face, at nominal travel
foot_x := board_x + plate_t + foot_l / 2                    // the foot's centre: floor inserts here

// -- the housing's extent ------------------------------------------------------------------
side_in := carrier_w / 2 + 5mm                             // the +x wall's inside
x_in := board_x - travel - cam_behind - 8mm                // the -x wall's inside: room for the ribbon's fold
top := max(h + carrier_w / 2, h + cam_board / 2, h + lens_d / 2) + 3mm
lid_t := 4mm
boss_w := mirror_w + 6mm                                   // the fixed mirror's boss, across y
lid_x := [x_in + 5mm, side_in]                             // lid screws: near each end wall
mount_dx := 100mm          // M5 inserts underneath, on this rectangle, for the T-slot frame
mount_dy := 40mm
mount_cx := (x_in + side_in) / 2
mount_cy := (front_out - back_out) / 2
