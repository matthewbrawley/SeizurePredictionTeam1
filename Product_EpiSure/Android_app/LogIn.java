package com.example.rr.seizure_prediction_app;

import android.content.Intent;
import android.database.sqlite.SQLiteDatabase;
import android.os.StrictMode;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
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

public class LogIn extends AppCompatActivity {

    EditText ed1,ed2;
    Button b1;

    HttpClient hc;
    HttpPost hp;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_log_in);

        if (android.os.Build.VERSION.SDK_INT > 9) {
            StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
            StrictMode.setThreadPolicy(policy);
            System.out.println("*** My thread is now configured to allow connection");
        }


        ed1 = (EditText)findViewById(R.id.editText1);
        ed2 = (EditText)findViewById(R.id.editText2);
        TextView reg = (TextView)findViewById(R.id.textView4);
        b1  = (Button)findViewById(R.id.button1);
        hc  = new DefaultHttpClient();
        hp = new HttpPost("http://10.0.2.2/xampp/login.php");

        b1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String uid = ed1.getText().toString();
                String pwd = ed2.getText().toString();


                    ArrayList<NameValuePair> ls = new ArrayList<NameValuePair>(2);

                    ls.add(new BasicNameValuePair("uid", uid));
                    ls.add(new BasicNameValuePair("pwd", pwd));

                    try {
                        hp.setEntity(new UrlEncodedFormEntity(ls));

                        HttpResponse res  =  hc.execute(hp);
                         String s =EntityUtils.toString(res.getEntity());

                       //

                        if(s.toString().equals("Found"))
                        {
                            Intent in = new Intent(LogIn.this,Home.class);
                            in.putExtra("Data",uid) ;
                            startActivity(in);

                        }else{
                            Toast.makeText(getBaseContext(), "Invalid Username or Password", Toast.LENGTH_LONG).show();
                        }
                        ;
                        ed1.setText(null);
                        ed2.setText(null);
                    } catch (UnsupportedEncodingException e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                    } catch (ClientProtocolException e) {
                        e.printStackTrace();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }

              /*  String iquery = "insert into userdata (name,mobile,address,email,password)values('"+name+"','"+mobile+"','"+address+"','"+uid+"','"+pwd+"')";
                db.execSQL(iquery);
                Toast.makeText(getBaseContext(),"Database Created",2000).show();
            */
                    ed1.setText(null);
                    ed2.setText(null);


            }
        });




        reg.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View arg0) {
                Intent in = new Intent(LogIn.this,Registration.class);
                startActivity(in);

            }
        });

        TextView fp = (TextView)findViewById(R.id.textView3);
        fp.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View arg0) {
                Intent in = new Intent(LogIn.this,ForgotPassword.class);
                startActivity(in);

            }
        });
    }
}
