package com.example.rr.seizure_prediction_app;

import android.app.ProgressDialog;
import android.content.Intent;
import android.content.pm.PackageInstaller;
import android.os.AsyncTask;
import android.os.Message;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import java.io.UnsupportedEncodingException;
import java.util.Properties;

import javax.mail.MessagingException;
import javax.mail.Multipart;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;

public class ForgotPassword extends AppCompatActivity {

    EditText ed;
    Button b1;
    private static final String username = "abc@gmail.com";
    private static final String password = "000000";
    private static final String emailid = "xyz@outlook.com";
    private static final String subject = "Photo";
    private static final String message = "Hello";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_forgot_password);
        ed =(EditText)findViewById(R.id.editText4);
        b1 = (Button)findViewById(R.id.button1);
        b1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if(TextUtils.isEmpty(ed.getText().toString())==false) {
                    Toast.makeText(getBaseContext(), "An Email has been forwarded to your Email Address", Toast.LENGTH_LONG).show();

                    Intent in = new Intent(ForgotPassword.this, LogIn.class);
                    startActivity(in);
                }else
                {
                    Toast.makeText(getBaseContext(), "Enter Email Address", Toast.LENGTH_LONG).show();
                }
                /*Intent intent = new Intent(Intent.ACTION_SEND);

                intent.setType("text/plain");
                intent.putExtra(Intent.EXTRA_EMAIL, ed.getText().toString());
                intent.putExtra(Intent.EXTRA_SUBJECT, "Password Forgot");
                intent.putExtra(Intent.EXTRA_TEXT, "");

                startActivity(Intent.createChooser(intent, "Send Email"));

                Intent i = new Intent(Intent.ACTION_SEND);
                i.setType("message/rfc822");
                i.putExtra(Intent.EXTRA_EMAIL  , new String[]{ed.getText().toString()});
                i.putExtra(Intent.EXTRA_SUBJECT, "Forgot Password");
                i.putExtra(Intent.EXTRA_TEXT   , "Replay");
                try {
                    startActivity(Intent.createChooser(i, "Send mail..."));
                } catch (android.content.ActivityNotFoundException ex) {
                    Toast.makeText(ForgotPassword.this, "There are no email clients installed.", Toast.LENGTH_SHORT).show();
                }
                */


            }
        });
    }
/*
    private void sendMail(String email, String subject, String messageBody)
    {

            Session session = createSessionObject();

        try {
            Message message = createMessage(email, subject, messageBody, session);
            new SendMailTask().execute(message);
        }
        catch (AddressException e)
        {
            e.printStackTrace();
        }
        catch (MessagingException e)
        {
            e.printStackTrace();
        }
        catch (UnsupportedEncodingException e)
        {
            e.printStackTrace();
        }
    }


    private Session createSessionObject()
    {
        Properties properties = new Properties();
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.host", "smtp.gmail.com");
        properties.put("mail.smtp.port", "587");

        return Session.getInstance(properties, new javax.mail.Authenticator()
        {
            protected PasswordAuthentication getPasswordAuthentication()
            {
                return new PasswordAuthentication(username, password);
            }
        });
    }

    private Message createMessage(String email, String subject, String messageBody, Session session) throws

            MessagingException, UnsupportedEncodingException
    {
        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress("episure23@gmail.com", "EpiSure Admin"));
        message.addRecipient(Message.RecipientType.TO, new InternetAddress(email, email));
        message.setSubject(subject);
        message.setText(messageBody);
        return message;
    }



    public class SendMailTask extends AsyncTask<Message, Void, Void>
    {
        private ProgressDialog progressDialog;

        @Override
        protected Void doInBackground(Message... params) {
            return null;
        }

        @Override
        protected void onPreExecute()
        {
            super.onPreExecute();
            progressDialog = ProgressDialog.show(ForgotPassword.this, "Please wait", "Sending mail", true, false);
        }

        @Override
        protected void onPostExecute(Void aVoid)
        {
            super.onPostExecute(aVoid);
            progressDialog.dismiss();
        }

        protected Void doInBackground(javax.mail.Message... messages)
        {
            try
            {
                Transport.send(messages[0]);
            } catch (MessagingException e)
            {
                e.printStackTrace();
            }
            return null;
        }
    }*/
}
