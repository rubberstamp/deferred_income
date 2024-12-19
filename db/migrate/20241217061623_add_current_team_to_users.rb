class AddCurrentTeamToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :current_team_id, :integer
  end
end
