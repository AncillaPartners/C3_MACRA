class Theme < ApplicationRecord

  def self.fixed_footer_themes
    theme_ids = Array.new
    self.where(layout_name: ['_hlc', '_fan', 'rad']).map{|x| theme_ids << x.id }
    theme_ids
  end
end
