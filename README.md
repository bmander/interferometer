# Shearography head for guitar soundboard modal analysis

A Michelson shearing interferometer in front of a Raspberry Pi Global Shutter Camera (IMX296),
modelled in [Solvent](https://github.com/bmander/geomsolver) and checked with `solventc` v0.1.16.
The head images a **500 mm square** of soundboard from about **1.07 m** through a 40 mm
beamsplitter cube, lit by a 532 nm laser. It bolts to your T-slot frame through four M5 inserts in
its floor.

![open assembly](renders/assembly_open.png)

```
make check     # solve the model; every optics and clearance claim is judged
make stl       # stl/housing.stl, carrier.stl, carriage.stl, lid.stl
make renders   # renders/*.png
```

## Layout

| file | what |
|---|---|
| `head/dims.sv` | every number, and the optics claims that size the cube, mirrors, window and filter |
| `head/prims.sv` | boxes, bores along x/y/z, a slot |
| `head/housing.sv` | the main print: cube pedestal, fixed-mirror boss, adjuster wall, window, filter pocket |
| `head/carrier.sv` | mirror A's tip/tilt carrier |
| `head/carriage.sv` | the sliding camera plate |
| `head/lid.sv` | lid with a light-seal lip |
| `head/optics.sv` | stand-ins for the bought parts (cube, mirrors, filter, ball, camera + lens) |
| `head.sv` | the assembly, with clearance claims between parts |

Axes: x right, y forward to the guitar, z up. The origin is under the cube's centre on the floor,
and the optical axis is 40 mm up. Light from the soundboard enters the front (+y) cube face and
splits to **mirror A** (behind, -y, tip/tilt) and **mirror B** (right, +x, fixed). Both returns
reach the camera on the left (-x). Tilting A shears one image against the other.

## Optics: why the parts are the sizes they are

For a 500 mm square you chose ~1 m and an 8 mm lens. That is a wide field (about ±13° half-angle) for
a cube that sits in *front* of the lens, and it drives the design:

- **Square crop.** The 500 mm field maps onto the sensor's short side (1088 px × 3.45 µm =
  3.75 mm), so the image is the central 1088 × 1088. The long side's extra pixels would need a
  much bigger cube, so they are cropped in software.
- **40 mm cube.** Traced back from the lens's entrance pupil, the field passes through two cube
  lengths of glass. Its footprint at the object face is **34.6 mm**, against a 36 mm clear aperture
  (90%). A 25.4 mm cube would cut off the corners of the field.
- **30 × 30 mm mirrors.** The footprint on each mirror is 21.3 mm square. Its diagonal (30 mm)
  is why 1" round mirrors are not enough.
- **Filter outside the window.** A 532 nm bandpass between lens and cube would push the pupil back
  and cause vignetting, so the filter is a 2" (Ø50.8) disc in a pocket outside the front window.
  It is optional in a dark room.
- **f/8** makes speckle about 10 µm, three pixels. Go no wider than f/5.6.
- **Shear.** An M3×0.5 adjuster at a 38 mm lever gives **≈28 mm of shear per turn** at the
  soundboard. A typical 5–15 mm shear is ⅕ to ½ turn. M3×0.35 fine screws or 1/4-80 adjusters
  give finer control (change `adjust_pitch`).

All of these are value claims in `head/dims.sv`. Change a number, rerun `make check`, and each
claim is re-judged as theorem or refuted.

### The one number to measure: `pupil_depth`

The cube's margin depends on how far the lens's entrance pupil sits behind its front rim. It is
assumed to be **12 mm**, but this is rarely published for CCTV lenses. To find it, hold the lens
at arm's length and look into the front. The iris appears to float at some depth, and that depth
is the pupil. Set `pupil_depth` and `lens_len` (lens plus C–CS spacer) and run `make check`. If
`exit_spot <= cube_ca` is refuted, use a lens with a shallower pupil, a 50 mm cube
(`cube := 50mm`), or a longer working distance.

## Bill of materials

| qty | part | notes |
|---|---|---|
| 1 | Non-polarizing beamsplitter cube, **40 mm**, 50:50, VIS (400–700 nm) | must be *non*-polarizing |
| 2 | First-surface mirror, **30 × 30 × 3 mm** | protected Al is fine. Static mirror errors cancel in the before/after subtraction |
| 1 | 532 nm bandpass filter, Ø50.8 mm, ≤ 5 mm thick | optional |
| 1 | Raspberry Pi Global Shutter Camera | |
| 1 | 8 mm C-mount lens with manual iris, rated for ≥ 1/2.9" | uses the camera's C–CS spacer |
| 1 | Ø4 mm steel ball | the pivot |
| 2 | M3 × 16 adjuster screws (ball-end set screws, or cap screws) | add knobs for fine control |
| 2 | Extension springs, ~4 mm OD × 12–15 mm | pull the carrier onto the pivot and screws |
| 4 | 1.5 mm pins, ~10 mm long (cut paperclip or dowel) | spring anchors in the grooves |
| 8 | M3 heat-set inserts (Ø4.0 hole × 6 deep) | 2 adjusters, 2 carriage, 4 lid |
| 4 | M5 heat-set inserts (Ø6.4 hole × 6.5 deep) | frame mounting, underneath |
| 4 | M2.5 × 12 screws | camera to carriage, tapped into the print |
| 2 | M3 × 10 + washers | carriage to floor |
| 4 | M3 × 8 | lid |
| — | RTV silicone | three dots behind each mirror |

Hole sizes for the inserts and taps are in `head/dims.sv` (`m3_insert_d`, `m5_insert_d`,
`m25_tap_d`, `fit`). Tune them to your printer and filament.

## Printing (carbon-filled filament)

- Prefer **CF-PETG or CF-ASA** over PA-CF. Nylon absorbs water and creeps, and stability matters
  more here than strength. If you do use nylon, dry it and let the parts settle before aligning.
- **Housing**: print upright, open top up. The window's top edge is a 38 mm bridge. The filter
  pocket's arc overhangs near its top, so use supports there or print the pocket shallower.
- **Carrier**: face (mirror pocket) down. **Carriage**: standing on its foot. **Lid**: upside down.
- Use high infill (≥ 60%) and ≥ 4 perimeters. Rigidity and mass damp vibration, which matters
  because the head sits near a speaker-driven guitar.

## Assembly and alignment

1. Press the inserts: two adjusters from behind into the back wall, two in the floor for the
   carriage, four in the wall tops for the lid, and four M5 from underneath.
2. **Mirror B**: three RTV dots in the boss pocket, mirror face out, flush with the boss.
   **Mirror A**: the same in the carrier pocket.
3. **Carrier**: put the ball in the back wall's seat (low, toward the camera). Hook the springs
   through the carrier and the wall onto pins in the grooves, then run the two adjuster screws in
   until they just touch. The springs should pull the carrier onto the ball and both screws.
4. **Cube**: stand it on the pedestal, pushed against both ledges. Orient the **coated hypotenuse
   from the front-left corner to the back-right corner** seen from above, with the camera on the
   left. To check, cover both mirrors with card: the camera's image should go dark. If it still
   sees the soundboard, it is looking straight off the hypotenuse; turn the cube a quarter turn.
5. **Camera**: set the back focus on the bench, then bolt the board to the carriage with the
   ring through the bore. Slide the carriage until the lens front is ~3 mm off the cube and lock
   the two M3 screws. Focus at 1.07 m and stop down to f/8.
6. **Zero shear**: aim at a textured target or the guitar under room light, and turn the two
   adjusters until the doubled image merges into one. Then dial in shear with one screw: the
   lower-right screw seen from behind shears horizontally, the upper-left vertically.
7. Lid on. Run the ribbon out of the slot low in the left (-x) wall.

## Using it for modes

With no phase stepper, two capture modes work:

- **Time-averaged subtraction.** Grab a reference frame with the top at rest, then frames while
  driving a sinusoid. |difference| shows correlation fringes, and the nodal lines stay dark
  (unchanged) where the top doesn't move. Sweep frequency to find the modes.
- **Stroboscopic.** The global shutter lets you gate the exposure, or pulse the laser via TTL, at
  a fixed phase of the drive. Subtracting two phases (0° and 180°) gives fringes of the
  deflection *gradient* along the shear, which is what shearography measures.

Shear along the soundboard's length or across it highlights different modes, so try both
screws.

## Not yet covered

- Laser mount and beam expander, the guitar fixture, and excitation (head only, as scoped).
- No piezo phase stepper. If you add one later, the carrier would need a different back.
- The camera stand-in is only an envelope. Check it against your actual lens's diameter
  (`lens_d`) and length (`lens_len`).
