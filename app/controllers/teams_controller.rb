class TeamsController < ApplicationController

    before_action :ensure_team_exists, only: [:index, :show, :edit, :update, :destroy]

    def index
        @teams = current_user.teams
    end

    def show
        @team = current_user.teams.find(params[:id]) 
    end

    def new 
        @team = current_user.teams.new
    end

    def create
        @team = current_user.teams.new(team_params)
        if @team.save
            redirect_to root_path, notice: 'Team was successfully created.'
        else
            render :new
        end
    end

    def update
        @team = current_user.teams.find(params[:id])
        if @team.update(team_params)
            redirect_to root_path, notice: 'Team was successfully updated.'
        else
            render :edit
        end
    end

    def destroy
        @team = current_user.teams.find(params[:id])
        @team.destroy
        redirect_to root_path, notice: 'Team was successfully destroyed.'
    end

    def set_current
      current_user.update(current_team_id: params[:current_team_id])
      redirect_back(fallback_location: root_path, notice: 'Current team updated.')
    end

    private

    def team_params
        params.require(:team).permit(:name)
    end

    def ensure_team_exists
      if current_user.teams.empty?
        redirect_to new_team_path, alert: 'You must create a team before proceeding.'
      end
    end

end
