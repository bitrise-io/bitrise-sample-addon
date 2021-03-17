# frozen_string_literal: true

class DataProviderController < ActionController::API
  attr_reader :app

  before_action :retrieve_app

  def ascii_provider
    begin
      Datastore.check_limit!(params[:app_slug])
    rescue StandardError => ex
      return render json: { error: ex.to_s }.to_json, status: :bad_request
    end

    location = File.dirname(__FILE__)
    file = File.open("#{location}/../../assets/art#{Random.rand(1..3)}.txt")
    bitbot = []
    file.each do |line|
      bitbot = bitbot.concat([line.to_s])
    end
    bitbot.join

    render plain: bitbot
  end

  private

  def retrieve_app
    @app = Datastore.get_app(params[:app_slug])
    if @app.nil?
      return render json: { error: 'no app provisioned with this slug' }.to_json, status: :bad_request
    end
  end
end
