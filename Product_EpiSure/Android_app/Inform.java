package com.example.rr.seizure_prediction_app;



        import java.io.IOException;
        import java.util.ArrayList;

        import org.apache.http.HttpResponse;
        import org.apache.http.NameValuePair;
        import org.apache.http.client.ClientProtocolException;
        import org.apache.http.client.HttpClient;
        import org.apache.http.client.entity.UrlEncodedFormEntity;
        import org.apache.http.client.methods.HttpPost;
        import org.apache.http.impl.client.DefaultHttpClient;
        import org.apache.http.message.BasicNameValuePair;
        import org.apache.http.util.EntityUtils;

        import android.app.AlertDialog;
        import android.app.Notification;
        import android.app.NotificationManager;
        import android.app.PendingIntent;
        import android.app.Service;
        import android.content.Intent;
        import android.net.Uri;
        import android.os.Binder;
        import android.os.Bundle;
        import android.os.Handler;
        import android.os.IBinder;
        import android.telephony.SmsManager;
        import android.util.Log;
        import android.widget.Toast;



public class Inform extends Service {
    private NotificationManager mNM;
    Bundle b;
    Handler handle ;
    Intent notificationIntent;
    HttpPost hp;
    HttpClient hc;
    HttpResponse hr;
    String responseStr;
    private final IBinder mBinder = new LocalBinder();
    private String newtext;



    public class LocalBinder extends Binder {
        Inform getService() {
            return Inform.this;
        }
    }

    @Override
    public void onCreate() {

        mNM = (NotificationManager)getSystemService(NOTIFICATION_SERVICE);

        newtext = "Seizure Prediction Service is Running";

        @SuppressWarnings("deprecation")
        Notification notification = new Notification(R.drawable.se, newtext,System.currentTimeMillis());
        PendingIntent contentIntent = PendingIntent.getActivity(Inform.this, 0, new Intent(Inform.this,LogIn.class), 0);
       // notification.setLatestEventInfo(Inform.this,"EpiSure", newtext, contentIntent);
        mNM.notify("Hello", 0, notification);
        notificationIntent = new Intent(this,Home.class);
        showNotification();

    }

    public int onStartCommand(Intent intent, int flags, int startId) {


        handle = new Handler();

        final Runnable r = new Runnable() {
            public void run() {
                hc = new DefaultHttpClient();
                hp = new HttpPost("http://10.0.2.2/xampp/seizure_found.php");
                final ArrayList<NameValuePair> ls = new ArrayList<NameValuePair>(1);
                ls.add(new BasicNameValuePair("pid","1"));
                try {
                    hp.setEntity(new UrlEncodedFormEntity(ls));
                    hr = hc.execute(hp);
                    responseStr = EntityUtils.toString(hr.getEntity());
                    if(responseStr.equals("Seizure Found")){
                       // Toast.makeText(getBaseContext(), "Seizure Found", Toast.LENGTH_LONG).show();
                   // To
                       // SmsManager smsManager = SmsManager.getDefault();
                       // smsManager.sendTextMessage("9428075424", null, "sms message", null, null);
                        //
                       /* AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(getBaseContext());
                        alertDialogBuilder.setTitle("Seizure Detected");


                        alertDialogBuilder.setMessage("Alert: You got Seizure attack. And Message has been send your Emergency Contact ");
                        //startActivity(new Intent(Intent.ACTION_VIEW, Uri.fromParts("Urgent Seizure Predicted", "5554", null)));
                        alertDialogBuilder.show();*/
/*
                        final AlertDialog alertDialog = new AlertDialog.Builder(Inform.this).create();
                        alertDialog.setTitle("your title");
                        alertDialog.setMessage("your message");
                        alertDialog.setIcon(R.drawable.se);

                        alertDialog.show();*/

                        Toast.makeText(getBaseContext(),"Seizure Detected", Toast.LENGTH_LONG).show();

                  }


                } catch (ClientProtocolException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                } catch (IOException e) {
                    // TODO Autso-generated catch block
                    e.printStackTrace();
                }
                handle.postDelayed(this, 3000);
            }
        };

        handle.postDelayed(r, 3000);

        Toast.makeText(getBaseContext(), "Service is On", Toast.LENGTH_LONG).show();

        return START_STICKY;
    }
    public void onDestroy() {
        mNM.cancel("Service Started", 0);
        stopSelf();
    }
    private void showNotification() {

        CharSequence text = "Service Chalu";

        Notification notification = new Notification(R.drawable.se, text, System.currentTimeMillis());
        PendingIntent contentIntent = PendingIntent.getActivity(this, 0,new Intent(this, LogIn.class), 0);
        //notification.setLatestEventInfo(this, "EpiSure",newtext, contentIntent);
        notification.flags = Notification.FLAG_ONGOING_EVENT | Notification.FLAG_NO_CLEAR;
        notificationIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);

        mNM.notify("Chalu", 0, notification);

    }
    @Override
    public IBinder onBind(Intent intent) {
        return mBinder;
    }
}