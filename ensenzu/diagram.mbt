///|
pub struct DiagramPoint {
  x : Double
  y : Double
  point : OperatingPoint
} derive(Debug, Eq)

///|
pub struct PlotBounds {
  min_x : Double
  max_x : Double
  min_y : Double
  max_y : Double
} derive(Debug, Eq)

///|
pub struct CircleDiagram {
  params : CircuitParams
  points : Array[DiagramPoint]
  bounds : PlotBounds
  no_load : DiagramPoint
  locked_rotor : DiagramPoint
  max_torque : DiagramPoint
} derive(Debug, Eq)

///|
const DEFAULT_DIAGRAM_SAMPLES : Int = 96

///|
const DEFAULT_MIN_SLIP : Double = 0.01

///|
const DIAGRAM_BOUNDS_X_PADDING_RATIO : Double = 0.12

///|
const DIAGRAM_BOUNDS_Y_PADDING_RATIO : Double = 0.18

///|
const DIAGRAM_BOUNDS_MIN_PADDING : Double = 1.0

///|
pub fn make_circle_diagram(
  params : CircuitParams,
  samples? : Int = DEFAULT_DIAGRAM_SAMPLES,
  min_slip? : Double = DEFAULT_MIN_SLIP,
) -> CircleDiagram raise CircleDiagramError {
  guard samples >= 2 else { raise InvalidInput("samples must be at least 2") }
  guard min_slip >= MINIMUM_SLIP else {
    raise InvalidInput("min_slip is below MINIMUM_SLIP")
  }
  guard min_slip <= 1.0 else {
    raise InvalidInput("min_slip must not exceed 1")
  }
  let count = samples
  let floor_slip = min_slip
  let points : Array[DiagramPoint] = []
  for i in 0..<count {
    let t = i.to_double() / (count - 1).to_double()
    let slip = 1.0 - t * (1.0 - floor_slip)
    let op = operating_point(params, slip~)
    points.push(DiagramPoint::from_operating_point(op))
  }
  let no_load = DiagramPoint::from_operating_point(
    operating_point(params, slip=floor_slip),
  )
  let locked_rotor = DiagramPoint::from_operating_point(
    operating_point(params, slip=1.0),
  )
  let mut max_torque = locked_rotor
  for p in points {
    if p.point.torque > max_torque.point.torque {
      max_torque = p
    }
  }
  let bounds = PlotBounds::covering_diagram_points(points, [
    no_load, locked_rotor, max_torque,
  ])
  { params, points, bounds, no_load, locked_rotor, max_torque }
}

///|
fn DiagramPoint::from_operating_point(point : OperatingPoint) -> Self {
  { x: point.input_current.re, y: -point.input_current.im, point }
}

///|
fn PlotBounds::default() -> Self {
  { min_x: 0.0, max_x: 1.0, min_y: 0.0, max_y: 1.0 }
}

///|
fn PlotBounds::include_point(bounds : Self, p : DiagramPoint) -> Self {
  {
    min_x: if p.x < bounds.min_x {
      p.x
    } else {
      bounds.min_x
    },
    max_x: if p.x > bounds.max_x {
      p.x
    } else {
      bounds.max_x
    },
    min_y: if p.y < bounds.min_y {
      p.y
    } else {
      bounds.min_y
    },
    max_y: if p.y > bounds.max_y {
      p.y
    } else {
      bounds.max_y
    },
  }
}

///|
fn PlotBounds::padded(bounds : Self) -> Self {
  let x_pad = (bounds.max_x - bounds.min_x) * DIAGRAM_BOUNDS_X_PADDING_RATIO +
    DIAGRAM_BOUNDS_MIN_PADDING
  let y_pad = (bounds.max_y - bounds.min_y) * DIAGRAM_BOUNDS_Y_PADDING_RATIO +
    DIAGRAM_BOUNDS_MIN_PADDING
  {
    min_x: bounds.min_x - x_pad,
    max_x: bounds.max_x + x_pad,
    min_y: bounds.min_y - y_pad,
    max_y: bounds.max_y + y_pad,
  }
}

///|
fn PlotBounds::covering_diagram_points(
  points : Array[DiagramPoint],
  landmark_points : Array[DiagramPoint],
) -> Self {
  let mut bounds = PlotBounds::default()
  for p in points {
    bounds = bounds.include_point(p)
  }
  for p in landmark_points {
    bounds = bounds.include_point(p)
  }
  bounds.padded()
}
