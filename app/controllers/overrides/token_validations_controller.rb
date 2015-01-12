module Overrides
  class TokenValidationsController < DeviseTokenAuth::TokenValidationsController
    include DeviseTokenAuth::Concerns::SetUserByToken

    def validate_token
      if current_user
        render json: { data: JSON.parse(user_json(current_user)) }
      else
        render json: {
          success: false,
          errors: ["Invalid login credentials"]
        }, status: 401
      end
    end

    private

    def user_json(user)
      Jbuilder.new do |json|
        json.(user,
          :id,
          :first_name,
          :last_name,
          :full_name,
          :provider,
          :uid,
          :gender,
          :about_me,
          :onboarded
        )

        json.profile_pictures do
          json.square50 user.profile_picture(:square50)
          json.medium user.profile_picture(:medium)
        end
      end.target!
    end

  end
end
