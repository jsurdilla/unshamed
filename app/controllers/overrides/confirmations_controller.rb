module Overrides
  class ConfirmationsController < DeviseTokenAuth::ConfirmationsController
    include DeviseTokenAuth::Concerns::SetUserByToken

    def show
      @resource = resource_class.confirm_by_token(params[:confirmation_token])

      if @resource and @resource.id
        # create client id
        client_id  = SecureRandom.urlsafe_base64(nil, false)
        token      = SecureRandom.urlsafe_base64(nil, false)
        token_hash = BCrypt::Password.create(token)
        expiry     = (Time.now + DeviseTokenAuth.token_lifespan).to_i

        @resource.tokens[client_id] = {
          token:  token_hash,
          expiry: expiry
        }

        @resource.save!

        redirect_to_url = "http://#{request.host_with_port}/#/onboarding?confirmed=true"
        redirect_to(@resource.build_auth_url(redirect_to_url, {
          token:                        token,
          client_id:                    client_id,
          account_confirmation_success: true,
          config:                       params[:config]
        }))
      else
        if resource_class.where(confirmation_token: params[:confirmation_token]).exists?
          redirect_to("http://#{request.host_with_port}/#/onboarding") and return
        end
        raise ActionController::RoutingError.new('Not Found')
      end
    end

  end
end
