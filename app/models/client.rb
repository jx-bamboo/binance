class Client < ApplicationRecord
    belongs_to :user
    validates :name, :platform, :public_key, :secret_key,  presence: true
end
