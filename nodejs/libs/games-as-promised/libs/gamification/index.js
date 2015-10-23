/*
* Licensed Materials - Property of IBM
* (C) Copyright IBM Corp. 2014. All Rights Reserved.
* US Government Users Restricted Rights - Use, duplication or
* disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*/

var express = require('express');
var router = express();
var parseUrl = require('url');
var request = require('request');

exports.proxy = function (config) {
  return function (req, res) {
    if (!config.get('planName') || !config.get('key') || !config.get('gamiHost') || typeof config.get('getLoginUid') != 'function') {
      if (config.get('errorHandler') && typeof(config.get('errorHandler')) == 'function') {
        config.get('errorHandler')(res);
      } else {
        res.json(500, {
          error : 'Proxy error !'
        })
      }
    }
    
    //use white url list for access control
    var planName = config.get('planName');
    var validURLWhilteList = {};
    validURLWhilteList['\/service\/plan\/' + config.get('planName') + '\/user\/{uid}\/?']           = 'GET,PUT';//retrieve & update login user's profile
    validURLWhilteList['\/service\/plan\/' + config.get('planName') + '\/user\/{uid}\/defaultTitle/?']    = 'PUT';  //update login user's title
    validURLWhilteList['\/service\/plan\/' + config.get('planName') + '\/user\/{uid}\/pic/?']         = 'PUT';  //update login user's picture
    validURLWhilteList['\/service\/plan\/' + config.get('planName') + '\/user\/{uid}\/leaderboard(/?|/.+)'] = 'GET';  //get login user's leaderboard
    validURLWhilteList['\/service\/plan\/' + config.get('planName') + '\/user\/(.+)\/?']          = 'GET';  //get any user's profile
    validURLWhilteList['\/service\/plan\/' + config.get('planName') + '\/user\/(.+)\/pic\/?']         = 'GET';  //get any user's picture
    validURLWhilteList['\/service\/plan\/' + config.get('planName') + '\/var(/?|/.+)']            = 'GET';  //get variable definition
    validURLWhilteList['\/service\/plan\/' + config.get('planName') + '\/deed(/?|/.+)']           = 'GET';  //get deed definition
    validURLWhilteList['\/service\/plan\/' + config.get('planName') + '\/mission(/?|/.+)']          = 'GET';  //get mission definition
    validURLWhilteList['\/trigger\/plan\/' + config.get('planName') + '\/mission(/?|/.+)']          = 'GET';  //get any user's mission history
    validURLWhilteList['\/cometd(/?|/.+)']                                  = 'POST'; //cometd notification
    
    var self = this;
    var uid = config.get('getLoginUid').call(self, req);
    if(uid == null){
      console.warn("cannot find login user to update resource - return 403");
      res.json(403, {
        error : 'unauthorize !'
      })
    }else{
      var matched = false;
      for(var url in validURLWhilteList){
        var matchUrl = url.replace('{uid}', uid);
        if(req.url.match(matchUrl) && validURLWhilteList[url].indexOf(req.method) >= 0){
          matched = true;
          break;
        }
      }
      if(!matched){
        console.warn("request URL(" + req.url + ") is not authorized for user(" + uid + ") - return 403");
        res.json(403, {
          error : 'unauthorize !'
        })
      }
    }       
      
    if (req.url.indexOf('/proxy/') >= 0)
      req.url = req.url.substring(req.url.indexOf('/proxy/') + '/proxy'.length);
    if (req.url.indexOf('?') < 0) {
      req.url += '?';
    }

    req.url += '&key=' + config.get('key') + '&tenantId=' + config.get('tenantId');
    var servicePath = 'https://' + config.get('gamiHost');
    if (config.get('gamiPort'))
      servicePath += ':' + config.get('gamiPort');
    url = servicePath + req.url;
    if(req.method ==='GET'){
      req.pipe(request(url)).pipe(res);
    }else if(req.method ==='POST'){
      req.pipe(request.post(url, {body:JSON.stringify(req.body)})).pipe(res);
    }else if(req.method ==='PUT'){
      req.pipe(request.put(url, {body:JSON.stringify(req.body)})).pipe(res);
    }
  };
}

exports.config = function (conf) {
  this.conf  = conf;
  this.get   = function (key) {
    return this.conf[key];
  }
  this.set = function(key,value){
    this.conf[key]=value;
  }
  return this;
}
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";
function RESTClient() {
  //Child needs to provide
  this.validateParam = function () {
    if (!this.host) throw new Error("GamiREST Host is empty!");
    if (!this.path) throw new Error("GamiREST Path is empty!");
    if (!this.planName) throw new Error("planName is empty!");
    if (!this.key) throw new Error("key is empty");
    if (!this.tenantId)   throw new Error('TenantId is empty');
  }
  this.resultHandler = function (LOG_TITLE,callback, errorHandler) {
    return function (err, res, result) {
      if (!err && res.statusCode === 200) {
        secureLog(result);
        if (typeof callback==='function')callback(JSON.stringify(result));
      } else {
        var errorMsg = '';
        if (err) {
          errorMsg = err;
          console.error(LOG_TITLE, 'failed with error  ' + errorMsg);
        } else if (res.statusCode === 500) {
          errorMsg = 'internal server error';
          console.error(LOG_TITLE, 'faild with internal server error');
        } else {
          errorMsg = JSON.stringify(result);
          console.error(LOG_TITLE, 'faild with error ' + errorMsg);
        }
        if (typeof errorHandler === 'function'){errorHandler(errorMsg) ;}else if (typeof callback==='function'){callback('{}')}
      }
    }
  }
}
RESTClient.prototype.create = function (data, callback, errorHandler) {
  this.validateParam();
  var LOG_TITLE = 'RESTClient.create';
  var path = this.path + '?key=' + this.key+'&tenantId='+this.tenantId;
  var port = this.port||443;
  var options = {
    url : "https://" + this.host +":"+port+ path,
    method : 'POST',
    json : JSON.parse(data),
    headers:{'Content-Type':'application/json'}
  }
  request.post(options, this.resultHandler(LOG_TITLE,callback, errorHandler));
};
 RESTClient.prototype.byName = function(name,callback,errorHandler){
  this.validateParam();
  var LOG_TITLE = 'RESTClient.byName';
  var path = this.path + '/' + encodeURIComponent(name) + '?key=' + this.key+'&tenantId='+this.tenantId;
  var port = this.port||443;
  var options = {
    url : "https://" + this.host +":"+port+ path,
    method : 'GET',
    json:true
  }
  request.get(options,this.resultHandler(LOG_TITLE,callback,errorHandler));
 }

RESTClient.prototype.list = function (criteria, callback,errorHandler) {
  this.validateParam();
  var LOG_TITLE = 'RESTClient.list';
  var path = this.path + '?key='+this.key+'&tenantId='+this.tenantId+'&' + criteria;
  var port = this.port||443;
  var options = {
    url : "https://" + this.host +":"+port+ path,
    method : 'GET',
    json:true
  }
  request.get(options,this.resultHandler(LOG_TITLE,callback,errorHandler));
}

RESTClient.prototype.del = function (name, callback,errorHandler) {
  this.validateParam();
  
  var LOG_TITLE = 'RESTClient.del'
  var path = this.path + '/' + encodeURIComponent(name) + '?key=' + this.key+'&tenantId='+this.tenantId+'&force='+true;
  var port = this.port||443;
  var options = {
    url : "https://" + this.host +":"+port+ path,
    method : 'DELETE'
  }
  request.del(options,this.resultHandler(LOG_TITLE,callback,errorHandler));
}

RESTClient.prototype.get = function (criteria, callback,errorHandler) {
  this.validateParam();
  var data = [];
  this.list(criteria, function (result) {
    (result[0]) ? callback(result[0]) : callback(null);
  },errorHandler);

};

RESTClient.prototype.update = function (data, callback,errorHandler) {
  this.validateParam();
  var dataObj  = JSON.parse(data);
  var LOG_TITLE = 'RESTClient.update';
  
  var path = this.path +'/'+encodeURIComponent(dataObj.name)+ '?key=' + this.key+'&tenantId='+this.tenantId;
  var port = this.port||443;
  var options = {
    url : "https://" + this.host +":"+port+ path,
    method : 'PUT',
    json : dataObj
  }
  request.put(options,this.resultHandler(LOG_TITLE,callback,errorHandler));
}

function GamePlanManager(gamiRESTConf,
                              /*optional*/ gamePlanObj) {
     this.host = gamiRESTConf.get('gamiHost');
     this.port = gamiRESTConf.get('gamiPort');
     this.tenantId = gamiRESTConf.get('tenantId');
     this.planName = gamiRESTConf.get('planName')||gamePlanObj.planName;
     this.key = gamiRESTConf.get('key')||gamePlanObj.key;
   this.path = '/service/plan';
   
     var self = this;
     this.listByTenant = function (tanentId, callback,errorHandler) {
/*           var client = new RESTClient();
          client.host = expressObj.get('gamiHost');
          client.port = expressObj.get('gamiPort');
          client.path = expressObj.get('gamiREST') + '/service/plan/?tenantId='+self.tenantId;
          client.planName = expressObj.get('planName')||gamePlanObj.planName;
          client.key = expressObj.get('key')||gamePlanObj.key;
          client.list('', callback,errorHandler); */
      
      self.path+='?tenantId='+self.tenantId+'&key='+self.key;
      RESTClient.prototype.list.call(self,'', callback,errorHandler);
     }
}
GamePlanManager.prototype = new RESTClient();

exports.GamePlanManager = GamePlanManager;
function VarManager(gamiRESTConf, 
        /*optional*/ gamePlanObj) {
  this.host = gamiRESTConf.get('gamiHost');
  this.port = gamiRESTConf.get('gamiPort');
  this.planName = gamiRESTConf.get('planName')||gamePlanObj.planName;
  this.key = gamiRESTConf.get('key')||gamePlanObj.key;
  this.tenantId = gamiRESTConf.get('tenantId');
  this.path = '/service/plan/'+this.planName+'/var';
}
VarManager.prototype = new RESTClient();
exports.VarManager = VarManager;

function DeedManager(gamiRESTConf, 
        /*optional*/ gamePlanObj) {
  this.host = gamiRESTConf.get('gamiHost');
  this.port = gamiRESTConf.get('gamiPort');
  this.planName = gamiRESTConf.get('planName')||gamePlanObj.planName;
  this.key = gamiRESTConf.get('key')||gamePlanObj.key;
  this.tenantId = gamiRESTConf.get('tenantId');
  this.path =  '/service/plan/'+this.planName+'/deed';
}
DeedManager.prototype = new RESTClient();
exports.DeedManager = DeedManager;

function MissionManager(gamiRESTConf, 
          /*optional*/ gamePlanObj) {
  this.host = gamiRESTConf.get('gamiHost');
  this.port = gamiRESTConf.get('gamiPort');
  this.planName = gamiRESTConf.get('planName')||gamePlanObj.planName;
  this.key = gamiRESTConf.get('key')||gamePlanObj.key;
  this.tenantId = gamiRESTConf.get('tenantId');
  this.path =  '/service/plan/'+this.planName+'/mission';
  var self = this;
  
  this.startMission =  function(missionName, uid,  callback,errorHandler){
    self.path =  '/trigger/plan/'+self.planName+'/mission/'+missionName;
    var data = {uid : uid ,name:missionName};
    RESTClient.prototype.create.call(self, JSON.stringify(data),callback,errorHandler);
  };
  
  this.acceptMission = function(missionName,uid,callback,errorHandler){
    self.path =  '/trigger/plan/'+self.planName+'/mission';
    var data = {uid:uid,currentState:"accepted",name:missionName};
    RESTClient.prototype.update.call(self,JSON.stringify(data),callback,errorHandler);
  };
  
  this.abandonMission = function(missionName,uid,callback,errorHandler){
    self.path =  '/trigger/plan/'+self.planName+'/mission';
    var data = {uid:uid,currentState:"abandoned",name:missionName};
    RESTClient.prototype.update.call(self,JSON.stringify(data),callback,errorHandler);
  };
  
  this.completeMission = function(missionName,uid,callback,errorHandler){
    self.path =  '/trigger/plan/'+self.planName+'/mission';
    var data = {uid:uid,currentState:"completed",name:missionName};
    RESTClient.prototype.update.call(self,JSON.stringify(data),callback,errorHandler);
  };
}
MissionManager.prototype = new RESTClient();
exports.MissionManager = MissionManager;
function EventManager(gamiRESTConf, 
          /*optional*/ gamePlanObj) {
  this.host = gamiRESTConf.get('gamiHost');
  this.port = gamiRESTConf.get('gamiPort');
  this.planName = gamiRESTConf.get('planName')||gamePlanObj.planName;
  this.key = gamiRESTConf.get('key')||gamePlanObj.key;
  this.tenantId = gamiRESTConf.get('tenantId');
  this.path =  '/service/plan/'+this.planName+'/event';
  var self = this;
  
  this.fireEvent = function(eventName,eventSource,uid,callback,errorHandler){
    self.path =  '/trigger/plan/'+self.planName+'/event/'+eventName;
    var data = {uid:uid,eventSource:eventSource};
    RESTClient.prototype.create.call(self,JSON.stringify(data),callback,errorHandler);
  }
}
EventManager.prototype = new RESTClient();
exports.EventManager = EventManager;

/**    User     **/
function UserManager(gamiRESTConf, 
        /*optional*/ gamePlanObj) {
  this.host = gamiRESTConf.get('gamiHost');
  this.port = gamiRESTConf.get('gamiPort');
  this.planName = gamiRESTConf.get('planName')||gamePlanObj.planName;
  this.tenantId = gamiRESTConf.get('tenantId');
  this.key = gamiRESTConf.get('key')||gamePlanObj.key;
  this.path =  '/service/plan/'+this.planName+'/user';
    
  var self = this;
  this.byName = function (name, callback,errorHandler) {
    RESTClient.prototype.byName.call(self, name, callback,errorHandler);
  };
  
  this.update = function (dataStr, callback, errorHandler) {
    this.validateParam();
    var dataObj = JSON.parse(dataStr);
    var LOG_TITLE = 'UserManager.update';

    var path = this.path + '/' + dataObj.uid + '?key=' + this.key + '&tenantId=' + this.tenantId;
    var port = this.port || 443;
    var options = {
      url : "https://" + this.host + ":" + port + path,
      method : 'PUT',
      json : dataObj
    }
    request.put(options, this.resultHandler(LOG_TITLE, callback, errorHandler));
  };
  
/*  this.del= function(uid,callback,errorHandler){
    RESTClient.prototype.del.call(self,uid,callback,errorHandler);
  }*/
}
UserManager.prototype = new RESTClient();
exports.UserManager = UserManager;

/**    Temp Key     **/
function TempKeyManager(gamiRESTConf,
  /*optional*/
  gamePlanObj) {
  this.host = gamiRESTConf.get('gamiHost');
  this.port = gamiRESTConf.get('gamiPort');
  this.planName = gamiRESTConf.get('planName') || gamePlanObj.planName;
  this.tenantId = gamiRESTConf.get('tenantId');
  this.key = gamiRESTConf.get('key') || gamePlanObj.key;
  this.path = '/service/plan/' + this.planName + '/tempKey';
}
TempKeyManager.prototype = new RESTClient();
exports.TempKeyManager = TempKeyManager;
function secureLog(obj){
  var fieldsToHide = ['key'];
  var newObj = {};
  for (var k in obj){
    if (fieldsToHide.indexOf(k)>=0) continue;
    newObj[k] = obj[k];
  }
}