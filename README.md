# Ready App Venue

IBM Ready App for Venue demonstrates a personalized and social experience within the fictional theme park - Brickland. At Brickland, visitors use their mobile app to discover what is near them, find their way to their favorite attractions, keep in touch with their group, and achieve badges based on their activity.

## Project Structure 

* `/iOS`        directory for the iOS client.
* `/companion-iPad` directory for the companion application.
* `/nodejs`     directory for the nodeJS server that receives calls from MFP.
* `/venue-mfpf` directory for the MFP server. This server is a gate keeper that passes iOS request to NodeJS through the following process:
  1. Receives request from iOS and might perfom some authorization logic through the MFP framework.
  2. Sends an internal request to the NodeJS server.
  3. Receives the response from NodeJS might apply some transformation and then sends it a response to iOS.
* `/scripts`    directory for useful scripts for the project like building and running the server components in development computer.