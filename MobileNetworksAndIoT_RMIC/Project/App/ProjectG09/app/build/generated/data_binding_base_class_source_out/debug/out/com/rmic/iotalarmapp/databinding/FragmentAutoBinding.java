// Generated by view binder compiler. Do not edit!
package com.rmic.iotalarmapp.databinding;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.ToggleButton;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.viewbinding.ViewBinding;
import androidx.viewbinding.ViewBindings;
import com.github.mikephil.charting.charts.LineChart;
import com.rmic.iotalarmapp.R;
import java.lang.NullPointerException;
import java.lang.Override;
import java.lang.String;

public final class FragmentAutoBinding implements ViewBinding {
  @NonNull
  private final RelativeLayout rootView;

  @NonNull
  public final ToggleButton button;

  @NonNull
  public final TextView panelVoltageAuto;

  @NonNull
  public final RelativeLayout relativeLayout;

  @NonNull
  public final Button resetChart;

  @NonNull
  public final LineChart voltageChart;

  private FragmentAutoBinding(@NonNull RelativeLayout rootView, @NonNull ToggleButton button,
      @NonNull TextView panelVoltageAuto, @NonNull RelativeLayout relativeLayout,
      @NonNull Button resetChart, @NonNull LineChart voltageChart) {
    this.rootView = rootView;
    this.button = button;
    this.panelVoltageAuto = panelVoltageAuto;
    this.relativeLayout = relativeLayout;
    this.resetChart = resetChart;
    this.voltageChart = voltageChart;
  }

  @Override
  @NonNull
  public RelativeLayout getRoot() {
    return rootView;
  }

  @NonNull
  public static FragmentAutoBinding inflate(@NonNull LayoutInflater inflater) {
    return inflate(inflater, null, false);
  }

  @NonNull
  public static FragmentAutoBinding inflate(@NonNull LayoutInflater inflater,
      @Nullable ViewGroup parent, boolean attachToParent) {
    View root = inflater.inflate(R.layout.fragment_auto, parent, false);
    if (attachToParent) {
      parent.addView(root);
    }
    return bind(root);
  }

  @NonNull
  public static FragmentAutoBinding bind(@NonNull View rootView) {
    // The body of this method is generated in a way you would not otherwise write.
    // This is done to optimize the compiled bytecode for size and performance.
    int id;
    missingId: {
      id = R.id.button;
      ToggleButton button = ViewBindings.findChildViewById(rootView, id);
      if (button == null) {
        break missingId;
      }

      id = R.id.panel_voltage_auto;
      TextView panelVoltageAuto = ViewBindings.findChildViewById(rootView, id);
      if (panelVoltageAuto == null) {
        break missingId;
      }

      RelativeLayout relativeLayout = (RelativeLayout) rootView;

      id = R.id.reset_chart;
      Button resetChart = ViewBindings.findChildViewById(rootView, id);
      if (resetChart == null) {
        break missingId;
      }

      id = R.id.voltageChart;
      LineChart voltageChart = ViewBindings.findChildViewById(rootView, id);
      if (voltageChart == null) {
        break missingId;
      }

      return new FragmentAutoBinding((RelativeLayout) rootView, button, panelVoltageAuto,
          relativeLayout, resetChart, voltageChart);
    }
    String missingId = rootView.getResources().getResourceName(id);
    throw new NullPointerException("Missing required view with ID: ".concat(missingId));
  }
}
