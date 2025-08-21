
require 'rails_helper'

RSpec.describe ChatServices do
  describe ".find_all" do
    context "when application exists" do
      let!(:application) { create(:application) }
      let!(:token) { application.token }
      let!(:chat) { create(:chat, application: application, application_token: token) }

      it "returns all chats for the application" do
        #   application = create(:application)
        #  token = application.token
        #   chat = create(:chat, application: application, application_token: token)
        result = described_class.find_all(token)
        expect(result.success?).to be true


        expect(result.data).to all(be_a(Chat))
        expect(result.data).to include(chat)
      end
    end

    context "when application does not exist" do
      it "returns an error response" do
        result = described_class.find_all("invalid_token")
        expect(result.success?).to be false
        expect(result.error).to eq("Application not found")
      end
    end

    context "when an exception occurs" do
      before do
        allow(Application).to receive(:includes).and_raise(StandardError.new("DB error"))
      end

      it "returns an error response" do
        result = described_class.find_all("any_token")
        expect(result.success?).to be false
        expect(result.error).to eq("DB error")
      end
    end
    context "when no chats exist" do
      let!(:application) { create(:application) }
      let!(:token) { application.token }

      it "returns an empty array" do
        result = described_class.find_all(token)
        expect(result.success?).to be true
        expect(result.data).to eq([])
      end
    end
  end
  describe ".create" do
  let!(:application) { create(:application) }
  let(:token) { application.token }

  before do
        ActiveJob::Base.queue_adapter = :test
    # Ensure Redis starts clean for each test
    $redis.del(token)
  end

  context "when application exists" do
    it "increments Redis counter, enqueues job, and returns success" do
      expect {
        result = described_class.create(token)

        expect(result.success?).to be true
        expect(result.data).to be_a(Integer)
        expect(result.data).to eq(1) # first chat number

        # Check Redis counter actually incremented
        expect($redis.get(token).to_i).to eq(1)

        # Check job was enqueued with correct args
        expect(CreateChatJob).to have_been_enqueued.with(token, 1, application.id)
      }.to have_enqueued_job(CreateChatJob)
    end
  end

  context "when application does not exist" do
    it "returns an error response" do
      result = described_class.create("invalid_token")
      expect(result.success?).to be false
      expect(result.error).to eq("Application not found")
    end
  end

  context "when Redis counter returns invalid value" do
    before do
      allow($redis).to receive(:incr).and_return(nil)
    end

    it "returns an error response" do
      result = described_class.create(token)
      expect(result.success?).to be false
      expect(result.error).to eq("Invalid chat number generated")
    end
  end

  context "when job enqueueing fails" do
    before do
      allow(CreateChatJob).to receive(:perform_later).and_raise(StandardError.new("Queue down"))
    end

    it "returns an error response" do
      result = described_class.create(token)
      expect(result.success?).to be false
      expect(result.error).to eq("Failed to enqueue chat creation: Queue down")
    end
  end

  context "when an unexpected exception occurs" do
    before do
      allow(Application).to receive(:find_by).and_raise(StandardError.new("DB error"))
    end

    it "returns an error response" do
      result = described_class.create("any_token")
      expect(result.success?).to be false
      expect(result.error).to eq("DB error")
    end
  end
end

describe ".find" do
  context "when chat exists" do
    let!(:application) { create(:application) }
    let!(:token) { application.token }
    let!(:chat) { create(:chat, application: application, application_token: token) }


    it "returns the correct chat" do
      result = described_class.find(token, chat.number)
      expect(result.success?).to be true
      expect(result.data).to be_a(Chat)
      expect(result.data.number).to eq(chat.number)
      expect(result.data.application_token).to eq(token)
    end
  end
  context "when chat does not exist" do
    it "returns an error response" do
      result = described_class.find("invalid_token", 9999)
      expect(result.success?).to be false
      expect(result.error).to eq("Chat not found")
    end
  end
  context "when application does not exist" do
    it "returns an error response" do
      result = described_class.find("invalid_token", 1)
      expect(result.success?).to be false
      expect(result.error).to eq("Chat not found")
    end
  end
  context "when an unexpected exception occurs" do
        let!(:application) { create(:application) }
    let!(:token) { application.token }
    let!(:chat) { create(:chat, application: application, application_token: token) }
    before do
        allow(Chat).to receive_message_chain(:includes, :find_by)
    .and_raise(StandardError.new("DB error"))
    end

    it "returns an error response" do
      result = described_class.find(token, chat.number)

      expect(result.success?).to be false
      expect(result.error).to eq("DB error")
    end
  end
end
end
