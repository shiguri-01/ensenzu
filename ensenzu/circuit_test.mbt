///|
test "complex arithmetic" {
  let a = Complex::Complex(re=3.0, im=2.0)
  let b = Complex::Complex(re=1.0, im=-4.0)
  let product = a * b
  assert_eq(product.re, 11.0)
  assert_eq(product.im, -10.0)
  let quotient = product / b
  assert_eq(quotient.re, a.re)
  assert_eq(quotient.im, a.im)
}

///|
fn almost_equal(a : Double, b : Double) -> Bool {
  (a - b).abs() <= (a.abs() + b.abs() + 1.0) * 1.0e-10
}

///|
test "operating points are finite and plausible" {
  let params = example_params()
  let no_load = operating_point(params, slip=0.01)
  let locked = operating_point(params, slip=1.0)
  assert_true(no_load.input_current.abs() > 0.0)
  assert_true(locked.input_current.abs() > no_load.input_current.abs())
  assert_true(locked.torque > 0.0)
  assert_true(locked.power_factor > 0.0)
}

///|
test "diagram point count and svg output" {
  let params = example_params()
  let diagram = make_circle_diagram(params, point_count=16)
  assert_eq(diagram.points.length(), 16)
  let output_power = operating_point(params, slip=0.05).output_power
  let svg = render_svg(diagram, output_power~, size={
    width: 480.0,
    height: 320.0,
  })
  assert_true(svg.contains("<svg"))
  assert_true(svg.contains("output line"))
}

///|
test "diagram lengths and characteristics are available" {
  let params = example_params()
  let diagram = make_circle_diagram(params, point_count=32)
  let output_power = operating_point(params, slip=0.05).output_power
  let readout = read_at_output_power(diagram, output_power~)
  let lengths = readout.characteristic_line_lengths()
  let characteristics = readout.characteristics()
  assert_true(characteristics.primary_current > 0.0)
  assert_true(characteristics.input_power > 0.0)
  assert_true(characteristics.output_power > 0.0)
  assert_true(characteristics.torque > 0.0)
  assert_true(characteristics.secondary_copper_loss > 0.0)
  assert_true(characteristics.primary_copper_loss >= 0.0)
  assert_true(characteristics.core_loss > 0.0)
  assert_true(characteristics.efficiency > 0.0)
  assert_true(lengths.o_p > 0.0)
  assert_true(lengths.p_m > 0.0)
  assert_true(lengths.p_a > 0.0)
  assert_true(lengths.p_b > 0.0)
  assert_true(lengths.a_b > 0.0)
  assert_true(lengths.f_y > 0.0)
  assert_true(lengths.f_s > 0.0)
  assert_true(lengths.g_r > 0.0)
  assert_true(lengths.g_s > 0.0)
  assert_true(almost_equal(characteristics.output_power, output_power))
  assert_true(
    almost_equal(
      characteristics.secondary_copper_loss,
      characteristics.input_power * lengths.a_b / lengths.p_m,
    ),
  )
  assert_true(
    almost_equal(
      characteristics.primary_copper_loss,
      params.phases.to_double() * params.r1 * lengths.o_p * lengths.o_p,
    ),
  )
  assert_true(
    almost_equal(
      characteristics.core_loss,
      params.phases.to_double() *
      params.phase_voltage *
      params.phase_voltage /
      params.core_loss_resistance,
    ),
  )
  assert_true(
    almost_equal(
      characteristics.efficiency,
      output_power / characteristics.input_power,
    ),
  )
  assert_true(almost_equal(characteristics.slip, lengths.g_r / lengths.g_s))
  assert_true(almost_equal(readout.distance(from=D, to=H), lengths.p_a))
  assert_eq(readout.distance(from=P, to=A), lengths.p_a)
}

///|
test "circle diagram readout matches equivalent circuit calculation" {
  let params = example_params()
  let diagram = make_circle_diagram(params, point_count=32)
  let expected = operating_point(params, slip=0.05)
  let readout = read_at_output_power(
    diagram,
    output_power=expected.output_power,
  )
  let actual = readout.characteristics()
  assert_true(almost_equal(actual.slip, expected.slip))
  assert_true(
    almost_equal(actual.primary_current, expected.input_current.abs()),
  )
  assert_true(almost_equal(actual.power_factor, expected.power_factor))
  assert_true(almost_equal(actual.input_power, expected.input_power))
  assert_true(almost_equal(actual.air_gap_power, expected.air_gap_power))
  assert_true(almost_equal(actual.output_power, expected.output_power))
  assert_true(almost_equal(actual.torque, expected.torque))
  assert_true(
    almost_equal(
      actual.secondary_copper_loss,
      expected.air_gap_power - expected.output_power - params.mechanical_loss,
    ),
  )
  assert_true(
    almost_equal(
      actual.primary_copper_loss,
      params.phases.to_double() * params.r1 * expected.input_current.abs2(),
    ),
  )
  assert_true(
    almost_equal(
      actual.core_loss,
      params.phases.to_double() *
      params.phase_voltage *
      params.phase_voltage /
      params.core_loss_resistance,
    ),
  )
  assert_true(almost_equal(actual.efficiency, expected.efficiency))
}

///|
test "no-load and locked-rotor tests derive equivalent circuit params" {
  let tests : NoLoadLockedRotorTestParams = {
    phase_voltage: 200.0 / 3.0.sqrt(),
    frequency: 50.0,
    poles: 4,
    phases: 3,
    primary_resistance: 0.7,
    no_load_input_power: 110.0,
    no_load_current: 3.65,
    mechanical_loss: 20.0,
    locked_rotor_voltage: 80.0 / 3.0.sqrt(),
    locked_rotor_input_power: 900.0,
    locked_rotor_current: 10.0,
  }
  let params = circuit_params_from_tests(tests)
  let phases = tests.phases.to_double()
  let no_load_primary_copper_loss = phases *
    tests.primary_resistance *
    tests.no_load_current *
    tests.no_load_current
  let core_loss = tests.no_load_input_power -
    no_load_primary_copper_loss -
    tests.mechanical_loss
  let active_current = core_loss / (phases * tests.phase_voltage)
  let reactive_current = (tests.no_load_current * tests.no_load_current -
  active_current * active_current).sqrt()
  let locked_impedance = tests.locked_rotor_voltage / tests.locked_rotor_current
  let locked_resistance = tests.locked_rotor_input_power /
    (phases * tests.locked_rotor_current * tests.locked_rotor_current)
  let leakage_reactance = (locked_impedance * locked_impedance -
  locked_resistance * locked_resistance).sqrt()
  assert_true(almost_equal(params.r1, tests.primary_resistance))
  assert_true(
    almost_equal(params.r2, locked_resistance - tests.primary_resistance),
  )
  assert_true(almost_equal(params.x1, leakage_reactance / 2.0))
  assert_true(almost_equal(params.x2, leakage_reactance / 2.0))
  assert_true(almost_equal(params.xm, tests.phase_voltage / reactive_current))
  assert_true(
    almost_equal(
      params.core_loss_resistance,
      phases * tests.phase_voltage * tests.phase_voltage / core_loss,
    ),
  )
  assert_true(almost_equal(params.mechanical_loss, tests.mechanical_loss))
}

///|
test "mechanical loss reduces shaft output power" {
  let base = example_params()
  let params : CircuitParams = { ..base, mechanical_loss: 20.0 }
  let op = operating_point(params, slip=0.05)
  assert_true(
    almost_equal(op.output_power, op.air_gap_power * (1.0 - op.slip) - 20.0),
  )
  let diagram = make_circle_diagram(params, point_count=32)
  let readout = read_at_output_power(diagram, output_power=op.output_power)
  let characteristics = readout.characteristics()
  assert_true(almost_equal(characteristics.output_power, op.output_power))
  assert_true(almost_equal(characteristics.mechanical_loss, 20.0))
}

///|
test "invalid minimum slip returns an error" {
  try ignore(make_circle_diagram(example_params(), min_slip=0.0)) catch {
    InvalidInput(_) => ()
    _ => fail("expected InvalidInput")
  } noraise {
    _ => fail("expected invalid minimum slip to fail")
  }
}

///|
test "invalid circuit parameters return an error" {
  let params : CircuitParams = {
    phase_voltage: 0.0,
    frequency: 50.0,
    poles: 4,
    phases: 3,
    r1: 1.2,
    x1: 0.5,
    r2: 0.2,
    x2: 0.5,
    xm: 500.0,
    core_loss_resistance: 1800.0,
    mechanical_loss: 0.0,
  }
  try ignore(operating_point(params, slip=0.01)) catch {
    InvalidInput(_) => ()
    _ => fail("expected InvalidInput")
  } noraise {
    _ => fail("expected invalid circuit parameters to fail")
  }
}

///|
test "invalid slip above locked rotor returns an error" {
  try ignore(operating_point(example_params(), slip=1.1)) catch {
    InvalidInput(_) => ()
    _ => fail("expected InvalidInput")
  } noraise {
    _ => fail("expected slip above 1 to fail")
  }
}

///|
test "invalid render size returns an error" {
  let params = example_params()
  let diagram = make_circle_diagram(params, point_count=16)
  let output_power = operating_point(params, slip=0.05).output_power
  try
    ignore(
      render_svg(diagram, output_power~, size={ width: 30.0, height: 30.0 }),
    )
  catch {
    InvalidInput(_) => ()
    _ => fail("expected InvalidInput")
  } noraise {
    _ => fail("expected invalid render size to fail")
  }
}

///|
test "negative leakage reactance returns an error" {
  let params : CircuitParams = {
    phase_voltage: 200.0,
    frequency: 50.0,
    poles: 4,
    phases: 3,
    r1: 1.2,
    x1: -0.5,
    r2: 0.2,
    x2: 0.5,
    xm: 500.0,
    core_loss_resistance: 1800.0,
    mechanical_loss: 0.0,
  }
  try ignore(branch_currents(params, slip=0.05)) catch {
    InvalidInput(_) => ()
    _ => fail("expected InvalidInput")
  } noraise {
    _ => fail("expected negative leakage reactance to fail")
  }
}
