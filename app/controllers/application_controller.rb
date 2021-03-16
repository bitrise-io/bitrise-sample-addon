# frozen_string_literal: true

class ApplicationController < ActionController::API
  def index
    render plain: 'Welcome to Bitrise Sample Addon'
  end
end
