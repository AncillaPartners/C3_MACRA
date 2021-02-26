class AttestationRequirementSetDetail < ApplicationRecord
  belongs_to :event

  def self.AttestationRequirementSetDetails_By_Department_EventID_AttestationClinicID(selected_department, event_id, attestation_clinic_id)
    if selected_department.group.group_type_id == 2
      join_text = " as x1 inner join x_group_attestation_requirement_set_details as x2 on x1.id = x2.attestation_requirement_set_detail_id"
      conditions = ' x2.group_id = '+selected_department.group_id.to_s
    else
      join_text = " as x1 inner join x_department_attestation_requirement_set_details as x2 on x1.id = x2.attestation_requirement_set_detail_id"
      conditions = ' x2.department_id = '+selected_department.id.to_s
    end
    join_text += " inner join events as x3 on x3.id = x1.event_id"

    conditions += ' and x3.id = '+event_id.to_s

    if attestation_clinic_id.to_i > 0
      conditions += ' and x2.attestation_clinic_id = '+attestation_clinic_id.to_s
    end

    where(conditions)
        .joins(join_text)
        .group("x1.id")
        .select("x1.*")
        .first
  end
end
