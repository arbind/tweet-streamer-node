# A TweetStream Service

### To Start Server:
````
npm install
npm start
````

### To Start Client:
````
browse to [ http://localhost:8888 ]
````

### To Execute Specs:
````
mocha -R spec --compilers cofee:coffee-script spec/*/*/*
````
### &hearts; The MVP #1 (In Progress):
1. &hearts; homepage
  * &hearts; /
  * &hearts; stream new tweets from any tweet streamer
  * &hearts; menu bar: streamers / tweeters / login / logout

1. &hearts; streamers
  * &hearts; /streamers  
  * &hearts; list of all streamers
  * &hearts; add a new streamer (via twitter oauth login)
  * &hearts; load streamer friends as new tweeters

1. &hearts; streamer info
  * &hearts; /streamers/:screen_name
  * &hearts; /streamers/:screen_name/load_tweeter_friends
  * &hearts; list of friends
  * &hearts; list of tweets
  * &hearts; reload load streamer friends as new tweeters
  * &hearts; delete the streamer

1. &#10003; twitter oauth to setup food truck streamers
  * &Xi; /streamer/login ( redirect to /streamer/:streamer_screen_name )
2. &#10003; listen for tweets from thousands of food trucks around the world (save to redis)
  * &Xi; /user/:food_truck_screen_name
  * &Xi; /streamer/:streamer_screen_name
  * &Xi; /tweets/:max
3. &Xi; keeps the 10 most recent tweets in redis (food-truck.ws/:food_truck_screen_name)
4. &Xi; updates food truck crafts in mongodb with recent activity and trusted location / schedule info
5. &Xi; trigger a rank recalculation when a new tweet comes in


### &Xi; MVP #2:
6. &Xi; manual ui to identify tweets that have location / schedule info
7. &Xi; manual ui to highlight trusted location / schedule info in a tweet
8. &Xi; updates food truck crafts in mongodb with trusted location / schedule info
9. &Xi; trigger a rank recalculation when location /schedule info is determined

### &Xi; MVP #3:
10. &Xi; auto identify tweets that have location / schedule info
11. &Xi; auto parse to highlight trusted location / schedule info in a tweet
12. &Xi; manual ui to disambiguate parsed location /schedule info

### &Xi; TO DO
````
+ push this codebase to heroku
+ setup cakefile
+ MVP #1
+ MVP #2
+ MVP #3
````

> **Key**

> &#10003; Complete

> &hearts; In Progres

> &Xi; ToDo
