package com.pixjuegos.pato;

import org.libsdl.app.SDLActivity;
import org.bennugd.iap.iap;
import android.os.Bundle;

/*
 * A sample wrapper class that just calls SDLActivity
 */ 

public class Pato extends SDLActivity {
	@Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
		iap.onCreate(this);
    }
    
	@Override
    protected void onDestroy() {
        super.onDestroy();
    }
}
