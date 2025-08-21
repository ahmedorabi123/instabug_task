require 'rails_helper'

RSpec.describe ChatsController, type: :controller do
  let!(:application) { create(:application) }  # Creates with a token
  let!(:token) { application.token }
  let!(:chat) { create(:chat, application: application, application_token: token) }

  describe "GET #index" do
    context "when successful" do
      before do
        allow(ChatServices).to receive(:find_all).with(token).and_return(
          ServiceResponse.success([ chat ])
        )
        get :index, params: { application_token: token }
      end

      it "returns status 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns chats in body" do
        expect(JSON.parse(response.body).size).to eq(1)
      end

         it "returns the right token in body" do
         expect(JSON.parse(response.body)).to all(include("application_token" => token))
      end
    end

    context "with missing token" do
      it "returns bad request" do
        get :index, params: { application_token: '' }
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["error"]).to eq("token is required")
      end
    end

    context "when service returns error" do
      before do
        allow(ChatServices).to receive(:find_all).and_return(
          ServiceResponse.error("Service error")
        )
        get :index, params: { application_token: token }
      end

      it "returns unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to eq("Service error")
      end
    end
  end



  describe "POST #create" do
    context "when successful" do
      before do
        allow(ChatServices).to receive(:create).with(token).and_return(
          ServiceResponse.success(chat)
        )
        post :create, params: { application_token: token }
      end

      it "returns status 201" do
        expect(response).to have_http_status(:created)
      end



      it "contains correct attributes" do
        expect(JSON.parse(response.body)).to include(
          "application_token" => token,
          "number" => chat.number,
          "messages" => an_instance_of(Array)
        )
      end

      it "returns chat number" do
        expect(JSON.parse(response.body)["number"]).to be_a(Integer)
      end
    end

    context "when service fails" do
      before do
        allow(ChatServices).to receive(:create).with(token).and_return(
          ServiceResponse.error("Failed to create chat")
        )
        post :create, params: { application_token: token }
      end

      it "returns unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Failed to create chat")
      end
    end
    context "with missing token" do
      it "returns bad request" do
        post :create, params: { application_token: '' }
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["error"]).to eq("token is required")
      end
    end
  end



describe "GET #show" do
    context "when successful" do
      before do
        allow(ChatServices).to receive(:find).with(token, chat.number).and_return(
          ServiceResponse.success(chat)
        )

        get :show, params: { application_token: token, chat_number: chat.number }
      end
      it "returns status 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns chat with the correct attributes" do
        expect(JSON.parse(response.body)).to include(
          "application_token" => token,
          "number" => chat.number,
          "messages" => an_instance_of(Array)
        )
      end
    end
    context "with missing token or chat number" do
      it "returns bad request" do
        get :show, params: { application_token: '', chat_number: '' }
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["error"]).to eq("token and chat number are required")
      end
    end

    context "when service returns error" do
      before do
        allow(ChatServices).to receive(:find).and_return(
          ServiceResponse.error("Chat not found")
        )
        get :show, params: { application_token: token, chat_number: 1 }
      end

      it "returns unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to eq("Chat not found")
      end
    end
  end
  end
