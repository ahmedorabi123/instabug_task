require "rails_helper"

RSpec.describe CreateMessageJob, type: :job do
    include ActiveJob::TestHelper
  let(:chat) { create(:chat) }
  let(:number) { 42 }
  let(:text) { "Hello world" }
  let(:chat_id) { chat.id }

  before do
    $redis.del("newCreatedMessages")
    ActiveJob::Base.queue_adapter = :test
  end

  describe "#perform" do
    it "creates a message with correct attributes" do
      expect {
        described_class.perform_now(number, text, chat_id)
      }.to change(Message, :count).by(1)

      msg = Message.last
      expect(msg.number).to eq(number)
      expect(msg.text).to eq(text)
      expect(msg.chat_id).to eq(chat_id)
    end

    it "adds the chat_id to Redis set" do
      described_class.perform_now(number, text, chat_id)
      expect($redis.smembers("newCreatedMessages")).to include(chat_id.to_s)
    end

 it "enqueues IndexMessageJob with the new message id" do
  expect {
    described_class.perform_now(number, text, chat_id)
  }.to have_enqueued_job(IndexMessageJob)
end



    it "logs an error if message creation fails" do
      allow(Message).to receive(:create!).and_raise(StandardError, "DB error")
      expect(Rails.logger).to receive(:error).with(/CreateMessageJob failed: DB error/)
      described_class.perform_now(number, text, chat_id)
    end

    it "does not update Redis or enqueue IndexMessageJob if creation fails" do
      allow(Message).to receive(:create!).and_raise(StandardError)
      expect {
        described_class.perform_now(number, text, chat_id)
      }.not_to change(Message, :count)

      expect($redis.smembers("newCreatedMessages")).to be_empty
      expect(IndexMessageJob).not_to have_been_enqueued
    end
  end
end
