class Question < ApplicationRecord
    has_many :answers, dependent: :destroy
    has_many :subjects, through: :answers
end
