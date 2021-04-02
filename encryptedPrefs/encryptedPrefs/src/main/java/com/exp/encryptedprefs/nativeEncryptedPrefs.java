package com.exp.encryptedprefs;


import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;

import androidx.security.crypto.EncryptedSharedPreferences;
import androidx.security.crypto.MasterKey;

import com.unity3d.player.UnityPlayer;

import java.io.IOException;
import java.security.GeneralSecurityException;

public class nativeEncryptedPrefs {

    public SharedPreferences CreateEncryptedSharedPreference() throws GeneralSecurityException, IOException {
        Activity activity = UnityPlayer.currentActivity;
        Context context = activity.getApplicationContext();
        MasterKey masterKeyAlias = new MasterKey.Builder(context)
                .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
                .build();

        SharedPreferences sharedPreferences = EncryptedSharedPreferences.create(
                context,
                "secret_shared_prefs",
                masterKeyAlias,
                EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
                EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
                );

        return  sharedPreferences;
    }

    public int EditPrefs(String key, String value){
        try{
            SharedPreferences.Editor edit = CreateEncryptedSharedPreference().edit();
            edit.putString(key, value);
            edit.apply();
            return 0;

        } catch (Exception e) {
            //in iOS, 0 = success, else = failure
            return 1;
        }
    }
    
    public String GetItem(String key){
        try {
            SharedPreferences sharedPreferences = CreateEncryptedSharedPreference();
            String val = sharedPreferences.getString(key, null);
            return val;

        } catch (Exception e){

            return  null;
        }
    }

}
