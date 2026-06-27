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
