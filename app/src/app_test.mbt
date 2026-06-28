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
  assert_true(c.primary_current > 0.0)
  assert_true(c.efficiency > 0.0 && c.efficiency < 1.0)
  assert_true(c.power_factor > 0.0 && c.power_factor <= 1.0)
  assert_eq(c.primary_current, lengths.o_p)
  assert_eq(c.active_current_component, lengths.p_m)
  assert_true(c.torque > 0.0)
  assert_true(c.secondary_copper_loss > 0.0)
  assert_true(c.primary_copper_loss >= 0.0)
  assert_true(c.core_loss > 0.0)
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
test "no-load and locked-rotor test input renders characteristics" {
  let fields = {
    ..@app.default_app_fields(),
    input_source: @app.NoLoadLockedRotorTest,
    r1: "0.7",
    no_load_input_power: "110",
    no_load_current: "3.65",
    mechanical_loss: "20",
    locked_rotor_voltage: "46.19",
    locked_rotor_input_power: "900",
    locked_rotor_current: "10",
    output_power: "400",
  }
  let model = @app.model_from_fields(fields)
  assert_true(model.error == None)
  assert_true(model.svg.contains("<svg"))
  guard model.characteristics is Some(c) else {
    fail("expected characteristics")
  }
  assert_eq(c.mechanical_loss, 20.0)
  assert_true(c.core_loss > 0.0)
  assert_true(c.primary_copper_loss > 0.0)
}

///|
test "default test input renders after switching source" {
  let fields = {
    ..@app.default_app_fields(),
    input_source: @app.NoLoadLockedRotorTest,
    r1: "0.7",
    mechanical_loss: "20",
  }
  let model = @app.model_from_fields(fields)
  assert_true(model.error == None)
  assert_true(model.characteristics is Some(_))
}

///|
test "test input ignores hidden equivalent circuit fields" {
  let fields = {
    ..@app.default_app_fields(),
    input_source: @app.NoLoadLockedRotorTest,
    x1: "",
    r2: "",
    x2: "",
    xm: "",
    core_loss_resistance: "",
    r1: "0.7",
    no_load_input_power: "110",
    no_load_current: "3.65",
    mechanical_loss: "20",
    locked_rotor_voltage: "46.19",
    locked_rotor_input_power: "900",
    locked_rotor_current: "10",
    output_power: "400",
  }
  let model = @app.model_from_fields(fields)
  assert_true(model.error == None)
  assert_true(model.characteristics is Some(_))
}

///|
test "invalid output_power shows an error" {
  let fields = { ..@app.default_app_fields(), output_power: "0" }
  let model = @app.model_from_fields(fields)
  assert_true(model.error is Some(_))
  assert_true(model.characteristics == None)
  assert_true(model.line_lengths == None)
}

///|
test "diagram api response returns svg and characteristics" {
  let body = @app.ApiDiagramRequest::from_params(@app.default_app_params())
    .to_json()
    .stringify()
  let json = @json.parse(@app.render_api_response_json(body))
  let response : @app.ApiDiagramResponse = @json.from_json(json)
  assert_true(response.ok)
  guard response.payload is Some(payload) else { fail("expected payload") }
  assert_true(payload.svg.contains("<svg"))
  guard payload.characteristics is Some(c) else {
    fail("expected characteristics")
  }
  assert_true(c.primary_current > 0.0)
  assert_true(payload.line_lengths is Some(_))
}

///|
test "diagram api response reports invalid json" {
  let json = @json.parse(@app.render_api_response_json("{"))
  let response : @app.ApiDiagramResponse = @json.from_json(json)
  assert_true(!response.ok)
  assert_true(response.payload == None)
  assert_true(response.error is Some(_))
}
