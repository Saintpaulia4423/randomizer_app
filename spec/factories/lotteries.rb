# frozen_string_literal: true

FactoryBot.define do
  factory :lottery do

    sequence(:name) { |n| "lot#{n}" }
    reality { 0 }
    origin_id { random_set_id }
    
    trait :with_pickup do
      default_pickup { true }
    end
    trait :with_checked do
      default_check { true }
    end
    trait :with_dict do
      dict { "test_dict" }
    end
  end
end
