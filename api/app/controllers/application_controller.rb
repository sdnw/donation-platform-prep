class ApplicationController < ActionController::API
  # One error shape everywhere: { "errors": ["message", ...] }
  rescue_from ActionController::ParameterMissing do |e|
    render_error(e.message, :bad_request)
  end

  rescue_from ActiveRecord::RecordNotFound do
    render_error("Not found", :not_found)
  end

  private

  def render_error(message, status)
    render json: { errors: [ message ] }, status: status
  end
end
