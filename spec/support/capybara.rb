# frozen_string_literal: true

# NOTE: loading JS from webpack in integration tests assumes
#       a predicatable port. ensure this is the same as
#       config.x.url in ./config/environments/test.rb
#
#       we do not use port 3000, since it conflicts with
#       running the development server at the same time
Capybara.server_port = 63000

Capybara.save_path = "tmp/capybara"

# Set wait time to ENV['wait_time'] if set,
# or 3 seconds by default
Capybara.default_max_wait_time =
  if ENV["wait_time"].to_i > 0
    ENV["wait_time"].to_i
  else
    3
  end


# Selenium settings per:
#   https://gist.github.com/nruth/864dc9875b4feb183b7b10ddbd25c7f4
chrome_switches = [
  "--disable-default-apps",
  "--disable-extensions",
  "--disable-infobars",
  "--disable-notifications",
  "--disable-password-generation",
  "--disable-password-manager-reauthentication",
  "--disable-password-separated-signin-flow",
  "--disable-popup-blocking",
  "--disable-save-password-bubble",
  "--disable-translate",
  "--incognito",
  "--mute-audio",
  "--no-default-browser-check",
  "--window-size=1920,1080",
]

chrome_options = Selenium::WebDriver::Chrome::Options.new
chrome_switches.each do |option|
  chrome_options.add_argument(option)
end

chrome_options.add_preference(:download, { prompt_for_download: false })
chrome_options.add_preference(:credentials_enable_service, false)
chrome_options.add_preference(
  :profile,
  {
    password_manager_enabled: false,
    default_content_settings: { popups: 0 },
    content_settings: {
      pattern_pairs: { "*": { "multiple-automatic-downloads": 1 } },
    },
  },
)

Capybara.register_driver(:chrome_headless) do |app|
  # chrome_options.add_argument("--headless")

  # according to https://github.com/SeleniumHQ/selenium/blob/master/rb/lib/selenium/webdriver/remote/http/default.rb
  # Warning: Setting {#open_timeout} to non-nil values will cause a separate thread to spawn.
  # Debuggers that freeze the process will not be able to evaluate any operations if that happens.
  client = Selenium::WebDriver::Remote::Http::Default.
    new(open_timeout: nil, read_timeout: 120)
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    clear_local_storage: true,
    clear_session_storage: true,
    options: chrome_options,
    http_client: client,
  )
end
Capybara.javascript_driver = :chrome_headless

Capybara::Screenshot.register_driver(:chrome_headless) do |driver, path|
  driver.browser.save_screenshot(path)
end
Capybara.default_max_wait_time = 5
if (chrome_bin = ENV.fetch("GOOGLE_CHROME_SHIM", nil))
  Selenium::WebDriver::Chrome.path = chrome_bin
end
