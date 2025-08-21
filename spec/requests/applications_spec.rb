# spec/requests/applications_spec.rb
require "rails_helper"

RSpec.describe "Applications API", type: :request do
  # before(:each) { host! "www.example.com" }
  describe "GET /applications" do
    context "when applications exist" do
      let!(:app1) { create(:application, name: "App One") }
      let!(:app2) { create(:application, name: "App Two") }

      it "returns all applications" do
        get "/applications"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.size).to eq(2)
        expect(json.map { |a| a["name"] }).to contain_exactly("App One", "App Two")
      end
    end

    context "when no applications exist" do
      it "returns an empty array" do
        get "/applications"

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq([])
      end
    end

    context "when an error occurs" do
      before do
        allow(ApplicationServices).to receive(:find).and_return(ServiceResponse.error("Unexpected error"))
      end

      it "returns an error response" do
        get "/applications"

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Unexpected error")
      end
    end
  end
  describe "POST /applications" do
    context "with valid parameters" do
      it "creates a new application and returns sanitized data" do
        # post "/applications", params: { application: { name: "Test App" } }
        expect {
          post "/applications", params: { application: { name: "Test App" } }
        }.to change(Application, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["name"]).to eq("Test App")
        expect(json).to have_key("token")
        expect(json).to have_key("chats")
        expect(json).not_to have_key("id")
      end
    end

    context "when name is blank" do
      it "returns a bad request error" do
        post "/applications", params: { application: { name: "" } }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Name is required")
      end
    end

    context "when name param is missing completely" do
      it "returns a bad request error" do
        post "/applications", params: {}

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Name is required")
      end
    end

    context "when ApplicationServices.create fails" do
      it "returns a bad request error" do
        # Stub the service method to return an error response
        allow(ApplicationServices).to receive(:create)
          .and_return(ServiceResponse.error("Validation failed"))

        post "/applications", params: { application: { name: "Invalid App" } }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Validation failed")
      end
    end

    context "when an unexpected error occurs" do
      it "returns internal server error" do
        # Stub the service method to raise an unexpected error
        allow(ApplicationServices).to receive(:create)
          .and_return(ServiceResponse.error("Unexpected error"))

        post "/applications", params: { application: { name: "Crash App" } }


        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Unexpected error")
      end
    end
  end

  describe "GET /applications/:token" do
    let!(:application) { create(:application, name: "Test App") }
    let!(:token) { application.token }

    context "when application exists" do
      it "returns the application data" do
        get "/applications/#{token}"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["name"]).to eq("Test App")
        expect(json).to have_key("token")
        expect(json).to have_key("chats")
      end
    end

    context "when application does not exist" do
      it "returns a not found error" do
        get "/applications/invalid_token"

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Application not found")
      end
    end

    context "when an error occurs" do
      before do
        allow(ApplicationServices).to receive(:find_by_token).and_return(ServiceResponse.error("Unexpected error"))
      end

      it "returns an error response" do
        get "/applications/#{token}"
        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Unexpected error")
      end
    end
    # context "when application token is missing" do
    #   it "returns a bad request error" do
    #     get "/applications/"

    #     expect(response).to have_http_status(:bad_request)
    #     json = JSON.parse(response.body)
    #     expect(json["error"]).to eq("Token is required")
    #   end
    # end
  end
end
