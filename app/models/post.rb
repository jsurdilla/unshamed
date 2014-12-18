class Post < ActiveRecord::Base

  acts_as_commentable

  belongs_to :author, class_name: 'User'
  has_many :supports

end
