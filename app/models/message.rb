class Message < ApplicationRecord
  belongs_to :chat
    validates :number, presence: true
    validates :text, presence: true
        include Elasticsearch::Model
  index_name "chat_messages"
  def as_indexed_json(_options = {})
    {
      msg_id: id,
      application_token: chat.application_token,
      chat_number: chat.number,
      msg_number: number,
      text: text
    }
  end
end
