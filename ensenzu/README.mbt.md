# shiguri-01/ensenzu

L-equivalent circuit circle diagram generator written in MoonBit.

## Usage

Generate the sample SVG:

```bash
moon run cmd/main > circle_diagram.svg
```

The library separates the numerical model from rendering:

- `complex.mbt`: complex arithmetic
- `circuit.mbt`: L-equivalent circuit and operating-point calculations
- `diagram.mbt`: circle-diagram sampling and plot data
- `construction.mbt`: L-type circle-diagram geometric construction
- `characteristics.mbt`: circle-diagram distances and motor characteristics
- `render.mbt`: SVG rendering with `bobzhang/vg`

The usual flow is:

```mbt check
///|
test {
  let params = sample_params()
  let diagram = make_circle_diagram(params, samples=48)
  ignore(render_svg(diagram, size={ width: 900.0, height: 640.0 }))
}
```

Read the construction lengths for a selected output power, then calculate the
operating characteristics from those lengths:

```mbt check
///|
test {
  let params = sample_params()
  let diagram = make_circle_diagram(params, samples=48)
  let output_power = operating_point(params, slip=0.05).output_power
  let readout = read_at_output_power(diagram, output_power~)
  let lengths = readout.characteristic_line_lengths()
  ignore(readout.characteristics())
  ignore(lengths)
}
```

Invalid input parameters and impossible geometric constructions are reported as
`CircleDiagramError`.
