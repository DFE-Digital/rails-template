# frozen_string_literal: true
class ErrorsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def not_found
    render 'not_found', status: :not_found
  end

  def unprocessable_entity
    render 'unprocessable_entity', status: :unprocessable_entity
  end

  def internal_server_error
    render 'internal_server_error', status: :internal_server_error
  end
end
