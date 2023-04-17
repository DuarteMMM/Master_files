package com.rmic.iotalarmapp;

import android.annotation.SuppressLint;
import android.icu.number.Precision;
import android.media.MediaPlayer;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.SeekBar;
import android.widget.TextView;

import com.github.mikephil.charting.data.Entry;
import com.google.firebase.database.ChildEventListener;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.Query;
import com.google.firebase.database.ValueEventListener;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Date;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link fragmentManual#newInstance} factory method to
 * create an instance of this fragment.
 */
public class fragmentManual extends Fragment {
    private SeekBar azSeekbar;
    private TextView azText;
    private SeekBar elSeekbar;
    private TextView elText;

    public fragmentManual() {
        // Required empty public constructor
    }



    public static fragmentManual newInstance(String param1, String param2) {
        fragmentManual fragment = new fragmentManual();
        Bundle args = new Bundle();

        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);


    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_manual, container, false);
    }

    boolean seeking = false;
    @Override
    public void onViewCreated(View view, @NonNull Bundle savedInstantState) {

        // Our database
        FirebaseDatabase database = FirebaseDatabase.getInstance();

        //==================================================================================
        // Panel Voltage
        //==================================================================================
        DatabaseReference voltage_values = database.getReference("voltage_values");
        voltage_values.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                if (snapshot.hasChildren()){
                    Query last = snapshot.getRef().orderByKey().limitToLast(1);

                    Log.v("MyActivity", String.valueOf(snapshot.getRef().orderByKey().limitToLast(1).get()));
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {

            }
        });


        DecimalFormat df = new DecimalFormat("###.#");
        TextView panel_voltage = (TextView) getView().findViewById(R.id.panel_voltage);
        TextView power = (TextView) getView().findViewById(R.id.power_manual);
        voltage_values.getRef().orderByKey().limitToLast(1).addChildEventListener(new ChildEventListener() {
            @Override
            public void onChildAdded(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {
                Log.v("MyActivity", "added-> " + String.valueOf(snapshot.getValue(DataPoint.class).getVoltage()));
                float pv = snapshot.getValue(DataPoint.class).getVoltage();
                panel_voltage.setText("Panel Voltage: " + pv + "V");
                power.setText("Nominal Power: " + df.format(pv*pv) + "W");
            }

            @Override
            public void onChildChanged(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {
                float pv = snapshot.getValue(DataPoint.class).getVoltage();
                panel_voltage.setText("Panel Voltage: " + pv + "V");
                power.setText("Nominal Power: " + (int)(pv*pv) + "W");
            }

            @Override
            public void onChildRemoved(@NonNull DataSnapshot snapshot) {

            }

            @Override
            public void onChildMoved(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {

            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {

            }
        });
        //==================================================================================
        //// Azimuth
        //==================================================================================
        DatabaseReference ref_azimuth = database.getReference("angles/azimuth");

        azSeekbar = (SeekBar) getView().findViewById(R.id.seekBar1);
        azText = (TextView) getView().findViewById(R.id.Azimuth);
        azText.setText("Azimuth: " + azSeekbar.getProgress() + "º");
        azSeekbar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            int pval = 0;
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean b) {
                pval = progress;
                azText.setText("Azimuth: " + pval + "º");
                ref_azimuth.setValue(pval);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                seeking = true;
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                ref_azimuth.setValue(pval);
                seeking = false;
            }
        });

        ref_azimuth.addValueEventListener(new ValueEventListener() {
            @SuppressLint("SetTextI18n") // Suppresses warning in setText
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                // method called with the initial value and whenever data is updated.
                Integer value_azimuth = dataSnapshot.getValue(Integer.class);
                //Log.d(TAG, "Value of measurement is: " + value_measurement);
                // Put value in TextView
                if(!seeking){
                    azText.setText(("Azimuth: " + value_azimuth + "º"));
                    azSeekbar.setProgress(value_azimuth);
                }

            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                // Failed to read value
                //Log.w(TAG, "Failed to read measurement value.", error.toException());
            }
        });

        //==================================================================================
        //// Elevation
        //==================================================================================
        DatabaseReference ref_elevation = database.getReference("angles/elevation");

        elSeekbar = (SeekBar) getView().findViewById(R.id.seekBar2);
        elText = (TextView) getView().findViewById(R.id.Elevation);
        elText.setText("Elevation: " + elSeekbar.getProgress() + "º");

        elSeekbar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            int pval = 0;
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean b) {
                pval = progress;
                elText.setText("Elevation: " + pval + "º");
                ref_elevation.setValue(pval);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                seeking = true;
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                seeking = false;
            }
        });

        ref_elevation.addValueEventListener(new ValueEventListener() {
            @SuppressLint("SetTextI18n") // Suppresses warning in setText
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                // method called with the initial value and whenever data is updated.
                Integer value_elevation = dataSnapshot.getValue(Integer.class);
                //Log.d(TAG, "Value of measurement is: " + value_measurement);

                if(!seeking) {
                    elText.setText("Elevation: " + value_elevation + "º");
                    elSeekbar.setProgress(value_elevation);
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                // Failed to read value
                //Log.w(TAG, "Failed to read measurement value.", error.toException());
            }
        });

    }

}