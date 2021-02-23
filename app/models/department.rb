class Department < ApplicationRecord
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
end
