Devise.setup do |config|
  config.authentication_keys = [ :email ]

  config.mailer_sender = 'ben@unshamed.com'
end
