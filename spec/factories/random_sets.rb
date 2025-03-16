# frozen_string_literal: true

FactoryBot.define do
  factory :random_set do
    name { "Test_Random_Set" }
    password { "test" }
    pick_type { "mix" }
    rate { [
      { reality: 0, value: 80 },
      { reality: 1, value: 10 },
      { reality: 2, value: 5 }
    ] }
    pickup_rate { [
      { reality: 0, value: 50 }
    ] }
    pickup_type { "pre" }
  end
end
