# spec/factories/chats.rb
FactoryBot.define do
  factory :chat do
    number { rand(1..1000) }  # Random number for chat
    application_token { SecureRandom.uuid }  # must be unique, not nil or blank
    association :application   # automatically sets application and application_id
  end
end
