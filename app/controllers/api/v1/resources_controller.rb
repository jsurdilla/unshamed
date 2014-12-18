class Api::V1::ResourcesController < ApplicationController

  before_action :authenticate_user!

  def index
    @resources = Resource.order('created_at DESC').first(10)
    render json: { resources: @resources }
  end
end
