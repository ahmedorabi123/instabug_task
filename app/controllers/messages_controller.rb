

class MessagesController < ApplicationController
  # skip_before_action :verify_authenticity_token

  def index
     application_token = params[:application_token]
    chat_number = params[:chat_chat_number]
     if application_token.blank? || chat_number.blank?
      return handle_result(ServiceResponse.error("Application token and chat number are required"), :ok, :bad_request)
     end
    result = MessageServices.find_all(application_token, chat_number.to_i)
     if result.success
    sanitized =  result.data.as_json(except: [ :id, :chat_id ])

    handle_result(ServiceResponse.success(sanitized))
     else
    handle_result(result)
     end
  end

  def create
    application_token = params[:application_token]
    chat_number = params[:chat_chat_number]


      if application_token.blank? || chat_number.blank? || message_params[:text].blank?
      return handle_result(ServiceResponse.error("Application token, chat number, and message text are required"), :ok, :bad_request)
      end
    result = MessageServices.create(application_token, chat_number.to_i, message_params[:text])
     if result.success
    sanitized =  result.data.as_json(except: [ :id, :chat_id ])

    handle_result(ServiceResponse.success(sanitized))
     else
    handle_result(result)
     end
  end

  def show
    application_token = params[:application_token]
    chat_number = params[:chat_chat_number]
    message_number = params[:message_number]
      if application_token.blank? || chat_number.blank? || message_number.blank?
      return handle_result(ServiceResponse.error("Application token, chat number, and message number are required"), :ok, :bad_request)
      end
    result = MessageServices.find(application_token, chat_number.to_i, message_number.to_i)
        if result.success
    sanitized =  result.data.as_json(except: [ :id, :chat_id ])

    handle_result(ServiceResponse.success(sanitized))
        else
    handle_result(result)
        end
  end

  def search
    application_token = params[:application_token]
    chat_number = params[:chat_chat_number].to_i || params[:chat_number].to_i
    query = params[:q]
    if application_token.blank? || chat_number.blank? || query.blank?
      return handle_result(ServiceResponse.error("Application token, chat number, and query are required"), :ok, :bad_request)
    end
    result = MessageServices.searchMessages(application_token, chat_number.to_i, query)
    handle_result(result)
  end

  private

  def message_params
    params.require(:message).permit(:text)
  end
end
