package com.rmic.iotalarmapp;

import android.annotation.SuppressLint;
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
import android.widget.CompoundButton;
import android.widget.RadioGroup;
import android.widget.TextView;
import android.widget.ToggleButton;

import com.github.mikephil.charting.charts.LineChart;
import com.github.mikephil.charting.components.XAxis;
import com.github.mikephil.charting.components.YAxis;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.LineData;
import com.github.mikephil.charting.data.LineDataSet;
import com.github.mikephil.charting.formatter.IAxisValueFormatter;
import com.github.mikephil.charting.formatter.IndexAxisValueFormatter;
import com.github.mikephil.charting.interfaces.datasets.ILineDataSet;
import com.google.firebase.database.ChildEventListener;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
//import com.jjoe64.graphview.DefaultLabelFormatter;
//import com.jjoe64.graphview.GraphView;
//import com.jjoe64.graphview.series.DataPointInterface;
//import com.jjoe64.graphview.series.LineGraphSeries;

import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.GregorianCalendar;

/**
 * A simple {@link Fragment} subclass.
 * Use the  factory method to
 * create an instance of this fragment.
 */
public class fragmentAuto extends Fragment {
    public fragmentAuto() {
        // Required empty public constructor
    }

    LineChart voltChart;
    //GraphView voltGraph;
    //LineGraphSeries series;
    SimpleDateFormat date_format = new SimpleDateFormat("hh:mm:ss");
    LineDataSet lineDataSet = new LineDataSet(null, null);
    ArrayList<ILineDataSet> iLineDataSets = new ArrayList<>();
    LineData lineData;

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_auto, container, false);
    }

    @Override
    public void onViewCreated(View view, @NonNull Bundle savedInstantState) {
        //final String TAG = "MyActivity"; // For log messages

        // Our database
        FirebaseDatabase database = FirebaseDatabase.getInstance();

/*        //// MEASUREMENT
        DatabaseReference ref_measurement = database.getReference("measurement");
        // to write value in measurement: myRef.setValue(1) for example

        // Load textview
        //TextView textview_measurement = (TextView) getView().findViewById(R.id.textView3);

        // Read from the database
        ref_measurement.addValueEventListener(new ValueEventListener() {
            @SuppressLint("SetTextI18n") // Suppresses warning in setText
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                // method called with the initial value and whenever data is updated.
                Integer value_measurement = dataSnapshot.getValue(Integer.class);
                //Log.d(TAG, "Value of measurement is: " + value_measurement);
                // Put value in TextView
                //textview_measurement.setText(Integer.toString(value_measurement));
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                // Failed to read value
                //Log.w(TAG, "Failed to read measurement value.", error.toException());
            }
        });
        */
/*
        ///// ALARM_STATUS
        DatabaseReference ref_alarm_status = database.getReference("alarm_status");
        TextView textview_alarm_status = (TextView) getView().findViewById(R.id.textView2);

        ref_alarm_status.addValueEventListener(new ValueEventListener() {
            @SuppressLint("SetTextI18n")
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                Boolean value_alarm_status = dataSnapshot.getValue(Boolean.class);
                //Log.d(TAG, "Value of alarm_status is: " + value_alarm_status);
                if (!value_alarm_status) {
                    textview_alarm_status.setText("Nothing to report");
                }
                else {
                    textview_alarm_status.setText("ALERT! ALERT!");
                    //Uri notification = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
                    //MediaPlayer mp = MediaPlayer.create(getContext().getApplicationContext(), notification);
                    //mp.start();
                    //Alternative:
                    //Uri notification = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
                    //Ringtone r = RingtoneManager.getRingtone(getApplicationContext(), notification);
                    //r.play();
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                //Log.w(TAG, "Failed to read alarm_status value.", error.toException());
            }
        });*/


        ////GRAPH VIEW
    /*    voltGraph = (GraphView) getView().findViewById(R.id.voltageChart);
        series = new LineGraphSeries();
        voltGraph.addSeries(series);
        voltGraph.getGridLabelRenderer().setLabelFormatter(new DefaultLabelFormatter(){
            @Override
            public String formatLabel(double value, boolean isValueX) {
                if (isValueX) {
                    return date_format.format(new Date((long) value));
                }else {
                    return super.formatLabel(value, isValueX);
                }
            }
        });*/

        //VOLTAGE CHART
        voltChart = getView().findViewById(R.id.voltageChart);
        XAxis x_axis = voltChart.getXAxis();
        x_axis.setValueFormatter(new date_formatter());
        x_axis.setLabelCount(3);

        DatabaseReference voltage_values = database.getReference("voltage_values");
        voltage_values.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                ArrayList<Entry> dataVals = new ArrayList<Entry>();

                if (snapshot.hasChildren()){
                    for(DataSnapshot myDataSnapshot : snapshot.getChildren()) {
                        DataPoint dataPoint = myDataSnapshot.getValue(DataPoint.class);
                        if (global.initialTime == 0){
                            global.initialTime = dataPoint.getTime();
                        }
                        if(myDataSnapshot.getChildrenCount() == 1) {
                            String id = myDataSnapshot.getKey();
                            long time = new Date().getTime()-global.initialTime;time/=1000;
                            voltage_values.child(id).child("time").setValue(new Date().getTime());
                            dataVals.add(new Entry((float)time, dataPoint.getVoltage()));
                        }else {
                            dataVals.add(new Entry((float)(dataPoint.getTime()-global.initialTime)/1000, dataPoint.getVoltage()));
                        }
                    }
                    showChart(dataVals);
                }
                else {
                    voltChart.clear();
                    voltChart.invalidate();
                    global.initialTime = 0;
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {

            }
        });

        ///// Tracking
        DatabaseReference tracking = database.getReference("tracking");
        ToggleButton toggle = getView().findViewById(R.id.button);

        toggle.setTextOn("Tracking"); toggle.setTextOff("Not Tracking");
        toggle.setChecked(true);

        toggle.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton button, boolean on) {
                if(on) {
                    tracking.setValue(true);
                }else{
                    tracking.setValue(false);
                }
                //String id = voltage_values.push().getKey();
                //voltage_values.child(id).child("voltage").setValue(volt);
            }
        });

        ////RESET CHART
        Button reset = getView().findViewById(R.id.reset_chart);
        reset.setOnClickListener(v->{
            voltage_values.removeValue();
        });

        DecimalFormat df = new DecimalFormat("###.#");

        TextView panel_voltage = (TextView) getView().findViewById(R.id.panel_voltage_auto);
        TextView power = (TextView) getView().findViewById(R.id.power_auto);
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


    }



    private void showChart(ArrayList<Entry> dataVals) {
        lineDataSet.setValues(dataVals);
        lineDataSet.setLabel("Voltage");
        voltChart.getAxisRight().setDrawLabels(false);
        voltChart.getAxisLeft().setAxisMinimum(0f);
        iLineDataSets.clear();
        iLineDataSets.add(lineDataSet);
        lineData = new LineData(iLineDataSets);
        lineData.setDrawValues(true);
        voltChart.setMaxVisibleValueCount(1);
        voltChart.clear();
        voltChart.setData(lineData);
        voltChart.invalidate();

    }
}

