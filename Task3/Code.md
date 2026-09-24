<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

    <uses-permission
        android:name="android.permission.VIBRATE"
        android:maxSdkVersion="31" />

    <uses-permission
        android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="28" />

    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />

    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_CAMERA" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />

    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MICROPHONE" />

    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />

    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />

    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION" />

    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

    <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />

    <permission
        android:name="com.university.zefirka.permission.READ_INTERNAL_LOGS"
        android:protectionLevel="signature" />

    <permission
        android:name="com.university.zefirka.permission.INTERNAL_BROADCAST"
        android:protectionLevel="signature" />

    <uses-feature
        android:name="android.hardware.camera"
        android:required="false" />

    <uses-feature
        android:name="android.hardware.camera.autofocus"
        android:required="false" />

    <uses-feature
        android:name="android.hardware.bluetooth_le"
        android:required="false" />

    <uses-feature
        android:name="android.hardware.fingerprint"
        android:required="false" />

    <uses-feature
        android:name="android.hardware.nfc"
        android:required="false" />

    <uses-feature
        android:name="android.hardware.telephony"
        android:required="false" />

    <uses-feature
        android:name="android.hardware.gamepad"
        android:required="false" />

    <uses-feature
        android:name="android.hardware.touchscreen"
        android:required="false" />

    <uses-feature
        android:name="android.hardware.touchscreen.multitouch"
        android:required="false" />

    <uses-feature
        android:name="android.hardware.touchscreen.multitouch.distinct"
        android:required="false" />

    <supports-screens
        android:smallScreens="false"
        android:normalScreens="true"
        android:largeScreens="true"
        android:xlargeScreens="true"
        android:anyDensity="true" />

    <queries>

        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="https" />
        </intent>

        <package android:name="ru.yandex.yandexmaps" />

        <package android:name="ru.dublgis.dgismobile" />

    </queries>

    <uses-permission
        android:name="android.permission.READ_PHONE_STATE"
        tools:node="remove" />

    <uses-sdk
        tools:overrideLibrary="com.example.library" />

    <uses-feature
        android:name="android.hardware.type.watch"
        android:required="true" />

    <uses-permission
        android:name="android.permission.HIGH_SAMPLING_RATE_SENSORS" />

    <uses-feature
        android:name="android.hardware.camera.flash"
        android:required="false" />

    <uses-feature
        android:name="android.hardware.usb.host"
        android:required="false" />
    <uses-feature
        android:name="android.software.leanback"
        android:required="false" />

    <application
        android:name=".MainApplication"
        android:allowBackup="false"
        android:banner="TODO"
        tools:replace="android:allowBackup"

        android:dataExtractionRules="@xml/data_extraction_rules"
        android:fullBackupContent="@xml/backup_rules"

        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher_round"

        android:label="@string/app_name"

        android:supportsRtl="true"
        android:theme="@style/Theme.Zefirka"

        android:usesCleartextTraffic="false"

        android:networkSecurityConfig="@xml/network_security_config"

        android:largeHeap="true">

    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="@string/google_maps_key" />

    <meta-data
        android:name="com.yandex.maps.API_KEY"
        android:value="@string/yandex_maps_key" />

    <meta-data
        android:name="android.content.res.LocaleConfig"
        android:resource="@xml/locales_config" />

    <activity
        android:name=".ui.UsbActivity"
        android:exported="true">

        <intent-filter>
            <action android:name="android.hardware.usb.action.USB_DEVICE_ATTACHED" />
        </intent-filter>

        <meta-data
            android:name="android.hardware.usb.action.USB_DEVICE_ATTACHED"
            android:resource="@xml/device_filter" />

    </activity>

    <activity
        android:name="SplashScreenActivity"
        android:exported="true"/>

        <intent-filter>
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" />
        </intent-filter>

    <activity
        android:name=".MainActivity"
        android:exported="false"
        android:windowSoftInputMode="adjustResize" />

    <activity
        android:name=".ui.AuthActivity"
        android:exported="false"/>

    <activity
        android:name=".ui.ProfileActivity"
        android:exported="false"
        android:launchMode="singleTop" />

    <activity
        android:name=".ui.GameActivity"
        android:exported="false"
        android:configChanges="orientation|screenSize|keyboardHidden" />

    <activity
        android:name=".ui.IncomingCallActivity"
        android:exported="false"
        android:launchMode="singleInstance" />

    <activity
        android:name=".ui.ProductDetailsActivity"
        android:exported="true">

        <intent-filter>
            <action android:name="android.intent.action.VIEW" />

            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />

            <data
                android:scheme="myapp"
                android:host="products" />
        </intent-filter>

        <receiver
            android:name=".receivers.SecureReceiver"
            android:exported="false"
            android:permission="com.university.zefirka.permission.INTERNAL_BROADCAST" />

        <intent-filter android:autoVerify="true">

            <action android:name="android.intent.action.VIEW" />

            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />

            <data
                android:scheme="https"
                android:host="store.university.ru"
                android:pathPrefix="/item/" />

        </intent-filter>

    </activity>

    <activity
        android:name=".ui.BankTransactionActivity"
        android:exported="false"
        android:filterTouchesWhenObscured="true" />

    <activity
        android:name=".ui.ShareImageActivity"
        android:exported="true">


        <intent-filter>

            <action android:name="android.intent.action.SEND" />
            <category android:name="android.intent.category.DEFAULT" />
            <data android:mimeType="image/*" />

        </intent-filter>

    </activity>

    <activity
        android:name=".ui.PhoneActivity"
        android:exported="true">

        <intent-filter>

            <action android:name="android.intent.action.VIEW" />

            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />

            <data android:scheme="tel" />

        </intent-filter>

    </activity>

    <activity
        android:name=".tv.TvMainActivity"
        android:exported="true">

        <intent-filter>
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LEANBACK_LAUNCHER" />
        </intent-filter>

    </activity>

    <activity
        android:name=".ui.PdfActivity"
        android:exported="true">

        <intent-filter>

            <action android:name="android.intent.action.VIEW" />

            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />

            <data
                android:scheme="https"
                android:host="store.university.ru"
                android:pathPattern=".*\.pdf" />

        </intent-filter>

    </activity>

    <activity
        android:name=".ui.NfcActivity"
        android:exported="true">

        <intent-filter>
            <action android:name="android.nfc.action.TECH_DISCOVERED" />

            <category android:name="android.intent.category.DEFAULT" />
        </intent-filter>

        <meta-data
            android:name="android.nfc.action.TECH_DISCOVERED"
            android:resource="@xml/nfc_tech_filter" />

    </activity>

    <activity
        android:name=".HiddenActivity"
        android:exported="true" />

    <activity
        android:name="Theme.SplashScreenActivity"
        android:exported="true"
        android:theme="@style/Theme.Zefirka.SplashScreen">

        <intent-filter>
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" />
        </intent-filter>

    </activity>

    <activity-alias
        android:name=".ChristmasAlias"
        android:enabled="false"
        android:exported="true"
        android:icon="@mipmap/ic_christmas"
        android:label="@string/app_name"
        android:targetActivity=".MainActivity">

        <intent-filter>
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" />
        </intent-filter>

    </activity-alias>

    <activity
        android:name=".ui.MapActivity"
        android:exported="true">

        <intent-filter>
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />

            <data android:scheme="geo" />
        </intent-filter>

    </activity>

    <activity
        android:name=".ui.DocumentActivity"
        android:exported="true">

        <intent-filter>
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />

            <data android:mimeType="application/vnd.openxmlformats-officedocument.wordprocessingml.document" />
            <data android:mimeType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" />
        </intent-filter>

    </activity>



    <activity
        android:name=".MainActivity"
        android:exported="true">

        <layout
            android:minWidth="300dp"
            android:minHeight="450dp" />

    </activity>

    <service
        android:name=".playback.AudioService"
        android:exported="false"
        android:process=":playback_process"
        android:foregroundServiceType="mediaPlayback" />

    <activity
        android:name=".ui.MasterPasswordActivity"
        android:exported="false"
        android:excludeFromRecents="true" />

    <activity
        android:name=".ui.BankConfirmationActivity"
        android:exported="false"
        android:excludeFromRecents="true" />

    <instrumentation
        android:name="com.example.TestInstrumentationRunner"
        android:targetPackage="${applicationId}" />

    <service
        android:name=".service.DynamicCodeService"
        android:exported="false"
        android:isolatedProcess="true" />

    <provider
        android:name=".provider.SecureDataProvider"
        android:authorities="${applicationId}.secure"
        android:exported="true"
        android:readPermission="com.university.zefirka.permission.READ_DATA"
        android:writePermission="com.university.zefirka.permission.WRITE_DATA" />

    <activity
        android:name=".ui.MarketActivity"
        android:exported="true">

        <intent-filter android:autoVerify="true">
            <action android:name="android.intent.action.VIEW" />

            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />

            <data
                    android:scheme="https"
                    android:host="marketplace.com"
                    android:pathPrefix="/catalog/shoes" />
        </intent-filter>

    </activity>

    <receiver
        android:name=".receivers.MediaButtonReceiver"
        android:exported="true">

        <intent-filter>
                <action android:name="android.intent.action.MEDIA_BUTTON" />
        </intent-filter>

    </receiver>

    <activity
        android:name=".ui.SearchActivity"
        android:exported="true">

        <intent-filter>
            <action android:name="android.intent.action.SEARCH" />
        </intent-filter>

        <meta-data
            android:name="android.app.searchable"
            android:resource="@xml/searchable" />

    </activity>


    <activity
        android:name=".ui.SmsActivity"
        android:exported="true">

        <intent-filter>
            <action android:name="android.intent.action.SENDTO" />

            <category android:name="android.intent.category.DEFAULT" />

            <data android:scheme="smsto" />

        </intent-filter>

    </activity>

    <receiver
        android:name=".receivers.BootReceiver"
        android:exported="false">

        <intent-filter>
            <action android:name="android.intent.action.BOOT_COMPLETED" />
        </intent-filter>

    </receiver>

    <activity
        android:name=".ui.OAuthCallbackActivity"
        android:exported="true">

        <intent-filter>
            <action android:name="android.intent.action.VIEW" />

            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />

            <data
                android:scheme="org.example.app"
                android:host="oauth-callback" />
        </intent-filter>

    </activity>

    <activity
        android:name=".ui.ConfigActivity"
        android:exported="true">

        <intent-filter>
            <action android:name="android.intent.action.VIEW" />

            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />

            <data android:mimeType="application/x-myconfig" />

        </intent-filter>

    </activity>

    <service
        android:name=".service.MyAccessibilityService"
        android:exported="true"
        android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE">

        <intent-filter>
            <action android:name="android.accessibilityservice.AccessibilityService" />
        </intent-filter>

        <meta-data
            android:name="android.accessibilityservice"
            android:resource="@xml/accessibility_service_config" />

    </service>

    <service
        android:name=".service.AccountSyncService"
        android:exported="true"
        android:process=":sync">

        <intent-filter>
            <action android:name="android.content.SyncAdapter" />
        </intent-filter>

        <meta-data
            android:name="android.content.SyncAdapter"
            android:resource="@xml/syncadapter" />

    </service>

    <service
        android:name=".wallpaper.MyWallpaperService"
        android:exported="true"
        android:permission="android.permission.BIND_WALLPAPER">

        <intent-filter>
            <action android:name="android.service.wallpaper.WallpaperService" />
        </intent-filter>

        <meta-data
            android:name="android.service.wallpaper"
            android:resource="@xml/wallpaper" />

    </service>

    <service
        android:name=".service.VoiceNoteService"
        android:exported="false"
        android:foregroundServiceType="microphone" />

    <service
        android:name=".service.CourierLocationService"
        android:exported="false"
        android:foregroundServiceType="location" />

    <service
        android:name=".service.FileUploadService"
        android:exported="false"
        android:foregroundServiceType="dataSync" />

    <service
        android:name=".service.TvStreamingService"
        android:exported="false"
        android:foregroundServiceType="mediaProjection" />

    <provider
        android:name="androidx.startup.InitializationProvider"
        android:authorities="${applicationId}.androidx-startup"
        android:exported="false"
        tools:node="merge">

        <meta-data
            android:name="androidx.work.WorkManagerInitializer"
            tools:node="remove" />

    </provider>



    <activity
        android:name=".VideoActivity"
        android:exported="false"
        android:supportsPictureInPicture="true"
        android:configChanges="orientation|screenSize|smallestScreenSize|screenLayout" />

    <activity
        android:name=".ui.FoldableActivity"
        android:exported="false"/>


    <activity
        android:name=".ui.TextReceiverActivity"
        android:exported="true">

        <intent-filter>

            <action android:name="android.intent.action.SEND" />

            <category android:name="android.intent.category.DEFAULT" />

            <data android:mimeType="text/plain" />
            <data android:mimeType="text/html" />

        </intent-filter>

    </activity>

    <service
        android:name=".service.DatabaseSyncService"
        android:exported="false" />

    <service
        android:name=".playback.MediaService"
        android:exported="false"
        android:foregroundServiceType="mediaPlayback" />

    <service
        android:name=".service.LocationService"
        android:exported="false"
        android:foregroundServiceType="location" />


    <receiver
        android:name=".receivers.BootReceiver"
        android:exported="false">

        <intent-filter>
            <action android:name="android.intent.action.BOOT_COMPLETED" />
        </intent-filter>

    </receiver>

    <provider
        android:name="androidx.core.content.FileProvider"
        android:authorities="${applicationId}.fileprovider"
        android:exported="false"
        android:grantUriPermissions="true">

        <meta-data
            android:name="android.support.FILE_PROVIDER_PATHS"
            android:resource="@xml/file_paths" />

    </provider>

    <activity
        android:name=".ui.SearchActivity"
        android:exported="true">

        <meta-data
            android:name="android.app.searchable"
            android:resource="@xml/searchable" />

    </activity>

    <activity
        android:name=".ui.AccessibilitySettingsActivity"
        android:exported="true"
        android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE" />

    <provider
        android:name=".provider.SecureDataProvider"
        android:authorities="${applicationId}.secure"
        android:exported="false"
        android:grantUriPermissions="true">

        <grant-uri-permission android:pathPrefix="/shared_docs/" />

    </provider>

    <provider
        android:name="androidx.startup"
        android:authorities="${applicationId}.androidx-startup"
        android:exported="false"
        tools:node="merge">

        <meta-data
            android:name="com.example.SomeInitializer"
            tools:node="remove" />

    </provider>

    <meta-data
        android:name="android.graphics.HIGH_REFRESH_RATE"
        android:value="true" />

    <meta-data
        android:name="android.app.shortcuts"
        android:resource="@xml/shortcuts" />

    <meta-data
        android:name="com.google.android.gms.car.application"
        android:resource="@xml/automotive_app_desc" />
        <meta-data
            android:name="com.google.android.wearable.standalone"
            android:value="true" />

    </application>

</manifest>

