Devise.setup do |config|
  config.authentication_keys = [ :email ]

  config.mailer_sender = 'members@unshamed.com'
  
  config.secret_key = '805d9889ce9d3817d5204dbdfe427ac596fe9e9f304b36ac8f576e9703fa382d8d515a2d708bd5d0823a5e9291bf17bfffe9479d2fafc2bd4e5d2d1b1cc07152'
end