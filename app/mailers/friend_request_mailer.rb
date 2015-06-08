class FriendRequestMailer < ActionMailer::Base
  default from: 'members@unshamed.com'

  def new_friend_request(user, requester)
    @user = user
    @requester = requester

    mail(to: @user.email, subject: 'New Friend Request')
  end

end
