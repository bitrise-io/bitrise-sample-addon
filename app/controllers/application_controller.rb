class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def provision
    puts 'Provisioning the addon ...'

    render json: {}, status: :ok
  end

  def change_plan
    puts "Changing plan for app (slug: #{safe_params[:slug]}) ..."

    render json: {}, status: :ok
  end

  def deprovision
    puts "Deprovisioning addon for app (slug: #{safe_params[:slug]}) ..."

    render json: {}, status: :ok
  end

  def login
    puts "SSO login"
  end

  def safe_params
    params.permit(:slug)
  end
end
