class ActionItem < ApplicationRecord

  def self.any_incomplete_by_group_id?(group_id)
    action_items = self.where(['active = 1 and group_id = ? and action_item_status_id != 4', group_id])
    action_items.size > 0
  end
end
