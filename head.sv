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
