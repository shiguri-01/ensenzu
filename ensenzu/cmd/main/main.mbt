///|
fn main raise {
  let params = @ensenzu.example_params()
  let diagram = @ensenzu.make_circle_diagram(params)
  let output_power = @ensenzu.operating_point(params, slip=0.05).output_power
  println(@ensenzu.render_svg(diagram, output_power~))
}
