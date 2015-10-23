# Venue MFP Adapters
- - -

* **poisAdapter**
    * getAllPOIs()
    * getAllPOIsForAPark()
    * insertPOI(poi)
* **usersAdapter**
    * getAllUsers()
    * getGroup(groupId)
    * getUser(userId)
    * insertUser(user)
* **demoAdapter**
    * clearGameplan()
    * deleteGamePlayers(players)
    * getBlobsAndMatches()
    * getCurrentGamePlan(planName, key) 
    * insertBlob(appVersion, revision, blob)
    * setupGameplan()
    * setupGamePlayers()    
    * updateCheck(appVersion, revision)
* **gamificationAdapter**
    * addPlayerToGroup(groupId, playerId)
    * deletePlayer(playerId)
    * fireEvent(badgeName, playerId)
    * getBadge(badgeName)
    * getBadges()
    * getGroup(groupId)
    * getGroupLeaderboard(groupId)
    * getPlayer(playerId)
    * getPlayerBadges(playerId)
    * insertPlayer(player)
    
- - -
# poisAdapter

### getAllPOIs()   
returns all the POIs in the database 

*returns*

```
[
    {
        "id": "asffbevwvbeGEfs",
        "parkId": "Brickland",
        "name": "Tejas Twister",
        "coordinate_x": 5,
        "coordinate_y": 19,
        "types":  ["ride", "family friendly"],
        "subtitle": "Thrill Level",
        "height_requirement": 42,
        "description": "the best in the park",
        "details" : ["closed captions availible", "accessible"],
        "thumbnail_url":"www.img.url.com/rideThumbnail",
        "picture_url": "www.img.url.com/ridePic"
    },
    {
        "id": "asffbevwasd",
        "parkId": "Brickland",
        "name": "Cactus Canyon",
        "coordinate_x": 5,
        "coordinate_y": 19,
        "types":  ["ride", "family friendly"],
        "subtitle": "Thrill Level",
        "height_requirement": 42,
        "description": "the best in the park",
        "details" : ["closed captions availible", "accessible"],
        "thumbnail_url":"www.img.url.com/rideThumbnail",
        "picture_url": "www.img.url.com/ridePic"
    },
    {
        "id": "AbdsfbrFwcasac",
        "parkId": "ThePark",
        "name": "The Ride",
        "coordinate_x": 5,
        "coordinate_y": 19,
        "types":  ["ride", "family friendly"],
        "subtitle": "Thrill Level",
        "height_requirement": 42,
        "description": "the best in the park",
        "details" : ["closed captions availible", "accessible"],
        "thumbnail_url":"www.img.url.com/rideThumbnail",
        "picture_url": "www.img.url.com/ridePic"
    }
]
```

### getAllPOIsForAPark(parkId)
returns all the POIs for a given parkId. 

 *expects*  
 
* parkId: as a string

*returns*

```
[
    {
        "id": "asffbevwvbeGEfs",
        "parkId": "Brickland",
        "name": "Tejas Twister",
        "coordinate_x": 5,
        "coordinate_y": 19,
        "types":  ["ride", "family friendly"],
        "subtitle": "Thrill Level",
        "height_requirement": 42,
        "description": "the best in the park",
        "details" : ["closed captions availible", "accessible"],
        "thumbnail_url":"www.img.url.com/rideThumbnail",
        "picture_url": "www.img.url.com/ridePic"
    },
    {
        "id": "asffbevwasd",
        "parkId": "Brickland",
        "name": "Cactus Canyon",
        "coordinate_x": 5,
        "coordinate_y": 19,
        "types":  ["ride", "family friendly"],
        "subtitle": "Thrill Level",
        "height_requirement": 42,
        "description": "the best in the park",
        "details" : ["closed captions availible", "accessible"],
        "thumbnail_url":"www.img.url.com/rideThumbnail",
        "picture_url": "www.img.url.com/ridePic"
    }
]
```

### insertPOI(poi) 
Creates a POI record on the app's database.
 
 *expects*  
 
* poi: as a JSON of the form

```
{
    "parkId": "Brickland",
    "name": "Tejas Twister",
    "coordinate_x": 5,
    "coordinate_y": 19,
    "types":  ["ride", "family friendly"],
    "subtitle": "Thrill Level",
    "height_requirement": 42,
    "description": "the best in the park",
    "details" : ["closed captions availible", "accessible"],
    "thumbnail_url":"www.img.url.com/rideThumbnail",
    "picture_url": "www.img.url.com/ridePic"
}
```

*returns*

```
{
    "id": "asffbevwvbeGEfs",
    "parkId": "Brickland",
    "name": "Tejas Twister",
    "coordinate_x": 5,
    "coordinate_y": 19,
    "types":  ["ride", "family friendly"],
    "subtitle": "Thrill Level",
    "height_requirement": 42,
    "description": "the best in the park",
    "details" : ["closed captions availible", "accessible"],
    "thumbnail_url":"www.img.url.com/rideThumbnail",
    "picture_url": "www.img.url.com/ridePic"
}
```
   
# usersAdapter

### getAllUsers()  
Retrieves all the users in the database

*returns*

```
[
    { 
        "id": "19",    
        "groupId": "501", 
        "first_name": "Rex",
        "last_name": "Rodriguez"
        "pictureUrl": "www.img.url.com/profilePic",
        "phone_number": "(555) 555-5555",
        "email": "email@domain.co",
        "totalPoints": 50,
        "achievements": [ 
            {
                "id": "familyFun",
                "description": "",
                "name": "Family Fun",
                "thumbnail_url": "",
                "steps": [
                    {
                        "name": "brickBlaster",
                        "reqCount": 1,
                        "playerCount": 1
                    },
                    {
                        "name": "dustyTrail",
                        "reqCount": 1,
                        "playerCount": 1
                    },
                    {
                        "name": "alpineAdventure",
                        "reqCount": 1,
                        "playerCount": 2
                    }
                ],
                "points": 50,
                "isEarned": true
            },
            {
                "id": "rideChampion",
                "description": "",
                "name": "Ride Champion",
                "thumbnail_url": "",
                "steps": [
                    {
                        "name": "rideCompleted",
                        "reqCount": 5,
                        "playerCount": 0
                    }
                ],
                "points": 100,
                "isEarned": false
            }  
        ],
        "favorites":  [ "POIid1", "POIid2" ]
        "notifications_recieved":  [ "noficationId1", "noficationId2" ]
    },
    { 
        "id": "5",    
        "groupId": "501", 
        "first_name": "Fives",
        "last_name": "Fernandez"
        "pictureUrl": "www.img.url.com/profilePic",
        "phone_number": "(555) 555-5555",
        "email": "email@domain.co",
        "totalPoints": 100,
        "achievements": [ 
            {
                "id": "familyFun",
                "description": "",
                "name": "Family Fun",
                "thumbnail_url": "",
                "steps": [
                    {
                        "name": "brickBlaster",
                        "reqCount": 1,
                        "playerCount": 1
                    },
                    {
                        "name": "dustyTrail",
                        "reqCount": 1,
                        "playerCount": 
                    },
                    {
                        "name": "alpineAdventure",
                        "reqCount": 1,
                        "playerCount": 0
                    }
                ],
                "points": 50,
                "isEarned": false
            },
            {
                "id": "rideChampion",
                "description": "",
                "name": "Ride Champion",
                "thumbnail_url": "",
                "steps": [
                    {
                        "name": "rideCompleted",
                        "reqCount": 5,
                        "playerCount": 6
                    }
                ],
                "points": 100,
                "isEarned": true
            }  
        ],
        "favorites":  [ "POIid1", "POIid2" ]
        "notifications_recieved":  [ "noficationId1", "noficationId2" ]
    },
    { 
        "id": "5",    
        "groupId": "9001", 
        "first_name": "Joe",
        "last_name": "Cut"
        "pictureUrl": "www.img.url.com/profilePic",
        "phone_number": "(555) 555-5555",
        "email": "email@domain.co",
        "totalPoints": 0,
        "achievements": [ 
            {
                "id": "familyFun",
                "description": "",
                "name": "Family Fun",
                "thumbnail_url": "",
                "steps": [
                    {
                        "name": "brickBlaster",
                        "reqCount": 1,
                        "playerCount": 1
                    },
                    {
                        "name": "dustyTrail",
                        "reqCount": 1,
                        "playerCount": 
                    },
                    {
                        "name": "alpineAdventure",
                        "reqCount": 1,
                        "playerCount": 0
                    }
                ],
                "points": 50,
                "isEarned": false
            },
            {
                "id": "rideChampion",
                "description": "",
                "name": "Ride Champion",
                "thumbnail_url": "",
                "steps": [
                    {
                        "name": "rideCompleted",
                        "reqCount": 5,
                        "playerCount": 0
                    }
                ],
                "points": 100,
                "isEarned": false
            }  
        ],
        "favorites":  [ "POIid1", "POIid2" ]
        "notifications_recieved":  [ "noficationId1", "noficationId2" ]
    }
]
```

### getGroup(groupId)  
Retrieves all the users in given group

 *expects*  
 
* groupId as a String

*returns*

```
[
    { 
        "id": "19",    
        "groupId": "501", 
        "first_name": "Rex",
        "last_name": "Rodriguez"
        "pictureUrl": "www.img.url.com/profilePic",
        "phone_number": "(555) 555-5555",
        "email": "email@domain.co",
        "totalPoints": 50,
        "achievements": [ 
            {
                "id": "familyFun",
                "description": "",
                "name": "Family Fun",
                "thumbnail_url": "",
                "steps": [
                    {
                        "name": "brickBlaster",
                        "reqCount": 1,
                        "playerCount": 1
                    },
                    {
                        "name": "dustyTrail",
                        "reqCount": 1,
                        "playerCount": 1
                    },
                    {
                        "name": "alpineAdventure",
                        "reqCount": 1,
                        "playerCount": 2
                    }
                ],
                "points": 50,
                "isEarned": true
            },
            {
                "id": "rideChampion",
                "description": "",
                "name": "Ride Champion",
                "thumbnail_url": "",
                "steps": [
                    {
                        "name": "rideCompleted",
                        "reqCount": 5,
                        "playerCount": 0
                    }
                ],
                "points": 100,
                "isEarned": false
            }  
        ],
        "favorites":  [ "POIid1", "POIid2" ]
        "notifications_recieved":  [ "noficationId1", "noficationId2" ]
    },
    { 
        "id": "5",    
        "groupId": "501", 
        "first_name": "Fives",
        "last_name": "Fernandez"
        "pictureUrl": "www.img.url.com/profilePic",
        "phone_number": "(555) 555-5555",
        "email": "email@domain.co",
        "totalPoints": 100,
        "achievements": [ 
            {
                "id": "familyFun",
                "description": "",
                "name": "Family Fun",
                "thumbnail_url": "",
                "steps": [
                    {
                        "name": "brickBlaster",
                        "reqCount": 1,
                        "playerCount": 1
                    },
                    {
                        "name": "dustyTrail",
                        "reqCount": 1,
                        "playerCount": 
                    },
                    {
                        "name": "alpineAdventure",
                        "reqCount": 1,
                        "playerCount": 0
                    }
                ],
                "points": 50,
                "isEarned": false
            },
            {
                "id": "rideChampion",
                "description": "",
                "name": "Ride Champion",
                "thumbnail_url": "",
                "steps": [
                    {
                        "name": "rideCompleted",
                        "reqCount": 5,
                        "playerCount": 6
                    }
                ],
                "points": 100,
                "isEarned": true
            }  
        ],
        "favorites":  [ "POIid1", "POIid2" ]
        "notifications_recieved":  [ "noficationId1", "noficationId2" ]
    }
]
```

### getUser(userId)  
expects a user id and returns the user entry that matches the given id.

 *expects*  
 
* userId as a String

*returns*

```
{ 
    "id": "19",    
    "groupId": "501", 
    "first_name": "Rex",
    "last_name": "Rodriguez"
    "pictureUrl": "www.img.url.com/profilePic",
    "phone_number": "(555) 555-5555",
    "email": "email@domain.co",
    "totalPoints": 9001,
    "achievements": [ 
        {
            "id": "familyFun",
            "description": "",
            "name": "Family Fun",
            "thumbnail_url": "",
            "steps": [
                {
                    "name": "brickBlaster",
                    "reqCount": 1,
                    "playerCount": 1
                },
                {
                    "name": "dustyTrail",
                    "reqCount": 1,
                    "playerCount": 1
                },
                {
                    "name": "alpineAdventure",
                    "reqCount": 1,
                    "playerCount": 2
                }
            ],
            "points": 50,
            "isEarned": true
        },
        {
            "id": "rideChampion",
            "description": "",
            "name": "Ride Champion",
            "thumbnail_url": "",
            "steps": [
                {
                    "name": "rideCompleted",
                    "reqCount": 5,
                    "playerCount": 0
                }
            ],
            "points": 100,
            "isEarned": false
        }  
    ],
    "favorites":  [ "POIid1", "POIid2" ]
    "notifications_recieved":  [ "noficationId1", "noficationId2" ]
}
```

### insertUser(user)
Creates a user record on the app's database as well as a player record in the Gamification service to match the created user record.

 *expects*  
 
* player: as a JSON of the form

```
{ 
    "groupId": "501", 
    "first_name": "Rex",
    "last_name": "Rodriguez"
    "pictureUrl": "www.img.url.com/profilePic",
    "phone_number": "(555) 555-5555",
    "email": "email@domain.co",
    "totalPoints": 9001,
    "achievements": [],
    "favorites":  []
    "notifications_recieved":  []
}
```

*returns*

```
{ 
    "id": "19",
    "groupId": "501", 
    "first_name": "Rex",
    "last_name": "Rodriguez"
    "pictureUrl": "www.img.url.com/profilePic",
    "phone_number": "(555) 555-5555",
    "email": "email@domain.co",
    "totalPoints": 9001,
    "achievements": [],
    "favorites":  []
    "notifications_recieved":  []
}
```

## demoAdapter

### clearPlan(plan, key)
Clears a plan **that must have been created on the UI of the Gamification Service**. By programmatically removing the specified game plan components. 

*expects*

* plan: a JSON describing the name of the plan and the names of the components to be removed.

```
{
    "name": "The Best Plan Ever!",
    "deeds": [
        { "name": 'rideChampion'},
        { "name": 'selfieSultan'}
    ],
    "events": [
        { "name": 'rideCompleted' },
        { "name": 'pictureShared' }
    ],
    "missions": [
        { "name": 'rideChampionMission' },
        { "name": 'selfieSultanMission' }
    ],
    "variables": [
        { "name": 'xp' },
        { "name": 'cash' }
    ]
}
```

* key: the key of the plan created on the gamification service as a string.


*returns*
A JSON with the names of the components that were successfully removed.

```
{
    "data": {
        "deeds": [
            'rideChampion',
            'selfieSultan'
        ],
        "events": [
            'rideCompleted',
            'pictureShared'
        ],
        "missions": [
            'rideChampionMission',
            'selfieSultanMission'
        ],
        "variables": [
            'xp',
            'cash'
        ]
    }
}
```

### deleteGamePlayers(players)
Delete a collection of players and group from the Gamification Service.

*expects*

* players: an array of JSONs of the form. `{"id": "Player10", "groupId": "Group7" }`. The is _id_ is required but the _groupId_ is optional. Note all the group that match any groupId in the player JSONs will be deleted.

*returns*

```
{
    "data": { 
        "players": [ "player1", "player7", "player3" ], 
        "groups": [ "group6", "group13"] 
    }
}
```

### getBlobsAndMatches()
Fetches the History of all the blobs that have been stored and which is the latest revision for each app version.

*returns*

```
{
    "data": {
        "appVersionMatches": [
            {
                "appVersion": "0.3",
                "id": "ef9c2204-7c68-4576-8e4f-6569f4f886cb",
                "revision": 1,
                "revisionId": "fc41ecd9-a5f4-4813-ae62-d8d596a89045"
            },
            {
                "appVersion": "0.0.1",
                "id": "53d53f24-a7e2-4520-b750-90036e983175",
                "revision": 1,
                "revisionId": "b7da4536-076b-4159-9ff4-24c687ad4dfd"
            },
            ...
        ],
        "blobs": [
            {
                "id": "fc41ecd9-a5f4-4813-ae62-d8d596a89045",
                "dataAttr" : "x"
            },
            {
                "id": "b7da4536-076b-4159-9ff4-24c687ad4dfd",
                "dataAttr" : "z"
            },
            ...
        ]
}
```
### setupGamePlan(plan, key)
Populates a plan **that must have been created on the UI of the Gamification Service**. By programmatically creating the specified game plan components. 

*expects*

* plan: a JSON with the data for the components of the game plan. See an example of this [here](https://hub.jazz.net/project/milbuild/Ready%20App%20Venue/overview#https://hub.jazz.net/git/milbuild%252FReady.App.Venue/contents/develop/nodejs/test/unit/demo/data/gameplan.js). For more info about this data check the [documention for the Gamification Service](http://gs.ng.bluemix.net/index.html#GamePlan).
* key: the key of the plan on the gamification service as a string.


*returns*
A JSON with the names of the components that were successfully created.

```
{
    deeds: [
        'rideChampion',
        'selfieSultan'
    ],
    events: [
        'rideCompleted',
        'pictureShared'
    ],
    missions: [
        'rideChampionMission',
        'selfieSultanMission'
    ],
    variables: [
        'xp',
        'cash'
    ]
}
```

### getCurrentGamePlan(planName, key)
Get the current Game plan setup in the Gamification Service.

*expects*  

* planName: the name of the plan as shown on the gamification service as a string.
* key: the key of the plan as shown on the gamification service as a string.

*returns*  
A JSON with the data for the components of the game plan. See an example of this [here](https://hub.jazz.net/project/milbuild/Ready%20App%20Venue/overview#https://hub.jazz.net/git/milbuild%252FReady.App.Venue/contents/develop/nodejs/test/unit/demo/data/gameplan.js). For more info about this data check the [documention for the Gamification Service](http://gs.ng.bluemix.net/index.html#GamePlan).

### insertBlob(appVersion, revision, blob)
Saves a blob revision to Venue's database.

*expects*  

* appVersion: the app version as a String. Example: "1.0.12"
* revision: the revision of the data blob as a number.
* blob: a JSON with all the desired demo data.

*returns*  
A JSON with a data attribute that contains the blob JSON passed in with an additional attribute _id_ which is the database entry id.


### setupGameplan(gameplanData)
Creates the specified game plan componenets in a game plan from the Gamification Service.

*expects*  

* gameplanData: a JSON like the one in Venue's [test data](https://hub.jazz.net/project/milbuild/Ready%20App%20Venue/overview#https://hub.jazz.net/git/milbuild%252FReady.App.Venue/contents/master/nodejs/test/unit/demo/data/gameplan.js).

*returns*  
```
{ 
    "data": {
        deeds: [ 'rideChampion', 'selfieSultan' ], 
        events: [ 'rideCompleted', 'pictureShared' ], 
        missions: [ 'rideChampionMission', 'selfieSultanMission' ], 
        variables: [ 'xp', 'cash' ] 
    }
}
```
### setupGamePlayers(playersData) 
Creates the specified players and groups in the Gamification Service.

*expects*  

* playersData: an array with players to be created where each entry is of the form `{ "id": "PLAYER_ID", "name": "MIL_USER", "group": "GROUP_ID" }`

*returns*  

```
{
    "data": {
        "users": []
        "groups": []
}
```

The entries of the _users_ and _groups_ arrays will be JSON with the user's data as described in the [Gamification Service Docs](http://gs.ng.bluemix.net/index.html#User).

### updateCheck(appVersion, revision)
Check if the revision passed in is the latests revision for the appVersion. If is not up to date it will return the latest blob.

*expects*  

* appVersion: the app version as a String. Example: "1.0.12"
* revision: the revision of the data blob as a number.

*returns*  
```
{
    "data": {
        "isUpToDate": false,
        "blob": {
            "dataAttr" : "z",
            "revision": 5
        }
    }
}
```

## gamificationAdapter

### addPlayerToGroup(groupId, playerId)
"Adds a player to a group" by making the player entry in the Gamification Service that matches the _playerId_ follow a player entry that matches the _groupId_. If no player entry in the Gamification Service match the _groupId_ then an entry will be created.

*expects*

* groupId as a String
* playerId as a String

*returns*

```
{
    "data": {
        "user": "SUPER_USER",
        "group": "rootedDeviceTeam"
    }
}
```

### deletePlayer(playerId)
 delete an specific player entry in the Gamification Service for the app. 

*expects*  

* playerId as a String

*returns*  

```
{ 
    data: { "id": playerId} 
}
```
### fireEvent(eventName, playerId)
fire an specific event for an specific user

*expects*  

* eventName as a String
* playerId as a String

*returns*  

```
{ 
    data: { "event": "evenName", "for": "userId5" }.
}
```

###getBadge(badgeName)
fetches badge/achievement that matches the given _badgeName_

*expects*

* badgeName as a String (This matches the path name of the deed on the Gamification Service)

*returns*

```
{
    "data": {
        "id": "familyFun",
        "description": "",
        "name": "Family Fun",
        "thumbnail_url": "",
        "steps": [
            {
                "name": "brickBlaster",
                "reqCount": 1
            },
            {
                "name": "dustyTrail",
                "reqCount": 1
            },
            {
                "name": "alpineAdventure",
                "reqCount": 1
            }
        ],
        points: 50
    }
}
```

###getBadges()
fetches all the badges in the gamification service for Venue

*returns*

```
{
    "data": [
        {
            "id": "familyFun",
            "description": "",
            "name": "Family Fun",
            "thumbnail_url": "",
            "steps": [
                {
                    "name": "brickBlaster",
                    "reqCount": 1
                },
                {
                    "name": "dustyTrail",
                    "reqCount": 1
                },
                {
                    "name": "alpineAdventure",
                    "reqCount": 1
                }
            ],
            "points": 50
        },
        {
            "id": "rideChampion",
            "description": "",
            "name": "Ride Champion",
            "thumbnail_url": "",
            "steps": [
                {
                    "name": "rideCompleted",
                    "reqCount": 5
                }
            ],
            "points": 100
        },
        {
            "id": "selfieSultan",
            "description": "",
            "name": "Selfie Sultan",
            "thumbnail_url": "",
            "steps": [
                {
                    "name": "pictureShared",
                    "reqCount": 3
                }
            ],
            "points": 50
        }
    ]
}
```

### getGroup(groupId)
gets all the players in a group as provided from the gamification service (as followers to the user group).

*expects*

* groupId as a String

*returns*
```
{
    "data": [
        {
            "state": "accepted",
            "follower": {
                "firstName": "Player 1",
                "varValues": {},
                "userDeeds": {},
                "acceptedMissions": {},
                "missions": [],
                "uid": "2",
                "missionStateCount": {},
                "eventCount": {},
                "lastUpdated": "2014-07-01T00:00:00.000+0000",
                "created": null
            },
            "followee": {
                "firstName": "userGroup",
                "varValues": {},
                "userDeeds": {},
                "acceptedMissions": {},
                "missions": [],
                "uid": "0",
                "missionStateCount": {},
                "eventCount": {},
                "lastUpdated": "2014-07-01T00:00:00.000+0000",
                "created": null
            },
            "id": "3b693755-3c5b-4092-8b0d-75bf29f37ef7",
            "lastUpdated": "2015-10-14T18:52:16.180+0000",
            "created": "2015-10-14T18:52:15.732+0000"
        },
        {
            "state": "accepted",
            "follower": {
                "firstName": "Player 2",
                "varValues": {},
                "userDeeds": {},
                "acceptedMissions": {},
                "missions": [],
                "uid": "3",
                "missionStateCount": {},
                "eventCount": {},
                "lastUpdated": "2014-07-01T00:00:00.000+0000",
                "created": null
            },
            "followee": {
                "firstName": "userGroup",
                "varValues": {},
                "userDeeds": {},
                "acceptedMissions": {},
                "missions": [],
                "uid": "0",
                "missionStateCount": {},
                "eventCount": {},
                "lastUpdated": "2014-07-01T00:00:00.000+0000",
                "created": null
            },
            "id": "55d89a99-da8a-4668-8eba-3af7270d0156",
            "lastUpdated": "2015-10-14T18:52:22.966+0000",
            "created": "2015-10-14T18:52:22.617+0000"
        }
    ]
}
```

###getGroupLeaderboard(groupId) 
gets the leaderboard for a given group. The array with the player sorted by points in decresing order.

*expects*

* groupId as a String

*returns*

```
{
    "data": [
        {
            "id": "3",
            "group_id": "100001",
            "name": "Taylor Franklin",
            "total_points": 2881,
            "timeline_achievements": [
                "selfieSultan",
                "rideChampion"
            ]
        },
        {
            "id": "2",
            "group_id": "100001",
            "name": "Daniel Firsht",
            "total_points": 481,
            "timeline_achievements": [
                "rideChampion"
            ]
        },
        {
            "id": "1",
            "group_id": "100001",
            "name": "Hatty Hattington",
            "total_points": 1,
            "timeline_achievements": []
        }
    ]
}
```

### getPlayer(playerId) 
retrieves the Gamification Service player that matches the id provided.

*expects*:  

* playerId as a String

*returns*:  

```
{
    "data": {
        "firstName": "Player name",
        "varValues": {
            "565842e6-8d6d-4645-813b-081461f2b6aa.DevPlan.xp": {
                "userId": "6eef4f5e-772e-4870-ae2e-35a6e74e62e4",
                "varId": "1287cf99-8c99-437f-9625-3abe029f298e",
                "value": 1,
                "level": 1,
                "varLabel": "Experience Point",
                "nextLevel": 2,
                "currentLevelThreshold": 1,
                "nextLevelThreshold": 21,
                "type": "XP",
                "qname": "565842e6-8d6d-4645-813b-081461f2b6aa.DevPlan.xp",
                "userUid": "2",
                "varName": "xp",
                "lastUpdated": "2015-09-18T18:19:11.110+0000",
                "created": "2015-09-18T18:19:02.654+0000"
            },
            "565842e6-8d6d-4645-813b-081461f2b6aa.DevPlan.cash": {
                "userId": "6eef4f5e-772e-4870-ae2e-35a6e74e62e4",
                "varId": "805d167f-1efe-4181-8c51-33e50a929ec8",
                "value": 1,
                "level": 1,
                "varLabel": "Virtual Cash",
                "nextLevel": 2,
                "currentLevelThreshold": 1,
                "nextLevelThreshold": 10001,
                "type": "VC",
                "qname": "565842e6-8d6d-4645-813b-081461f2b6aa.DevPlan.cash",
                "userUid": "2",
                "varName": "cash",
                "lastUpdated": "2015-09-18T18:19:02.658+0000",
                "created": "2015-09-18T18:19:02.658+0000"
            }
        },
        "userDeeds": {},
        "acceptedMissions": {},
        "missions": [],
        "uid": "2",
        "planId": "0edad4b4-f43d-4eee-a6ac-fbf8c7bf91c0",
        "missionStateCount": {},
        "id": "6eef4f5e-772e-4870-ae2e-35a6e74e62e4",
        "lastUpdated": "2015-09-18T18:19:02.607+0000",
        "created": "2015-09-18T18:19:02.607+0000"
    }
}
``` 

###getPlayerBadges(playerId)
retrieves the badges (matching our data model) for the user that match the given player id.

*expects*

* playerId as a String

*returns*

```
{
    "data": [
        {
            "id": "familyFun",
            "description": "",
            "name": "Family Fun",
            "thumbnail_url": "",
            "steps": [
                {
                    "name": "brickBlaster",
                    "reqCount": 1,
                    "playerCount": 1
                },
                {
                    "name": "dustyTrail",
                    "reqCount": 1,
                    "playerCount": 1
                },
                {
                    "name": "alpineAdventure",
                    "reqCount": 1,
                    "playerCount": 2
                }
            ],
            "points": 50,
            "isEarned": true
        },
        {
            "id": "rideChampion",
            "description": "",
            "name": "Ride Champion",
            "thumbnail_url": "",
            "steps": [
                {
                    "name": "rideCompleted",
                    "reqCount": 5,
                    "playerCount": 0
                }
            ],
            "points": 100,
            "isEarned": false
        }  
   ]
}
```

###insertPlayer(player)
 creates a player entry in the Gamification Service for the app. 

 *expects*  
 
* player: `{ "id": "APP_USER_ID", "name": "MIL_USER" }`

*returns*

```
{
    "data": {
        "firstName": "MIL_USER",
        "varValues": {
            "565842e6-8d6d-4645-813b-081461f2b6aa.DevPlan.xp": {
                "userId": "a589a7d7-04ac-4b12-b69a-54bbc084856d",
                "varId": "1287cf99-8c99-437f-9625-3abe029f298e",
                "value": 1,
                "level": 1,
                "varLabel": "Experience Point",
                "nextLevel": 2,
                "currentLevelThreshold": 1,
                "nextLevelThreshold": 21,
                "type": "XP",
                "qname": "565842e6-8d6d-4645-813b-081461f2b6aa.DevPlan.xp",
                "userUid": "APP_USER_ID",
                "varName": "xp",
                "lastUpdated": "2015-09-21T20:38:29.302+0000",
                "created": "2015-09-21T20:38:27.090+0000"
            },
            "565842e6-8d6d-4645-813b-081461f2b6aa.DevPlan.cash": {
                "userId": "a589a7d7-04ac-4b12-b69a-54bbc084856d",
                "varId": "805d167f-1efe-4181-8c51-33e50a929ec8",
                "value": 1,
                "level": 1,
                "varLabel": "Virtual Cash",
                "nextLevel": 2,
                "currentLevelThreshold": 1,
                "nextLevelThreshold": 10001,
                "type": "VC",
                "qname": "565842e6-8d6d-4645-813b-081461f2b6aa.DevPlan.cash",
                "userUid": "APP_USER_ID",
                "varName": "cash",
                "lastUpdated": "2015-09-21T20:38:27.117+0000",
                "created": "2015-09-21T20:38:27.117+0000"
            }
        },
        "userDeeds": {},
        "acceptedMissions": {},
        "missions": [],
        "uid": "APP_USER_ID",
        "planId": "0edad4b4-f43d-4eee-a6ac-fbf8c7bf91c0",
        "missionStateCount": {},
        "id": "a589a7d7-04ac-4b12-b69a-54bbc084856d",
        "lastUpdated": "2015-09-21T20:38:27.015+0000",
        "created": "2015-09-21T20:38:27.015+0000"
    }
}
```