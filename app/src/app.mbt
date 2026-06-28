///|
pub(all) struct AppParams {
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
  width : Double
  height : Double
  output_power : Double
} derive(Debug, Eq)

///|
pub(all) struct AppFields {
  phase_voltage : String
  frequency : String
  poles : String
  phases : String
  r1 : String
  x1 : String
  r2 : String
  x2 : String
  xm : String
  core_loss_resistance : String
  width : String
  height : String
  output_power : String
} derive(Debug, Eq)

///|
pub(all) enum FieldKey {
  PhaseVoltage
  Frequency
  Poles
  Phases
  R1
  X1
  R2
  X2
  Xm
  CoreLossResistance
  Width
  Height
  OutputPower
} derive(Debug, Eq)

///|
pub(all) struct Model {
  fields : AppFields
  svg : String
  characteristics : @ensenzu.CircleDiagramCharacteristics?
  line_lengths : @ensenzu.CharacteristicLineLengths?
  error : String?
  show_advanced : Bool
  confirm_reset : Bool
} derive(Debug, Eq)

///|
pub(all) enum Msg {
  Change(FieldKey, String)
  RequestReset
  Reset
  CancelReset
  Download
  ToggleAdvanced
} derive(Debug, Eq)

///|
pub(all) suberror AppInputError {
  InvalidField(String, String)
} derive(Debug)

///|
const DEFAULT_APP_POINT_COUNT : Int = 96

///|
const DEFAULT_APP_MIN_SLIP : Double = 0.01

///|
const MAX_SVG_WIDTH : Double = 1800.0

///|
const MAX_SVG_HEIGHT : Double = 1400.0

///|
pub fn default_app_params() -> AppParams {
  let sample = @ensenzu.example_params()
  {
    phase_voltage: sample.phase_voltage,
    frequency: sample.frequency,
    poles: sample.poles,
    phases: sample.phases,
    r1: sample.r1,
    x1: sample.x1,
    r2: sample.r2,
    x2: sample.x2,
    xm: sample.xm,
    core_loss_resistance: sample.core_loss_resistance,
    width: 900.0,
    height: 640.0,
    output_power: 1000.0,
  }
}

///|
pub fn default_app_fields() -> AppFields {
  let params = default_app_params()
  AppFields::from_params(params)
}

///|
fn AppFields::from_params(params : AppParams) -> Self {
  {
    phase_voltage: params.phase_voltage.to_string(),
    frequency: params.frequency.to_string(),
    poles: params.poles.to_string(),
    phases: params.phases.to_string(),
    r1: params.r1.to_string(),
    x1: params.x1.to_string(),
    r2: params.r2.to_string(),
    x2: params.x2.to_string(),
    xm: params.xm.to_string(),
    core_loss_resistance: params.core_loss_resistance.to_string(),
    width: params.width.to_string(),
    height: params.height.to_string(),
    output_power: params.output_power.to_string(),
  }
}

///|
fn AppFields::set(self : Self, key : FieldKey, value : String) -> Self {
  match key {
    PhaseVoltage => { ..self, phase_voltage: value }
    Frequency => { ..self, frequency: value }
    Poles => { ..self, poles: value }
    Phases => { ..self, phases: value }
    R1 => { ..self, r1: value }
    X1 => { ..self, x1: value }
    R2 => { ..self, r2: value }
    X2 => { ..self, x2: value }
    Xm => { ..self, xm: value }
    CoreLossResistance => { ..self, core_loss_resistance: value }
    Width => { ..self, width: value }
    Height => { ..self, height: value }
    OutputPower => { ..self, output_power: value }
  }
}

///|
fn parse_double(label : String, value : String) -> Double raise AppInputError {
  try @string.parse_double(value) catch {
    _ => raise InvalidField(label, "数値を入力してください")
  } noraise {
    x => x
  }
}

///|
fn parse_int(label : String, value : String) -> Int raise AppInputError {
  try @string.parse_int(value) catch {
    _ => raise InvalidField(label, "整数を入力してください")
  } noraise {
    x => x
  }
}

///|
pub fn AppFields::to_params(self : Self) -> AppParams raise AppInputError {
  let params : AppParams = {
    phase_voltage: parse_double("相電圧", self.phase_voltage),
    frequency: parse_double("周波数", self.frequency),
    poles: parse_int("極数", self.poles),
    phases: parse_int("相数", self.phases),
    r1: parse_double("一次抵抗 r1", self.r1),
    x1: parse_double("一次漏れリアクタンス x1", self.x1),
    r2: parse_double("二次抵抗 r2", self.r2),
    x2: parse_double("二次漏れリアクタンス x2", self.x2),
    xm: parse_double("励磁リアクタンス xm", self.xm),
    core_loss_resistance: parse_double(
      "鉄損抵抗",
      self.core_loss_resistance,
    ),
    width: parse_double("SVG幅", self.width),
    height: parse_double("SVG高さ", self.height),
    output_power: parse_double("出力電力", self.output_power),
  }
  params.validate_for_interactive_render()
  params
}

///|
fn AppParams::validate_for_interactive_render(
  self : Self,
) -> Unit raise AppInputError {
  guard self.width <= MAX_SVG_WIDTH else {
    raise InvalidField("SVG幅", "\{MAX_SVG_WIDTH}以下にしてください")
  }
  guard self.height <= MAX_SVG_HEIGHT else {
    raise InvalidField(
      "SVG高さ",
      "\{MAX_SVG_HEIGHT}以下にしてください",
    )
  }
}

///|
fn AppParams::to_circuit_params(self : Self) -> @ensenzu.CircuitParams {
  {
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
  }
}

///|
fn build_diagram(
  params : AppParams,
) -> @ensenzu.CircleDiagram raise @ensenzu.CircleDiagramError {
  @ensenzu.make_circle_diagram(
    params.to_circuit_params(),
    point_count=DEFAULT_APP_POINT_COUNT,
    min_slip=DEFAULT_APP_MIN_SLIP,
  )
}

///|
pub fn render_app_svg(
  params : AppParams,
) -> String raise @ensenzu.CircleDiagramError {
  let diagram = build_diagram(params)
  @ensenzu.render_svg(diagram, output_power=params.output_power, size={
    width: params.width,
    height: params.height,
  })
}

///|
pub fn render_default_svg() -> String raise @ensenzu.CircleDiagramError {
  render_app_svg(default_app_params())
}

///|
pub fn svg_data_uri(svg : String) -> String {
  "data:image/svg+xml;charset=utf-8," +
  svg
  .replace_all(old="%", new="%25")
  .replace_all(old="#", new="%23")
  .replace_all(old="<", new="%3C")
  .replace_all(old=">", new="%3E")
  .replace_all(old="\"", new="%22")
  .replace_all(old=" ", new="%20")
  .replace_all(old="\n", new="")
}

///|
priv suberror RenderError {
  RenderError(String)
}

///|
priv struct RenderResult {
  svg : String
  characteristics : @ensenzu.CircleDiagramCharacteristics?
  line_lengths : @ensenzu.CharacteristicLineLengths?
}

///|
fn read_operating_values(
  diagram : @ensenzu.CircleDiagram,
  output_power~ : Double,
) -> (
  @ensenzu.CircleDiagramCharacteristics?,
  @ensenzu.CharacteristicLineLengths?,
) raise @ensenzu.CircleDiagramError {
  let readout = @ensenzu.read_at_output_power(diagram, output_power~)
  (Some(readout.characteristics()), Some(readout.characteristic_line_lengths()))
}

///|
fn render_from_fields(fields : AppFields) -> RenderResult raise RenderError {
  let params = fields.to_params() catch {
    InvalidField(label, msg) => raise RenderError("\{label}: \{msg}")
  }
  let diagram = build_diagram(params) catch {
    InvalidInput(msg) | GeometryError(msg) => raise RenderError(msg)
  }
  let svg = @ensenzu.render_svg(diagram, output_power=params.output_power, size={
    width: params.width,
    height: params.height,
  }) catch {
    InvalidInput(msg) | GeometryError(msg) => raise RenderError(msg)
  }
  let values = read_operating_values(diagram, output_power=params.output_power) catch {
    InvalidInput(msg) | GeometryError(msg) => raise RenderError(msg)
  }
  let (characteristics, line_lengths) = values
  { svg, characteristics, line_lengths }
}

///|
pub fn model_from_fields(
  fields : AppFields,
  previous_svg? : String = "",
  show_advanced? : Bool = false,
) -> Model {
  let make_error = fn(msg : String) -> Model {
    {
      fields,
      svg: previous_svg,
      characteristics: None,
      line_lengths: None,
      error: Some(msg),
      show_advanced,
      confirm_reset: false,
    }
  }
  try render_from_fields(fields) catch {
    RenderError(msg) => make_error(msg)
  } noraise {
    result =>
      {
        fields,
        svg: result.svg,
        characteristics: result.characteristics,
        line_lengths: result.line_lengths,
        error: None,
        show_advanced,
        confirm_reset: false,
      }
  }
}

///|
pub fn initial_model() -> Model {
  model_from_fields(default_app_fields(), show_advanced=false)
}

///|
fn update(
  _emit : @rabbita.Emit[Msg],
  msg : Msg,
  model : Model,
) -> (@rabbita.Cmd, Model) {
  match msg {
    Change(key, value) => {
      let fields = model.fields.set(key, value)
      (
        @rabbita.none,
        model_from_fields(
          fields,
          previous_svg=model.svg,
          show_advanced=model.show_advanced,
        ),
      )
    }
    RequestReset => (@rabbita.none, { ..model, confirm_reset: true })
    CancelReset => (@rabbita.none, { ..model, confirm_reset: false })
    Reset =>
      (
        @rabbita.none,
        model_from_fields(
          default_app_fields(),
          show_advanced=model.show_advanced,
        ),
      )
    Download =>
      if model.svg.length() == 0 || model.error is Some(_) {
        (@rabbita.none, model)
      } else {
        (download_svg_cmd("circle-diagram.svg", model.svg), model)
      }
    ToggleAdvanced =>
      (@rabbita.none, { ..model, show_advanced: !model.show_advanced })
  }
}

///|
pub fn make_app() -> @rabbita.Cell {
  @rabbita.cell(model=initial_model(), update~, view~)
}

///|
pub fn mount_app() -> Unit {
  @rabbita.new(make_app()).mount("app")
}
