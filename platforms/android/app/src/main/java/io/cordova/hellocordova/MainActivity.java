/*
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
 */

package io.cordova.hellocordova;

import android.os.Bundle;
import android.widget.Toast;
import android.content.Intent;
import org.apache.cordova.CordovaActivity;
import android.webkit.JavascriptInterface;
import android.webkit.WebView;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends CordovaActivity {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Enable Cordova apps to be started in the background
        Bundle extras = getIntent().getExtras();
        if (extras != null && extras.getBoolean("cdvStartInBackground", false)) {
            moveTaskToBack(true);
        }

        // Set by <content src="index.html" /> in config.xml
        loadUrl(launchUrl);

        // Добавляем JavaScript интерфейс для взаимодействия с нативным кодом
        ((WebView) appView.getEngine().getView()).addJavascriptInterface(new WebAppInterface(), "Android");
    }

    // Внутренний класс для работы с JavaScript-интерфейсом
    private class WebAppInterface {
        @JavascriptInterface
        public void showNativeToast(String message) {
            Toast.makeText(getApplicationContext(), message, Toast.LENGTH_LONG).show();
        }

        // Метод для запуска Flutter
        @JavascriptInterface
        public void startFlutterActivity() {
            Intent flutterIntent = FlutterActivity.createDefaultIntent(MainActivity.this);
            startActivity(flutterIntent);
        }
    }
}
