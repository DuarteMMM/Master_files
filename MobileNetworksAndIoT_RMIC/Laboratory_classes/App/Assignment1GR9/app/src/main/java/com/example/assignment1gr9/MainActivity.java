package com.example.assignment1gr9;

import androidx.annotation.NonNull; // For NonNull in read from database
import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.media.MediaPlayer; // For notification sound
import android.media.RingtoneManager; // For notification sound
import android.net.Uri; // For notification sound
import android.os.Bundle;
import android.util.Log;
//import android.view.View; // For button click
import android.widget.Button;
import android.widget.TextView;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

public class MainActivity extends AppCompatActivity {
    @SuppressLint("SetTextI18n")
    @Override
    protected void onCreate(Bundle savedInstanceState) {

        //Before: private static final String TAG = "MyActivity"; // For log messages
        final String TAG = "MainActivity"; // For log messages

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Our database
        FirebaseDatabase database = FirebaseDatabase.getInstance();

        //// MEASUREMENT
        DatabaseReference ref_measurement = database.getReference("measurement");
        // to write value in measurement: myRef.setValue(1) for example

        // Load textview
        TextView textview_measurement = findViewById(R.id.measurement);

        // Read from the database
        ref_measurement.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                // method called with the initial value and whenever data is updated.
                Integer value_measurement = dataSnapshot.getValue(Integer.class);
                Log.d(TAG, "Value of measurement is: " + value_measurement);
                // Put value in TextView
                textview_measurement.setText(Integer.toString(value_measurement));
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                // Failed to read value
                Log.w(TAG, "Failed to read measurement value.", error.toException());
            }
        });

        ///// ALARM_STATUS
        DatabaseReference ref_alarm_status = database.getReference("alarm_status");
        TextView textview_alarm_status = findViewById(R.id.alarm_status);

        ref_alarm_status.addValueEventListener(new ValueEventListener() {
            @SuppressLint("SetTextI18n")
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                Boolean value_alarm_status = dataSnapshot.getValue(Boolean.class);
                Log.d(TAG, "Value of alarm_status is: " + value_alarm_status);
                if (!value_alarm_status) {
                    textview_alarm_status.setText("Nothing to report");
                }
                else {
                    textview_alarm_status.setText("ALERT! ALERT!");
                    Uri notification = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
                    MediaPlayer mp = MediaPlayer.create(getApplicationContext(), notification);
                    mp.start();
                    /*Alternative:
                    Uri notification = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
                    Ringtone r = RingtoneManager.getRingtone(getApplicationContext(), notification);
                    r.play();*/
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                Log.w(TAG, "Failed to read alarm_status value.", error.toException());
            }
        });

        ///// ENABLE_ALERT_SOUND
        DatabaseReference ref_enable_alert_sound = database.getReference("enable_alert_sound");
        Button button_enable_alert_sound = findViewById(R.id.enable_alert_sound);

        // Initialize value from database only once, in the beginning
        ref_enable_alert_sound.addListenerForSingleValueEvent(new ValueEventListener() {
        @Override
        public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
            Boolean value_enable_alert_sound = dataSnapshot.getValue(Boolean.class);
            Log.d(TAG, "Value of enable_alert_status is: " + value_enable_alert_sound);
            if (value_enable_alert_sound) {
                button_enable_alert_sound.setText("Disable Buzzer");
            }
            else {
                button_enable_alert_sound.setText("Enable Buzzer");
            }
        }

        @Override
        public void onCancelled(@NonNull DatabaseError error) {
            Log.w(TAG, "Failed to initialize button text.", error.toException());
            }
        });

        // Change if button clicked
        button_enable_alert_sound.setOnClickListener(v -> {
            if (button_enable_alert_sound.getText().toString().equals("Disable Buzzer")) {
                ref_enable_alert_sound.setValue(false);
                button_enable_alert_sound.setText("Enable Buzzer");
            }
            else if (button_enable_alert_sound.getText().toString().equals("Enable Buzzer")) {
                ref_enable_alert_sound.setValue(true);
                button_enable_alert_sound.setText("Disable Buzzer");
            }
        });

        // Before
        /*
        button_enable_alert_sound.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (button_enable_alert_sound.getText().toString().equals("Disable Buzzer")) {
                    ref_enable_alert_sound.setValue(false);
                    button_enable_alert_sound.setText("Enable Buzzer");
                }
                else if (button_enable_alert_sound.getText().toString().equals("Enable Buzzer")) {
                    ref_enable_alert_sound.setValue(true);
                    button_enable_alert_sound.setText("Disable Buzzer");
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                Log.w(TAG, "Failed to check button.", error.toException());
            }
        });*/

        /*Alternative - also can try without the new method addListenerForSingleValueEvent
        if (button_enable_alert_sound.getText().toString().equals("Disable Buzzer") && button_enable_alert_sound.isPressed()) {
            ref_enable_alert_sound.setValue(false);
            button_enable_alert_sound.setText("Enable Buzzer");
        }*/
    }
}