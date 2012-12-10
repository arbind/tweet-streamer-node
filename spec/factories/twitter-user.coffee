chai.factory 'twitter-user',
  id: 0
  name: 'John Doe'
  screen_name: 'john+doe'
  description: 'Streamer Account of John Doe'
  profile_image_url: "http://mysite.com/myimage"
  location: 'NY,NY'
  lang: 'en'
  followers_count: 30
  friends_count: 400
  utc_offset: -21600
  time_zone: 'Central Time (US & Canada)'

class TwitterUserFactory
  @uid: 100

  @make: (overrides={})->
    atts = @newAtts()
    atts.inject overrides
    hash = chai.create 'twitter-user', atts

  @newAtts: ()->
    id = @uid++
    name = Charlatan.Name.name()
    uname = Charlatan.Internet.userName()
    city = Charlatan.Address.city()
    st = Charlatan.Address.state(1)
    atts = 
      id: id
      name: name
      screen_name: uname
      profile_image_url: Charlatan.Internet.domainName()
      description: "Streamer Account for #{name}"
      location: "#{city}, #{st}"
      lang: 'en'
      followers_count: Charlatan.Helpers.rand(3, 20)
      friends_count: Charlatan.Helpers.rand(200, 1000)

TwitterUser::TESTDATA = TwitterUserFactory