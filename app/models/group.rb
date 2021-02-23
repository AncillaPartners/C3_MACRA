class Group < ApplicationRecord
  belongs_to  :business_partner, class_name: 'Group', foreign_key: :business_partner_id
  belongs_to  :group_type
  has_one :logo

  def self.GetFilteredGroupsBySecurity_Level(user, group, health_system_id)
    conditions = {}
    #join_text = "as xug inner join groups as g on xug.group_id = g.group_id"
    join_text = 'group_bp'
    join_text += ' inner join groups group_sub on group_sub.business_partner_id = group_bp.id'
    join_text += ' inner join group_types gt on gt.id = group_sub.group_type_id'
    selectstr = ''
    status = 1
    active = [1, 2]
    sort_order = 'gt.sort_order, group_sub.name'

    # group status is 1 = current
    selectstr = 'group_bp.status = :status and group_sub.status = :status'
    conditions[:status] = status
    andstr = ' and '

    # group active is 1 = yes, 2 = prospect
    selectstr += andstr + 'group_bp.active in (:active) and group_sub.active in (:active)'
    conditions[:active] = active

    # Filter for health system security level
    if user.security_level_id.to_i == 2 and health_system_id > 0
      selectstr += andstr + 'group_sub.health_system_id = :health_system_id'
      conditions[:health_system_id] = health_system_id
    elsif user.security_level_id.to_i == 2 and health_system_id <= 0
      selectstr += andstr + 'group_sub.id = :group_id'
      conditions[:group_id] = group.group_id
    end

    # Filter for hospital and department security level
    if user.security_level_id.to_i == 3 || user.security_level_id.to_i == 4 || user.security_level_id.to_i == 5
      selectstr += andstr + 'group_sub.id = :group_id'
      conditions[:group_id] = group.group_id
    end

    if user.security_level_id.to_i == 6
      if group.group.group_type_id == 1
        selectstr += andstr + '(group_sub.business_partner_id = :business_partner_id or group_sub.id = :business_partner_id)'
        conditions[:business_partner_id] = group.group_id
      end
      if group.group.group_type_id == 4
        selectstr += andstr + 'group_bp.business_partner_id = :business_partner_id'
        conditions[:business_partner_id] = group.group_id
      end
    end

    user_groups = self.where([selectstr,conditions])
                      .joins(join_text)
                      .order(sort_order)
                      .select('group_sub.*')
  end

  def has_fixed_footer
    minimalist_themes = Theme.fixed_footer_themes
    minimalist_themes.include? self.theme_id
  end
end
