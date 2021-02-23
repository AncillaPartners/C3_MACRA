class XYearAttestationMethod < ApplicationRecord
  def self.attestation_methods_by_group_and_clinic_and_event_and_year_and_department_owner(selected_group_id, selected_clinic_id, selected_event_id, selected_fiscal_year_id, selected_department_owner_id)
    conditions = {}
    join_text = 'as xyam inner join attestation_requirement_set_details arsd on arsd.x_year_attestation_method_id = xyam.id'
    join_text += ' inner join x_department_attestation_requirement_set_details xdarsd on xdarsd.attestation_requirement_set_detail_id = arsd.id'
    join_text += ' inner join departments d on d.id = xdarsd.department_id'
    join_text += ' inner join events e on e.id = arsd.event_id'

    status = 1
    active = 1
    andstr = ' and '
    sort_order = 'xyam.sort_order'

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
      selectstr += andstr + 'xdarsd.attestation_clinic_id is NULL'
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

    # year id
    if selected_fiscal_year_id != -1
      selectstr += andstr + 'e.attestation_requirement_fiscal_year_id = :e_fiscal_year_id'
      conditions[:e_fiscal_year_id] = selected_fiscal_year_id
    end

    selecting = 'xyam.*'
    self.where([selectstr,conditions])
        .joins(join_text)
        .order(sort_order)
        .group('xyam.id')
        .select(selecting)
  end
end
