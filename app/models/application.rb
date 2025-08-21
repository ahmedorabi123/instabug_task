class Application < ApplicationRecord
  has_many :chats
   validates :name, presence: true, uniqueness: true
     validates :token, presence: true
end
