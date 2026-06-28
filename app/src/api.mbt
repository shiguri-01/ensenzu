///|
pub(all) enum ApiInputSource {
  LTypeEquivalentCircuit
  NoLoadLockedRotorTest
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct ApiDiagramRequest {
  input_source : ApiInputSource
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
  mechanical_loss : Double
  no_load_input_power : Double
  no_load_current : Double
  locked_rotor_voltage : Double
  locked_rotor_input_power : Double
  locked_rotor_current : Double
  width : Double
  height : Double
  output_power : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct ApiCharacteristics {
  slip : Double
  primary_current : Double
  active_current_component : Double
  power_factor : Double
  input_power : Double
  air_gap_power : Double
  output_power : Double
  torque : Double
  secondary_copper_loss : Double
  primary_copper_loss : Double
  core_loss : Double
  mechanical_loss : Double
  efficiency : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct ApiLineLengths {
  o_p : Double
  o_m : Double
  p_m : Double
  p_a : Double
  p_b : Double
  a_b : Double
  f_y : Double
  f_s : Double
  g_r : Double
  g_s : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct ApiDiagramPayload {
  svg : String
  characteristics : ApiCharacteristics?
  line_lengths : ApiLineLengths?
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct ApiDiagramResponse {
  ok : Bool
  payload : ApiDiagramPayload?
  error : String?
} derive(Debug, Eq, ToJson, FromJson)

///|
fn ApiInputSource::to_input_source(self : Self) -> InputSource {
  match self {
    LTypeEquivalentCircuit => InputSource::LTypeEquivalentCircuit
    NoLoadLockedRotorTest => InputSource::NoLoadLockedRotorTest
  }
}

///|
fn ApiInputSource::from_input_source(source : InputSource) -> Self {
  match source {
    LTypeEquivalentCircuit => ApiInputSource::LTypeEquivalentCircuit
    NoLoadLockedRotorTest => ApiInputSource::NoLoadLockedRotorTest
  }
}

///|
pub fn ApiDiagramRequest::from_params(params : AppParams) -> Self {
  {
    input_source: ApiInputSource::from_input_source(params.input_source),
    phase_voltage: params.phase_voltage,
    frequency: params.frequency,
    poles: params.poles,
    phases: params.phases,
    r1: params.r1,
    x1: params.x1,
    r2: params.r2,
    x2: params.x2,
    xm: params.xm,
    core_loss_resistance: params.core_loss_resistance,
    mechanical_loss: params.mechanical_loss,
    no_load_input_power: params.no_load_input_power,
    no_load_current: params.no_load_current,
    locked_rotor_voltage: params.locked_rotor_voltage,
    locked_rotor_input_power: params.locked_rotor_input_power,
    locked_rotor_current: params.locked_rotor_current,
    width: params.width,
    height: params.height,
    output_power: params.output_power,
  }
}

///|
fn ApiDiagramRequest::to_params(self : Self) -> AppParams {
  {
    input_source: self.input_source.to_input_source(),
    phase_voltage: self.phase_voltage,
    frequency: self.frequency,
    poles: self.poles,
    phases: self.phases,
    r1: self.r1,
    x1: self.x1,
    r2: self.r2,
    x2: self.x2,
    xm: self.xm,
    core_loss_resistance: self.core_loss_resistance,
    mechanical_loss: self.mechanical_loss,
    no_load_input_power: self.no_load_input_power,
    no_load_current: self.no_load_current,
    locked_rotor_voltage: self.locked_rotor_voltage,
    locked_rotor_input_power: self.locked_rotor_input_power,
    locked_rotor_current: self.locked_rotor_current,
    width: self.width,
    height: self.height,
    output_power: self.output_power,
  }
}

///|
fn ApiCharacteristics::from_characteristics(
  c : @ensenzu.CircleDiagramCharacteristics,
) -> Self {
  {
    slip: c.slip,
    primary_current: c.primary_current,
    active_current_component: c.active_current_component,
    power_factor: c.power_factor,
    input_power: c.input_power,
    air_gap_power: c.air_gap_power,
    output_power: c.output_power,
    torque: c.torque,
    secondary_copper_loss: c.secondary_copper_loss,
    primary_copper_loss: c.primary_copper_loss,
    core_loss: c.core_loss,
    mechanical_loss: c.mechanical_loss,
    efficiency: c.efficiency,
  }
}

///|
fn ApiLineLengths::from_line_lengths(
  lengths : @ensenzu.CharacteristicLineLengths,
) -> Self {
  {
    o_p: lengths.o_p,
    o_m: lengths.o_m,
    p_m: lengths.p_m,
    p_a: lengths.p_a,
    p_b: lengths.p_b,
    a_b: lengths.a_b,
    f_y: lengths.f_y,
    f_s: lengths.f_s,
    g_r: lengths.g_r,
    g_s: lengths.g_s,
  }
}

///|
fn ApiDiagramPayload::from_render_result(result : RenderResult) -> Self {
  {
    svg: result.svg,
    characteristics: result.characteristics.map(
      ApiCharacteristics::from_characteristics,
    ),
    line_lengths: result.line_lengths.map(ApiLineLengths::from_line_lengths),
  }
}

///|
fn ApiDiagramResponse::success(payload : ApiDiagramPayload) -> Self {
  { ok: true, payload: Some(payload), error: None }
}

///|
fn ApiDiagramResponse::failure(message : String) -> Self {
  { ok: false, payload: None, error: Some(message) }
}

///|
pub fn render_api_response(request : ApiDiagramRequest) -> ApiDiagramResponse {
  try render_from_params(request.to_params()) catch {
    RenderError(msg) => ApiDiagramResponse::failure(msg)
  } noraise {
    result =>
      ApiDiagramResponse::success(ApiDiagramPayload::from_render_result(result))
  }
}

///|
pub fn render_api_response_json(request_body : String) -> String {
  let response = try {
    let json = @json.parse(request_body[:])
    let request : ApiDiagramRequest = @json.from_json(json)
    render_api_response(request)
  } catch {
    _ => ApiDiagramResponse::failure("Invalid request body.")
  }
  response.to_json().stringify()
}
