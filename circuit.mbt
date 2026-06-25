///|
pub(all) struct CircuitParams {
  phase_voltage : Double
  frequency : Double
  poles : Int
  phases : Int
  r1 : Double
  x1 : Double
  r2 : Double
  x2 : Double
  xm : Double
  core_loss_resistance : Double
} derive(Debug, Eq)

///|
pub struct BranchCurrents {
  exciting : Complex
  rotor : Complex
  input : Complex
} derive(Debug, Eq)

///|
pub struct OperatingPoint {
  slip : Double
  input_current : Complex
  rotor_current : Complex
  exciting_current : Complex
  input_power : Double
  power_factor : Double
  air_gap_power : Double
  output_power : Double
  torque : Double
  efficiency : Double
} derive(Debug, Eq)

///|
const MINIMUM_SLIP : Double = 1.0e-4

///|
fn CircuitParams::validate(self : Self) -> Unit raise CircleDiagramError {
  guard self.phase_voltage > 0.0 else {
    raise InvalidInput("phase_voltage must be positive")
  }
  guard self.frequency > 0.0 else {
    raise InvalidInput("frequency must be positive")
  }
  guard self.poles > 0 else { raise InvalidInput("poles must be positive") }
  guard self.phases > 0 else { raise InvalidInput("phases must be positive") }
  guard self.r1 >= 0.0 else { raise InvalidInput("r1 must not be negative") }
  guard self.x1 >= 0.0 else { raise InvalidInput("x1 must not be negative") }
  guard self.r2 > 0.0 else { raise InvalidInput("r2 must be positive") }
  guard self.x2 >= 0.0 else { raise InvalidInput("x2 must not be negative") }
  guard self.xm > 0.0 else { raise InvalidInput("xm must be positive") }
  guard self.core_loss_resistance > 0.0 else {
    raise InvalidInput("core_loss_resistance must be positive")
  }
}

///|
pub fn sample_params() -> CircuitParams {
  {
    phase_voltage: 200.0,
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
}

///|
fn checked_slip(slip : Double) -> Double raise CircleDiagramError {
  if slip < MINIMUM_SLIP {
    raise InvalidInput("slip is below MINIMUM_SLIP")
  } else if slip > 1.0 {
    raise InvalidInput("slip must not exceed 1")
  } else {
    slip
  }
}

///|
fn synchronous_speed_rad_per_sec(params : CircuitParams) -> Double {
  4.0 * @math.PI * params.frequency / params.poles.to_double()
}

///|
pub fn branch_currents(
  params : CircuitParams,
  slip~ : Double,
) -> BranchCurrents raise CircleDiagramError {
  params.validate()
  let s = checked_slip(slip)
  let v = Complex(re=params.phase_voltage, im=0.0)
  let rotor_z = Complex(re=params.r1 + params.r2 / s, im=params.x1 + params.x2)
  let rotor = v / rotor_z
  let magnetizing = v / Complex(re=0.0, im=params.xm)
  let core = v / Complex(re=params.core_loss_resistance, im=0.0)
  let exciting = magnetizing + core
  { exciting, rotor, input: exciting + rotor }
}

///|
pub fn operating_point(
  params : CircuitParams,
  slip~ : Double,
) -> OperatingPoint raise CircleDiagramError {
  let s = checked_slip(slip)
  let currents = branch_currents(params, slip=s)
  let phases = params.phases.to_double()
  let v = Complex(re=params.phase_voltage, im=0.0)
  let apparent_per_phase = v * currents.input.conj()
  let input_power = phases * apparent_per_phase.re
  let apparent = phases * params.phase_voltage * currents.input.abs()
  guard apparent > 0.0 else {
    raise InvalidInput("apparent power must be positive")
  }
  let power_factor = input_power / apparent
  let rotor_i2 = currents.rotor.abs2()
  let air_gap_power = phases * rotor_i2 * params.r2 / s
  let output_power = air_gap_power * (1.0 - s)
  let torque = air_gap_power / synchronous_speed_rad_per_sec(params)
  guard input_power > 0.0 else {
    raise InvalidInput("input power must be positive")
  }
  let efficiency = output_power / input_power
  {
    slip: s,
    input_current: currents.input,
    rotor_current: currents.rotor,
    exciting_current: currents.exciting,
    input_power,
    power_factor,
    air_gap_power,
    output_power,
    torque,
    efficiency,
  }
}
