package com.rmic.iotalarmapp;


import com.github.mikephil.charting.formatter.IndexAxisValueFormatter;
import com.google.firebase.installations.Utils;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class date_formatter extends IndexAxisValueFormatter {
    @Override
    public String getFormattedValue(float value) {
        long time_ms = (long)value * 1000 + global.initialTime;
        Date time = new Date(time_ms);
        //DateFormat dateTimeFormat = DateFormat.getDateTimeInstance();
        SimpleDateFormat date_format = new SimpleDateFormat("dd MMM HH:mm:ss");
        return date_format.format(time);
    }

}
