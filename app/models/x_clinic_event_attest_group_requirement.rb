class XClinicEventAttestGroupRequirement < ApplicationRecord

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
end
