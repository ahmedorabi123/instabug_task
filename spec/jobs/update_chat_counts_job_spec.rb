require "rails_helper"

RSpec.describe UpdateChatCountsJob, type: :job do
  include ActiveJob::TestHelper

 let!(:app1) { create(:application, name: "App One", chats_count: 0) }
let!(:app2) { create(:application, name: "App Two", chats_count: 0) }

  before do
    $redis.flushdb
    ActiveJob::Base.queue_adapter = :test
  end

  describe "#perform" do
    context "when there are no new created chats in Redis" do
      it "does nothing" do
        expect(Chat).not_to receive(:where)
        described_class.perform_now
      end
    end

    context "when there are new chats in Redis" do
      before do
        create_list(:chat, 2, application: app1)
        create_list(:chat, 3, application: app2)
        $redis.sadd("newCreatedChats", app1.id, app2.id)
      end

      it "updates chats_count for each application" do
        described_class.perform_now
        expect(app1.reload.chats_count).to eq(2)
        expect(app2.reload.chats_count).to eq(3)
      end

      it "removes the newCreatedChats set from Redis" do
        described_class.perform_now
        expect($redis.smembers("newCreatedChats")).to be_empty
      end
    end

    context "when an application is missing" do
      before do
        create_list(:chat, 2, application: app1)
        $redis.sadd("newCreatedChats", app1.id, 9999) # 9999 does not exist
      end

      it "skips updating for missing application IDs" do
        expect {
          described_class.perform_now
        }.not_to raise_error
        expect(app1.reload.chats_count).to eq(2)
      end
    end

    context "when an error occurs" do
      before do
        $redis.sadd("newCreatedChats", app1.id)
        allow(Chat).to receive(:where).and_raise(StandardError, "DB failure")
      end

      it "logs the error" do
        expect(Rails.logger).to receive(:error).with(/UpdateChatCountsJob failed: DB failure/)
        expect(Rails.logger).to receive(:error).with(instance_of(String)) # backtrace
        described_class.perform_now
      end
    end
  end
end
