class Logo < ApplicationRecord
  belongs_to  :group

  # has_attachment storage: :file_system,
  #                max_size: 10.megabytes,
  #                path_prefix: 'public/images/uploaded_logos'

end
