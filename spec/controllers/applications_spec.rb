require 'rails_helper'

RSpec.describe ApplicationsController, type: :controller do
  describe "GET #index" do
    context "when successful" do
      let(:applications) { build_list(:application, 3) }

      before do
        allow(ApplicationServices).to receive(:find).and_return(
          ServiceResponse.success(applications)
        )
        get :index
      end

      it "returns status 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the applications in response body" do
        expect(JSON.parse(response.body).size).to eq(3)
      end
    end

    context "when service returns error" do
      before do
        allow(ApplicationServices).to receive(:find).and_return(
          ServiceResponse.error("Something went wrong")
        )
        get :index
      end

      it "returns 422 status" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns error message" do
        expect(JSON.parse(response.body)["error"]).to eq("Something went wrong")
      end
    end


      before do
    allow(ApplicationServices).to receive(:find).and_return(
      ServiceResponse.success([])
    )
    get :index
  end

  it "returns status 200" do
    expect(response).to have_http_status(:ok)
  end

  it "returns an empty array" do
    expect(JSON.parse(response.body)).to eq([])
  end
  end


  describe "POST #create" do
    context "with valid params" do
      let(:app) { build(:application, name: "My App") }

      before do
        allow(ApplicationServices).to receive(:create).and_return(
          ServiceResponse.success(app)
        )
        post :create, params: { application: { name: "My App" } }
      end

      it "returns status 201" do
        expect(response).to have_http_status(:created)
      end

      it "returns created application name" do
          expect(JSON.parse(response.body)).to include(
          "token" => be_a(String),  # Assuming token is generated and not fixed
          "name" => app.name,
          "chats" => an_instance_of(Array)
        )
      end
    end

    context "with missing name" do
      it "returns bad request" do
        post :create, params: { application: {} } # empty application hash to trigger missing name

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["error"]).to eq("Name is required")
      end
    end

    context "when service fails" do
      before do
        allow(ApplicationServices).to receive(:create).and_return(
          ServiceResponse.error("DB error")
        )
        post :create, params: { application: { name: "Failing App" } }
      end

      it "returns unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to eq("DB error")
      end
    end
  end


  describe "GET #show" do
    context "when successful" do
      let!(:app) { build(:application, token: "06304d02-c4b2-43ed-97a7-5f138ca137e2") }

      before do
        allow(ApplicationServices).to receive(:find_by_token).and_return(
          ServiceResponse.success(app)
        )
        get :show, params: { token: "06304d02-c4b2-43ed-97a7-5f138ca137e2" }
      end

      it "returns status 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns correct token" do
        expect(JSON.parse(response.body)["token"]).to eq("06304d02-c4b2-43ed-97a7-5f138ca137e2")
      end

         it "contains correct attributes" do
        expect(JSON.parse(response.body)).to include(
          "token" => "06304d02-c4b2-43ed-97a7-5f138ca137e2",
          "name" => app.name,
          "chats" => an_instance_of(Array)
        )
      end
    end

    context "with missing token" do
      it "returns bad request" do
        get :show, params: { token: '' }  # Blank token param, to avoid routing error
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["error"]).to eq("token is required")
      end
    end


    before do
    allow(ApplicationServices).to receive(:find_by_token).and_return(
      ServiceResponse.error("Application not found")
    )
    get :show, params: { token: "nonexistent" }
  end

  it "returns 422 unprocessable entity" do
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "returns error message" do
    expect(JSON.parse(response.body)["error"]).to eq("Application not found")
  end
  end
end
