package com.rmic.iotalarmapp;

public class PointValue {
    long time;
    int voltage;

    public PointValue() {
    }

    public PointValue(long time, int voltage) {
        this.time = time;
        this.voltage = voltage;
    }

    public long getTime() {
        return time;
    }

    public int getVoltage() {
        return voltage;
    }
}
