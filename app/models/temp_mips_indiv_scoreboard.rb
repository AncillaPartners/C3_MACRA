class TempMipsIndivScoreboard < ApplicationRecord
  belongs_to  :department
  belongs_to  :event

  validates_presence_of :department_id, :event_id
end
