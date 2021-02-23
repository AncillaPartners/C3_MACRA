class SubmissionStatus < ApplicationRecord

  def self.submission_status_for_select
    where('active = 1 and status = 1').map{|ss| [ss.name, ss.id]}
  end
end
