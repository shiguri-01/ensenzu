///|
fn view(emit : @rabbita.Emit[Msg], model : Model) -> @rabbita.Html {
  @html.main_(class="shell", [
    @html.section(class="preview", [
      @html.div(class="preview-bar", [
        @html.span(class="app-name", "円線図"),
        @html.button(
          class="btn-primary",
          type_="button",
          disabled=model.error is Some(_),
          on_click=emit(Download),
          "SVGをダウンロード",
        ),
      ]),
      @html.div(class="preview-area", [
        @html.object(
          attrs=@html.Attrs::build()
            .data(svg_data_uri(model.svg))
            .type_("image/svg+xml"),
          "円線図プレビュー",
        ),
      ]),
    ]),
    @html.aside(class="settings", [
      settings_bar_view(model~, emit~),
      error_view(model~),
      @html.form(on_submit=@rabbita.none, [
        @html.fieldset([
          field(
            name="相電圧",
            unit="V",
            key=PhaseVoltage,
            value=model.fields.phase_voltage,
            emit~,
          ),
          field(
            name="周波数",
            unit="Hz",
            key=Frequency,
            value=model.fields.frequency,
            emit~,
          ),
          field(
            name="極数",
            unit="",
            key=Poles,
            value=model.fields.poles,
            emit~,
          ),
          field(
            name="相数",
            unit="",
            key=Phases,
            value=model.fields.phases,
            emit~,
          ),
        ]),
        fieldset_view(title="等価回路", children=[
          field(
            name="一次抵抗",
            unit="Ω",
            key=R1,
            value=model.fields.r1,
            emit~,
            symbol="r1",
          ),
          field(
            name="一次漏れリアクタンス",
            unit="Ω",
            key=X1,
            value=model.fields.x1,
            emit~,
            symbol="x1",
          ),
          field(
            name="二次抵抗",
            unit="Ω",
            key=R2,
            value=model.fields.r2,
            emit~,
            symbol="r2",
          ),
          field(
            name="二次漏れリアクタンス",
            unit="Ω",
            key=X2,
            value=model.fields.x2,
            emit~,
            symbol="x2",
          ),
          field(
            name="励磁リアクタンス",
            unit="Ω",
            key=Xm,
            value=model.fields.xm,
            emit~,
            symbol="xm",
          ),
          field(
            name="鉄損抵抗",
            unit="Ω",
            key=CoreLossResistance,
            value=model.fields.core_loss_resistance,
            emit~,
            symbol="rc",
          ),
        ]),
        fieldset_view(title="動作点", children=[
          field(
            name="出力電力",
            unit="W",
            key=OutputPower,
            value=model.fields.output_power,
            emit~,
          ),
        ]),
        advanced_section(model~, emit~),
      ]),
    ]),
    characteristics_panel(model~),
  ])
}

///|
fn settings_bar_view(
  model~ : Model,
  emit~ : @rabbita.Emit[Msg],
) -> @rabbita.Html {
  @html.div(class="settings-bar", [
    if model.confirm_reset {
      @html.span(class="confirm-text", "リセットしますか？")
    } else {
      @html.span(class="settings-title", "パラメーター")
    },
    if model.confirm_reset {
      @html.div(class="confirm-actions", [
        @html.button(
          class="btn-secondary",
          type_="button",
          on_click=emit(CancelReset),
          "キャンセル",
        ),
        @html.button(
          class="btn-danger",
          type_="button",
          on_click=emit(Reset),
          "リセット",
        ),
      ])
    } else {
      @html.button(
        class="btn-secondary",
        type_="button",
        on_click=emit(RequestReset),
        "リセット",
      )
    },
  ])
}

///|
fn error_view(model~ : Model) -> @rabbita.Html {
  match model.error {
    Some(message) =>
      @html.div(
        class="validation",
        attrs=@html.Attrs::build().role("alert").aria_live("polite"),
        [@html.span(message)],
      )
    None => @html.nothing
  }
}

///|
fn fieldset_view(
  title~ : String,
  children~ : Array[@rabbita.Html],
) -> @rabbita.Html {
  @html.fieldset([@html.legend(title)] + children)
}

///|
fn advanced_section(
  model~ : Model,
  emit~ : @rabbita.Emit[Msg],
) -> @rabbita.Html {
  let label = if model.show_advanced {
    "▾  描画設定"
  } else {
    "▸  描画設定"
  }
  @html.div(class="advanced-wrap", [
    @html.button(
      class="advanced-toggle",
      type_="button",
      on_click=emit(ToggleAdvanced),
      label,
    ),
    if model.show_advanced {
      @html.div(class="advanced-fields", [
        field(name="幅", unit="px", key=Width, value=model.fields.width, emit~),
        field(
          name="高さ",
          unit="px",
          key=Height,
          value=model.fields.height,
          emit~,
        ),
      ])
    } else {
      @html.nothing
    },
  ])
}

///|
fn characteristics_panel(model~ : Model) -> @rabbita.Html {
  @html.aside(class="readout", [
    @html.div(class="readout-bar", "特性"),
    match model.characteristics {
      None =>
        @html.div(
          class="readout-empty",
          "出力電力を\n入力してください",
        )
      Some(c) =>
        @html.div(
          class="readout-rows",
          characteristic_rows(c, lengths=model.line_lengths),
        )
    },
  ])
}

///|
fn characteristic_rows(
  c : @ensenzu.CircleDiagramCharacteristics,
  lengths~ : @ensenzu.CharacteristicLineLengths?,
) -> Array[@rabbita.Html] {
  let base = [
    readout_row(label="滑り", value=fmt_pct(c.slip), unit="%"),
    readout_row(
      label="入力電流",
      value=fmt_num(c.input_current, 3),
      unit="A",
    ),
    readout_row(
      label="有効分電流",
      value=fmt_num(c.active_current_component, 3),
      unit="A",
    ),
    readout_row(label="力率", value=fmt_pct(c.power_factor), unit="%"),
    readout_row(label="入力電力", value=fmt_num(c.input_power, 1), unit="W"),
    readout_row(
      label="空隙電力",
      value=fmt_num(c.air_gap_power, 1),
      unit="W",
    ),
    readout_row(
      label="出力電力",
      value=fmt_num(c.output_power, 1),
      unit="W",
    ),
    readout_row(label="トルク", value=fmt_num(c.torque, 3), unit="N·m"),
    readout_row(label="効率", value=fmt_pct(c.efficiency), unit="%"),
  ]
  let extra = match lengths {
    None => []
    Some(lengths) => line_length_rows(lengths)
  }
  base + extra
}

///|
fn line_length_rows(
  lengths : @ensenzu.CharacteristicLineLengths,
) -> Array[@rabbita.Html] {
  [
    @html.div(class="readout-section-title", "線の長さ"),
    readout_row(label="OP", value=fmt_num(lengths.o_p, 3), unit="A"),
    readout_row(label="OM", value=fmt_num(lengths.o_m, 3), unit="A"),
    readout_row(label="PM", value=fmt_num(lengths.p_m, 3), unit="A"),
    readout_row(label="PA", value=fmt_num(lengths.p_a, 3), unit="A"),
    readout_row(label="PB", value=fmt_num(lengths.p_b, 3), unit="A"),
    readout_row(label="AB", value=fmt_num(lengths.a_b, 3), unit="A"),
    readout_row(label="FY", value=fmt_num(lengths.f_y, 3), unit="A"),
    readout_row(label="FS", value=fmt_num(lengths.f_s, 3), unit="A"),
    readout_row(label="GR", value=fmt_num(lengths.g_r, 3), unit="A"),
    readout_row(label="GS", value=fmt_num(lengths.g_s, 3), unit="A"),
  ]
}

///|
fn readout_row(
  label~ : String,
  value~ : String,
  unit~ : String,
) -> @rabbita.Html {
  @html.fragment([
    @html.span(class="readout-label", label),
    @html.span(class="readout-value", value),
    @html.span(class="readout-unit", unit),
  ])
}

///|
fn fmt_pct(v : Double) -> String {
  fmt_num(v * 100.0, 2)
}

///|
fn fmt_num(v : Double, decimals : Int) -> String {
  let scale = for i = 0, s = 1.0; i < decimals; {
    continue i + 1, s * 10.0
  } nobreak {
    s
  }
  ((v * scale).round() / scale).to_string()
}

///|
fn field(
  name~ : String,
  unit~ : String,
  key~ : FieldKey,
  value~ : String,
  emit~ : @rabbita.Emit[Msg],
  symbol? : String = "",
) -> @rabbita.Html {
  @html.label(class="input-row", [
    @html.span(class="input-label", [
      @html.span(class="input-name", name),
      if symbol == "" {
        @html.nothing
      } else {
        @html.span(class="input-symbol", symbol)
      },
    ]),
    @html.span(class="input-control", [
      @html.input(input_type=Number, value~, inputmode="decimal", on_input=text => {
        emit(Change(key, text))
      }),
      @html.span(class="input-unit", unit),
    ]),
  ])
}
