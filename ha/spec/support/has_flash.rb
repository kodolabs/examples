module Capybara
  class Session
    def has_flash?(message)
      has_xpath?("//div[@class='flash-message'][@data-message='#{message}']")
    end

    def has_flash_like?(message)
      has_xpath?("//div[@class='flash-message'][contains(@data-message, '#{message}')]")
    end

    def has_no_flash?(message)
      !has_flash?(message)
    end
  end
end
