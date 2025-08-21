require 'rails_helper'

RSpec.describe "Chats API Integration", type: :request do
  let!(:application) { create(:application) }
  let!(:token) { application.token }
  let!(:chat) { create(:chat, application: application, application_token: token) }

  before do
    # Use the test queue adapter to avoid executing jobs inline
    ActiveJob::Base.queue_adapter = :test
    # Reset Redis counter
    $redis.del(token)
  end

  describe "GET /applications/:application_token/chats" do
    it "returns all chats for the application" do
      get "/applications/#{token}/chats"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to be_an(Array)
      expect(body.first).to include(
        "application_token" => token,
        "number" => chat.number
      )
    end


    it "returns error when application not found" do
      get "/applications/invalid_token/chats"
      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)["error"]).to eq("Application not found")
    end
  end

  describe "POST /applications/:application_token/chats" do
    it "creates a chat and enqueues CreateChatJob" do
      expect {
        post "/applications/#{token}/chats"
      }.to have_enqueued_job(CreateChatJob)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)


      expect(body).to eq(1)

      # Verify Redis counter incremented
      expect($redis.get(token).to_i).to eq(1)
    end

    # it "returns bad request when token is missing" do
    #   post "/applications//chats"
    #   expect(response).to have_http_status(:bad_request)
    #   expect(JSON.parse(response.body)["error"]).to eq("token is required")
    # end

    it "returns error when application does not exist" do
      post "/applications/invalid_token/chats"
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["error"]).to eq("Application not found")
    end
  end

  describe "GET /applications/:application_token/chats/:chat_number" do
    it "returns the chat with messages" do
      get "/applications/#{token}/chats/#{chat.number}"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to include(
        "application_token" => token,
        "number" => chat.number,
        "messages" => an_instance_of(Array)
      )
    end

    # it "returns bad request when token or chat_number missing" do
    #   get "/applications//chats/"
    #   expect(response).to have_http_status(:bad_request)
    #   expect(JSON.parse(response.body)["error"]).to eq("token and chat number are required")
    # end

    it "returns error when chat not found" do
      get "/applications/#{token}/chats/9999"
      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)["error"]).to eq("Chat not found")
    end
  end
end
