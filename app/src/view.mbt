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
        advanced_section(model~, emit~),
      ]),
    ]),
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
