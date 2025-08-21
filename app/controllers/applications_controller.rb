class ApplicationsController < ApplicationController
  def index
    result = ApplicationServices.find

    if result.success
      sanitized = result.data.as_json(include: {
        chats: { except: [ :id, :application_id ] }
      }, except: [ :id ])

      handle_result(ServiceResponse.success(sanitized))
    else
      handle_result(result)
    end
  end

  def create
    name = application_params[:name] rescue nil

    if name.blank?
      return handle_result(ServiceResponse.error("Name is required"), :ok, :bad_request)
    end

    result = ApplicationServices.create(name)

    if result.success
      sanitized = result.data.as_json(include: {
        chats: { except: [ :id, :application_id ] }
      }, except: [ :id ])

      handle_result(ServiceResponse.success(sanitized), :created)
    else
      handle_result(result)
    end
  end

  def show
    token = params[:token]

    if token.blank?
      return handle_result(ServiceResponse.error("token is required"), :ok, :bad_request)
    end

    result = ApplicationServices.find_by_token(token)

    if result.success
      sanitized = result.data.as_json(include: {
        chats: { except: [ :id, :application_id ] }
      }, except: [ :id ])

      handle_result(ServiceResponse.success(sanitized))
    else
      handle_result(result)
    end
  end

  def update
    result = ApplicationServices.update(params[:token], application_params)
    handle_result(result)
  end

  private

  def application_params
    params.require(:application).permit(:name)
  end
end
