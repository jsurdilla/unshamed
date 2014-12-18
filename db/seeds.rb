10.times do
  first_name = Faker::Name.first_name.to_s
  last_name = Faker::Name.last_name.to_s

  User.create(
    first_name: first_name,
    last_name:  last_name,
    email:      "#{first_name}.#{last_name}@fakemail.com",
    image:      Faker::Avatar.image("my-own-slug", "60x60"),
    gender:     %w{f m}.sample(),
    provider:   'email',
    uid:        "#{first_name}.#{last_name}@fakemail.com",
    password:   'password',
    onboarded:  true,

    confirmation_sent_at: Time.now,
    confirmed_at:         Time.now
  )
end

10.times do
  Resource.create(
    title: Faker::Lorem.sentence,
    url:   'http://www.google.com'
  )
end

if @allow
  user = User.first
  100.times do
    user.posts.create(body: Faker::Lorem.paragraphs(2).join("\n"))
  end
end

image_urls = [
  "http://i.imgur.com/G0dTCja.png",
  "http://upload.wikimedia.org/wikipedia/en/0/02/Homer_Simpson_2006.png",
  "http://www.landofthebrave.info/images/james-madison.jpg",
  "http://cdn.wegotthiscovered.com/wp-content/uploads/James-Marsden.jpg",
  "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcTVWaI9BqlhoJOUExs-ZUghiNMrCwQwLxgKASvLdcEaBAd8Ju25",
  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ-QqJxNNg93Hr52iWVyLA_WXDyeesQ5igTBEPAhZ0-mHsteLymnQ",
  "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcQ-5EFbH7fQ5s9Q1TGMHYV89Ta_T0kLcy5eoPIa_sxUyiNkxxuClA"
]
