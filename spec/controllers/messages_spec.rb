require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  let!(:application) { create(:application) }  # Creates with a token
  let!(:token) { application.token }
  let!(:chat) { create(:chat, application: application, application_token: token) }
  let!(:message) { create(:message, chat: chat) }

  describe "GET #index" do
    context "when successful" do
      before do
        allow(MessageServices).to receive(:find_all).with(token, chat.number).and_return(
          ServiceResponse.success([ message ])
        )

        get :index, params: { application_token: token, chat_chat_number: chat.number }
      end

      it "returns status 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns messages in body" do
        expect(JSON.parse(response.body).size).to eq(1)
      end
    end

    context "with missing token or chat number" do
      it "returns bad request" do
        get :index, params: { application_token: '', chat_chat_number: '' }
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["error"]).to eq("Application token and chat number are required")
      end
    end

    context "when service returns error" do
      before do
        allow(MessageServices).to receive(:find_all).and_return(
          ServiceResponse.error("Service error")
        )
        get :index, params: { application_token: token, chat_chat_number: chat.number }
      end

      it "returns unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to eq("Service error")
      end
    end
  end
  describe "POST #create" do
    context "when successful" do
      let!(:message_text) { "Hello, world!" }

      before do
        allow(MessageServices).to receive(:create).with(token, chat.number, message_text).and_return(
          ServiceResponse.success(create(:message, chat: chat, text: message_text))
        )
        post :create, params: { application_token: token, chat_chat_number: chat.number, message: { text: message_text } }
      end

      it "returns status 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns created message in body" do
        expect(JSON.parse(response.body)).to include(
          "text" => message_text,)
      end
    end

    context "with missing parameters" do
      it "returns bad request" do
        post :create, params: { application_token: token, chat_chat_number: chat.number, message: { text: '' } }
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["error"]).to eq("Application token, chat number, and message text are required")
      end
    end

    context "when service returns error" do
      before do
        allow(MessageServices).to receive(:create).and_return(
          ServiceResponse.error("Service error")
        )
        post :create, params: { application_token: token, chat_chat_number: chat.number, message: { text: "Test" } }
      end

      it "returns unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to eq("Service error")
      end
    end
  end
  describe "GET #show" do
    context "when successful" do
      before do
        allow(MessageServices).to receive(:find).with(token, chat.number, message.number).and_return(
          ServiceResponse.success(message)
        )
        get :show, params: { application_token: token, chat_chat_number: chat.number, message_number: message.number }
      end

      it "returns status 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns message in body" do
        expect(JSON.parse(response.body)).to include(
          "text" => message.text,
          "number" => message.number
        )
      end
    end

    context "with missing parameters" do
      it "returns bad request" do
        get :show, params: { application_token: token, chat_chat_number: chat.number, message_number: '' }

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["error"]).to eq("Application token, chat number, and message number are required")
      end
    end

    context "when service returns error" do
      before do
        allow(MessageServices).to receive(:find).and_return(
          ServiceResponse.error("Service error")
        )
        get :show, params: { application_token: token, chat_chat_number: chat.number, message_number: message.number }
      end

      it "returns unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to eq("Service error")
      end
    end
  end
end
