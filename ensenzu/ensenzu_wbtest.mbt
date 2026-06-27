///|
fn close_to(a : Double, b : Double) -> Bool {
  (a - b).abs() <= NUMERIC_TOLERANCE
}

///|
fn collinear(a : PlotPoint, b : PlotPoint, c : PlotPoint) -> Bool {
  nearly_zero((b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x))
}

///|
fn perpendicular(
  a : PlotPoint,
  b : PlotPoint,
  c : PlotPoint,
  d : PlotPoint,
) -> Bool {
  nearly_zero((b.x - a.x) * (d.x - c.x) + (b.y - a.y) * (d.y - c.y))
}

///|
test "construction invariants" {
  let diagram = make_circle_diagram(example_params())
  let k = make_default_render_construction(diagram)
  assert_true(k.d.x > k.o.x)
  assert_true(close_to(k.c.y, k.n.y))
  assert_true(close_to(k.c.distance(k.n), k.radius))
  assert_true(close_to(k.c.distance(k.s), k.radius))
  assert_true(close_to(k.c.distance(k.p), k.radius))
  assert_true(collinear(k.n, k.s, k.d))
  assert_true(
    collinear(
      k.h,
      k.p,
      PlotPoint(x=k.h.x + k.s.x - k.n.x, y=k.h.y + k.s.y - k.n.y),
    ),
  )
  assert_true(close_to(k.d.distance(k.h), k.p.distance(k.a)))
  assert_true(collinear(k.n, k.s, k.qm))
  assert_true(perpendicular(k.n, k.s, k.c, k.qm))
  assert_true(collinear(k.n, k.t, k.qt))
  assert_true(perpendicular(k.n, k.t, k.c, k.qt))
  assert_true(collinear(k.d, k.p, k.y))
  assert_true(collinear(k.f, k.s, k.y))
  assert_true(collinear(k.n, k.p, k.r))
  assert_true(collinear(k.g, k.s, k.r))
}
