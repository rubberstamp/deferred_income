class IntegrationsController < ApplicationController
  def new
    @integration = Integration.new
    @teams = current_user.teams
  end

  def create
    @integration = current_user.integrations.build(integration_params)
    if @integration.save
      redirect_to root_path, notice: 'Integration was successfully created.'
    else
      render :new
    end
  end

  private

  def integration_params
    params.require(:integration).permit(:integration_type, :api_key, :team_id)
  end
end
