
class ChatsController < ApplicationController
  # skip_before_action :verify_authenticity_token

  def index
    token = params[:application_token]

      if token.blank?
      return handle_result(ServiceResponse.error("token is required"), :ok, :bad_request)
      end

    result = ChatServices.find_all(token)
   if result.success
    sanitized =  result.data.as_json(include:
     {

  messages: {
      except: [ :id, :chat_id ]
    }


  }, except: [ :id, :application_id ])

    handle_result(ServiceResponse.success(sanitized))
   else
    handle_result(result)
   end
  end

  def create
   token = params[:application_token]
      if token.blank?
      return handle_result(ServiceResponse.error("token is required"), :ok, :bad_request)
      end

    result = ChatServices.create(token)
     if result.success
    sanitized =  result.data.as_json(include: {
    messages: {
      except: [ :id, :chat_id ]
    }
  }, except: [ :id, :application_id ])

    handle_result(ServiceResponse.success(sanitized), :created)
     else
    handle_result(result)
     end
  end

  def show
     token = params[:application_token]
     chat_number = params[:chat_number].to_i
      if token.blank? || chat_number.blank?
      return handle_result(ServiceResponse.error("token and chat number are required"), :ok, :bad_request)
      end
    result = ChatServices.find(token, chat_number.to_i)
        if result.success
    sanitized =  result.data.as_json(include: {
    messages: {
      except: [ :id, :chat_id ]
    }
  }, except: [ :id, :application_id ])


    handle_result(ServiceResponse.success(sanitized))
        else
    handle_result(result)
        end
  end
end
