package com.example.rr.seizure_prediction_app;

import android.content.Intent;
import android.os.StrictMode;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import android.os.Handler;


public class Home extends AppCompatActivity {

    HttpClient hc,hc2;
    HttpPost hp,hp2;
    String result,s;
    String class_flag = "0";
    Handler handler;
    Runnable r;
    public static boolean isService = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        if (android.os.Build.VERSION.SDK_INT > 9) {
            StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
            StrictMode.setThreadPolicy(policy);
            System.out.println("*** My thread is now configured to allow connection");
        }

        hc  = new DefaultHttpClient();
        hp = new HttpPost("http://10.0.2.2/xampp/getuid.php");

        Bundle b = getIntent().getExtras();
        result= b.getString("Data").toString();
        TextView tv = (TextView)findViewById(R.id.textView1);
        tv.setText("Hello "+result +",");

        ArrayList<NameValuePair> ls = new ArrayList<NameValuePair>(1);

        ls.add(new BasicNameValuePair("uid", result));


        try {
            hp.setEntity(new UrlEncodedFormEntity(ls));

            HttpResponse res  =  hc.execute(hp);
            s = EntityUtils.toString(res.getEntity());

           // Toast.makeText(getBaseContext(), "Patient id : "  + s , Toast.LENGTH_SHORT).show();
           // tv.setText(s.toString());
            //

        } catch (UnsupportedEncodingException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (ClientProtocolException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }


        Button b1 = (Button)findViewById(R.id.button);
        b1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


                Intent in =new Intent(Home.this,EmergencyContact.class);
                in.putExtra("Patient_ID",s);
                startActivity(in);
            }
        });

        startService(new Intent(Home.this,Inform.class));
        Intent startMain = new Intent(Intent.ACTION_MAIN);
        startMain.addCategory(Intent.CATEGORY_HOME);
        startMain.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(startMain);
        isService = true;


    }
}
