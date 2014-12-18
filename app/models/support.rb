class Support < ActiveRecord::Base

  belongs_to :user
  belongs_to :supportable, polymorphic: true

  scope :of_type, ->(supportable_type) { where(supportable_type: supportable_type) }
  scope :with_id, ->(supportable_id) { where(supportable_id: supportable_id) }
  scope :by_id, ->(user_id) { where(user_id: user_id) }

  scope :for, ->(supportable) { where(supportable_type: supportable.class.name, supportable_id: supportable.id) }

end
