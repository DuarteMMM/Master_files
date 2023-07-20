import * as functions from 'firebase-functions';

// Import Admin SDK
var admin = require("firebase-admin");

// Import HTTPS
const https = require('https');
//const querystring = require('querystring');

admin.initializeApp();

// Get a database reference to our blog
var db = admin.database();
var alarm_statusRef = db.ref("alarm_status");
var measurementRef = db.ref("measurement");
var enable_alert_soundRef = db.ref("enable_alert_sound");

var push_path;
var replace_path;
var api_key;
//var _end_device_ids;

var enable_alert_sound:String;
var enable_alert_sound_old:String;

var downlink_ready = false;

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
 export const helloWorld = functions.https.onRequest((request, response) => {
   functions.logger.info("Hello logs!", {structuredData: true});
   
   console.log("Request received:");
   console.log(enable_alert_sound);
   
   console.log(request.body);

   console.log("API Key:");

   api_key = request.headers['x-downlink-apikey'];
   console.log("API_KEY: ", api_key);

   push_path = request.headers['x-downlink-push'];
   console.log("PUSH_PATH: ", push_path);

   replace_path = request.headers['x-downlink-replace'];
   console.log("REPLACE_PATH: ", replace_path);

  
   
   if ( request.body.uplink_message != null ) {
     if ( request.body.uplink_message.decoded_payload.decoded.alarm_status == true ) {
       alarm_statusRef.set(true);  
     }
     else {
       alarm_statusRef.set(false);
     }
   
     measurementRef.set(request.body.uplink_message.decoded_payload.decoded.measurement);

//     _end_device_ids = request.body.end_device_ids;
     
     downlink_ready = true;
   }
   
   
   response.end();
 });

// Attach an asynchronous callback to read the data at our posts reference
enable_alert_soundRef.on("value", function(snapshot) {
  if (!downlink_ready) return;

  console.log(snapshot.val());
  enable_alert_sound = snapshot.val();
  console.log("enable_alert_sound: " + enable_alert_sound);
  
  if ( Boolean(enable_alert_sound) == Boolean(enable_alert_sound_old) ) {
    console.log("enable_alert_sound: same as before");
    return;
  }
  
  enable_alert_sound_old = enable_alert_sound;
  
  var parameters;
  
  if ( Boolean(enable_alert_sound) == true ) {  
// Depending if we have set a downlink encoder or not in the TTN application, we may send the payload as raw or JSON formatted.     
    
//    parameters = {dev_id: "device1", port: 0, confirmed: true, payload_raw: "MQ=="};
//    parameters = {end_device_ids: _end_device_ids, downlinks: {f_port: 0, frm_payload: "MQ==", decoded_payload: {enable_alert_sound:true}, priority: "NORMAL", confirmed: true, correlation_ids: "custom_id"}};
//    parameters = {downlinks: [{f_port: 1, frm_payload: "MQ==", priority: "NORMAL"}]}
    parameters = {downlinks: [{f_port: 1, frm_payload: "AQ==", priority: "NORMAL"}]}

  }
  else {
//    parameters = {dev_id: "device1", port: 0, confirmed: true, payload_raw: "MA=="};
//    parameters = {dev_id: "device1", port: 0, confirmed: true, payload_fields: {enable_alert_sound: false}};
//    parameters = {end_device_ids: _end_device_ids, downlinks: {f_port: 0, frm_payload: "MA==", decoded_payload: {enable_alert_sound:true}, priority: "NORMAL", confirmed: true, correlation_ids: "custom_id"}}
//    parameters = {downlinks: [{f_port: 1, frm_payload: "MA==", priority: "NORMAL"}]}
      parameters = {downlinks: [{f_port: 1, frm_payload: "AA==", priority: "NORMAL"}]}
  
  }
  
  console.log("Payload to send in POST:");
  console.log(JSON.stringify(parameters));
  
  const headerDict = {
    'Authorization': 'Bearer ' + api_key 
  }

  console.log("Header contents:")
  console.log(headerDict);
  
  const options = {
    host: "eu1.cloud.thethings.network",
    path: "/api/v3/as/applications/iot-alarm-app/webhooks/iot-alarm-app/devices/eui-0097cf9eb38628aa/down/replace",
//    path: replace_path,
    method: 'POST',
    headers: headerDict,
    json: true
  }
  
  console.log("HTTP options:")
  console.log(options);

  
  const request = https.request(options, (response) => {
    //response processing
    console.log("Response from TTN server:");
    console.log(response.headers);
    console.log(response.statusCode);
        
    
    var chunks_of_data: string[] = [];
    
    //gather chunk
    response.on('data', (fragments) => {
      chunks_of_data.push(fragments);
    });    
    
    // no more data to come
    // combine all chunks
    response.on('end', () => {
      console.log(chunks_of_data);
      console.log("Status code:");
      console.log(response.status);
    });      
    
  });

  console.log("Body:" + JSON.stringify(parameters));
  
  request.write(JSON.stringify(parameters));
  
  console.log("Sending request:");
  console.log(request);
  
  console.log(request.headers);
  console.log(JSON.stringify(request.body));

  request.end();
  
}, function (errorObject) {
  console.log("The read failed: " + errorObject.code);
});

