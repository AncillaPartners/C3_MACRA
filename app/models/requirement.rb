class Requirement < ApplicationRecord
  belongs_to  :metric_type, optional: true

  def self.new_group_requirements(selected_group_id)
    conditions = {}
    conditions2 = {}
    selectstr = ""
    selectstr2 = ""
    status = 1
    active = 1
    andstr = ""

    # requirement record status, active is 1 = yes
    selectstr = "r.active = :requirement_active"
    selectstr2 = "active = :requirement_active"
    conditions[:requirement_active] = active
    conditions2[:requirement_active] = active
    andstr = " and "

    # requirement record status, status published is 1 = yes
    selectstr += andstr + "r.status = :requirement_status"
    selectstr2 += andstr + "status = :requirement_status"
    conditions[:requirement_status] = status
    conditions2[:requirement_status] = status
    andstr = " and "

    # group requirement record status, active is 1 = yes
    selectstr += andstr + "xgr.active = :group_requirement_active"
    conditions[:group_requirement_active] = active
    andstr = " and "

    # group id
    selectstr += andstr + "xgr.group_id = :group_id"
    conditions[:group_id] = selected_group_id
    andstr = " and "

    groups = where([selectstr,conditions])
                 .joins("as r inner join x_group_requirements as xgr on xgr.requirement_id = r.id")
                 .select("r.id")

    # group id
    if groups.count > 0
      selectstr2 += andstr + "id NOT in (:groups)"
      conditions2[:groups] = groups
      andstr = " and "
    end

    other_review_indicators = where([selectstr2,conditions2])
                                  .select("id")

  end
end
