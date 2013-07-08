package com.pixjuegos.pixfrogger.free;

import org.libsdl.app.SDLActivity;
import android.os.*;

import com.google.ads.AdRequest;
import com.google.ads.AdSize;
import com.google.ads.AdView;

/*
 * A sample wrapper class that just calls SDLActivity
 */ 

public class PiXFrogger extends SDLActivity {
	private AdView adView;

    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
		
		//admob:
		adView = new AdView(this, AdSize.BANNER, "a15070071291f57");
		super.mLayout.addView(adView);
		AdRequest adRequest = new AdRequest();
		adRequest.addTestDevice(AdRequest.TEST_EMULATOR);
		adView.loadAd(new AdRequest());
    }
    
    protected void onDestroy() {
        super.onDestroy();
		if (adView != null) {
		  adView.destroy();
		}
    }
}
