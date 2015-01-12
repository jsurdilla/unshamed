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

Resource.create(title: "What is Depression", url: "http://www.nami.org/Template.cfm?Section=depression", struggles: ['depression'], media_type: 'article')
Resource.create(title: "Depression", url: "http://www.helpguide.org/home-pages/depression.htm", struggles: ['depression'], media_type: 'article')
Resource.create(title: "10 Things to Say (and 10 Not to Say) to Someone With Depression", url: "http://www.health.com/health/gallery/0,,20393228,00.html", struggles: ['depression'], media_type: 'article')
Resource.create(title: "Depression", url: "http://kidshealth.org/teen/your_mind/mental_health/depression.html", struggles: ['depression'], media_type: 'article')
Resource.create(title: "Depression and Sleep", url: "http://sleepfoundation.org/sleep-disorders-problems/depression-and-sleep", struggles: ['depression'], media_type: 'article')

Resource.create(title: "10 Signs You May Have OCD", url: "http://www.health.com/health/gallery/0,,20707257,00.html", struggles: ['ocd'], media_type: 'article')
Resource.create(title: "Rewiring the Brain to Treat OCD", url: "http://discovermagazine.com/2013/nov/14-defense-free-will", struggles: ['ocd'], media_type: 'article')
Resource.create(title: "Speak of the Devil", url: "http://www.ocdonline.com/#!speak-of-the-devil/c1mva", struggles: ['ocd'], media_type: 'article')
Resource.create(title: "Strategies for Managing OCD’s Anxious Moments Dance with the Devil", url: "http://www.ocdonline.com/#!managing-ocd/c1qmf", struggles: ['ocd'], media_type: 'article')
Resource.create(title: "OCD Test", url: "http://www.ocdla.com/OCDtest.html", struggles: ['ocd'], media_type: 'article')

Resource.create(title: "12 Signs You May Have an Anxiety Disorder", url: "http://www.health.com/health/gallery/0,,20646990,00.html", struggles: ['anxiety'], media_type: 'article')
Resource.create(title: "Why Teenagers Act Crazy", url: "http://www.nytimes.com/2014/06/29/opinion/sunday/why-teenagers-act-crazy.html?_r=1", struggles: ['anxiety'], media_type: 'article')
Resource.create(title: "What is Anxiety?", url: "http://teenshealth.org/teen/your_mind/mental_health/anxiety.html", struggles: ['anxiety'], media_type: 'article')
Resource.create(title: "7 Things People with Anxiety Want Their Loved Ones to Know", url: "http://hellogiggles.com/7-things-people-anxiety-want-loved-ones-know", struggles: ['anxiety'], media_type: 'article')
Resource.create(title: "Surviving Anxiety", url: "http://www.theatlantic.com/magazine/archive/2014/01/surviving_anxiety/355741/", struggles: ['anxiety'], media_type: 'article')

Resource.create(title: "My Story: Overcoming Depression & Anxiety", url: "https://www.youtube.com/watch?v=1y-L4dsOT9s", struggles: ['anxiety', 'depression'], media_type: 'video')
Resource.create(title: "My Experience with OCD", url: "https://www.youtube.com/watch?v=WCujueljIug", struggles: ['ocd'], media_type: 'video')
