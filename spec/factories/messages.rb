FactoryBot.define do
  factory :message do
    number { rand(1..1000) }
    association :chat
    text { "Sample message text" }
  end
end
