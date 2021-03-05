class XClinicEventAttestGroupRequirement < ApplicationRecord
  belongs_to :x_group_requirement

  def self.first_group_aci_requirement_with_date_range_by_clinic_id_and_attestation_method_id_and_event_id(clinic_id, attestation_method_id, event_id, use_manual_flag = false)
    conditions = {}
    join_text = 'as xceagr inner join x_clinic_event_attest_methods xceam on xceam.id = xceagr.x_clinic_event_attest_method_id'
    join_text += ' inner join x_group_requirements xgr on xceagr.x_group_requirement_id = xgr.id'
    join_text += ' inner join requirements r on r.id = xgr.requirement_id'

    andstr = ' and '

    selectstr = 'xceam.attestation_clinic_id = :attestation_clinic_id'
    conditions[:attestation_clinic_id] = clinic_id

    selectstr += andstr + 'xceam.event_id = :xceam_event_id'
    conditions[:xceam_event_id] = event_id

    selectstr += andstr + 'xceam.attestation_method_id = :attestation_method_id'
    conditions[:attestation_method_id] = attestation_method_id

    selectstr += andstr + 'r.status = 1'
    selectstr += andstr + 'r.active = true'

    selectstr += andstr + 'r.event_id = :r_event_id'
    conditions[:r_event_id] = event_id

    selectstr += ' and xgr.status = 1'
    selectstr += ' and xgr.active = true'

    selectstr += ' and r.aci_scoring_type_id IS NOT NULL'

    # selectstr += ' and ('
    # # when 1 # Base
    # selectstr += 'r.required_for_base_score_flag = 1'
    # # when 2 # Performance
    # selectstr += ' or r.aci_scoring_type_id in (2, 3, 4, 5, 6)'
    # # when 3 # Bonus
    # selectstr += ' or r.aci_performance_bonus_points > 0'
    #
    # selectstr += ')'

    select_text = 'xceagr.*'
    if use_manual_flag
      selectstr += ' and xceagr.manual_current_measure_start_date IS NOT NULL and xceagr.manual_current_measure_end_date IS NOT NULL'
      select_text += ', xceagr.manual_current_measure_start_date as aci_start_date, xceagr.manual_current_measure_end_date as aci_end_date'
    else
      selectstr += ' and xceagr.current_measure_start_date IS NOT NULL and xceagr.current_measure_end_date IS NOT NULL'
      select_text += ', xceagr.current_measure_start_date as aci_start_date, xceagr.current_measure_end_date as aci_end_date'
    end

    where([selectstr,conditions])
        .joins(join_text)
        .group('xceagr.id')
        .order('xceagr.id')
        .select(select_text)
        .first
  end

  def self.group_requirements_for_cqm_submission_json_by_clinic_id_and_attestation_method_id_and_event_id(clinic_id, attestation_method_id, event_id, use_manual_flag = false)
    conditions = {}
    join_text = 'as xceagr inner join x_clinic_event_attest_methods xceam on xceam.id = xceagr.x_clinic_event_attest_method_id'
    join_text += ' inner join x_group_requirements xgr on xceagr.x_group_requirement_id = xgr.id'
    join_text += ' inner join requirements r on r.id = xgr.requirement_id'

    andstr = ' and '

    selectstr = 'xceam.attestation_clinic_id = :attestation_clinic_id'
    conditions[:attestation_clinic_id] = clinic_id

    selectstr += andstr + 'xceam.event_id = :xceam_event_id'
    conditions[:xceam_event_id] = event_id

    selectstr += andstr + 'xceam.attestation_method_id = :attestation_method_id'
    conditions[:attestation_method_id] = attestation_method_id

    selectstr += andstr + 'r.event_id = :r_event_id'
    conditions[:r_event_id] = event_id

    selectstr += andstr + 'r.criterion_id = :r_criterion_id'
    conditions[:r_criterion_id] = 4

    select_text = 'xceagr.*'
    if use_manual_flag
      selectstr += andstr + 'xceagr.manual_cqm_select_flag = 1'

      selectstr += ' and xceagr.manual_current_measure_start_date IS NOT NULL'
      selectstr += ' and xceagr.manual_current_measure_end_date IS NOT NULL'
      selectstr += ' and xceagr.manual_current_measure_start_date = xceam.manual_quality_submission_start_date'
      selectstr += ' and xceagr.manual_current_measure_end_date = xceam.manual_quality_submission_end_date'

      select_text += ', xceagr.manual_numerator as numerator, xceagr.manual_denominator as denominator'
    else
      selectstr += andstr + 'xceagr.cqm_select_flag = 1'

      selectstr += ' and xceagr.current_measure_start_date IS NOT NULL'
      selectstr += ' and xceagr.current_measure_end_date IS NOT NULL'
      selectstr += ' and xceagr.current_measure_start_date = xceam.quality_submission_start_date'
      selectstr += ' and xceagr.current_measure_end_date = xceam.quality_submission_end_date'

      select_text += ', xceagr.numerator as numerator, xceagr.denominator as denominator'
    end

    where([selectstr,conditions])
        .joins(join_text)
        .group('xceagr.id')
        .select(select_text)
  end

  def self.group_requirements_for_aci_submission_json_by_clinic_id_and_attestation_method_id_and_event_id(clinic_id, attestation_method_id, event_id, use_manual_flag = false)
    conditions = {}
    join_text = 'as xceagr inner join x_clinic_event_attest_methods xceam on xceam.id = xceagr.x_clinic_event_attest_method_id'
    join_text += ' inner join x_group_requirements xgr on xceagr.x_group_requirement_id = xgr.id'
    join_text += ' inner join requirements r on r.id = xgr.requirement_id'

    andstr = ' and '

    selectstr = 'xceam.attestation_clinic_id = :attestation_clinic_id'
    conditions[:attestation_clinic_id] = clinic_id

    selectstr += andstr + 'xceam.event_id = :xceam_event_id'
    conditions[:xceam_event_id] = event_id

    selectstr += andstr + 'xceam.attestation_method_id = :attestation_method_id'
    conditions[:attestation_method_id] = attestation_method_id

    selectstr += andstr + 'r.status = 1'
    selectstr += andstr + 'r.active = true'

    selectstr += andstr + 'r.event_id = :r_event_id'
    conditions[:r_event_id] = event_id

    selectstr += ' and xgr.status = 1'
    selectstr += ' and xgr.active = true'

    selectstr += ' and r.aci_scoring_type_id IS NOT NULL'

    # selectstr += ' and ('
    # # when 1 # Base
    # selectstr += 'r.required_for_base_score_flag = 1'
    # # when 2 # Performance
    # selectstr += ' or r.aci_scoring_type_id in (2, 3, 4, 5, 6)'
    # # when 3 # Bonus
    # selectstr += ' or r.aci_performance_bonus_points > 0'
    #
    # selectstr += ')'

    select_text = 'xceagr.*'
    if use_manual_flag
      select_text += ', xceagr.manual_numerator as numerator, xceagr.manual_denominator as denominator, xceagr.manual_exclusion_flag as exclusion_flag, xceagr.manual_exclusion2_flag as exclusion2_flag, xceagr.manual_exclusion3_flag as exclusion3_flag'
    else
      select_text += ', xceagr.numerator as numerator, xceagr.denominator as denominator, xceagr.exclusion_flag as exclusion_flag, xceagr.exclusion2_flag as exclusion2_flag, xceagr.exclusion3_flag as exclusion3_flag'
    end

    where([selectstr,conditions])
        .joins(join_text)
        .group('xceagr.id')
        .select(select_text)
  end

  def self.group_requirement_by_attestation_clinic_id_and_attestation_method_id_and_event_id_and_requirement_identifier(clinic_id, attestation_method_id, event_id, requirement_identifier)
    conditions = {}
    join_text = 'as xceagr inner join x_clinic_event_attest_methods xceam on xceam.id = xceagr.x_clinic_event_attest_method_id'
    join_text += ' inner join x_group_requirements xgr on xceagr.x_group_requirement_id = xgr.id'
    join_text += ' inner join requirements r on r.id = xgr.requirement_id'

    andstr = ' and '

    selectstr = 'xceam.attestation_clinic_id = :attestation_clinic_id'
    conditions[:attestation_clinic_id] = clinic_id

    selectstr += andstr + 'xceam.event_id = :xceam_event_id'
    conditions[:xceam_event_id] = event_id

    selectstr += andstr + 'xceam.attestation_method_id = :attestation_method_id'
    conditions[:attestation_method_id] = attestation_method_id

    selectstr += andstr + 'r.status = 1'
    selectstr += andstr + 'r.active = true'

    selectstr += andstr + 'r.event_id = :r_event_id'
    conditions[:r_event_id] = event_id

    selectstr += andstr + 'r.requirement_identifier = :r_requirement_identifier'
    conditions[:r_requirement_identifier] = requirement_identifier

    selectstr += ' and xgr.status = 1'
    selectstr += ' and xgr.active = true'

    select_text = 'xceagr.*'

    where([selectstr,conditions])
        .joins(join_text)
        .group('xceagr.id')
        .order('xceagr.id')
        .select(select_text)
        .first
  end
end
