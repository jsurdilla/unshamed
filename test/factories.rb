FactoryGirl.define do

  factory :user do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    email      { "#{first_name}.#{last_name}@example.com".downcase }
    uid        { email }
    provider   'email'
    password   'password'
  end

  factory :member_profile do
    user

    trait(:anxiety) { struggles ['anxiety'] }
    trait(:depression) { struggles ['depression'] }
    trait(:ocd) { struggles ['ocd'] }
  end

  factory :post do
    body { Faker::Lorem.paragraph }
    user
  end

  factory :journal_entry do
    title { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }
    user
    public false

    trait(:public) { public true }
  end

  factory :anxiety, class: Struggle do
    id 'anxiety'
    friendly_text 'Anxiety'
  end
end
