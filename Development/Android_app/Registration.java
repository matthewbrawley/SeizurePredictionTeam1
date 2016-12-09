package com.example.rr.seizure_prediction_app;

import android.app.Activity;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.sqlite.SQLiteDatabase;
import android.os.StrictMode;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.Html;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.inputmethod.BaseInputConnection;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;


public class Registration extends Activity {

    EditText ed1,ed2,ed3,ed4,ed5,ed6;
    Button b1;
    SQLiteDatabase db;
    HttpClient hc;
    HttpPost hp;
    CheckBox cb;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_registration);
        if (android.os.Build.VERSION.SDK_INT > 9) {
            StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
            StrictMode.setThreadPolicy(policy);
            System.out.println("*** My thread is now configured to allow connection");
        }


        // Step 1 : Object Declaration
        ed1 = (EditText)findViewById(R.id.editText1);
        ed2 = (EditText)findViewById(R.id.editText2);
        ed3 = (EditText)findViewById(R.id.editText3);
        ed4 = (EditText)findViewById(R.id.editText4);
        ed5 = (EditText)findViewById(R.id.editText5);
        ed6 = (EditText)findViewById(R.id.editText6);
        cb = (CheckBox)findViewById(R.id.checkBox);
        b1  = (Button)findViewById(R.id.button1);
        hc  = new DefaultHttpClient();
        hp = new HttpPost("http://10.0.2.2/xampp/insert_data.php");


        //Step 2 : Database Connectivity

        // db = openOrCreateDatabase("TestDb",MODE_PRIVATE,null);

        // Step 3 :  Create table

        //   db.execSQL("create table if not exists userdata(patient_id INTEGER PRIMARY KEY AUTOINCREMENT,name text,mobile text,address text,email text,password text)");
        //Toast.makeText(getBaseContext(),"Database Created",2000).show();

        // Step 4 : Insert data in db

        b1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String name = ed1.getText().toString();
                String mobile = ed2.getText().toString();
                String address = ed3.getText().toString();
                String uid = ed4.getText().toString();
                String pwd = ed5.getText().toString();
                if(TextUtils.isEmpty(name) == false &&TextUtils.isEmpty(mobile) == false && TextUtils.isEmpty(address) == false &&TextUtils.isEmpty(uid) == false && TextUtils.isEmpty(pwd) == false)
                {
                //if(ed1.equals(null) != false || ed2.equals(null)!=false || ed3.equals(null)!=false || ed4.equals(null)!=false || ed5.equals(null)!=false){
                if (ed6.getText().toString().equals(pwd)==true ) {
                    if( cb.isChecked()==true){
                   final  ArrayList<NameValuePair> ls = new ArrayList<NameValuePair>(5);
                    ls.add(new BasicNameValuePair("nm", name));
                    ls.add(new BasicNameValuePair("no", mobile));
                    ls.add(new BasicNameValuePair("ad", address));
                    ls.add(new BasicNameValuePair("uid", uid));
                    ls.add(new BasicNameValuePair("pwd", pwd));
                    AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(Registration.this);
                    alertDialogBuilder.setMessage("Do You Want to Register with this Username : " + uid);
                            alertDialogBuilder.setPositiveButton("Yes",
                                    new DialogInterface.OnClickListener() {
                                        @Override
                                        public void onClick(DialogInterface arg0, int arg1) {
                                            try {
                                                hp.setEntity(new UrlEncodedFormEntity(ls));
                                                hc.execute(hp);
                                                Toast.makeText(getBaseContext(), "Profile Created", Toast.LENGTH_LONG).show();
                                                ;
                                               // ed1.setText(null);
                                                //ed2.setText(null);

                                                Intent in = new Intent(Registration.this,LogIn.class);
                                                startActivity(in);

                                            } catch (UnsupportedEncodingException e) {

                                                // TODO Auto-generated catch block
                                                e.printStackTrace();
                                            } catch (ClientProtocolException e) {
                                                e.printStackTrace();
                                            } catch (IOException e) {
                                                e.printStackTrace();
                                            }
                                            ed1.setText(null);
                                            ed2.setText(null);
                                            ed3.setText(null);
                                            ed4.setText(null);
                                            ed5.setText(null);
                                            ed6.setText(null);
                                        }
                                    });

                    alertDialogBuilder.setNegativeButton("No",new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {

                        }
                    });

                    AlertDialog alertDialog = alertDialogBuilder.create();
                    alertDialog.show();


              /*  String iquery = "insert into userdata (name,mobile,address,email,password)values('"+name+"','"+mobile+"','"+address+"','"+uid+"','"+pwd+"')";
                db.execSQL(iquery);
                Toast.makeText(getBaseContext(),"Database Created",2000).show();
            */}else{ Toast.makeText(getBaseContext(),"Please accept Terms and Condition",Toast.LENGTH_LONG).show();}

            }else{
                    Toast.makeText(getBaseContext(),"Password must be same",Toast.LENGTH_LONG).show();
                }
                }else
                { Toast.makeText(getBaseContext(),"Complete the missing values",Toast.LENGTH_LONG).show();}
            }
        });


        cb.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {

                AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(Registration.this);
                alertDialogBuilder.setTitle("Terms and Condition");

               alertDialogBuilder.setMessage("The Seizure Prediction app (EpiSure) does it's best to predict seizures before they occur. There are occassions of false positives and negatives. By using this application you understand that it is not guaranteed to predict every epileptic seizure accurately.");

                alertDialogBuilder.setPositiveButton("Yes",
                        new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface arg0, int arg1) {

                            cb.setChecked(true);
                            }
                        });

                alertDialogBuilder.setNegativeButton("No",new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        cb.setChecked(false);
                    }
                });

                AlertDialog alertDialog = alertDialogBuilder.create();

                alertDialog.show();

            }
        });

    }
}
