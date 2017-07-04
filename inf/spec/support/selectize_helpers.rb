module SelectizeHelpers
  def selectize_click(id)
    selectize_within(id) do
      first('div.selectize-input').click
    end
  end

  def select_option(id, text)
    selectize_within(id) do
      first('div.selectize-input').click
      find('div.option', text: text).click
    end
  end

  def set_text(id, text)
    selectize_within(id) do
      first('div.selectize-input input').set(text)
    end
  end

  def selectize_within(id)
    within(:xpath, "//*[@id='#{id}']/..") do
      yield if block_given?
    end
  end
end
