class XUserMessage < ApplicationRecord
  belongs_to :user
  belongs_to :message

  def self.messages_by_user_id(user_id)
    where(['user_id = ? and messages.status = ? and messages.active = ?', user_id, 1, 1])
        .order('read_flag, messages.updated_at desc')
        .joins([:user, :message])
        .select('*, messages.name')
  end
end
