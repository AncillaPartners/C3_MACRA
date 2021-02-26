class Department < ApplicationRecord
  belongs_to :group

  def self.Group_Departments_Without_AttestationClinic_By_GroupID_And_PecosClinic_And_DepartmentTaskStatus(selected_group_id, selected_pecos_clinic_id, selected_department_task_status_id, recent_medicare_billing_year_id)
    conditions = {}
    join_text = "as d left outer join x_attestation_clinic_departments xacd on xacd.department_id = d.id"
    join_text += " left outer join cms_ep_actual_billing_details as cms_abd on cms_abd.NPI = d.npi and cms_abd.attestation_requirement_fiscal_year_id = "+recent_medicare_billing_year_id.to_s
    selectstr = ""
    active = 1
    andstr = ""
    sort_order = "d.name"

    selectstr += andstr + "d.active = :d_active"
    conditions[:d_active] = active
    andstr = " and "

    selectstr += andstr + "d.group_id = :d_group_id"
    conditions[:d_group_id] = selected_group_id.to_i
    andstr = " and "

    selectstr += andstr + "d.left_group_in_fiscal_year_id is null"

    selectstr += andstr + "xacd.attestation_clinic_id is null"

    if selected_pecos_clinic_id.to_i > 0
      join_text += " left outer join x_pecos_clinic_departments xpcd on xpcd.department_id = d.id"
      selectstr += andstr + "xpcd.pecos_clinic_id = :xpcd_pecos_clinic_id"
      conditions[:xpcd_pecos_clinic_id] = selected_pecos_clinic_id
    end

    if selected_department_task_status_id.to_i > 0
      selectstr += andstr + "d.department_task_status_id = :d_department_task_status_id"
      conditions[:d_department_task_status_id] = selected_department_task_status_id
    end

    selecting = 'd.*, cms_abd.total_medicare_payment_amt'
    self.where([selectstr,conditions])
        .joins(join_text)
        .order(sort_order)
        .group('d.id')
        .select(selecting)
  end

  def self.Group_Departments_With_Task_Status_By_GroupID_AttestationClinicID_DepartmentTaskStatusID(selected_group_id, attestation_clinic_id, department_task_status_id)
    conditions = {}
    join_text = 'as d'
    join_text += ' left outer join x_attestation_clinic_departments xacd on xacd.department_id = d.id'

    status = 1
    active = 1
    sort_order = 'd.name, d.id'

    # department active
    selectstr = 'd.active = :d_active'
    conditions[:d_active] = active

    # group id
    selectstr += ' and d.group_id = :d_group_id'
    conditions[:d_group_id] = selected_group_id.to_i

    if attestation_clinic_id > 0
      selectstr += ' and xacd.attestation_clinic_id = :xacd_attestation_clinic_id'
      conditions[:xacd_attestation_clinic_id] = attestation_clinic_id
    elsif attestation_clinic_id == 0
      selectstr += ' and xacd.attestation_clinic_id is null'
    end

    # department task status
    if department_task_status_id.to_i > 0
      selectstr += ' and d.department_task_status_id = :d_department_task_status_id'
      conditions[:d_department_task_status_id] = department_task_status_id.to_i
    else
      selectstr += ' and d.department_task_status_id is not null'
    end

    selecting = 'd.*'
    self.where([selectstr,conditions])
        .joins(join_text)
        .order(sort_order)
        .group('d.id')
        .select(selecting)
  end

  def self.Group_Departments_By_GroupID_ClinicID_EventID_XYearAttestationMethodID_UserDefinedFields_DepartmentOwnerID(selected_group_id, selected_clinic_id, selected_event_id, selected_x_year_attestation_method_id, multi_user_defined_8_values, selected_billing_info_fiscal_year_id, selected_department_owner_id, selected_low_volume = 1, selected_clinic_rollup = false, selected_group_rollup = false, selected_low_volume_confirmed = -1)
    conditions = {}
    join_text = 'as d inner join x_department_attestation_requirement_set_details xdarsd on xdarsd.department_id = d.id'
    join_text += ' inner join attestation_clinics ac on ac.id = xdarsd.attestation_clinic_id'
    join_text += ' inner join attestation_requirement_set_details arsd on arsd.id = xdarsd.attestation_requirement_set_detail_id'
    join_text += ' inner join events e on e.id = arsd.event_id'
    join_text += ' left outer join x_year_attestation_methods xyam on xyam.id = arsd.x_year_attestation_method_id'
    join_text += ' left outer join attestation_methods am on am.id = xyam.attestation_method_id'
    join_text += ' left outer join temp_mips_indiv_scoreboards mis on mis.department_id = d.id and mis.event_id = e.id and mis.attestation_clinic_id = xdarsd.attestation_clinic_id'
    join_text += " left outer join cms_ep_actual_billing_details abd on abd.NPI = d.npi and abd.attestation_requirement_fiscal_year_id = #{selected_billing_info_fiscal_year_id.to_s}"
    join_text += ' left outer join submission_methods sm on sm.id = arsd.submission_method_id'
    if selected_group_rollup
      join_text += ' left outer join x_group_year_attest_methods xgyam on xgyam.group_id = d.group_id and xgyam.attestation_requirement_fiscal_year_id = e.attestation_requirement_fiscal_year_id and xgyam.attestation_method_id = xyam.attestation_method_id'
      join_text += ' left outer join x_clinic_event_attest_methods xceam on xceam.attestation_clinic_id = xdarsd.attestation_clinic_id and xceam.event_id = arsd.event_id and xceam.attestation_method_id = xyam.attestation_method_id'
    elsif selected_clinic_rollup
      join_text += ' left outer join x_clinic_event_attest_methods xceam on xceam.attestation_clinic_id = xdarsd.attestation_clinic_id and xceam.event_id = arsd.event_id and xceam.attestation_method_id = xyam.attestation_method_id'
    end

    # To get the count of history records a department has in the same year to evenly split 'total_medicare_payment_amt'
    join_text += ' left outer join x_department_attestation_requirement_set_details xdarsd1 on xdarsd1.department_id = d.id'
    join_text += ' inner join attestation_requirement_set_details arsd1 on arsd1.id = xdarsd1.attestation_requirement_set_detail_id'
    join_text += ' inner join events e1 on e1.id = arsd1.event_id and e1.attestation_requirement_fiscal_year_id = e.attestation_requirement_fiscal_year_id'

    status = 1
    active = 1
    andstr = ' and '
    sort_order = 'd.name'

    # department active
    selectstr = 'd.active = :d_active'
    conditions[:d_active] = active

    # group id
    selectstr += andstr + 'd.group_id = :d_group_id'
    conditions[:d_group_id] = selected_group_id.to_i

    # attestation clinic id
    if selected_clinic_id > 0
      selectstr += andstr + 'xdarsd.attestation_clinic_id = :xdarsd_attestation_clinic_id'
      conditions[:xdarsd_attestation_clinic_id] = selected_clinic_id.to_i
    elsif selected_clinic_id == 0
      selectstr += andstr + 'd.attestation_clinic_id is NULL'
    end

    # department owner id
    if selected_department_owner_id != -1
      selectstr += andstr + '(d.department_owner_id = :d_department_owner_id or d.department_owner_alt_id = :d_department_owner_id)'
      conditions[:d_department_owner_id] = selected_department_owner_id
    end

    # event id
    if selected_event_id != -1
      selectstr += andstr + 'e.id = :e_id'
      conditions[:e_id] = selected_event_id
    end

    # x year attestation method id
    selectstr += andstr + 'arsd.x_year_attestation_method_id = :arsd_x_year_attestation_method_id'
    conditions[:arsd_x_year_attestation_method_id] = selected_x_year_attestation_method_id

    selected_user_defined_8_value_id = 0
    selected_user_defined_8_value_null = false
    multi_user_defined_8_values.each do |multi_user_defined_8_value|
      if multi_user_defined_8_value.to_i == -1
        selected_user_defined_8_value_id = -1
      end
      if multi_user_defined_8_value == ''
        selected_user_defined_8_value_null = true
      end
    end

    if selected_user_defined_8_value_id != -1
      selectstr += ' and (ac.user_defined_value_id_8 in (:multi_user_defined_8_values)'
      conditions[:multi_user_defined_8_values] = multi_user_defined_8_values
      if selected_user_defined_8_value_null
        selectstr += ' or ac.user_defined_value_id_8 is null'
      end
      selectstr += ')'
    end

    # exclude low volume
    if selected_low_volume != -1
      selectstr += andstr + 'arsd.low_volume_flag = :arsd_low_volume_flag'
      conditions[:arsd_low_volume_flag] = selected_low_volume
    end

    # low volume confirmed
    if selected_low_volume_confirmed != -1
      selectstr += andstr + 'arsd.low_volume_confirmed_flag = :arsd_low_volume_confirmed_flag'
      conditions[:arsd_low_volume_confirmed_flag] = selected_low_volume_confirmed
    end

    selecting = 'd.*, mis.id as mis_id, mis.physician_compare_status'
    selecting += ', arsd.x_year_attestation_method_id as x_year_attestation_method_id, am.name as attestation_method_name'
    selecting += ', arsd.low_volume_flag'
    selecting += ', arsd.low_volume_confirmed_flag'
    selecting += ', arsd.id as arsd_id'
    selecting += ', sm.name as submission_method_name'
    if selected_group_rollup
      selecting += ', xgyam.advancing_care_info as advancing_care_info'
      selecting += ', xgyam.quality as quality'
      selecting += ', xgyam.resource_use as resource_use'
      selecting += ', xgyam.cpia as cpia'
      selecting += ', xceam.mips_composite_score as mips_composite_score'
      selecting += ', xceam.cms_mips_composite_score as cms_mips_composite_score'
      selecting += ', xceam.manual_composite_score_flag as manual_composite_score_flag'
      selecting += ', xceam.cms_advancing_care_info as cms_advancing_care_info'
      selecting += ', xceam.cms_quality as cms_quality'
      selecting += ', xceam.cms_resource_use as cms_resource_use'
      selecting += ', xceam.cms_cpia as cms_cpia'
    elsif selected_clinic_rollup
      selecting += ', IF(xceam.aci_use_manual_fields_flag, xceam.manual_advancing_care_info, xceam.advancing_care_info) as advancing_care_info'
      selecting += ', IF(xceam.quality_use_manual_fields_flag, xceam.manual_quality, xceam.quality) as quality'
      selecting += ', xceam.resource_use as resource_use'
      selecting += ', xceam.cpia as cpia'
      selecting += ', xceam.mips_composite_score as mips_composite_score'
      selecting += ', xceam.cms_mips_composite_score as cms_mips_composite_score'
      selecting += ', xceam.manual_composite_score_flag as manual_composite_score_flag'
      selecting += ', xceam.cms_advancing_care_info as cms_advancing_care_info'
      selecting += ', xceam.cms_quality as cms_quality'
      selecting += ', xceam.cms_resource_use as cms_resource_use'
      selecting += ', xceam.cms_cpia as cms_cpia'
    else
      selecting += ', mis.advancing_care_info as advancing_care_info'
      selecting += ', mis.quality as quality'
      selecting += ', mis.resource_use as resource_use'
      selecting += ', mis.cpia as cpia'
      selecting += ', mis.mips_composite_score as mips_composite_score'
      selecting += ', mis.cms_mips_composite_score as cms_mips_composite_score'
      selecting += ', mis.manual_composite_score_flag as manual_composite_score_flag'
      selecting += ', mis.cms_advancing_care_info as cms_advancing_care_info'
      selecting += ', mis.cms_quality as cms_quality'
      selecting += ', mis.cms_resource_use as cms_resource_use'
      selecting += ', mis.cms_cpia as cms_cpia'
    end
    selecting += ', (abd.total_medicare_payment_amt / count(*)) as total_medicare_payment_amt'
    selecting += ', xdarsd.attestation_clinic_id as attestation_clinic_id'
    self.where([selectstr,conditions])
        .joins(join_text)
        .order(sort_order)
        .group('arsd.id')
        .select(selecting)
  end
end
