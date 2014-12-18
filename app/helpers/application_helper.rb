module ApplicationHelper
  def present(object, klass = nil)
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end
end
