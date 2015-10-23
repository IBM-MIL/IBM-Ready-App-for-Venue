/*
 *  Licensed Materials - Property of IBM
 *  © Copyright IBM Corporation 2015. All Rights Reserved.
 */
'use strict';

module.exports = {
  "key": "bb0f2724-08e5-41de-9139-51ab2b41e1c2",  
  "plan": {
    "label": "DevPlan",
    "description": "",
    "name": "DevPlan",
    "owner": "Jorge",
    "ownerEmail": "jpaez@us.ibm.com",
    "defaultXpVarName": "xp",
    "defaultCashVarName": "cash",
    "phase": "designtime",
    "deeds": [
        {
            "name": "rideChampion",
            "label": "Ride Champion",
            "description": "",
            "type": "badge",
            "criteria": "deeds.rideChampion",
            "accumulative": false,
            "shared": false,
            "imageType": "default",
            "imageBase64": "",
            "imageUrl": ""
        },
        {
            "name": "selfieSultan",
            "label": "Selfie Sultan",
            "description": "",
            "type": "badge",
            "criteria": "deeds.selfieSultan",
            "accumulative": false,
            "shared": false,
            "imageType": "default",
            "imageBase64": "",
            "imageUrl": ""
        },
        {
            "name": "familyFun",
            "label": "Family Fun",
            "description": "",
            "type": "badge",
            "criteria": "deeds.familyFun",
            "accumulative": false,
            "shared": false,
            "imageType": "default",
            "imageBase64": "",
            "imageUrl": ""
        }
    ],
    "events": [
        {
            "name": "rideCompleted",
            "description": "ride completed event desc",
            "impacts": [
                {
                    "target": "vars.xp.value",
                    "formula": "vars.xp.value+8"
                }
            ]
        },
        {
            "name": "pictureShared",
            "description": "Picture Share Event description",
            "impacts": [
                {
                    "target": "vars.xp.value",
                    "formula": "vars.xp.value+8"
                }
            ]
        },
        {
            "name": "alpineAdventure",
            "description": "",
            "impacts": [
                {
                    "target": "vars.xp.value",
                    "formula": "vars.xp.value+1"
                }
            ]
        },
        {
            "name": "brickBlaster",
            "description": "",
            "impacts": [
                {
                    "target": "vars.xp.value",
                    "formula": "vars.xp.value+1"
                }
            ]
        },
        {
            "name": "dustyTrail",
            "description": "",
            "impacts": [
                {
                    "target": "vars.xp.value",
                    "formula": "vars.xp.value+1"
                }
            ]
        }
    ],
    "missions": [
        {
            "name": "rideChampionMission",
            "label": "Ride Champ Mission",
            "description": "",
            "autoAccept": true,
            "timeBounded": false,
            "enabled": true, 
            "goalCriteria": "events.rideCompleted.counts>=5",
            "events": [
                {
                    "name": "completed",
                    "impacts": [
                        {
                          "target": "vars.xp.value",
                          "formula": "vars.xp.value+100"            
                        },
                        {
                            "target": "deeds.rideChampion",
                            "formula": "true"
                        }
                    ]
                }
            ]
        },
        {
            "name": "selfieSultanMission",
            "label": "Selfie Sultan Mission",
            "description": "",
            "autoAccept": true,
            "timeBounded": false,
            "enabled": true, 
            "goalCriteria": "events.pictureShared.counts>=3",
            "events": [
                {
                    "name": "completed",
                    "impacts": [
                        {
                            "target": "deeds.selfieSultan",
                            "formula": "true"
                        },
                        {
                            "target": "vars.xp.value",
                            "formula": "vars.xp.value+50"
                        }       
                    ]
                }
            ]
        },
        {
            "name": "familyFunMission",
            "label": "Family Fun Mission",
            "description": "",
            "autoAccept": true,
            "timeBounded": false,
            "enabled": true, 
            "goalCriteria": "events.brickBlaster.counts>=1&&events.dustyTrail.counts>=1&&events.alpineAdventure.counts>=1",
            "events": [
                {
                    "name": "completed",
                    "impacts": [
                        {
                            "target": "deeds.familyFun",
                            "formula": "true"
                        },
                        {
                            "target": "vars.xp.value",
                            "formula": "vars.xp.value+50"
                        }
                    ]
                }
            ]
        }
    ],
    "variables": [
      {
        "name": "xp",
        "label": "Experience Point",
        "type": "XP",
        "rateBuy": 0,
        "rateSell": 0,
        "initialValue": 1,
        "initialLevel": 1,
        "levelCap": 10,
        "upperLimit": 0,
        "levelingType": "linear",
        "levelingBasePoint": 20,
        "levelingFactor": 1,
        "planId": "fd9dfa8d-e251-478c-9ec1-92de00234b50",
        "qualifiedName": "565842e6-8d6d-4645-813b-081461f2b6aa.ReadyAppVenue.xp",
        "description": "Experience Point",
        "shared": false,
        "defaultVar": false,
        "lowerLimit": 0,
        "id": "87e96288-a694-44b5-8d36-6d346992765f",
        "lastUpdated": "2015-09-08T16:58:53.547+0000",
        "created": "2015-09-08T16:58:53.547+0000"
      },
      {
        "name": "cash",
        "label": "Virtual Cash",
        "type": "VC",
        "rateBuy": 0,
        "rateSell": 0,
        "initialValue": 1,
        "initialLevel": 1,
        "levelCap": 10,
        "upperLimit": 0,
        "levelingType": "linear",
        "levelingBasePoint": 10000,
        "levelingFactor": 1,
        "planId": "fd9dfa8d-e251-478c-9ec1-92de00234b50",
        "qualifiedName": "565842e6-8d6d-4645-813b-081461f2b6aa.ReadyAppVenue.cash",
        "description": "Virtual Cash",
        "shared": false,
        "defaultVar": false,
        "lowerLimit": 0,
        "id": "af88ae3d-8bb3-4e04-bcd2-a66a8cfea003",
        "lastUpdated": "2015-09-08T16:58:53.558+0000",
        "created": "2015-09-08T16:58:53.558+0000"
      }
    ]
  }
};