class AttestationMethodType < ApplicationRecord
  has_many :attestation_methods

  def self.individual_id
    1
  end
  def self.group_id
    2
  end
  def self.aco_id
    3
  end
  def self.clinic_rollup_ids
    [group_id, aco_id]
  end
  def self.group_rollup_ids
    [aco_id]
  end

  def has_clinic_rollup?
    AttestationMethodType.clinic_rollup_ids.include? id
  end
  def has_group_rollup?
    AttestationMethodType.group_rollup_ids.include? id
  end
end
