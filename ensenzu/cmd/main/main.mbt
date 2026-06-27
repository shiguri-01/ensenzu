///|
fn main raise {
  let params = @ensenzu.example_params()
  let diagram = @ensenzu.make_circle_diagram(params)
  println(@ensenzu.render_svg(diagram))
}
