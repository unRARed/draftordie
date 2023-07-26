class NavigationItem
  attr_reader :text, :url, :options

  def initialize(text, url, options = {})
    options = { is_button: false }.merge(options)

    @text = text
    @url = url
    @is_button = options[:is_button]
    @options = options.except(:is_button)
  end

  def is_active?
    false
  end
end
