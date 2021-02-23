class AttestationMethod < ApplicationRecord
  def has_clinic_rollup?
    AttestationMethodType.clinic_rollup_ids.include? attestation_method_type_id
  end
  def has_group_rollup?
    AttestationMethodType.group_rollup_ids.include? attestation_method_type_id
  end
  def self.attestation_methods_by_fiscal_year_id(fiscal_year_id)
    join_text = 'as am inner join x_year_attestation_methods xyam on xyam.attestation_method_id = am.id'
    sort_order = 'xyam.sort_order'
    conditions = ' xyam.attestation_requirement_fiscal_year_id = '+fiscal_year_id.to_s
    conditions += ' and xyam.status = 1'
    conditions += ' and xyam.active = 1'
    where(conditions)
        .order(sort_order)
        .joins(join_text)
        .select('am.*, xyam.id as x_year_attestation_method_id')
  end
end
