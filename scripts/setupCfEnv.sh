cf set-env "Ready App Venue" RETHINKDB_HOST aws-us-east-1-portal.6.dblayer.com
cf set-env "Ready App Venue" RETHINKDB_PORT 10576
cf set-env "Ready App Venue" RETHINKDB_REMOTE_HOST 10.46.48.2
cf set-env "Ready App Venue" RETHINKDB_REMOTE_PORT 28015
cf set-env "Ready App Venue" RETHINKDB_LOCAL_HOST 127.0.0.2
cf set-env "Ready App Venue" RETHINKDB_LOCAL_PORT 28015
cf set-env "Ready App Venue" RETHINKDB_DB_NAME ra_venue
cf set-env "Ready App Venue" RETHINKDB_USER compose
cf set-env "Ready App Venue" NODE_ENV dev
cf set-env "Ready App Venue" RETHINKDB_AUTH_KEY UPDATE_THIS_VALUE
cf set-env "Ready App Venue" GAME_PLAN UPDATE_THIS_VALUE
cf set-env "Ready App Venue" GAME_KEY UPDATE_THIS_VALUE
cf restage "Ready App Venue"