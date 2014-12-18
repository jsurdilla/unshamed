class Api::V1::SupportsController < ApplicationController

  before_action :authenticate_user!
  before_action :find_support, only: [:toggle, :create, :destroy]

  def toggle
    if @support.persisted?
      destroy()
    else
      create()
    end
  end

  def create
    if @support.persisted?
      render json: { result: 'existing' }, status: :ok
    else
      if @support.save
        render json: { result: 'created' }, status: :created
      else
        head :unprocessable_entity
      end
    end
  end

  def destroy
    if @support.persisted?
      if @support.destroy
        render json: { result: 'deleted' }, status: :ok
      else
        head :unprocessable_entity
      end
    else
      head :not_found
    end
  end

  private

  def support_params
    params[:user_id] = current_user.id
    params.require(:support).permit(
      :supportable_type,
      :supportable_id,
      :user_id
    )
  end

  def find_support
    @support = Support.where(support_params).first_or_initialize
  end

end
