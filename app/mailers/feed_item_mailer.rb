class FeedItemMailer < ActionMailer::Base
  default from: 'members@unshamed.com'

  def new_comment(user, item)
    @user = user
    @item = item

    mail(to: @user.email, subject: 'New Friend Request')
  end

end
