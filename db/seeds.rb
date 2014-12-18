10.times do
  first_name = Faker::Name.first_name.to_s
  last_name = Faker::Name.last_name.to_s

  User.create(
    first_name:      first_name,
    last_name:       last_name,
    email:           "#{first_name}.#{last_name}@fakemail.com",
    profile_picture: Faker::Avatar.image("my-own-slug", "60x60"),
    gender:          %w{f m}.sample(),
    provider:        'email',
    uid:             "#{first_name}.#{last_name}@fakemail.com",
    password:        'password',
    onboarded:       true,

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

# SUPPORTER RESOURCES
Resource.create(title: "Supporting Children’s Mental Health: Tips for Parents and Educators", url: "http://www.nasponline.org/resources/mentalhealth/mhtips.aspx", struggles: ['supporter'], media_type: 'article')
Resource.create(title: "For Parents and Caregivers", url: "http://www.mentalhealth.gov/talk/parents-caregivers/", struggles: ['supporter'], media_type: 'article')
Resource.create(title: "Treatment of Children with Mental Illness", url: "http://www.nimh.nih.gov/health/publications/treatment-of-children-with-mental-illness-fact-sheet/index.shtml", struggles: ['supporter'], media_type: 'article')

Resource.create(title: "How to Deal with a Depressed Spouse", url: "http://www.rd.com/advice/relationships/how-to-cope-with-a-depressed-spouse/", struggles: ['supporter'], media_type: 'article')
Resource.create(title: "Suffering in Silence: When Your Spouse Is Depressed", url: "http://psychcentral.com/lib/suffering-in-silence-when-your-spouse-is-depressed/000334", struggles: ['supporter'], media_type: 'article')
Resource.create(title: "How to Talk to Your Alcoholic Partner", url: "http://psychcentral.com/lib/how-to-talk-to-your-alcoholic-partner/00017547", struggles: ['supporter'], media_type: 'article')
Resource.create(title: "Alcoholic Spouse in Addiction and Recovery", url: "http://alcoholrehab.com/alcoholism/alcoholic-spouse-in-addiction-and-recovery/", struggles: ['supporter'], media_type: 'article')

# ADDICTION
Resource.create(title: "What Is Addiction? What Causes Addiction?", url: "http://www.medicalnewstoday.com/info/addiction/", struggles: ['addiction'], media_type: 'article')
Resource.create(title: "DrugFacts: Understanding Drug Abuse and Addiction", url: "http://www.drugabuse.gov/publications/drugfacts/understanding-drug-abuse-addiction", struggles: ['addiction'], media_type: 'article')
Resource.create(title: "Am I Alcoholic?", url: "https://ncadd.org/learn-about-alcohol/alcohol-abuse-self-test", struggles: ['addiction'], media_type: 'article')

Resource.create(title: "Alcoholism and Alcohol Abuse", url: "http://www.helpguide.org/articles/addiction/alcoholism-and-alcohol-abuse.htm", struggles: ['addiction'], media_type: 'article')
Resource.create(title: "Drug Abuse and Addiction", url: "http://www.helpguide.org/articles/addiction/drug-abuse-and-addiction.htm", struggles: ['addiction'], media_type: 'article')
Resource.create(title: "Treating prescription drug addiction", url: "http://www.drugabuse.gov/publications/research-reports/prescription-drugs/treating-prescription-drug-addiction", struggles: ['addiction'], media_type: 'article')
Resource.create(title: "UNDERSTANDING WHY PAINKILLERS BECOME SO ADDICTIVE", url: "http://www.drugfreeworld.org/drugfacts/painkillers/understanding-why-painkillers-become-so-addictive.html", struggles: ['addiction'], media_type: 'article')

# EATINGDISORDER
Resource.create(title: "What are eating disorders?", url: "http://www.nimh.nih.gov/health/publications/eating-disorders-new-trifold/index.shtml", struggles: ['eatingdisorder'], media_type: 'article')
Resource.create(title: "What is an eating disorder?", url: "http://www.eatingdisorderfoundation.org/EatingDisorders.htm", struggles: ['eatingdisorder'], media_type: 'article')
Resource.create(title: "Eating Disorder Treatment and Recovery", url: "http://www.helpguide.org/articles/eating-disorders/eating-disorder-treatment-and-recovery.htm", struggles: ['eatingdisorder'], media_type: 'article')

Resource.create(title: "Eating Disorders", url: "http://www.apa.org/helpcenter/eating.aspx", struggles: ['eatingdisorder'], media_type: 'article')
Resource.create(title: "Loving Imperfection", url: "http://mccalldempsey.com/", struggles: ['eatingdisorder'], media_type: 'article')
Resource.create(title: "ED Bites", url: "http://edbites.com/", struggles: ['eatingdisorder'], media_type: 'article')


mhp_ids = User.all.select { |u| u.is_mhp? }.map(&:id)

MhpProfile.destroy_all
User.where(id: mhp_ids).destroy_all

experts = YAML.load_file("#{Rails.root}/db/mhps2.yml")
experts.each do |expert|
  email = ('joselito+' + expert['first_name'] + '_' + expert['last_name'] + '@unshamed.com'.downcase).gsub(/\s/, '_').gsub(/\(.+\)/, '').gsub(/_+/, '_')
  user = User.create(
    prefix: expert['prefix'],
    first_name: expert['first_name'],
    last_name: expert['last_name'],
    email: email,
    password: 'password',
    provider: 'email',
    uid: email,
    onboarded: true,
    profile_picture: File.open(Rails.root + 'db/experts/' + expert['pic'])
  )

  mhp_profile = MhpProfile.create(
    user_id: user.id,
    struggles: ['ocd', 'anxiety', 'depression', 'eatingdisorder', 'addiction'],
    qualification: expert['qualification'],
    education: expert['education'],
    about_me: expert['about_me']
  )
end

MhpProfile.all.each { |m| m.struggles = ['anxiety', 'depression', 'ocd', 'supporter', 'eatingdisorder', 'addiction']; m.save }




