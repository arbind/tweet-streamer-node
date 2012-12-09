chai.factory 'streamer',
  id: 0
  name: 'John Doe'
  screen_name: 'john+doe'
  description: 'Streamer Account of John Doe'
  location: 'NY,NY'
  oauth_access:
    token: 1
    secret: 2
  lang: 'en'
  followers_count: 30
  friends_count: 400
  utc_offset: -21600
  time_zone: 'Central Time (US & Canada)'

global.StreamerFactory = class StreamerFactory
  @uid: 100
  
  @make: (options)->
    atts = @newAtts()
    atts.inject options if isPresent(options)
    chai.create 'streamer', atts

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
      description: "Streamer Account for #{name}"
      location: "#{city}, #{st}"
      oauth_access:
        token: Charlatan.PhoneNumber.phoneNumber()
        secret: Charlatan.PhoneNumber.phoneNumber()
      lang: 'en'
      followers_count: Charlatan.Helpers.rand(3, 20)
      friends_count: Charlatan.Helpers.rand(200, 1000)
