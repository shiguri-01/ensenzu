///|
test "pending positive decimal input keeps the previous render without warning" {
  let previous = initial_model()
  let fields = { ..previous.fields, output_power: "0" }
  let model = model_from_fields_with_state(
    fields,
    previous_svg=previous.svg,
    previous_characteristics=previous.characteristics,
    previous_line_lengths=previous.line_lengths,
    pending_input=true,
  )
  assert_true(model.pending_input)
  assert_true(model.error == None)
  assert_eq(model.svg, previous.svg)
  assert_true(model.characteristics == previous.characteristics)
  assert_true(model.line_lengths == previous.line_lengths)
}

///|
test "invalid completed input preserves the previous render and reports an error" {
  let previous = initial_model()
  let fields = { ..previous.fields, output_power: "-1" }
  let model = model_from_fields_with_state(
    fields,
    previous_svg=previous.svg,
    previous_characteristics=previous.characteristics,
    previous_line_lengths=previous.line_lengths,
  )
  assert_true(!model.pending_input)
  assert_true(model.error is Some(_))
  assert_eq(model.svg, previous.svg)
  assert_true(model.characteristics == previous.characteristics)
  assert_true(model.line_lengths == previous.line_lengths)
}
