class Navigation
  attr_reader :static, :dynamic, :draft
  attr_accessor :current_path

  def initialize(options={})
    options = {
      static: [],
      dynamic: [],
      current_path: nil
    }.merge(options)

    @static = options[:static]
    @dynamic = options[:dynamic]
    @draft = []

    @current_path = options[:current_path]
  end

  def add_item(category, item)
    case category
    when :static
      @static << item
    when :dynamic
      @dynamic << item
    else
      @draft << item
    end
  end

  [:dynamic, :static, :draft].each do |category|
    define_method("#{category.to_s}_items") do
      self.send(category).reject{ |item| item.url == @current_path}
    end
  end
end
