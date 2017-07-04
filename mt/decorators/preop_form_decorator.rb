class PreopFormDecorator < Draper::Decorator
  delegate_all

  def string_field(name, label_text, disabled)
    [
      h.label_tag(field_name(name), label_text, class: 'preop-form__label'),
      h.text_field_tag(field_name(name), data_value(name), class: 'preop-form__input' + error_class(name), disabled: disabled)
    ].join.html_safe
  end

  def text_field(name, placeholder, disabled)
    h.text_area_tag(
      field_name(name), data_value(name),
      class: 'preop-form__textarea preop-form__textarea--hidden' + error_class(name),
      placeholder: placeholder, disabled: disabled
    )
  end

  def checkbox_field(name, label, disabled)
    [
      h.check_box_tag(field_name(name), 'yes', data_value(name), class: 'preop-form__checkbox' + error_class(name), disabled: disabled),
      label
    ].join.html_safe
  end

  def radio_field(name, value, disabled)
    h.radio_button_tag(field_name(name), value, data_value(name) == value.to_s, class: error_class(name), disabled: disabled)
  end

  def select_field(name, disabled, options = nil)
    h.select_tag(
      field_name(name), select_options(name, data_value(name), options),
      class: "preop-form__select#{options ? ' preop-form__select--short' : ''}" + error_class(name),
      include_blank: !options, disabled: disabled
    )
  end

  private

  def data_value(name)
    object.data[name]
  end

  def select_options(name, selected, options = nil)
    options ||= options(name)
    h.options_for_select(options, selected)
  end

  def options(name)
    PreopForm::SELECTS[name.to_sym].each_with_index.map do |data, index|
      [data.first, index]
    end
  end

  def field_name(name)
    "preop_form[data][#{name}]"
  end

  def error_class(name)
    invalid_fields = object.errors.messages[:data] || []
    invalid_fields.include?(name.to_s) ? ' invalid' : ''
  end
end
