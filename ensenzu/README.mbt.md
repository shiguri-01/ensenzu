# shiguri-01/ensenzu

Draw and read L-type induction-motor circle diagrams.

## Usage

```bash
moon run cmd/main > circle_diagram.svg
```

```mbt check
///|
test {
  let params = example_params()
  let diagram = make_circle_diagram(params, point_count=48)
  let output_power = operating_point(params, slip=0.05).output_power
  ignore(
    render_svg(diagram, output_power~, size={ width: 900.0, height: 640.0 }),
  )
}
```

## Readout

```mbt check
///|
test {
  let params = example_params()
  let diagram = make_circle_diagram(params, point_count=48)
  let output_power = operating_point(params, slip=0.05).output_power
  let readout = read_at_output_power(diagram, output_power~)
  let lengths = readout.characteristic_line_lengths()
  ignore(readout.characteristics())
  ignore(lengths)
}
```
