### Getting the server components to run locally 

1. Download and install [MFP CLI 7.0](http://public.dhe.ibm.com/ibmdl/export/pub/software/products/en/MobileFirstPlatform/mobilefirst_cli_installer_7.0.0.zip)

2. Download and install npm: 
  1. With Homebrew:  
  ```$ brew update
  $ brew upgrade node
  ```
  2. Get the installer from [Node's site](https://nodejs.org/download/)

3. Install [Grunt CLI](http://gruntjs.com/getting-started). `npm install -g grunt-cli`

4. To build the MFP and NodeJS servers run `./buildServer.sh`

5. To start the MFP and NodeJS servers run `./starServer.sh`. Once you see the output below you can run the iOS project from xCode and get responses from the localserver by pointing to http://localhost:10080/