class Chat < ApplicationRecord
  has_many :messages
  belongs_to :application
     validates :number, presence: true
     validates :application_token, presence: true
end
