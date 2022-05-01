class Subject < ApplicationRecord
    has_many :answers, dependent: :destroy
    has_many :questions, through: :answers
end
