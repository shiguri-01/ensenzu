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
- `render.mbt`: SVG rendering with `bobzhang/vg`

The usual flow is:

```mbt check
///|
test {
  let params = sample_params()
  let diagram = make_circle_diagram(params, samples=48)
  let svg = render_svg(diagram, size={ width: 900.0, height: 640.0 })
  assert_true(svg.contains("<svg"))
}
```

Invalid input parameters and impossible geometric constructions are reported as
`CircleDiagramError`.
