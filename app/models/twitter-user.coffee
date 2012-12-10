class TwitterUser extends ModelBase
  @extend  RedisORM
  classFieldNames:  [ 'id'
                    , 'screen_name'
                    , 'profile_image_url'
                    # , 'name'
                    # , 'oauth_access'
                    # , 'description'
                    # , 'location'
                    # , 'lang'
                    # , 'followers_count'
                    # , 'friends_count'
                    # , 'time_zone'
                    # , 'utc_offset'
                    ]

  # convenient accessors
  screenName:       ()=> (@get 'screen_name')
  profileImageURL:  ()-> (@get 'profile_image_url')

  # optional attributes: removed to trim DB size
  # name:             ()=> (@get 'name')
  # location:         ()=> (@get 'location')
  # description:      ()=> (@get 'description')
  # followersCount:   ()=> (@get 'followers_count')
  # friendsCount:     ()=> (@get 'friends_count')
  # timeZone:         ()=> (@get 'time_zone')
  # utcOffset:        ()=> (@get 'utc_offset')
  # language:         ()=> (@get 'lang')

  @modelIDFor: (id)-> (parseInt id.toString(), 10)

module.exports = TwitterUser