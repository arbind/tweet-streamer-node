yelpOauthConfig =
  consumer_key: 'EdtIXf4NMUBXh8XoysxW2Q'
  consumer_secret: 'hMUNaKi1Oa_d7OvlHH0d2_7d7-M'
  token: 'p4KFTaHrRR6oTGNOzGq28G9lrdgssyId'
  token_secret: '8Zvy3k9wMPQflJs7Ztgq9w2uE1c'

global.yelper = YelpService.client(yelpOauthConfig, redis)

exports.biz = (req, res) ->
  sessionId = req.query.sessionId || req.query.sessionid || 'no-session'
  yelpId = req.query.yelpId || req.query.yelpid || req.query.id || null
  if yelpId?
    yelper.bizById sessionId, yelpId, (err, biz)->
      data = {q:'biz', biz: biz}
      res.expose(data, 'appData') # load the data into a javascript var for the client
      res.render "index", title: 'biz', error: err, data: data, req: req, res: res
  else
    res.send "No yelpId given"

exports.multiBiz = (req, res) ->
  sessionId = req.query.sessionId || req.query.sessionid || 'no-session'
  yelpIdList = req.query.yelpIds || req.query.yelpids || req.query.ids || null
  yelpIdList ||= req.query.yelpIdList || req.query.yelpidList || req.query.idList || null
  if yelpIdList?
    yelpIdList = yelpIdList.tokens(',')
    yelper.multiBizByIds sessionId, yelpIdList, (err, bizList)->
      data = {q:'biz', bizList: bizList}
      res.expose(data, 'appData') # load the data into a javascript var for the client
      res.render "index", title: 'biz', error: err, data: data, req: req, res: res
  else
    res.send "No comma separated yelpIdList given"

exports.name = (req, res) ->
  if req.query.name? and req.query.location?
    yelper.bizByName req.query.name, req.query.location, (err, searchResults)-> 
      data = {q:'name', searchResults: searchResults}
      res.expose(data, 'appData') # load the data into a javascript var for the client
      res.render "index", title: 'name', error: err, data: data, req: req, res: res
  else
    res.send "name and location must both be given"

exports.search = (req, res) ->
  ( return exports.name(req, res) ) if req.query.name? and req.query.location?
  term = req.query.term | null
  location = req.query.location || null
  page = req.query.page || 1
  if term? and location?
    yelper.search term, location, page, (err, searchResults)-> 
      data = {q:'search', searchResults: searchResults}
      res.expose(data, 'appData') # load the data into a javascript var for the client
      res.render "index", title: 'search', error: err, data: data, req: req, res: res
  else
    res.send "term and location must both be given"
