# Ice experiment

Open **Library → Metal Shaders → Ice** (iOS 17+). Hold or slowly drag a finger
to accumulate heat. **Freeze** clears touch history and restarts growth from
the edges. **Melt / Restore ice** animates the entire sheet. **Thickness**
controls opacity and refraction. **Refreeze automatically** enables cooling.
All screen text is English.

## Book-based implementation

The material and algorithm follow Bookshelf's
[Texture Maps and Blending](https://bookshelf.dev/metal-tutorials/tutorials/metaltutorials/ice-textures/)
and [Freezing a View Over with Ice](https://bookshelf.dev/metal-tutorials/tutorials/metaltutorials/ice/),
read through the user's purchased-book access in Safari. This is an adaptation
for this app, not Riveo's original source or a claim of pixel-identical output.

- `Ice.metal` is compiled into `default.metallib` at **build time**. No runtime
  source compilation, MTKView, compute dispatches or snapshot capture remain.
- `IceSurface.swift` applies a stitchable SwiftUI `layerEffect` to live content.
  Its two image arguments are color and packed relief (R = height, G/B = normal
  X/Y). Normal Z is reconstructed, and Y is flipped for layer coordinates.
- A weighted 3×3 Voronoi neighborhood defines a soft activation-time field.
  Edge cells freeze first. It does not generate the visible crystal pattern.
- The height map controls growth and thaw thresholds. Thin material clears
  first; ridges survive longer. Normal-driven refraction, highlights and a
  thickness-based albedo blend complete the effect.
- Touches add 0.20 heat at 20 Hz in a smooth disc of radius 12% of view height.
  Heat holds for 2 seconds, then decays exponentially at 1.4/s. Nearby touches
  re-warm a deposit. Compared with the tutorial's individual samples, nearby
  deposits are merged and the history is capped at 160 to bound fragment work.
  At capacity, new heat merges into the nearest deposit; with refreezing off,
  very long drawing sessions therefore lose spatial precision, not old heat.
- The animation clock runs at up to 30 Hz, stops invalidating the view once
  settled, and is cancelled when hidden/inactive. Touches and growth pause in
  the background. Resizing restarts the clock with the new aspect ratio.

## Texture provenance

The bundled material uses these image examples from the tutorial, not invented
procedural crystals:

- [Original color image, 401×401](https://bookshelf.dev/metal-tutorials/images/MetalTutorials/ice-original.png)
- [Height-map example, 360×480](https://bookshelf.dev/metal-tutorials/images/MetalTutorials/ice-h-map.png)
- [Normal-map example, 360×480](https://bookshelf.dev/metal-tutorials/images/MetalTutorials/ice-n-decode.png)

These are the published example images, not a high-resolution source-material
download. Color is resampled to the map dimensions; all maps share coordinates.
`Tools/pack-ice-textures.swift` packs their numeric channels with an opaque alpha
and a linear color profile, avoiding unwanted gamma/premultiplication changes.
The material remains attributed to the book; this project does not grant a new
license to redistribute the author's assets. Confirm their license before any
public distribution of this demo.

To regenerate after downloading the three named PNGs into a local directory:

```sh
swift Tools/pack-ice-textures.swift /path/to/source-images Animations.swiftpm/Assets.xcassets
```

## Validation

Build the `Animations` scheme in `Animations.swiftpm`. Xcode's optional Metal
Toolchain component is required for the `.metal` file (install with
`xcodebuild -downloadComponent MetalToolchain` if absent).

The app currently has no unit-test target. A standalone deterministic harness
executes the actual simulation types, without adding a test framework:

```sh
swiftc Animations.swiftpm/Experiments/Metal/IceExperimentView.swift \
  Animations.swiftpm/Experiments/Metal/IceSurface.swift \
  Tools/check-ice-simulation.swift -o /tmp/check-ice-simulation
/tmp/check-ice-simulation
```

It checks settled freeze/idle, stationary heat accumulation, float-array layout,
refreeze off/on, bounded history, full melt and reset. Also verify initial
growth, drag/hold, full Melt/Freeze, back navigation and repeated entry on the
simulator with Metal API Validation enabled. Actual frame rate and energy use
still need profiling on the intended physical iPhone.
