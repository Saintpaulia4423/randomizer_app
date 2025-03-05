# frozen_string_literal: true

FactoryBot.define do
  factory :random_set do
    name { "Test_Random_Set" }
    password { "test" }
    data {
      { 
        type: "mix",
        rate: [
          { reality: 0, value: 80 },
          { reality: 1, value: 10 },
          { reality: 2, value: 5 }
        ],
        pickup: {
          type: "pre",
          gainrate: [
            { reality: 2, value: 50 }
          ],
          valuefix: []
        },
        value: []
      }
    }
  end
end
