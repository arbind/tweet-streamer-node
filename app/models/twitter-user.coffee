class TwitterUser extends ModelBase
  Service: TwitterUserService
  classFieldNames:  [ 'id'
                    , 'name'
                    , 'screen_name'
                    , 'profile_image_url'
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
  name:             ()=> (@get 'name')
  screenName:       ()=> (@get 'screen_name')
  profileImageURL:  ()-> (@get 'profile_image_url')


  # optional attributes: removed to trim DB size
  # location:         ()=> (@get 'location')
  # description:      ()=> (@get 'description')
  # followersCount:   ()=> (@get 'followers_count')
  # friendsCount:     ()=> (@get 'friends_count')
  # timeZone:         ()=> (@get 'time_zone')
  # utcOffset:        ()=> (@get 'utc_offset')
  # language:         ()=> (@get 'lang')

module.exports = Tweet
