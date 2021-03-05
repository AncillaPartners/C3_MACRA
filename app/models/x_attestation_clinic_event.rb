class XAttestationClinicEvent < ApplicationRecord
  belongs_to :event
  belongs_to :default_attestation_method, :class_name => 'AttestationMethod', optional: true
  belongs_to :submission_status, optional: true
  has_many  :attestation_clinic_submit_permission_files
  has_many  :attestation_clinic_cpia_documentation_files

  def get_submission_status
    response = Response.where(attestation_clinic_id: self.attestation_clinic_id,
                              attestation_requirement_fiscal_year_id: self.event.attestation_requirement_fiscal_year)
                       .first
    status =  if response.nil?
                'Not Submitted'
              elsif response.response_errors.count > 0
                'Submitted with Errors'
              elsif response.content.nil? && response.response_errors.count == 0
                'Submitted No Response'
              else
                'Submitted Successfully'
              end
  end
end
