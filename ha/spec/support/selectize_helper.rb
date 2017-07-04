module SelectizeHelpers
  def selectize_click(id)
    selectize_within(id) do
      first('div.selectize-input').click
    end
  end

  def select_option(id, text, input_type)
    selectize_within(id, input_type) do
      first('div.selectize-input').click
      find('div.option', text: text).click
    end
  end

  def select_option_exists?(id, text, input_type)
    selectize_within(id, input_type) do
      first('div.selectize-input').click
      find('div.option', text: text).click.present? rescue false
    end
  end

  def set_text(id, text, input_type)
    selectize_within(id, input_type) do
      first('div.selectize-input input').set(text)
    end
  end

  def selectize_within(id, input_type)
    within(:xpath, "//#{input_type}[@id='#{id}']/..") do
      yield if block_given?
    end
  end
end
