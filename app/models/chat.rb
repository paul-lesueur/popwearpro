class Chat < ApplicationRecord
  belongs_to :deadline
  belongs_to :user
end
