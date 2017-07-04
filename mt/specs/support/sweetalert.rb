module SweetAlert
  def click_with_confirmation(selector, confirm = true)
    find(selector).click
    sleep 0.6
    if confirm
      find('.sweet-alert .confirm').click
    else
      find('.sweet-alert .cancel').click
    end
  end
end
