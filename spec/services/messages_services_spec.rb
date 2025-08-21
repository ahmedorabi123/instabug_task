require 'rails_helper'

RSpec.describe MessageServices do
    describe ".find_all" do
      context "when successful" do
        let!(:application) { create(:application) }
        let!(:token) { application.token }
        let!(:chat) { create(:chat, application: application, application_token: token) }
        let!(:message) { create(:message, chat: chat) }

        it "returns all messages for the chat" do
          result = described_class.find_all(token, chat.number)
          expect(result.success?).to be true
          expect(result.data).to all(be_a(Message))
          expect(result.data).to include(message)
        end
      end

      context "when chat does not exist" do
        it "returns an error response" do
          result = described_class.find_all("invalid_token", 9999)
          expect(result.success?).to be false
          expect(result.error).to eq("Chat not found")
        end
      end

      context "when an exception occurs" do
        before do
          allow(Chat).to receive(:includes).and_raise(StandardError.new("DB error"))
        end

        it "returns an error response" do
          result = described_class.find_all("any_token", 1)
          expect(result.success?).to be false
          expect(result.error).to eq("DB error")
        end
      end

      context "when no messages exist" do
        let!(:application) { create(:application) }
        let!(:token) { application.token }
        let!(:chat) { create(:chat, application: application, application_token: token) }

        it "returns an empty array" do
          result = described_class.find_all(token, chat.number)
          expect(result.success?).to be true
          expect(result.data).to eq([])
        end
      end
    end

   describe ".create" do
  let!(:application) { create(:application) }
  let!(:app_token) { application.token }
  let!(:chat) { create(:chat, application: application, application_token: app_token,) }
  let!(:chat_number) { chat.number }

  before do
    ActiveJob::Base.queue_adapter = :test
    # Ensure Redis starts clean for each test
    $redis.del("#{app_token}:#{chat_number}")
  end

  context "when chat exists" do
    it "increments Redis counter, enqueues job, and returns success" do
      expect {
        result = described_class.create(app_token, chat_number, "Hello world")

        expect(result.success?).to be true
        expect(result.data).to be_a(Integer)
        expect(result.data).to eq(1) # first message number

        # Redis counter incremented
        expect($redis.get("#{app_token}:#{chat_number}").to_i).to eq(1)

        # Job enqueued with correct args
        expect(CreateMessageJob).to have_been_enqueued.with(1, "Hello world", chat.id)
      }.to have_enqueued_job(CreateMessageJob)
    end
  end

  context "when chat does not exist" do
    it "returns an error response" do
      result = described_class.create("invalid_token", 999, "Test")
      expect(result.success?).to be false
      expect(result.error).to eq("Chat not found")
    end
  end

  context "when Redis counter returns invalid value" do
    before do
      allow($redis).to receive(:incr).and_return(nil)
    end

    it "returns an error response" do
      result = described_class.create(app_token, chat_number, "Test")
      expect(result.success?).to be false
      expect(result.error).to eq("Invalid msg number generated")
    end
  end

  context "when job enqueueing fails" do
    before do
      allow(CreateMessageJob).to receive(:perform_later).and_raise(StandardError.new("Queue down"))
    end

    it "returns an error response" do
      result = described_class.create(app_token, chat_number, "Test")
      expect(result.success?).to be false
      expect(result.error).to eq("Failed to enqueue msg creation: Queue down")
    end
  end

  context "when an unexpected exception occurs" do
    before do
      allow(Chat).to receive(:find_by).and_raise(StandardError.new("DB error"))
    end

    it "returns an error response" do
      result = described_class.create(app_token, chat_number, "Test")
      expect(result.success?).to be false
      expect(result.error).to eq("DB error")
    end
  end
end

describe ".find" do
      context "when message exists" do
        let!(:application) { create(:application) }
        let!(:token) { application.token }
        let!(:chat) { create(:chat, application: application, application_token: token) }
        let!(:message) { create(:message, chat: chat) }

        it "returns the correct message" do
          result = described_class.find(token, chat.number, message.number)
          expect(result.success?).to be true
          expect(result.data).to be_a(Message)
          expect(result.data.number).to eq(message.number)
        end
      end

      context "when message does not exist" do
        it "returns an error response" do
          result = described_class.find("invalid_token", 9999, 1)
          expect(result.success?).to be false
          expect(result.error).to eq("Message not found")
        end
      end

      context "when an exception occurs" do
        before do
 allow(Message).to receive_message_chain(:joins, :find_by)
  .and_raise(StandardError, "DB error")
        end

        it "returns an error response" do
          result = described_class.find("any_token", 1, 1)
          expect(result.success?).to be false
          expect(result.error).to eq("DB error")
        end
      end
    end
end
