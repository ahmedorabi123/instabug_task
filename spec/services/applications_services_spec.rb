require 'rails_helper'

RSpec.describe ApplicationServices do
  describe ".find" do
    context "when successful" do
      it "returns all applications wrapped in a ServiceResponse" do
        app1 = create(:application)

        result = described_class.find

        expect(result.success?).to be true
        expect(result.data).to include(app1)
      end
    end

    context "when error occurs" do
      before do
        allow(Application).to receive(:includes).and_raise(StandardError.new("DB error"))
      end

      it "returns an error ServiceResponse" do
        result = described_class.find

        expect(result.success?).to be false
        expect(result.error).to eq("DB error")
      end
    end
    context "when no applications exist" do
  before do
  empty_relation = Application.none # returns an empty ActiveRecord::Relation
  allow(Application).to receive_message_chain(:includes, :all).and_return(empty_relation)
end


      it "returns an empty array" do
        result = described_class.find

        expect(result.success?).to be true
        expect(result.data).to eq([])
      end
    end
  end

  describe ".create" do
    context "when successful" do
      it "creates an application and returns success" do
        result = described_class.create("Test App")

        expect(result.success?).to be true
        expect(result.data.name).to eq("Test App")
      end
    end

    context "when validation error occurs" do
      it "returns an error ServiceResponse" do
        result = described_class.create(nil)  # invalid name triggers validation error

        expect(result.success?).to be false
        expect(result.error).to include("Name can't be blank")
      end
    end

    context "when exception occurs" do
      before do
        allow(Application).to receive(:new).and_raise(StandardError.new("Create error"))
      end

      it "returns an error ServiceResponse" do
        result = described_class.create("Test App")

        expect(result.success?).to be false
        expect(result.error).to eq("Create error")
      end
    end

    context "when name is already taken" do
      before do
        create(:application, name: "Duplicate Name")
      end

      it "returns an error ServiceResponse with uniqueness error" do
        result = described_class.create("Duplicate Name")

        expect(result.success?).to be false
        expect(result.error).to include("Name has already been taken")
      end
    end
  end






  describe ".find_by_token" do
  context "when application exists" do
     let!(:application) { create(:application) }
      it "returns the application" do
   token = application.token

   result = described_class.find_by_token(token)
        expect(result.success?).to be true
        expect(result.data).to eq(application)
      end
    end

    context "when application does not exist" do
      it "returns an error ServiceResponse" do
        result = described_class.find_by_token("invalid_token")

        expect(result.success?).to be false
        expect(result.error).to eq("Application not found")
      end
    end
  end
  context "when an exception occurs" do
    before do
      allow(Application).to receive_message_chain(:includes, :find_by).and_raise(StandardError.new("DB error"))
    end

    it "returns an error ServiceResponse" do
      result = described_class.find_by_token("invalid_token")

      expect(result.success?).to be false
      expect(result.error).to eq("DB error")
    end
  end
end
