class AttestationClinic < ApplicationRecord

  STATUSES = {:INCLUDE => 1, :EXCLUDE => 0, :NOT_VERIFIED => 2}
  STATUS_NAMES = {1 => 'Include', 0 => 'Exclude', 2 => 'Not Verified'}
  def include?
    status == STATUSES[:INCLUDE]
  end
  def exclude?
    status == STATUSES[:EXCLUDE]
  end
  def not_verified?
    status == STATUSES[:NOT_VERIFIED]
  end

  def status_name
    STATUS_NAMES[status]
  end

  def self.AttestationClinics_By_GroupID_And_DepartmentOwnerID_And_DepartmentCount_for_select_in_form(group_id, department_owner_id)
    join_text = 'as ac inner join x_attestation_clinic_departments as xacd on xacd.attestation_clinic_id = ac.id'
    join_text += ' inner join departments as d on d.id = xacd.department_id'

    sort_order = 'ac.name'

    group_by = 'ac.id'

    conditions = ' ac.group_id = '+group_id.to_s
    conditions += ' and ac.status = '+AttestationClinic::STATUSES[:INCLUDE].to_s
    conditions += ' and d.active = true'
    conditions += ' and d.department_owner_id = '+department_owner_id.to_s
    where(conditions)
        .order(sort_order)
        .joins(join_text)
        .group(group_by)
        .select("ac.name, ac.id").map{|clinic|
      [clinic.name, clinic.id]
    }
  end

  def self.AttestationClinics_By_GroupID_And_DepartmentCount_for_select_in_form(group_id)
    join_text = 'as ac inner join x_attestation_clinic_departments as xacd on xacd.attestation_clinic_id = ac.id'
    join_text += ' inner join departments as d on d.id = xacd.department_id'

    sort_order = 'ac.name'

    group_by = 'ac.id'

    conditions = ' ac.group_id = '+group_id.to_s
    conditions += ' and ac.status = '+AttestationClinic::STATUSES[:INCLUDE].to_s
    conditions += ' and d.active = true'
    where(conditions)
        .order(sort_order)
        .joins(join_text)
        .group(group_by)
        .select("ac.name, ac.id").map{|clinic|
      [clinic.name, clinic.id]
    }
  end
  def self.group_user_defined_value_multiselect_by_group_id(group_id, user_defined_label_number)
    conditions = {}
    if user_defined_label_number == 8
      join_text = 'ac inner join group_user_defined_values as gudv on ac.user_defined_value_id_8 = gudv.id'
    end

    sort_order = 'gudv.user_defined_value'

    selectstr = 'ac.status = :ac_status'
    conditions[:ac_status] = STATUSES[:INCLUDE]

    selectstr += ' and ac.group_id = :ac_group_id'
    conditions[:ac_group_id] = group_id

    selectstr += ' and gudv.user_defined_label_number = :gudv_user_defined_label_number'
    conditions[:gudv_user_defined_label_number] = user_defined_label_number

    where([selectstr,conditions])
        .joins(join_text)
        .order(sort_order)
        .group('gudv.id')
        .select('gudv.user_defined_value, gudv.id').map{|user_defined_values|
      [user_defined_values.user_defined_value, user_defined_values.id.to_s]}

  end
  def self.AttestationClinics_For_TIN_Summary_By_GroupID_And_EventID_And_UserDefinedFields(group_id, event_id, multi_user_defined_8_values, meeting_status_id)
    join_text = 'as ac left outer join x_attestation_clinic_departments xacd on xacd.attestation_clinic_id = ac.id'
    join_text += ' left outer join departments d on d.id = xacd.department_id and d.active = 1 and d.left_group_in_fiscal_year_id is null'
    join_text += ' left outer join x_department_attestation_requirement_set_details xdarsd on xdarsd.attestation_clinic_id = ac.id and xdarsd.department_id = d.id'
    join_text += " left outer join attestation_requirement_set_details arsd on arsd.id = xdarsd.attestation_requirement_set_detail_id and arsd.event_id = #{event_id}"
    join_text += ' left outer join x_year_attestation_methods xyam on xyam.id = arsd.x_year_attestation_method_id'
    join_text += ' left outer join attestation_methods am on am.id = xyam.attestation_method_id'
    join_text += ' left outer join temp_mips_indiv_scoreboards mis on mis.department_id = d.id and mis.event_id = arsd.event_id and mis.attestation_clinic_id = ac.id'
    join_text += " left outer join x_attestation_clinic_events xace on xace.attestation_clinic_id = ac.id and xace.event_id = #{event_id}"
    join_text += " left outer join x_clinic_event_attest_methods xceam on xceam.attestation_clinic_id = ac.id and xceam.event_id = #{event_id} and xceam.attestation_method_id = xace.default_attestation_method_id"
    join_text += ' left outer join action_items ai on ai.attestation_clinic_id = ac.id and ai.action_item_status_id != 4'
    sort_order = 'ac.name, ac.id'
    conditions = {}

    selectstr = 'ac.status = :ac_status'
    conditions[:ac_status] = STATUSES[:INCLUDE]

    selectstr += ' and ac.group_id = :ac_group_id'
    conditions[:ac_group_id] = group_id

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

    if meeting_status_id != -1
      if meeting_status_id == 0
        selectstr += ' and xace.meeting_status_id is null'
      else
        selectstr += ' and xace.meeting_status_id = :xace_meeting_status_id'
        conditions[:xace_meeting_status_id] = meeting_status_id
      end
    end

    include_condition = 'xyam.attestation_method_id = xace.default_attestation_method_id and (am.low_volume_included_flag or !arsd.low_volume_flag)'
    selecting = 'ac.*, count(distinct(d.id)) as assigned_ec_count'
    selecting += ', count(distinct(arsd.id)) as ah_ec_count'
    selecting += ', count(distinct(case when xyam.attestation_method_id = xace.default_attestation_method_id then arsd.id else null end)) as ah_ec_match_default_attestation_count'
    selecting += ', count(distinct(ai.id)) as active_action_items'
    selecting += ", avg(case when #{include_condition} then mis.advancing_care_info else null end) as indiv_avg_advancing_care_info"
    selecting += ", avg(case when #{include_condition} then mis.quality else null end) as indiv_avg_quality"
    selecting += ", avg(case when #{include_condition} then mis.resource_use else null end) as indiv_avg_resource_use"
    selecting += ", avg(case when #{include_condition} then mis.cpia else null end) as indiv_avg_cpia"
    selecting += ", avg(case when #{include_condition} then mis.cms_advancing_care_info else null end) as indiv_avg_cms_advancing_care_info"
    selecting += ", avg(case when #{include_condition} then mis.cms_quality else null end) as indiv_avg_cms_quality"
    selecting += ", avg(case when #{include_condition} then mis.cms_resource_use else null end) as indiv_avg_cms_resource_use"
    selecting += ", avg(case when #{include_condition} then mis.cms_cpia else null end) as indiv_avg_cms_cpia"
    selecting += ', xceam.advancing_care_info as advancing_care_info'
    selecting += ', xceam.quality as quality'
    selecting += ', xceam.resource_use as resource_use'
    selecting += ', xceam.cpia as cpia'
    selecting += ', xceam.quality_submission_start_date as quality_submission_start_date'
    selecting += ', xceam.quality_submission_end_date as quality_submission_end_date'
    selecting += ', xceam.quality_multi_date_ranges_flag as quality_multi_date_ranges_flag'
    selecting += ', xceam.aci_multi_date_ranges_flag as aci_multi_date_ranges_flag'
    selecting += ', xceam.manual_advancing_care_info as manual_advancing_care_info'
    selecting += ', xceam.manual_quality as manual_quality'
    selecting += ', xceam.manual_resource_use as manual_resource_use'
    selecting += ', xceam.manual_cpia as manual_cpia'
    selecting += ', xceam.manual_quality_submission_start_date as manual_quality_submission_start_date'
    selecting += ', xceam.manual_quality_submission_end_date as manual_quality_submission_end_date'
    selecting += ', xceam.manual_quality_multi_date_ranges_flag as manual_quality_multi_date_ranges_flag'
    selecting += ', xceam.manual_aci_multi_date_ranges_flag as manual_aci_multi_date_ranges_flag'
    selecting += ', xceam.cms_advancing_care_info as cms_advancing_care_info'
    selecting += ', xceam.cms_quality as cms_quality'
    selecting += ', xceam.cms_resource_use as cms_resource_use'
    selecting += ', xceam.cms_cpia as cms_cpia'
    where([selectstr, conditions])
        .order(sort_order)
        .joins(join_text)
        .group('ac.id')
        .select(selecting)
  end


  def self.For_Submission_Home_By_AttestationClinic_FiscalYearID_StagingID_EventID(selected_group_id, selected_attestation_clinic_id, selected_attestation_requirement_fiscal_year_id, selected_attestation_requirement_stage_id, selected_event_id)
    conditions = {}
    join_text = " as ac inner join x_attestation_clinic_departments xacd on xacd.attestation_clinic_id = ac.id"
    join_text += " inner join departments d on xacd.department_id = d.id"
    join_text += " inner join x_department_attestation_requirement_set_details xdarsd on xdarsd.department_id = d.id and xdarsd.attestation_clinic_id = ac.id"
    join_text += " inner join attestation_requirement_set_details arsd on xdarsd.attestation_requirement_set_detail_id = arsd.id"
    join_text += " inner join x_year_attestation_methods xyam on xyam.id = arsd.x_year_attestation_method_id"
    join_text += " inner join attestation_methods am on am.id = xyam.attestation_method_id"
    join_text += " inner join events e on arsd.event_id = e.id"
    # join_text += " left outer join x_attestation_clinic_events xace on xace.attestation_clinic_id = ac.id and xace.event_id = e.id"
    join_text += " left outer join x_clinic_event_attest_methods xceam on xceam.attestation_clinic_id = ac.id and xceam.event_id = e.id and xceam.attestation_method_id = xyam.attestation_method_id"

    # join_text = "as d"
    selectstr = ""
    status = 1
    active = 1
    andstr = ""
    sort_order = "ac.name, ac.id, xceam.event_id, xyam.sort_order, am.id"

    # department, status is 1 = current
    #selectstr = "d.status = :d_status"
    #conditions[:d_status] = status
    #andstr = " and "

    # department active is 1 = yes
    selectstr = "d.active = :d_active"
    conditions[:d_active] = active
    andstr = " and "

    #selected_attestation_clinic_id filter
    if selected_attestation_clinic_id != -1
      selectstr += andstr + "ac.id = :attestation_clinic_id"
      conditions[:attestation_clinic_id] = selected_attestation_clinic_id
      andstr = " and "
    end

    # if selected_x_year_attestation_method_id != -1
    #   selectstr += andstr + 'arsd.x_year_attestation_method_id = :arsd_x_year_attestation_method_id'
    #   conditions[:arsd_x_year_attestation_method_id] = selected_x_year_attestation_method_id
    #   andstr = " and "
    # end

    if selected_attestation_requirement_stage_id != -1
      selectstr += andstr + "e.attestation_requirement_stage_id = :attestation_requirement_stage_id"
      conditions[:attestation_requirement_stage_id] = selected_attestation_requirement_stage_id
      andstr = " and "
    end
    selectstr += andstr + "e.attestation_requirement_fiscal_year_id = :attestation_requirement_fiscal_year_id"
    conditions[:attestation_requirement_fiscal_year_id] = selected_attestation_requirement_fiscal_year_id
    andstr = " and "

    # group id
    selectstr += andstr + "d.group_id = :d_group_id"
    conditions[:d_group_id] = selected_group_id.to_i
    andstr = " and "

    selectstr += andstr + "ac.group_id = :ac_group_id"
    conditions[:ac_group_id] = selected_group_id.to_i
    andstr = " and "

    #attestation_requirement_status filter
    selectstr += andstr + "arsd.attestation_requirement_status_id != :attestation_requirement_status_not_eligible_id"
    conditions[:attestation_requirement_status_not_eligible_id] = 14
    andstr = " and "

    selecting = 'ac.*'
    selecting += ', e.id as event_id'
    selecting += ', am.name as attestation_method_name'
    selecting += ', xceam.id as xceam_id'
    selecting += ', am.id as am_id'

    selecting += ', xceam.aci_use_manual_fields_flag as aci_use_manual_fields_flag'
    selecting += ', xceam.quality_use_manual_fields_flag as quality_use_manual_fields_flag'

    selecting += ', xceam.advancing_care_info as advancing_care_info'
    selecting += ', xceam.quality as quality'
    selecting += ', xceam.resource_use as resource_use'
    selecting += ', xceam.cpia as cpia'

    selecting += ', xceam.manual_advancing_care_info as manual_advancing_care_info'
    selecting += ', xceam.manual_quality as manual_quality'
    selecting += ', xceam.manual_resource_use as manual_resource_use'
    selecting += ', xceam.manual_cpia as manual_cpia'

    selecting += ', xceam.cms_advancing_care_info as cms_advancing_care_info'
    selecting += ', xceam.cms_quality as cms_quality'
    selecting += ', xceam.cms_resource_use as cms_resource_use'
    selecting += ', xceam.cms_cpia as cms_cpia'
    selecting += ', xceam.cms_mips_composite_score as cms_mips_composite_score'

    where([selectstr,conditions])
        .joins(join_text)
        .order(sort_order)
        .group('ac.id, am.id')
        .select(selecting)
  end
end
