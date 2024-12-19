class AddUserIdToTeams < ActiveRecord::Migration[8.0]
  def change
    add_column :teams, :user_id, :integer
  end
end

class AddCurrentTeamToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :current_team_id, :integer
  end
end
