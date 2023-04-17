package com.rmic.iotalarmapp;

public class DataPoint {
    float voltage;
    long time;

    public DataPoint(){
    }

    public DataPoint(long time, float voltage) {
        this.time = time;
        this.voltage = voltage;
    }

    public float getVoltage() {
        return voltage;
    }

    public long getTime() {
        return time;
    }
}
