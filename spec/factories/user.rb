FactoryBot.define do
  factory :user do
    username { SecureRandom.hex.to_s }
    password_hash { SecureRandom.hex.to_s }
    name { Faker::Name.name }
    email { Faker::Internet.email }
  end
end
