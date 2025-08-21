require "rails_helper"

RSpec.describe CreateChatJob, type: :job do
  let!(:application) { create(:application) }
  let!(:application_token) { application.token }
  let!(:chat_num) { 5 }
  let!(:application_id) { application.id }

  before { $redis.del("newCreatedChats") }

  describe "#perform" do
    it "creates a chat" do
      expect {
        described_class.perform_now(application_token, chat_num, application_id)
      }.to change(Chat, :count).by(1)


      chat = Chat.last
      expect(chat.number).to eq(chat_num)
      expect(chat.application_token).to eq(application_token)
      expect(chat.application_id).to eq(application_id)
    end

    it "adds the application_id to Redis" do
      described_class.perform_now(application_token, chat_num, application_id)
      expect($redis.smembers("newCreatedChats")).to include(application_id.to_s)
    end

    it "logs an error if chat creation fails" do
      allow(Chat).to receive(:create!).and_raise(StandardError, "DB error")
      expect(Rails.logger).to receive(:error).with(/CreateChatJob failed: DB error/)
      described_class.perform_now(application_token, chat_num, application_id)
    end
    it "does not create a chat or update Redis if creation fails" do
  allow(Chat).to receive(:create!).and_raise(StandardError)
  expect {
    described_class.perform_now(application_token, chat_num, application_id)
  }.not_to change(Chat, :count)
  expect($redis.smembers("newCreatedChats")).to be_empty
end
  end
end
