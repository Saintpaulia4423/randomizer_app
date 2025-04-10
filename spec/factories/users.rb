# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:user_id) { |n| "user#{n}" }
    password { "default_password" }
  end
end
