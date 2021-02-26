class SubmissionMethod < ApplicationRecord

  def self.administrative_claims_id
    1
  end
  def self.claims_id
    2
  end
  def self.csv_id
    3
  end
  def self.cms_web_interface_id
    4
  end
  def self.ehr_id
    5
  end
  def self.registry_id
    6
  end
end
