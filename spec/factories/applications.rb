# spec/factories/applications.rb
FactoryBot.define do
  factory :application do
    token { SecureRandom.uuid }   # must be unique, not nil or blank
    name { "Test Application" }
  end
end
