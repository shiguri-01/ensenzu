///|
test "default params render an svg" {
  let svg = @app.render_default_svg()
  assert_true(svg.contains("<svg"))
  assert_true(svg.contains("<path"))
}

///|
test "rabbita app renders controls" {
  let model = @app.initial_model()
  assert_true(model.svg.contains("<svg"))
  assert_true(model.error == None)
}

///|
test "svg data uri escapes markup" {
  let uri = @app.svg_data_uri("<svg id=\"a b\">#</svg>")
  assert_true(uri.contains("%3Csvg"))
  assert_true(uri.contains("id=%22a%20b%22"))
  assert_true(uri.contains("%23"))
}

///|
test "interactive rendering rejects excessive svg size" {
  let fields = { ..@app.default_app_fields(), width: "99999" }
  let model = @app.model_from_fields(fields)
  assert_true(model.error is Some(_))
  assert_true(model.svg.length() == 0)
}

///|
test "characteristics are computed when output_power is valid" {
  let model = @app.initial_model()
  assert_true(model.characteristics is Some(_))
  assert_true(model.line_lengths is Some(_))
  guard model.characteristics is Some(c) else {
    fail("expected characteristics")
  }
  guard model.line_lengths is Some(lengths) else {
    fail("expected line lengths")
  }
  assert_true(c.input_current > 0.0)
  assert_true(c.efficiency > 0.0 && c.efficiency < 1.0)
  assert_true(c.power_factor > 0.0 && c.power_factor <= 1.0)
  assert_eq(c.input_current, lengths.o_p)
  assert_eq(c.active_current_component, lengths.p_m)
}

///|
test "output_power changes rendered readout lines" {
  let fields = @app.default_app_fields()
  let first = @app.model_from_fields({ ..fields, output_power: "900" })
  let second = @app.model_from_fields({ ..fields, output_power: "1100" })
  assert_true(first.error == None)
  assert_true(second.error == None)
  assert_true(first.svg != second.svg)
  assert_true(first.line_lengths != second.line_lengths)
}

///|
test "invalid output_power shows an error" {
  let fields = { ..@app.default_app_fields(), output_power: "0" }
  let model = @app.model_from_fields(fields)
  assert_true(model.error is Some(_))
  assert_true(model.characteristics == None)
  assert_true(model.line_lengths == None)
}
