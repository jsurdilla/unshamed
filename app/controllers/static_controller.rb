class StaticController < ApplicationController

  def index
    render file: 'public/web/index.html'
  end

end
