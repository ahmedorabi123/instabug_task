class ApplicationController < ActionController::API
  def handle_result(result, success_status = :ok, error_status = :unprocessable_content)
    if result.success
      render json: result.data, status: success_status
    else
      render json: { error: result.error }, status: error_status
    end
  end
end
