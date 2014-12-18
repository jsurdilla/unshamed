class LandingController < ApplicationController

  def resend_confirmation
    user = User.where(email: params[:email]).first
    if !user.confirmed?
      user.send_confirmation_instructions
      head :ok
    else
      head :unprocessable_entity
    end
  end

end
