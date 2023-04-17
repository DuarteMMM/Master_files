package com.rmic.iotalarmapp;



        import androidx.appcompat.app.AppCompatActivity;
        import androidx.fragment.app.FragmentPagerAdapter;
        import androidx.viewpager.widget.ViewPager;

        import android.annotation.SuppressLint;
        import android.os.Bundle;
        import android.os.Handler;
        import android.util.Log;
//import android.view.View; // For button click
        import android.widget.ImageView;
        import android.widget.TextView;

        import com.google.android.material.tabs.TabLayout;
        import com.google.firebase.database.DatabaseReference;
        import com.google.firebase.database.FirebaseDatabase;
        import com.rmic.iotalarmapp.databinding.ActivityMainBinding;

        import org.json.JSONException;
        import org.json.JSONObject;

        import java.io.BufferedReader;
        import java.io.IOException;
        import java.io.InputStream;
        import java.io.InputStreamReader;
        import java.net.HttpURLConnection;
        import java.net.MalformedURLException;
        import java.net.URL;
        import java.text.SimpleDateFormat;
        import java.util.Date;

public class MainActivity extends AppCompatActivity {

    private TabLayout tabLayout;
    private ViewPager viewPager;

    public int weather_code;

    ActivityMainBinding binding;
    Handler weatherHandler = new Handler();

    @SuppressLint("SetTextI18n")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        new fetchWeather().start();
        //Before: private static final String TAG = "MyActivity"; // For log messages
        final String TAG = "MyActivity"; // For log messages

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);


        // Our database
        FirebaseDatabase database = FirebaseDatabase.getInstance();

        DatabaseReference mode = database.getReference("auto_mode");
        // to write value in measurement: myRef.setValue(1) for example


        SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMMM");
        TextView date = findViewById(R.id.toolbarText);
        date.setText(dateFormat.format(new Date().getTime()));
        ImageView weather_icon = findViewById(R.id.weather_icon);


        tabLayout = findViewById(R.id.tabLayout2);
        viewPager = findViewById(R.id.viewpager);

        tabLayout.setupWithViewPager(viewPager);
        VPAdapter vpAdapter = new VPAdapter(getSupportFragmentManager(), FragmentPagerAdapter.BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT);
        vpAdapter.addFragment(new fragmentAuto(), "Auto");
        vpAdapter.addFragment(new fragmentManual(), "Manual");
        viewPager.setAdapter(vpAdapter);


        tabLayout.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener() {
            @Override
            public void onTabSelected(TabLayout.Tab tab){
                if (tab.getText().toString().equals("Auto")){
                    global.mode = true;
                    mode.setValue(true);
                }else {
                    global.mode = false;
                    mode.setValue(false);
                }
                new fetchWeather().start();
                //Log.v("MyActivity", "==================================================");
                //Log.v("MyActivity", "Weather: " + global.weather_code);
                //Log.v("MyActivity", "==================================================");
                //date.setText("Weather: " + global.weather_code);
                drawWeatherIcon();

            }

            @Override
            public void onTabUnselected(TabLayout.Tab tab) {

            }

            @Override
            public void onTabReselected(TabLayout.Tab tab) {

            }
        });


        binding = ActivityMainBinding.inflate(getLayoutInflater());
        //setContentView(binding.getRoot());

        new fetchWeather().start();
        //new fetchWeather().run();
        //drawWeatherIcon();
        //date.setText("Weather: " + global.weather_code);
    }

    private void drawWeatherIcon() {
        ImageView weather_icon = findViewById(R.id.weather_icon);
        TextView description = findViewById(R.id.weather_str);
        TextView temp = findViewById(R.id.temp);

        temp.setText(global.weather_temp + " ºC");
        switch (global.weather_code){

            case -1:
                weather_icon.setImageResource(R.mipmap.empty);

                temp.setText("");  break;

            case 0:
            case 1:
                description.setText("Clear Sky");
                weather_icon.setImageResource(R.mipmap.clear_sky);break;
            case 2:
                description.setText("Partly Cloudy");
                weather_icon.setImageResource(R.mipmap.partly_cloudy);break;
            case 3:
                description.setText("Cloudy");
                weather_icon.setImageResource(R.mipmap.cloudy);break;
            default:
                if(global.weather_code>=50 && global.weather_code<70){
                    description.setText("Raining");
                    weather_icon.setImageResource(R.mipmap.rainy);break;
                }else {
                    weather_icon.setImageResource(R.mipmap.empty);break;
                }
        }

        //Log.v("ICON", "==================================================");
        //Log.v("ICON", "Weather: " + global.weather_code);
        //Log.v("ICON", "==================================================");




    }

    class fetchWeather extends Thread{
        String data = "";
        @Override
        public void run(){
            weatherHandler.post(new Runnable() {
                @Override
                public void run() {

                }
            });

            try {
                URL url = new URL("https://api.open-meteo.com/v1/forecast?latitude=38.72&longitude=-9.13&current_weather=true&forecast_days=1");
                HttpURLConnection httpURLConnection = (HttpURLConnection) url.openConnection();

                InputStream inputStream = httpURLConnection.getInputStream();
                BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(inputStream));
                String line;
               while ((line = bufferedReader.readLine()) != null) {
                    data = data + line;
                }

                if(!data.isEmpty()){
                    JSONObject jsonObject = new JSONObject(data);
                    JSONObject current_weather = (jsonObject.getJSONObject("current_weather"));
                    weather_code = current_weather.getInt("weathercode");
                    global.weather_code = weather_code;
                    global.weather_temp =  (int) Math.round(current_weather.getDouble("temperature"));

                } /**/
            } catch (MalformedURLException e) {
                //throw new RuntimeException(e);
            } catch (IOException e) {
                //throw new RuntimeException(e);
            } catch (JSONException e) {
            //    throw new RuntimeException(e);
            }

        }
    }
}