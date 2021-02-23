class Event < ApplicationRecord
  belongs_to  :attestation_requirement_stage
  belongs_to  :attestation_requirement_fiscal_year
  belongs_to  :attestation_requirement_type
  def self.event_fiscal_year_by_group_type_id_and_fiscal_year_and_attestation_requirement_type_id(group_type_id, fiscal_year, attestation_requirement_type_id=0)
    join_text = " as x1 inner join attestation_requirement_fiscal_years as x2 on x1.attestation_requirement_fiscal_year_id = x2.id"
    sort_order = "x1.attestation_requirement_stage_id DESC"

    conditions = 'x1.active = true'
    conditions += ' and x1.status = 1'
    conditions += ' and x1.group_type_id = '+group_type_id.to_s if group_type_id > 1
    conditions += ' and x1.attestation_requirement_type_id <= '+(attestation_requirement_type_id + 1).to_s
    conditions += ' and x2.name = '+fiscal_year.to_s
    # example of if
    #conditions[:requirement_id] = selected_requirement_id if selected_requirement_id != -1
    where(conditions)
        .joins(join_text)
        .order(sort_order)
        .group("x2.id")
        .select("x2.*")
        .first
  end
  def self.event_fiscal_year_by_group_type_id_and_attestation_requirement_type_id(group_type_id, attestation_requirement_type_id=0)
    join_text = " as x1 inner join attestation_requirement_fiscal_years as x2 on x1.attestation_requirement_fiscal_year_id = x2.id"
    sort_order = "x1.attestation_requirement_fiscal_year_id desc, x1.attestation_requirement_stage_id DESC"

    conditions = 'x1.active = true'
    conditions += ' and x1.status = 1'
    conditions += ' and x1.group_type_id = '+group_type_id.to_s if group_type_id > 1
    conditions += ' and x1.attestation_requirement_type_id <= '+(attestation_requirement_type_id + 1).to_s
    # example of if
    #conditions[:requirement_id] = selected_requirement_id if selected_requirement_id != -1
    where(conditions)
        .joins(join_text)
        .order(sort_order)
        .group("x2.id")
        .select("x2.*")
        .first
  end
  def self.events_by_group_and_group_type_id_and_fiscal_year(group, fiscal_year_id)
    join_text = " as x1 left outer join attestation_requirement_fiscal_years as x2 on x1.attestation_requirement_fiscal_year_id = x2.id"
    if group.group_type_id == 2
      join_text += " inner join attestation_requirement_set_details as x3 on x1.id = x3.event_id"
      join_text += " inner join x_group_attestation_requirement_set_details as x4 on x3.id = x4.attestation_requirement_set_detail_id"
    end
    sort_order = "x2.name DESC, x1.attestation_requirement_stage_id DESC"

    conditions = 'x1.active = true'
    conditions += ' and x1.status = 1'
    conditions += ' and x4.group_id = '+group.id.to_s if group.group_type_id == 2
    conditions += ' and x1.group_type_id = '+group.group_type_id.to_s if group.group_type_id > 1
    attestation_requirement_type_id = 0
    attestation_requirement_type_id = (group.attestation_requirement_type_flag.nil?) ? 0 : group.attestation_requirement_type_flag
    conditions += ' and x1.attestation_requirement_type_id <= '+(attestation_requirement_type_id + 1).to_s
    conditions += ' and x2.name <= '+fiscal_year_id.to_s
    where(conditions)
        .joins(join_text)
        .order(sort_order)
        .group("x1.id")
        .select("x1.name, x1.id")
        .first
  end
  def self.event_by_group_type_id_and_attestation_requirement_type_id(group_type_id, attestation_requirement_type_id=0)
    #join_text = ""
    sort_order = "attestation_requirement_stage_id DESC"

    conditions = 'active = true'
    conditions += ' and status = 1'
    conditions += ' and group_type_id = '+group_type_id.to_s if group_type_id > 1
    conditions += ' and attestation_requirement_type_id <= '+(attestation_requirement_type_id + 1).to_s
    # example of if
    #conditions[:requirement_id] = selected_requirement_id if selected_requirement_id != -1
    where(conditions)
        .order(sort_order)
        .group("id")
        .select("name, id")
        .first
  end
  def self.events_by_group_and_group_type_id_and_attestation_requirement_type_id(group)
    join_text = " as x1 left outer join attestation_requirement_fiscal_years as x2 on x1.attestation_requirement_fiscal_year_id = x2.id"
    if group.group_type_id == 2
      join_text += " inner join attestation_requirement_set_details as x3 on x1.id = x3.event_id"
      join_text += " inner join x_group_attestation_requirement_set_details as x4 on x3.id = x4.attestation_requirement_set_detail_id"
    end
    sort_order = "x2.name DESC, x1.attestation_requirement_stage_id DESC"

    conditions = 'x1.active = true'
    conditions += ' and x1.status = 1'
    conditions += ' and x4.group_id = '+group.id.to_s if group.group_type_id == 2
    conditions += ' and x1.group_type_id = '+group.group_type_id.to_s if group.group_type_id > 1
    attestation_requirement_type_id = 0
    attestation_requirement_type_id = (group.attestation_requirement_type_flag.nil?) ? 0 : group.attestation_requirement_type_flag
    conditions += ' and x1.attestation_requirement_type_id <= '+(attestation_requirement_type_id + 1).to_s
    where(conditions)
        .joins(join_text)
        .order(sort_order)
        .group("x1.id")
        .select("x1.name, x1.id").map{|event|
      [event.name, event.id]
    }
  end
  def self.event_fiscal_years_by_group_type_id_and_attestation_requirement_type_id(group_type_id, attestation_requirement_type_id=0)
    join_text = " as x1 inner join attestation_requirement_fiscal_years as x2 on x1.attestation_requirement_fiscal_year_id = x2.id"
    join_text += " inner join attestation_requirement_stages as x3 on x1.attestation_requirement_stage_id = x3.id"
    join_text += " inner join attestation_requirement_types as x4 on x1.attestation_requirement_type_id = x4.id"
    sort_order = "x2.name DESC"

    conditions = 'x1.active = true'
    conditions += ' and x1.status = 1'
    conditions += ' and x1.group_type_id = '+group_type_id.to_s if group_type_id > 1
    conditions += ' and x1.attestation_requirement_type_id <= '+(attestation_requirement_type_id + 1).to_s
    where(conditions)
        .joins(join_text)
        .order(sort_order)
        .group("x2.id")
        .select("x2.name, x2.id").map{|fiscal_year|
      [fiscal_year.name, fiscal_year.id]
    }
  end
  def self.event_stages_by_group_type_id_and_attestation_requirement_fiscal_year_id_and_attestation_requirement_type_id(group_type_id, attestation_requirement_fiscal_year_id, attestation_requirement_type_id=0)
    join_text = " as x1 inner join attestation_requirement_fiscal_years as x2 on x1.attestation_requirement_fiscal_year_id = x2.id"
    join_text += " inner join attestation_requirement_stages as x3 on x1.attestation_requirement_stage_id = x3.id"
    join_text += " inner join attestation_requirement_types as x4 on x1.attestation_requirement_type_id = x4.id"
    # sort_order = "x3.name"
    sort_order = "x3.sort_order, x3.id"

    conditions = 'x1.active = true'
    conditions += ' and x1.status = 1'
    conditions += ' and x1.group_type_id = '+group_type_id.to_s if group_type_id > 1
    conditions += ' and x1.attestation_requirement_fiscal_year_id = '+attestation_requirement_fiscal_year_id.to_s
    conditions += ' and x1.attestation_requirement_type_id <= '+(attestation_requirement_type_id + 1).to_s
    where(conditions)
        .joins(join_text)
        .order(sort_order)
        .group("x3.id")
        .select("x3.name, x3.id").map{|stage|
      [stage.name, stage.id]
    }
  end
  def self.event_types_by_group_type_id_and_attestation_requirement_fiscal_year_id_and_attestation_requirement_type_id(group_type_id, attestation_requirement_fiscal_year_id, attestation_requirement_type_id=0)
    join_text = " as x1 inner join attestation_requirement_fiscal_years as x2 on x1.attestation_requirement_fiscal_year_id = x2.id"
    join_text += " inner join attestation_requirement_stages as x3 on x1.attestation_requirement_stage_id = x3.id"
    join_text += " inner join attestation_requirement_types as x4 on x1.attestation_requirement_type_id = x4.id"
    sort_order = "x4.name"

    conditions = 'x1.active = true'
    conditions += ' and x1.status = 1'
    conditions += ' and x1.group_type_id = '+group_type_id.to_s if group_type_id > 1
    conditions += ' and x1.attestation_requirement_fiscal_year_id = '+attestation_requirement_fiscal_year_id.to_s
    conditions += ' and x1.attestation_requirement_type_id <= '+(attestation_requirement_type_id + 1).to_s
    where(conditions)
        .joins(join_text)
        .order(sort_order)
        .group("x4.id")
        .select("x4.name, x4.id").map{|type|
      [type.name, type.id]
    }
  end
  def self.event_stage_by_group_type_id_and_attestation_requirement_fiscal_year_id_and_attestation_requirement_type_id(group_type_id, attestation_requirement_fiscal_year_id, attestation_requirement_type_id=0)
    join_text = " as x1 inner join attestation_requirement_fiscal_years as x2 on x1.attestation_requirement_fiscal_year_id = x2.id"
    join_text += " inner join attestation_requirement_stages as x3 on x1.attestation_requirement_stage_id = x3.id"
    join_text += " inner join attestation_requirement_types as x4 on x1.attestation_requirement_type_id = x4.id"
    # sort_order = "x3.name"
    sort_order = "x3.id"

    conditions = 'x1.active = true'
    conditions += ' and x1.status = 1'
    conditions += ' and x1.group_type_id = '+group_type_id.to_s if group_type_id > 1
    conditions += ' and x1.attestation_requirement_fiscal_year_id = '+attestation_requirement_fiscal_year_id.to_s
    conditions += ' and x1.attestation_requirement_type_id <= '+(attestation_requirement_type_id + 1).to_s
    where(conditions)
        .joins(join_text)
        .order(sort_order)
        .group("x3.id")
        .select("x3.id")
        .first
  end
end
