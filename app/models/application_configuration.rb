class ApplicationConfiguration < ApplicationRecord

  def self.get_mips_aci_calc_flag
    find(1).active
  end

  def self.get_mips_quality_calc_flag
    find(2).active
  end

  def self.get_mips_cpia_calc_flag
    find(4).active
  end

  def self.get_token
    find(5).description
  end

  def self.get_infusionsoft_static_tag
    find(6).description
  end

  def self.get_pecos_app_token
    find(7).description
  end

  def self.get_qpp_submission_api_endpoint
    find(8).description
  end
end
