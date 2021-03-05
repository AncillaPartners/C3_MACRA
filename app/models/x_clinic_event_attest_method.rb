class XClinicEventAttestMethod < ApplicationRecord
  belongs_to :attestation_clinic
  belongs_to :event
  belongs_to :attestation_method
  belongs_to :submission_method, optional: true
  belongs_to :override_submission_method, class_name: 'SubmissionMethod', optional: true

  has_many  :x_clinic_event_attest_group_requirements
end
