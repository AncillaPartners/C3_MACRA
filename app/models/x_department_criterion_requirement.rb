class XDepartmentCriterionRequirement < ApplicationRecord

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
end
