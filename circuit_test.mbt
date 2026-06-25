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
test "operating points are finite and plausible" {
  let params = sample_params()
  let no_load = operating_point(params, slip=0.01)
  let locked = operating_point(params, slip=1.0)
  assert_true(no_load.input_current.abs() > 0.0)
  assert_true(locked.input_current.abs() > no_load.input_current.abs())
  assert_true(locked.torque > 0.0)
  assert_true(locked.power_factor > 0.0)
}

///|
test "diagram samples and svg output" {
  let diagram = make_circle_diagram(sample_params(), samples=16)
  assert_eq(diagram.points.length(), 16)
  let svg = render_svg(diagram, size={ width: 480.0, height: 320.0 })
  assert_true(svg.contains("<svg"))
  assert_true(svg.contains("output line"))
}

///|
test "invalid minimum slip returns an error" {
  try ignore(make_circle_diagram(sample_params(), min_slip=0.0)) catch {
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
  try ignore(operating_point(sample_params(), slip=1.1)) catch {
    InvalidInput(_) => ()
    _ => fail("expected InvalidInput")
  } noraise {
    _ => fail("expected slip above 1 to fail")
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
  }
  try ignore(branch_currents(params, slip=0.05)) catch {
    InvalidInput(_) => ()
    _ => fail("expected InvalidInput")
  } noraise {
    _ => fail("expected negative leakage reactance to fail")
  }
}
