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
cube := 40mm               // 50:50 cube beamsplitter, VIS (Edmund #32-506); never a polarizing one
cube_ca := 0.9 * cube      // clear aperture: the coating's usable 90%
gap := 2mm                 // cube face to each mirror's surface: both arms the same
mirror_w := 30mm           // square first-surface mirrors, Edmund #63-165 (round would need 30 mm across the corners)
mirror_t := 5mm            // Edmund #63-165 (check the thickness of yours)
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
front_gap := 2mm           // cube's object face to the front wall's inside: room for the recess's wall
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

// The cube sits in a recess in its pedestal, which fixes it in x, y and its turn, and a padded
// post under the lid presses it down.  The recess's rim must stay below the light, which leaves
// the cube's faces no lower than `exit_spot / 2` under the axis.
recess_d := 2mm
recess_wall := 1.5mm
recess_rim := cube / 2 + fit + recess_wall    // the rim's outside, from the cube's centre
claim (cube - exit_spot) / 2 >= recess_d      // the rim clears the field
claim cube / 2 + front_gap > recess_rim       // the rim clears the front wall's window
pad_t := 2mm               // silicone or felt pad under the lid's post
pad_squeeze := 0.5mm       // how much the lid compresses it
press_w := 24mm            // the post's square footprint, centred over the cube

// -- mirror A's kinematic carrier --------------------------------------------------------------
// A pivot ball and two adjuster screws at three corners of a square, `lever` apart; two
// extension springs pull the carrier back onto them.  Seen from behind, the pivot is low and
// toward the camera, the horizontal-shear screw low and away from it, the vertical-shear screw
// above the pivot.
carrier_w := 50mm
carrier_t := 10mm          // 5 behind the mirror's pocket
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
carrier_relief := 1.5mm    // a step off the carrier's lower front edge, clear of the recess's rim
claim mirror_face + carrier_relief - recess_rim >= 1.5mm
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
travel := 9mm             // either way: lenses from 26 to 44 mm long
plate_t := 6mm
plate_w := 40mm
foot_l := 27mm             // in front of the plate
foot_t := 6mm
rib_t := 3mm
rib_h := 18mm
slot_y := 12mm             // the foot's two slots, either side of the axis
board_x := -(cube / 2 + lens_gap + lens_len + cam_proud)   // the flange face, at nominal travel
// The floor inserts, under the slots' middles.  Each slot runs `travel` either way of its
// insert: no nearer the plate than its screw's washer allows, and 3 short of the foot's end.
slot_lo := plate_t + washer_d / 2 + 0.5mm                  // the slots' range, from the plate's back face
slot_hi := plate_t + foot_l - 3mm - m3_clear / 2
foot_x := board_x + (slot_lo + slot_hi) / 2
claim (slot_hi - slot_lo) / 2 >= travel
// slid all the way forward, for the shortest lens, the foot stops short of the cube's pedestal
claim board_x + travel + plate_t + foot_l <= -recess_rim - 2mm

// -- the housing's extent ------------------------------------------------------------------
side_in := carrier_w / 2 + 5mm                             // the +x wall's inside
x_in := board_x - travel - cam_behind - 8mm                // the -x wall's inside: room for the ribbon's fold
top := max(h + carrier_w / 2, h + cam_board / 2, h + lens_d / 2) + 4mm
lid_t := 4mm
// The finish: the box's corners rounded in plan, its floor's and the lid's outer edges rounded,
// the walls filleted into the floor inside, and a lip under the lid that drops into the walls.
corner_r := 8mm            // the box's corners, in plan
edge_r := 2mm              // the floor's outside edges and the lid's top edges
inner_r := corner_r - wall_t    // the cavity's corners: an even wall round them
fillet := 1.5mm            // the walls into the floor, inside
lip_d := 3mm               // the lid's locating lip: its depth into the walls
lip_w := 2mm
lip_lead := 1mm            // its lower outside edge rounded, to lead it in
lid_x := [x_in - wall_t + corner_r, side_in + wall_t - corner_r]   // lid screws: on the corners' centres
boss_w := mirror_w + 6mm                                   // the fixed mirror's boss, across y
mount_dx := 100mm          // M5 inserts underneath, on this rectangle, for the T-slot frame
mount_dy := 40mm
mount_cx := (x_in + side_in) / 2
mount_cy := (front_out - back_out) / 2

// -- hardware ----------------------------------------------------------------------------------
// The bought fasteners, sized as the parts expect them (`head.hardware` draws them).
cap_head_d := 5.5mm        // M3 socket-head cap screw
cap_head_h := 3mm
adj_len := 16mm            // the adjusters: M3 × 16, tip on the carrier's back face
claim adj_len - back_t - kgap >= 3mm      // the head stands off the wall: room to turn it in
pin_d := 1.5mm             // the spring pins, lying in their grooves
// Mirror A's springs: McMaster-Carr 5108N95, music wire with loop ends, 12.5 mm long inside the
// loops, 3.5 mm OD on 0.5 mm wire, 0.46 lb (2.05 N) to start it and 0.33 lbf/mm (1.47 N/mm) after,
// 19.4 mm at its maximum load.  `head.sv` claims each sits within that range on its pins.
spring_len := 12.5mm
spring_max := 19.4mm
spring_f0 := 2.05N
spring_k := 1.47N / 1mm
spring_r := 1.5mm          // coil radius to the wire's centre: 3.5 OD in a Ø4 hole
spring_wire := 0.25mm      // wire radius
spring_turns := 12
lid_screw_len := 8mm       // M3 × 8 into the walls' inserts
cart_screw_len := 10mm     // M3 × 10 with a washer, through the carriage's slots
washer_d := 7mm
washer_t := 0.5mm
m25_len := 12mm            // M2.5 × 12 from behind the camera into the carriage
cam_stack := 6.2mm         // what those screws pass through first: the mount's flange and the board (check yours)
