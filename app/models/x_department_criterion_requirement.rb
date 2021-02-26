class XDepartmentCriterionRequirement < ApplicationRecord
  belongs_to :x_group_requirement

  def self.xdcs_id_with_most_points_by_clinic_id_and_attestation_method_id_and_event_id(clinic_id, attestation_method_id, event_id)
    xdcs_with_highest_cpia_points = xdcs_and_point_value_with_most_points_by_clinic_id_and_attestation_method_id_and_event_id(clinic_id, attestation_method_id, event_id)

    (xdcs_with_highest_cpia_points.nil? ? nil : xdcs_with_highest_cpia_points.xdcs_id.to_i)
  end

  def self.xdcs_and_point_value_with_most_points_by_clinic_id_and_attestation_method_id_and_event_id(clinic_id, attestation_method_id, event_id)
    conditions = {}
    join_text = 'as xdcr'
    join_text += ' inner join x_group_requirements xgr on xgr.id = xdcr.x_group_requirement_id'
    join_text += ' inner join requirements r on r.id = xgr.requirement_id'
    join_text += ' inner join x_department_criterion_statuses xdcs on xdcs.id = xdcr.x_department_criterion_status_id'
    join_text += ' inner join departments d on d.id = xdcs.department_id'
    join_text += ' inner join x_department_attestation_requirement_set_details xdarsd on xdarsd.department_id = d.id and xdarsd.attestation_clinic_id = xdcs.attestation_clinic_id'
    join_text += ' inner join attestation_requirement_set_details arsd on arsd.id = xdarsd.attestation_requirement_set_detail_id'
    # join_text += ' inner join x_year_attestation_methods xyam on xyam.id = arsd.x_year_attestation_method_id'

    status = 1
    active = 1

    selectstr = 'xdcr.status = :xdcr_status'
    conditions[:xdcr_status] = status

    andstr = ' and '

    selectstr += andstr + 'xdcr.active = :xdcr_active'
    conditions[:xdcr_active] = active

    selectstr += andstr + 'd.active = :d_active'
    conditions[:d_active] = active

    selectstr += andstr + 'xgr.status = :xgr_status'
    conditions[:xgr_status] = status

    selectstr += andstr + 'xgr.active = :xgr_active'
    conditions[:xgr_active] = active

    selectstr += andstr + 'r.status = :r_status'
    conditions[:r_status] = status

    selectstr += andstr + 'r.active= :r_active'
    conditions[:r_active] = active

    selectstr += andstr + 'xdcs.event_id = :xdcs_event_id'
    conditions[:xdcs_event_id] = event_id

    selectstr += andstr + 'r.event_id = :r_event_id'
    conditions[:r_event_id] = event_id

    selectstr += andstr + 'arsd.event_id = :arsd_event_id'
    conditions[:arsd_event_id] = event_id

    selectstr += andstr + 'xdcs.attestation_requirement_set_detail_id is null'

    selectstr += andstr + 'r.criterion_id = :r_criterion_id'
    conditions[:r_criterion_id] = 5

    selectstr += andstr + 'xdcr.cpia_select_flag = :xdcr_cpia_select_flag'
    conditions[:xdcr_cpia_select_flag] = 1

    selectstr += andstr + 'xdcs.attestation_clinic_id = :xdcs_attestation_clinic_id'
    conditions[:xdcs_attestation_clinic_id] = clinic_id

    # selectstr += andstr + 'xyam.attestation_method_id = :xyam_attestation_method_id'
    # conditions[:xyam_attestation_method_id] = attestation_method_id

    where([selectstr, conditions])
        .order('cpia_points desc')
        .joins(join_text)
        .group('xdcs.id')
        .select('xdcs.id xdcs_id, sum(r.score) cpia_points')
        .first
  end

  def self.group_requirements_for_cpia_submission_json_by_department_id_and_event_id_and_attestation_clinic_id(department_id, event_id, attestation_clinic_id)
    join_text = "as xdcr inner join x_group_requirements as xgr on xdcr.x_group_requirement_id = xgr.id inner join x_department_criterion_statuses as xdcs on xdcs.id = xdcr.x_department_criterion_status_id"
    join_text += " inner join x_department_attestation_requirement_set_details as x2 on x2.department_id = xdcs.department_id"
    join_text += " inner join attestation_requirement_set_details as arsd on x2.attestation_requirement_set_detail_id = arsd.id"
    join_text += " inner join requirements as r on r.id = xgr.requirement_id"

    conditions = 'xdcr.status = 1'
    conditions += ' and xdcr.active = 1'
    conditions += ' and r.status = 1'
    conditions += ' and r.active = true'
    conditions += ' and xgr.status = 1'
    conditions += ' and xgr.active = true'
    conditions += ' and xdcs.department_id = "'+department_id.to_s+'"'
    conditions += ' and xdcs.event_id = '+event_id.to_s
    conditions += ' and xdcs.attestation_clinic_id = "'+attestation_clinic_id.to_s+'"'
    conditions += ' and xdcs.event_id = arsd.event_id'
    conditions += ' and xdcs.attestation_requirement_set_detail_id is null'

    conditions += ' and xdcs.criterion_id = 5'
    conditions += ' and xdcr.cpia_select_flag = 1'

    where(conditions)
        .joins(join_text)
        .group("xdcr.id")
        .select("xdcr.*")
  end

  def self.group_requirements_for_cqm_submission_json_by_department_id_and_event_id_and_attestation_clinic_id(department_id, event_id, attestation_clinic_id)
    join_text = "as xdcr inner join x_group_requirements as xgr on xdcr.x_group_requirement_id = xgr.id inner join x_department_criterion_statuses as xdcs on xdcs.id = xdcr.x_department_criterion_status_id"
    join_text += " inner join x_department_attestation_requirement_set_details as x2 on x2.department_id = xdcs.department_id"
    join_text += " inner join attestation_requirement_set_details as arsd on x2.attestation_requirement_set_detail_id = arsd.id"
    join_text += " inner join requirements as r on r.id = xgr.requirement_id"

    conditions = 'xdcr.status = 1'
    conditions += ' and xdcr.active = 1'
    conditions += ' and r.status = 1'
    conditions += ' and r.active = true'
    conditions += ' and xgr.status = 1'
    conditions += ' and xgr.active = true'
    conditions += ' and xdcs.department_id = "'+department_id.to_s+'"'
    conditions += ' and xdcs.event_id = '+event_id.to_s
    conditions += ' and xdcs.attestation_clinic_id = "'+attestation_clinic_id.to_s+'"'
    conditions += ' and xdcs.event_id = arsd.event_id'
    conditions += ' and xdcs.attestation_requirement_set_detail_id is null'

    conditions += ' and xdcs.criterion_id = 4'
    conditions += ' and xdcr.cqm_select_flag = 1'
    conditions += ' and r.parent_requirement_id is null'

    conditions += ' and xdcr.current_measure_start_date IS NOT NULL'
    conditions += ' and xdcr.current_measure_end_date IS NOT NULL'
    conditions += ' and xdcr.current_measure_start_date = arsd.quality_submission_start_date'
    conditions += ' and xdcr.current_measure_end_date = arsd.quality_submission_end_date'

    where(conditions)
        .joins(join_text)
        .group("xdcr.id")
        .select("xdcr.*")
  end

  def self.group_requirements_for_aci_submission_json_by_department_id_and_event_id_and_attestation_clinic_id(department_id, event_id, attestation_clinic_id)
    join_text = "as xdcr inner join x_group_requirements as xgr on xdcr.x_group_requirement_id = xgr.id inner join x_department_criterion_statuses as xdcs on xdcs.id = xdcr.x_department_criterion_status_id"
    join_text += " inner join x_department_attestation_requirement_set_details as x2 on x2.department_id = xdcs.department_id"
    join_text += " inner join attestation_requirement_set_details as arsd on x2.attestation_requirement_set_detail_id = arsd.id"
    join_text += " inner join requirements as r on r.id = xgr.requirement_id"

    conditions = 'xdcr.status = 1'
    conditions += ' and xdcr.active = 1'
    conditions += ' and r.status = 1'
    conditions += ' and r.active = true'
    conditions += ' and r.aci_scoring_type_id IS NOT NULL'
    conditions += ' and xgr.status = 1'
    conditions += ' and xgr.active = true'
    conditions += ' and xdcs.department_id = "'+department_id.to_s+'"'
    conditions += ' and xdcs.event_id = '+event_id.to_s
    conditions += ' and xdcs.attestation_clinic_id = "'+attestation_clinic_id.to_s+'"'
    conditions += ' and xdcs.event_id = arsd.event_id'
    conditions += ' and xdcs.attestation_requirement_set_detail_id is null'

    conditions += ' and ('
    # when 1 # Base
    conditions += 'r.required_for_base_score_flag = 1'
    # when 2 # Performance
    conditions += ' or r.aci_scoring_type_id in (2, 3, 4, 5, 6)'
    # when 3 # Bonus
    conditions += ' or r.aci_performance_bonus_points > 0'

    conditions += ')'

    where(conditions)
        .joins(join_text)
        .group("xdcr.id")
        .select("xdcr.*")
  end

  def self.Department_Requirement_By_Group_DepartmentID_AttestationClinicID_EventID_RequirementIdentifier(selected_group, department_id, attestation_clinic_id, event_id, requirement_identifier)
    conditions = {}
    join_text = 'as xdcr inner join x_department_criterion_statuses xdcs on xdcs.id = xdcr.x_department_criterion_status_id'
    join_text += ' inner join departments d on d.id = xdcs.department_id'
    join_text += ' inner join attestation_clinics ac on ac.id = xdcs.attestation_clinic_id'
    join_text += ' inner join x_group_requirements xgr on xgr.id = xdcr.x_group_requirement_id'
    join_text += ' inner join requirements r on r.id = xgr.requirement_id'

    selectstr = 'xdcs.department_id = :xdcs_department_id'
    conditions[:xdcs_department_id] = department_id

    selectstr += ' and xdcs.attestation_clinic_id = :xdcs_attestation_clinic_id'
    conditions[:xdcs_attestation_clinic_id] = attestation_clinic_id

    selectstr += ' and xdcs.event_id = :xdcs_event_id'
    conditions[:xdcs_event_id] = event_id

    selectstr += ' and d.group_id = :d_group_id'
    conditions[:d_group_id] = selected_group.id

    selectstr += ' and ac.group_id = :ac_group_id'
    conditions[:ac_group_id] = selected_group.id

    selectstr += ' and r.requirement_identifier = :r_requirement_identifier'
    conditions[:r_requirement_identifier] = requirement_identifier

    where([selectstr,conditions])
        .joins(join_text)
        .group('xdcr.id')
        .select('xdcr.*')
        .first
  end
end
