import * as functions from 'firebase-functions';

// Import Admin SDK
var admin = require("firebase-admin");

admin.initializeApp();

// Get a database reference to our blog
var db = admin.database();
var alarm_statusRef = db.ref("alarm_status");
var measurementRef = db.ref("measurement");
var enable_alert_soundRef = db.ref("enable_alert_sound");

var enable_alert_sound:String;
var enable_alert_sound_old:String;
var enable_alert_sound_tx:Boolean = false;

const dgram = require('dgram');
const server = dgram.createSocket('udp4');
//var remote_info:Object;

var enable_alert_sound_ctr:number = 0;
const enable_alert_sound_period = 6;

server.on('error', (err) => {
  console.log(`server error:\n${err.stack}`);
  server.close();
});

server.on('message', (msg, rinfo) => {
  console.log(`server got: ${msg} | ${msg.toString('hex')} from ${rinfo.address}:${rinfo.port}`);
  
  //remote_info = rinfo;
  
  if ( msg[0] == 1 ) {
    alarm_statusRef.set(true);  
  }
  else {
    alarm_statusRef.set(false);
  }
   
  measurementRef.set(msg.readUInt16BE(1));  
  
  enable_alert_sound_ctr = (enable_alert_sound_ctr + 1) % enable_alert_sound_period;
  if ( enable_alert_sound_ctr == 0 ) enable_alert_sound_tx = true;
  
  if ( enable_alert_sound_tx ) {
    
     var buf = Buffer.alloc(1);
  
     if ( Boolean(enable_alert_sound) == true ) {  
        buf.writeUInt8(1, 0);
     }
     else {
        buf.writeUInt8(0, 0);
     }
  
     server.send(buf,0, buf.length, rinfo.port, rinfo.address, (err)=>{
        console.log("Response sent with result: " + err);
     });
     enable_alert_sound_tx = false;
     
     enable_alert_sound_ctr = 0;
  
     var local_addr = server.address();
     console.log(`Send response from ${local_addr.address}:${local_addr.port} to ${rinfo.address}:${rinfo.port} with payload:`);
     console.log(buf[0]);      
  }
  
});

server.on('listening', () => {
  const address = server.address();
  console.log(`server listening ${address.address}:${address.port}`);
});


export const helloWorld = functions.https.onRequest((request, response) => {
  server.bind(5555, '193.136.128.103');
  response.end();
});
// Prints: server listening 0.0.0.0:41234



// Attach an asynchronous callback to read the data at our posts reference
enable_alert_soundRef.on("value", function(snapshot) {
  console.log(snapshot.val());
  enable_alert_sound = snapshot.val();
  console.log("enable_alert_sound: " + enable_alert_sound);
  
  if ( Boolean(enable_alert_sound) == Boolean(enable_alert_sound_old) ) {
    console.log("enable_alert_sound: same as before");
    return;
  }
  else {
    enable_alert_sound_tx = true;
  }
  
  enable_alert_sound_old = enable_alert_sound;
  
 // var buf = Buffer.alloc(1);
  
//  if ( Boolean(enable_alert_sound) == true ) {  
//    buf.writeUInt8(1, 0);
//  }
//  else {
//    buf.writeUInt8(0, 0);
//  }
  
//  server.send(buf,0,remote_info.port, remote_info.address);
  
//  console.log("Payload to send :");
//  console.log(buf);
 
}, function (errorObject) {
  console.log("The read failed: " + errorObject.code);
});
