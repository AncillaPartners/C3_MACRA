require 'digest/sha1'
class User < ApplicationRecord
  has_many  :x_user_groups
  has_many  :groups, :through => :x_user_groups

  def self.authenticate(email_address, password)
    user = self.find_by_email_address(email_address)
    if user
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password
        user.number_of_logon_attempts = user.number_of_logon_attempts + 1
        user.save
        if user.number_of_logon_attempts.to_i > 3
          user.status = 0
          user.save
        else
          user = nil
        end
      else
        user.number_of_logon_attempts = 0
        user.login_count += 1
        user.last_login_date = Time.now
        user.save
      end
    end
    user
  end

  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt  # 'wibble' makes it harder to guess
    Digest::SHA1.hexdigest(string_to_hash)
  end

  def is_business_partner?
    self.groups.any? {|group| group.group_type_id == 1 }
  end

  def get_full_name
    if self.id > 0
      self.first_name + " " + self.last_name
    else
      "User not assigned"
    end
  end

  private

  def create_password_history
    return unless saved_change_to_password_digest?

    PasswordHistory.create(user_id: self.id, password_digest: password_digest)
    update_attribute(:force_password_reset, false)
  end
end
