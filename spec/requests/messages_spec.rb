require "rails_helper"

RSpec.describe "Messages API", type: :request do
  let!(:application) { create(:application) }
  let!(:chat) { create(:chat, application: application, application_token: application.token) }
  let!(:token) { application.token }

  describe "GET /applications/:application_token/chats/:chat_chat_number/messages" do
    context "when chat has messages" do
      let!(:message1) { create(:message, chat: chat,  number: 1, text: "hello") }
      let!(:message2) { create(:message, chat: chat,  number: 2, text: "world") }

      it "returns all messages for the chat" do
        get "/applications/#{token}/chats/#{chat.number}/messages"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.size).to eq(2)
        expect(json.map { |m| m["number"] }).to contain_exactly(1, 2)
      end
    end

    context "when chat has no messages" do
      it "returns an empty array" do
        get "/applications/#{token}/chats/#{chat.number}/messages"
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq([])
      end
    end

    context "when chat does not exist" do
      it "returns error" do
        get "/applications/#{token}/chats/999/messages"
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Chat not found")
      end
    end

    # context "when params are missing" do
    #   it "returns bad request" do
    #     get "/applications/#{token}/chats//messages"
    #     expect(response).to have_http_status(:bad_request)
    #     expect(JSON.parse(response.body)["error"]).to include("Application token and chat number are required")
    #   end
    # end
  end

  describe "POST /applications/:application_token/chats/:chat_chat_number/messages" do
    context "when successful" do
      it "enqueues a job to create a message" do
        ActiveJob::Base.queue_adapter = :test
        expect {
          post "/applications/#{token}/chats/#{chat.number}/messages", params: { message: { text: "Hello" } }
        }.to have_enqueued_job(CreateMessageJob)
      end

      it "returns the message number" do
        post "/applications/#{token}/chats/#{chat.number}/messages", params: { message: { text: "Hello" } }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to be_an(Integer)
      end
    end

    context "when chat not found" do
      it "returns error" do
        post "/applications/#{token}/chats/999/messages", params: { message: { text: "Hello" } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Chat not found")
      end
    end

    # context "when required params missing" do
    #   it "returns bad request" do
    #     post "/applications/#{token}/chats/#{chat.number}/messages", params: { text: "" }
    #     expect(response).to have_http_status(:bad_request)

    #     expect(JSON.parse(response.body)["error"]).to include("Application token, chat number, and message text are required")
    #   end
    # end
  end

  describe "GET /applications/:application_token/chats/:chat_chat_number/messages/:message_number" do
    let!(:message) { create(:message, chat: chat, number: 5, text: "Find me") }

    context "when message exists" do
      it "returns the message" do
        get "/applications/#{token}/chats/#{chat.number}/messages/#{message.number}"
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["number"]).to eq(message.number)
        expect(json["text"]).to eq("Find me")
      end
    end

    context "when message not found" do
      it "returns error" do
        get "/applications/#{token}/chats/#{chat.number}/messages/999"
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Message not found")
      end
    end

    # context "when params missing" do
    #   it "returns bad request" do
    #     get "/applications/#{token}/chats/#{chat.number}/messages/"
    #     expect(response).to have_http_status(:bad_request)
    #     expect(JSON.parse(response.body)["error"]).to include("Application token, chat number, and message number are required")
    #   end
    # end
  end

  describe "GET /applications/:application_token/chats/:chat_chat_number/messages/search" do
    let!(:message1) { create(:message, chat: chat, text: "hello world") }
    let!(:message2) { create(:message, chat: chat,  text: "hey there") }

    before do
      allow(Message).to receive(:__elasticsearch__).and_return(
        double(search: double(records: [ message1 ]))
      )
    end

    context "when query matches" do
      it "returns search results" do
        get "/applications/#{token}/chats/#{chat.number}/messages/query", params: { q: "hello" }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.first["text"]).to eq("hello world")
      end
    end

    # context "when query missing" do
    #   it "returns bad request" do
    #     get "/applications/#{token}/chats/#{chat.number}/messages/search"
    #     expect(response).to have_http_status(:bad_request)
    #     expect(JSON.parse(response.body)["error"]).to include("Application token, chat number, and query are required")
    #   end
    # end

    context "when chat not found" do
      it "returns error" do
        get "/applications/#{token}/chats/999/messages/search", params: { q: "hello" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Message not found")
      end
    end
  end
end
