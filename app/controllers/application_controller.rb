class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def has_a_team?
    redirect_to new_team_path if signed_in? and current_user.teams.empty?
  end
end
