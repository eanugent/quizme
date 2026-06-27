module AdminAuthentication
  extend ActiveSupport::Concern

  private

  def require_admin!
    head :unauthorized unless admin_authenticated?
  end

  def admin_authenticated?
    session[:admin_authenticated] == true
  end

  def valid_admin_credentials?(username, password)
    expected_username = ENV.fetch('QUIZME_ADMIN_USERNAME', '')
    expected_password = ENV.fetch('QUIZME_ADMIN_PASSWORD', '')
    return false if expected_username.blank? || expected_password.blank?

    secure_compare(username, expected_username) && secure_compare(password, expected_password)
  end

  def secure_compare(provided, expected)
    return false if provided.blank? || expected.blank?

    ActiveSupport::SecurityUtils.secure_compare(provided, expected)
  rescue ArgumentError
    false
  end
end
