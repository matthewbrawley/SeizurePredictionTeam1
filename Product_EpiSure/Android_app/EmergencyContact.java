package com.example.rr.seizure_prediction_app;

import android.app.Activity;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.StrictMode;
import android.provider.ContactsContract;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.w3c.dom.Text;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;

public class EmergencyContact extends AppCompatActivity {
    TextView tv;
    EditText ed1,ed2;
    HttpPost hp;
    Button b1;
    HttpClient hc;
    String result;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_emergency_contact);

        if (android.os.Build.VERSION.SDK_INT > 9) {
            StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
            StrictMode.setThreadPolicy(policy);
            System.out.println("*** My thread is now configured to allow connection");
        }
        Bundle b = getIntent().getExtras();
        result= b.getString("Patient_ID").toString();

        b1 = (Button)findViewById(R.id.button1);
        ed1 = (EditText)findViewById(R.id.editText1);
        ed2 = (EditText)findViewById(R.id.editText2);
        tv = (TextView)findViewById(R.id.textView1);
        hc  = new DefaultHttpClient();

        hp = new HttpPost("http://10.0.2.2/xampp/emergency.php");

        tv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Intent.ACTION_PICK, ContactsContract.Contacts.CONTENT_URI);
                startActivityForResult(intent, 1);
            }
        });

        b1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final ArrayList<NameValuePair> ls = new ArrayList<NameValuePair>(3);
                ls.add(new BasicNameValuePair("pid",result));
                ls.add(new BasicNameValuePair("ename",ed1.getText().toString()));
                ls.add(new BasicNameValuePair("emobile",ed2.getText().toString()));

                AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(EmergencyContact.this);
                alertDialogBuilder.setMessage("Do You Want to add "+ed1.getText().toString()+" as Emergency Contact?");
                alertDialogBuilder.setPositiveButton("Yes",
                        new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface arg0, int arg1) {
                                try {
                                    hp.setEntity(new UrlEncodedFormEntity(ls));
                                    hc.execute(hp);
                                    Toast.makeText(getBaseContext(), "Emergency Contact has been Added", Toast.LENGTH_LONG).show();
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
            */

            }

        });
    }

    @Override
    public void onActivityResult(int reqCode, int resultCode, Intent data){
        super.onActivityResult(reqCode, resultCode, data);

        switch(reqCode)
        {
            case (1):
                if (resultCode == Activity.RESULT_OK)
                {
                    Uri contactData = data.getData();
                    Cursor c = managedQuery(contactData, null, null, null, null);
                    if (c.moveToFirst())
                    {
                        String id = c.getString(c.getColumnIndexOrThrow(ContactsContract.Contacts._ID));

                        String hasPhone = c.getString(c.getColumnIndex(ContactsContract.Contacts.HAS_PHONE_NUMBER));

                        if (hasPhone.equalsIgnoreCase("1"))
                        {
                            Cursor phones = getContentResolver().query(ContactsContract.CommonDataKinds.Phone.CONTENT_URI,null,
                                    ContactsContract.CommonDataKinds.Phone.CONTACT_ID +" = "+ id,null, null);
                            phones.moveToFirst();
                            String cNumber = phones.getString(phones.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));
                            Toast.makeText(getApplicationContext(), cNumber, Toast.LENGTH_SHORT).show();

                            String nameContact = c.getString(c.getColumnIndexOrThrow(ContactsContract.Contacts.DISPLAY_NAME));

                            ed1.setText(nameContact);
                            ed2.setText(cNumber);
                        }
                    }
                }
        }
    }
}
