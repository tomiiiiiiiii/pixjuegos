package org.libsdl.app;

import javax.microedition.khronos.egl.EGL10;
import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.egl.EGLContext;
import javax.microedition.khronos.egl.EGLDisplay;
import javax.microedition.khronos.egl.EGLSurface;

import android.app.*;
import android.content.*;
import android.view.*;
import android.view.inputmethod.BaseInputConnection;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputConnection;
import android.view.inputmethod.InputMethodManager;
import android.widget.AbsoluteLayout;
import android.os.*;
import android.net.Uri;
import android.util.Log;
import android.graphics.*;
import android.media.*;
import android.hardware.*;

import java.lang.*;
import java.util.List;
import java.util.ArrayList;

import java.util.Locale;
import java.lang.reflect.Field;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.io.FileOutputStream;
import java.io.File;
import tv.ouya.console.api.OuyaController;



/**
    SDL Activity
*/
public class SDLActivity extends Activity {
    private static final String TAG = "SDL";

    // Keep track of the paused state
    public static boolean mIsPaused = false, mIsSurfaceReady = false;

	// OUYA
	public static boolean isOuya = false;
	public static int backButtonDelayOuya = 3;
	public static Thread OuyaButtonThread;
	
	// Language
	public static Locale Language;
	public static File dir;
	
    // Main components
    protected static SDLActivity mSingleton;
    protected static SDLSurface mSurface;
    protected static _SDLSurface _mSurface;
    protected static View mTextEdit;
    protected static ViewGroup mLayout;

    // This is what SDL runs in. It invokes SDL_main(), eventually
    protected static Thread mSDLThread;

    // Joystick
    private static boolean mJoyListCreated;
    private static List<Integer> mJoyIdList;

    // Audio
    protected static Thread mAudioThread;
    protected static AudioTrack mAudioTrack;

    // EGL objects
    protected static EGLContext  mEGLContext;
    protected static EGLSurface  mEGLSurface;
    protected static EGLDisplay  mEGLDisplay;
    protected static EGLConfig   mEGLConfig;
    protected static int mGLMajor, mGLMinor;

    // Load the .so
    static {
        //System.loadLibrary("png");
        System.loadLibrary("mikmod");
        System.loadLibrary("SDL2");
        System.loadLibrary("SDL2_mixer");
        System.loadLibrary("bgdrtm");
        System.loadLibrary("main");
    }

    // Setup
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        //Log.v("SDL", "onCreate()");
        super.onCreate(savedInstanceState);
        
		SDLActivity.dir = getFilesDir();
		try {
			SDLActivity.dir.mkdir();
		}catch(Exception e) {
		}
        
		//Log.v("SDL", "onCreate()");
        super.onCreate(savedInstanceState);       
		
        // So we can call stuff from static callbacks
        mSingleton = this;

        // Keep track of the paused state
        mIsPaused = false;
		
        // Set up the surface
        mEGLSurface = EGL10.EGL_NO_SURFACE;
        if(Build.VERSION.SDK_INT >= 12) {
            _mSurface = new _SDLSurface(getApplication());
            mLayout   = new AbsoluteLayout(this);
            mLayout.addView(_mSurface);
        } else {
            mSurface = new SDLSurface(getApplication());
            mLayout = new AbsoluteLayout(this);
            mLayout.addView(mSurface);
        }
		
		// Checking if we are on a OUYA
		try {
			Class<?> buildClass = Class.forName("android.os.Build");
			Field deviceField = buildClass.getDeclaredField("DEVICE");
			Object device = deviceField.get(null);
			SDLActivity.isOuya = "ouya_1_1".equals(device);
		} catch(Exception e) {
		}
			
        // Don't allow the screen lock
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        setContentView(mLayout);
    }

    // Events
    @Override
    protected void onPause() {
        Log.v("SDL", "onPause()");
        super.onPause();
        SDLActivity.handlePause();
    }

    @Override
    protected void onResume() {
        Log.v("SDL", "onResume()");
        super.onResume();
        SDLActivity.handleResume();
    }

    @Override
    public void onLowMemory() {
        Log.v("SDL", "onLowMemory()");
        super.onLowMemory();
        SDLActivity.nativeLowMemory();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.v("SDL", "onDestroy()");
        // Send a quit message to the application
        SDLActivity.nativeQuit();

        // Now wait for the SDL thread to quit
        if (mSDLThread != null) {
            try {
                mSDLThread.join();
            } catch(Exception e) {
                Log.v("SDL", "Problem stopping thread: " + e);
            }
            mSDLThread = null;

            //Log.v("SDL", "Finished waiting for SDL thread");
        }
    }


    /** Called by onPause or surfaceDestroyed. Even if surfaceDestroyed
     *  is the first to be called, mIsSurfaceReady should still be set
     *  to 'true' during the call to onPause (in a usual scenario).
     */
    public static void handlePause() {
        if (!SDLActivity.mIsPaused && SDLActivity.mIsSurfaceReady) {
            SDLActivity.mIsPaused = true;
            SDLActivity.nativePause();
        }
    }

    /** Called by onResume or surfaceCreated. An actual resume should be done only when the surface is ready.
     * Note: Some Android variants may send multiple surfaceChanged events, so we don't need to resume
     * every time we get one of those events, only if it comes after surfaceDestroyed
     */
    public static void handleResume() {
        if (SDLActivity.mIsPaused && SDLActivity.mIsSurfaceReady) {
            SDLActivity.mIsPaused = false;
            SDLActivity.nativeResume();
        }
    }


    // Messages from the SDLMain thread
    static final int COMMAND_CHANGE_TITLE = 1;
    static final int COMMAND_UNUSED = 2;
    static final int COMMAND_TEXTEDIT_HIDE = 3;

    protected static final int COMMAND_USER = 0x8000;

    /**
     * This method is called by SDL if SDL did not handle a message itself.
     * This happens if a received message contains an unsupported command.
     * Method can be overwritten to handle Messages in a different class.
     * @param command the command of the message.
     * @param param the parameter of the message. May be null.
     * @return if the message was handled in overridden method.
     */
    protected boolean onUnhandledMessage(int command, Object param) {
        return false;
    }

    /**
     * A Handler class for Messages from native SDL applications.
     * It uses current Activities as target (e.g. for the title).
     * static to prevent implicit references to enclosing object.
     */
    protected static class SDLCommandHandler extends Handler {
        @Override
        public void handleMessage(Message msg) {
            Context context = getContext();
            if (context == null) {
                Log.e(TAG, "error handling message, getContext() returned null");
                return;
            }
            switch (msg.arg1) {
            case COMMAND_CHANGE_TITLE:
                if (context instanceof Activity) {
                    ((Activity) context).setTitle((String)msg.obj);
                } else {
                    Log.e(TAG, "error handling message, getContext() returned no Activity");
                }
                break;
            case COMMAND_TEXTEDIT_HIDE:
                if (mTextEdit != null) {
                    mTextEdit.setVisibility(View.GONE);

                    InputMethodManager imm = (InputMethodManager) context.getSystemService(Context.INPUT_METHOD_SERVICE);
                    imm.hideSoftInputFromWindow(mTextEdit.getWindowToken(), 0);
                }
                break;

            default:
                if ((context instanceof SDLActivity) && !((SDLActivity) context).onUnhandledMessage(msg.arg1, msg.obj)) {
                    Log.e(TAG, "error handling message, command is " + msg.arg1);
                }
            }
        }
    }

    // Handler for the messages
    Handler commandHandler = new SDLCommandHandler();

    // Send a message from the SDLMain thread
    boolean sendCommand(int command, Object data) {
        Message msg = commandHandler.obtainMessage();
        msg.arg1 = command;
        msg.obj = data;
        return commandHandler.sendMessage(msg);
    }

    // C functions we call
    public static native void nativeInit();
    public static native void nativeLowMemory();
    public static native void nativeQuit();
    public static native void nativePause();
    public static native void nativeResume();
    public static native void onNativeResize(int x, int y, int format);
    public static native void onNativePadDown(int padId, int keycode);
    public static native void onNativePadUp(int padId, int keycode);
    public static native void onNativeJoy(int joyId, int axis,
                                            float value);
    public static native void onNativeKeyDown(int keycode);
    public static native void onNativeKeyUp(int keycode);
    public static native void onNativeTouch(int touchDevId, int pointerFingerId,
                                            int action, float x, 
                                            float y, float p);
    public static native void onNativeMouse(int action, int buttonId, float x, float y);
    public static native void nativeRunAudioThread();


    // Java functions called from C

    public static boolean createGLContext(int majorVersion, int minorVersion, int[] attribs) {
        return initEGL(majorVersion, minorVersion, attribs);
    }

    public static void flipBuffers() {
        flipEGL();
    }

    public static boolean setActivityTitle(String title) {
        // Called from SDLMain() thread and can't directly affect the view
        return mSingleton.sendCommand(COMMAND_CHANGE_TITLE, title);
    }

    // Create a list of valid ID's the first time this function is called
    private static void createJoystickList() {
        if(mJoyListCreated) {
            return;
        }

        mJoyIdList = new ArrayList<Integer>();
        // InputDevice.getDeviceIds requires SDK >= 16
        if(Build.VERSION.SDK_INT >= 16) {
            int[] deviceIds = InputDevice.getDeviceIds();
            for(int i=0; i<deviceIds.length; i++) {
                if( (InputDevice.getDevice(deviceIds[i]).getSources() & InputDevice.SOURCE_CLASS_JOYSTICK) != 0) {
                    mJoyIdList.add(deviceIds[i]);
                }
            }
        }
        mJoyListCreated = true;
    }

    public static int getNumJoysticks() {
        createJoystickList();

        return mJoyIdList.size();
    }

    public static String getJoystickName(int joy) {
        createJoystickList();

        return InputDevice.getDevice(mJoyIdList.get(joy)).getName();
    }

    public static int getJoystickAxes(int joy) {
        createJoystickList();

         // In newer Android versions we can get a real value
         // In older versions, we can assume a sane X-Y default configuration
         if(Build.VERSION.SDK_INT >= 12) {
            return InputDevice.getDevice(mJoyIdList.get(joy)).getMotionRanges().size();
         } else {
            return 2;
         }
    }

    public static int getJoyId(int devId) {
        int i=0;

        createJoystickList();

        for(i=0; i<mJoyIdList.size(); i++) {
            if(mJoyIdList.get(i) == devId) {
                return i;
            }
        }


        return -1;
    }

    public static boolean sendMessage(int command, int param) {
        return mSingleton.sendCommand(command, Integer.valueOf(param));
    }

    public static Context getContext() {
        return mSingleton;
    }

    static class ShowTextInputTask implements Runnable {
        /*
         * This is used to regulate the pan&scan method to have some offset from
         * the bottom edge of the input region and the top edge of an input
         * method (soft keyboard)
         */
        static final int HEIGHT_PADDING = 15;

        public int x, y, w, h;

        public ShowTextInputTask(int x, int y, int w, int h) {
            this.x = x;
            this.y = y;
            this.w = w;
            this.h = h;
        }

        @Override
        public void run() {
            AbsoluteLayout.LayoutParams params = new AbsoluteLayout.LayoutParams(
                    w, h + HEIGHT_PADDING, x, y);

            if (mTextEdit == null) {
                mTextEdit = new DummyEdit(getContext());

                mLayout.addView(mTextEdit, params);
            } else {
                mTextEdit.setLayoutParams(params);
            }

            mTextEdit.setVisibility(View.VISIBLE);
            mTextEdit.requestFocus();

            InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
            imm.showSoftInput(mTextEdit, 0);
        }
    }

    public static boolean showTextInput(int x, int y, int w, int h) {
        // Transfer the task to the main thread as a Runnable
        return mSingleton.commandHandler.post(new ShowTextInputTask(x, y, w, h));
    }


    // EGL functions
    public static boolean initEGL(int majorVersion, int minorVersion, int[] attribs) {
        try {
            if (SDLActivity.mEGLDisplay == null) {
                Log.v("SDL", "Starting up OpenGL ES " + majorVersion + "." + minorVersion);

                EGL10 egl = (EGL10)EGLContext.getEGL();

                EGLDisplay dpy = egl.eglGetDisplay(EGL10.EGL_DEFAULT_DISPLAY);

                int[] version = new int[2];
                egl.eglInitialize(dpy, version);

                EGLConfig[] configs = new EGLConfig[1];
                int[] num_config = new int[1];
                if (!egl.eglChooseConfig(dpy, attribs, configs, 1, num_config) || num_config[0] == 0) {
                    Log.e("SDL", "No EGL config available");
                    return false;
                }
                EGLConfig config = configs[0];

                SDLActivity.mEGLDisplay = dpy;
                SDLActivity.mEGLConfig = config;
                SDLActivity.mGLMajor = majorVersion;
                SDLActivity.mGLMinor = minorVersion;
            }
            return SDLActivity.createEGLSurface();

        } catch(Exception e) {
            Log.v("SDL", e + "");
            for (StackTraceElement s : e.getStackTrace()) {
                Log.v("SDL", s.toString());
            }
            return false;
        }
    }

    public static boolean createEGLContext() {
        EGL10 egl = (EGL10)EGLContext.getEGL();
        int EGL_CONTEXT_CLIENT_VERSION=0x3098;
        int contextAttrs[] = new int[] { EGL_CONTEXT_CLIENT_VERSION, SDLActivity.mGLMajor, EGL10.EGL_NONE };
        SDLActivity.mEGLContext = egl.eglCreateContext(SDLActivity.mEGLDisplay, SDLActivity.mEGLConfig, EGL10.EGL_NO_CONTEXT, contextAttrs);
        if (SDLActivity.mEGLContext == EGL10.EGL_NO_CONTEXT) {
            Log.e("SDL", "Couldn't create context");
            return false;
        }
        return true;
    }

    public static boolean createEGLSurface() {
        if (SDLActivity.mEGLDisplay != null && SDLActivity.mEGLConfig != null) {
            EGL10 egl = (EGL10)EGLContext.getEGL();
            if (SDLActivity.mEGLContext == null) createEGLContext();

            if (SDLActivity.mEGLSurface == EGL10.EGL_NO_SURFACE) {
                Log.v("SDL", "Creating new EGL Surface");
                if(Build.VERSION.SDK_INT >= 12) {
                    SDLActivity.mEGLSurface = egl.eglCreateWindowSurface(SDLActivity.mEGLDisplay, SDLActivity.mEGLConfig, SDLActivity._mSurface, null);
                } else { 
                    SDLActivity.mEGLSurface = egl.eglCreateWindowSurface(SDLActivity.mEGLDisplay, SDLActivity.mEGLConfig, SDLActivity.mSurface, null);
                }
                if (SDLActivity.mEGLSurface == EGL10.EGL_NO_SURFACE) {
                    Log.e("SDL", "Couldn't create surface");
                    return false;
                }
            }
            else Log.v("SDL", "EGL Surface remains valid");

            if (egl.eglGetCurrentContext() != SDLActivity.mEGLContext) {
                if (!egl.eglMakeCurrent(SDLActivity.mEGLDisplay, SDLActivity.mEGLSurface, SDLActivity.mEGLSurface, SDLActivity.mEGLContext)) {
                    Log.e("SDL", "Old EGL Context doesnt work, trying with a new one");
                    // TODO: Notify the user via a message that the old context could not be restored, and that textures need to be manually restored.
                    createEGLContext();
                    if (!egl.eglMakeCurrent(SDLActivity.mEGLDisplay, SDLActivity.mEGLSurface, SDLActivity.mEGLSurface, SDLActivity.mEGLContext)) {
                        Log.e("SDL", "Failed making EGL Context current");
                        return false;
                    }
                }
                else Log.v("SDL", "EGL Context made current");
            }
            else Log.v("SDL", "EGL Context remains current");


            return true;
        } else {
            Log.e("SDL", "Surface creation failed, display = " + SDLActivity.mEGLDisplay + ", config = " + SDLActivity.mEGLConfig);
            return false;
        }
    }

    // EGL buffer flip
    public static void flipEGL() {
        try {
            EGL10 egl = (EGL10)EGLContext.getEGL();

            egl.eglWaitNative(EGL10.EGL_CORE_NATIVE_ENGINE, null);

            // drawing here

            egl.eglWaitGL();

            egl.eglSwapBuffers(SDLActivity.mEGLDisplay, SDLActivity.mEGLSurface);


        } catch(Exception e) {
            Log.v("SDL", "flipEGL(): " + e);
            for (StackTraceElement s : e.getStackTrace()) {
                Log.v("SDL", s.toString());
            }
        }
    }

    // Audio
    public static void audioInit(int sampleRate, boolean is16Bit, boolean isStereo, int desiredFrames) {
        int channelConfig = isStereo ? AudioFormat.CHANNEL_CONFIGURATION_STEREO : AudioFormat.CHANNEL_CONFIGURATION_MONO;
        int audioFormat = is16Bit ? AudioFormat.ENCODING_PCM_16BIT : AudioFormat.ENCODING_PCM_8BIT;
        int frameSize = (isStereo ? 2 : 1) * (is16Bit ? 2 : 1);
        
        Log.v("SDL", "SDL audio: wanted " + (isStereo ? "stereo" : "mono") + " " + (is16Bit ? "16-bit" : "8-bit") + " " + (sampleRate / 1000f) + "kHz, " + desiredFrames + " frames buffer");
        
        // Let the user pick a larger buffer if they really want -- but ye
        // gods they probably shouldn't, the minimums are horrifyingly high
        // latency already
        desiredFrames = Math.max(desiredFrames, (AudioTrack.getMinBufferSize(sampleRate, channelConfig, audioFormat) + frameSize - 1) / frameSize);
        
        mAudioTrack = new AudioTrack(AudioManager.STREAM_MUSIC, sampleRate,
                channelConfig, audioFormat, desiredFrames * frameSize, AudioTrack.MODE_STREAM);
        
        audioStartThread();
        
        Log.v("SDL", "SDL audio: got " + ((mAudioTrack.getChannelCount() >= 2) ? "stereo" : "mono") + " " + ((mAudioTrack.getAudioFormat() == AudioFormat.ENCODING_PCM_16BIT) ? "16-bit" : "8-bit") + " " + (mAudioTrack.getSampleRate() / 1000f) + "kHz, " + desiredFrames + " frames buffer");
    }
    
    public static void audioStartThread() {
        mAudioThread = new Thread(new Runnable() {
            @Override
            public void run() {
                mAudioTrack.play();
                nativeRunAudioThread();
            }
        });
        
        // I'd take REALTIME if I could get it!
        mAudioThread.setPriority(Thread.MAX_PRIORITY);
        mAudioThread.start();
    }
    
    public static void audioWriteShortBuffer(short[] buffer) {
        for (int i = 0; i < buffer.length; ) {
            int result = mAudioTrack.write(buffer, i, buffer.length - i);
            if (result > 0) {
                i += result;
            } else if (result == 0) {
                try {
                    Thread.sleep(1);
                } catch(InterruptedException e) {
                    // Nom nom
                }
            } else {
                Log.w("SDL", "SDL audio: error return from write(short)");
                return;
            }
        }
    }
    
    public static void audioWriteByteBuffer(byte[] buffer) {
        for (int i = 0; i < buffer.length; ) {
            int result = mAudioTrack.write(buffer, i, buffer.length - i);
            if (result > 0) {
                i += result;
            } else if (result == 0) {
                try {
                    Thread.sleep(1);
                } catch(InterruptedException e) {
                    // Nom nom
                }
            } else {
                Log.w("SDL", "SDL audio: error return from write(byte)");
                return;
            }
        }
    }

    public static void audioQuit() {
        if (mAudioThread != null) {
            try {
                mAudioThread.join();
            } catch(Exception e) {
                Log.v("SDL", "Problem stopping audio thread: " + e);
            }
            mAudioThread = null;

            //Log.v("SDL", "Finished waiting for audio thread");
        }

        if (mAudioTrack != null) {
            mAudioTrack.stop();
            mAudioTrack = null;
        }
    }

    // Taken from
    // http://digitalsynapsesblog.blogspot.com.es/2011/09/cocos2d-x-launching-url-on-android.html
    public static void openURL(String url) {
        Intent i = new Intent(Intent.ACTION_VIEW);
        i.setData(Uri.parse(url));
        mSingleton.startActivity(i);
    }
}

/**
    Simple nativeInit() runnable
*/
class SDLMain implements Runnable {
    @Override
    public void run() {
        // Runs SDL_main()
        SDLActivity.nativeInit();

        //Log.v("SDL", "SDL thread terminated");
    }
}

class OuyaButton implements Runnable {
	public void run() {
		//OUYA hack for menu button
		while(1 == 1) {
			if (SDLActivity.backButtonDelayOuya < 2) {
				if(SDLActivity.backButtonDelayOuya==1){
					SDLActivity.onNativeKeyUp(KeyEvent.KEYCODE_ESCAPE);
				}
				SDLActivity.backButtonDelayOuya++;
			}
			try {
				Thread.sleep(100);
			} catch(InterruptedException e) {}
		}
	}
}

/* This code will only execute on API >= 12 */
class _SDLSurface extends SDLSurface implements SurfaceHolder.Callback,
    View.OnKeyListener, View.OnTouchListener, View.OnGenericMotionListener {
    
    // Startup
    public _SDLSurface(Context context) {
        super(context);
        getHolder().addCallback(this);
        
        setOnGenericMotionListener(this);
    }
    
    // Generic Motion (mouse hover, joystick...) events
    @Override
    public boolean onGenericMotion(View v, MotionEvent event) {
        int actionPointerIndex = event.getActionIndex();
        int action = event.getActionMasked();
        
        if ( (event.getSource() & InputDevice.SOURCE_MOUSE) != 0 ) {
            float x = event.getX(actionPointerIndex);
            float y = event.getY(actionPointerIndex);
            
            switch(action) {
                case MotionEvent.ACTION_HOVER_MOVE:
                    // Send mouse motion
                    SDLActivity.onNativeMouse(action, 0, x, y);
                    break;
                default:
                    // Send mouse click
                    int buttonId = 1; /* API 14: BUTTON_PRIMARY */
                    if(Build.VERSION.SDK_INT >= 14) {
                        buttonId = event.getButtonState();
                    }
                    // Event was mouse hover
                    SDLActivity.onNativeMouse(action, buttonId, x, y);
                    break;
            }
        } else if ( (event.getSource() & InputDevice.SOURCE_JOYSTICK) != 0) {
            switch(action) {
                case MotionEvent.ACTION_MOVE:
					int id;
					if (SDLActivity.isOuya) {
						id = OuyaController.getPlayerNumByDeviceId( event.getDeviceId() );
					} else {
						id = SDLActivity.getJoyId( event.getDeviceId() );
					}
                    float x = event.getAxisValue(MotionEvent.AXIS_X, actionPointerIndex);
                    float y = event.getAxisValue(MotionEvent.AXIS_Y, actionPointerIndex);
                    SDLActivity.onNativeJoy(id, 0, x);
                    SDLActivity.onNativeJoy(id, 1, y);
                    
                    break;
            }
        }
        return true;
    }
}


/**
    SDLSurface. This is what we draw on, so we need to know when it's created
    in order to do anything useful. 

    Because of this, that's where we set up the SDL thread
*/
class SDLSurface extends SurfaceView implements SurfaceHolder.Callback,
    View.OnKeyListener, View.OnTouchListener  {

    // Keep track of the surface size to normalize touch events
    protected static float mWidth, mHeight;

    // Startup    
    public SDLSurface(Context context) {
        super(context);
        getHolder().addCallback(this); 
    
        setFocusable(true);
        setFocusableInTouchMode(true);
        requestFocus();
        setOnKeyListener(this);
        setOnTouchListener(this);

        // Some arbitrary defaults to avoid a potential division by zero
        mWidth = 1.0f;
        mHeight = 1.0f;
    }

    // Called when we have a valid drawing surface
    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        Log.v("SDL", "surfaceCreated()");
        holder.setType(SurfaceHolder.SURFACE_TYPE_GPU);
        // Set mIsSurfaceReady to 'true' *before* any call to handleResume
        SDLActivity.mIsSurfaceReady = true;
    }

    // Called when we lose the surface
    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        Log.v("SDL", "surfaceDestroyed()");
        // Call this *before* setting mIsSurfaceReady to 'false'
        SDLActivity.handlePause();
        SDLActivity.mIsSurfaceReady = false;

        /* We have to clear the current context and destroy the egl surface here
         * Otherwise there's BAD_NATIVE_WINDOW errors coming from eglCreateWindowSurface on resume
         * Ref: http://stackoverflow.com/questions/8762589/eglcreatewindowsurface-on-ics-and-switching-from-2d-to-3d
         */
        
        EGL10 egl = (EGL10)EGLContext.getEGL();
        egl.eglMakeCurrent(SDLActivity.mEGLDisplay, EGL10.EGL_NO_SURFACE, EGL10.EGL_NO_SURFACE, EGL10.EGL_NO_CONTEXT);
        egl.eglDestroySurface(SDLActivity.mEGLDisplay, SDLActivity.mEGLSurface);
        SDLActivity.mEGLSurface = EGL10.EGL_NO_SURFACE;
    }

    // Called when the surface is resized
    @Override
    public void surfaceChanged(SurfaceHolder holder,
                               int format, int width, int height) {
        Log.v("SDL", "surfaceChanged()");

        int sdlFormat = 0x15151002; // SDL_PIXELFORMAT_RGB565 by default
        switch (format) {
        case PixelFormat.A_8:
            Log.v("SDL", "pixel format A_8");
            break;
        case PixelFormat.LA_88:
            Log.v("SDL", "pixel format LA_88");
            break;
        case PixelFormat.L_8:
            Log.v("SDL", "pixel format L_8");
            break;
        case PixelFormat.RGBA_4444:
            Log.v("SDL", "pixel format RGBA_4444");
            sdlFormat = 0x15421002; // SDL_PIXELFORMAT_RGBA4444
            break;
        case PixelFormat.RGBA_5551:
            Log.v("SDL", "pixel format RGBA_5551");
            sdlFormat = 0x15441002; // SDL_PIXELFORMAT_RGBA5551
            break;
        case PixelFormat.RGBA_8888:
            Log.v("SDL", "pixel format RGBA_8888");
            sdlFormat = 0x16462004; // SDL_PIXELFORMAT_RGBA8888
            break;
        case PixelFormat.RGBX_8888:
            Log.v("SDL", "pixel format RGBX_8888");
            sdlFormat = 0x16261804; // SDL_PIXELFORMAT_RGBX8888
            break;
        case PixelFormat.RGB_332:
            Log.v("SDL", "pixel format RGB_332");
            sdlFormat = 0x14110801; // SDL_PIXELFORMAT_RGB332
            break;
        case PixelFormat.RGB_565:
            Log.v("SDL", "pixel format RGB_565");
            sdlFormat = 0x15151002; // SDL_PIXELFORMAT_RGB565
            break;
        case PixelFormat.RGB_888:
            Log.v("SDL", "pixel format RGB_888");
            // Not sure this is right, maybe SDL_PIXELFORMAT_RGB24 instead?
            sdlFormat = 0x16161804; // SDL_PIXELFORMAT_RGB888
            break;
        default:
            Log.v("SDL", "pixel format unknown " + format);
            break;
        }

        mWidth = width;
        mHeight = height;
        SDLActivity.onNativeResize(width, height, sdlFormat);
        Log.v("SDL", "Window size:" + width + "x"+height);

        // Set mIsSurfaceReady to 'true' *before* making a call to handleResume
        SDLActivity.mIsSurfaceReady = true;

        if (SDLActivity.mSDLThread == null) {
            // This is the entry point to the C app.
            // Start up the C app thread and enable sensor input for the first time

            SDLActivity.mSDLThread = new Thread(new SDLMain(), "SDLThread");
            SDLActivity.mSDLThread.start();
        } else {
            // The app already exists, we resume via handleResume
            // Multiple sequential calls to surfaceChanged are handled internally by handleResume

            SDLActivity.handleResume();
        }

		if(SDLActivity.isOuya) {
			OuyaController.init(getContext());

			if (SDLActivity.OuyaButtonThread == null) {
				SDLActivity.OuyaButtonThread = new Thread(new OuyaButton(), "OuyaButtonThread");
				SDLActivity.OuyaButtonThread.start();
			}
		}
		
		Log.v("SDL", "Language: " + SDLActivity.Language.getDefault().getLanguage());
		
		try{
			FileWriter fWriter;
            try{
                 //fWriter = new FileWriter("files/lang.txt");
				 fWriter = new FileWriter(SDLActivity.dir+"/lang.txt");
                 fWriter.write(SDLActivity.Language.getDefault().getLanguage()+"\n\n");
                 fWriter.flush();
                 fWriter.close();
             }catch(Exception e){
                      e.printStackTrace();
             }
		} 
		catch (Exception e)
		{
			Log.v("SDL","Error: No se pudo crear el fichero lang.txt");
		}

    }

    // unused
    @Override
    public void onDraw(Canvas canvas) {}


    // Key events
    @Override
    public boolean onKey(View  v, int keyCode, KeyEvent event) {
	
		if (SDLActivity.isOuya) {
			if(keyCode == KeyEvent.KEYCODE_MENU) {
				if(event.getAction() == KeyEvent.ACTION_UP) {
					SDLActivity.backButtonDelayOuya = 0;
				} else if(event.getAction() == KeyEvent.ACTION_DOWN) {
					SDLActivity.onNativeKeyDown(KeyEvent.KEYCODE_ESCAPE);
				}
				return true;
			}
		}
	
        // Dispatch the different events depending on where they come from

		// Send volume key signal but return false, so that
		// Android will set the volume for our app
		
		if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN ||
			keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
			if (event.getAction() == KeyEvent.ACTION_DOWN) {
				SDLActivity.onNativeKeyDown(keyCode);
			} else if (event.getAction() == KeyEvent.ACTION_UP) {
				SDLActivity.onNativeKeyUp(keyCode);
			}
			return false;
		}
		
	   int id;
		if (SDLActivity.isOuya) {
			id = OuyaController.getPlayerNumByDeviceId( event.getDeviceId() );
		} else {
			id = SDLActivity.getJoyId( event.getDeviceId() );
		}

		//PIX wrapps in order to work properly with our controller's "API"
		switch((id+1)%2){
			case 1: //mando 1
				switch (keyCode) {
					case KeyEvent.KEYCODE_DPAD_LEFT:
						keyCode = KeyEvent.KEYCODE_DPAD_LEFT;
						break;
					case KeyEvent.KEYCODE_DPAD_RIGHT:
						keyCode = KeyEvent.KEYCODE_DPAD_RIGHT;
						break;
					case KeyEvent.KEYCODE_DPAD_UP:
						keyCode = KeyEvent.KEYCODE_DPAD_UP;
						break;
					case KeyEvent.KEYCODE_DPAD_DOWN:
						keyCode = KeyEvent.KEYCODE_DPAD_DOWN;
						break;
					case KeyEvent.KEYCODE_BUTTON_X:
						keyCode = KeyEvent.KEYCODE_Z;
						break;
					case KeyEvent.KEYCODE_BUTTON_A:
						keyCode = KeyEvent.KEYCODE_Q;
						break;
					case KeyEvent.KEYCODE_BUTTON_B:
						keyCode = KeyEvent.KEYCODE_M;
						break;
					case KeyEvent.KEYCODE_BUTTON_Y:
						keyCode = KeyEvent.KEYCODE_P;
						break;
					case KeyEvent.KEYCODE_BUTTON_R1:
						keyCode = KeyEvent.KEYCODE_ENTER;
						break;
					case KeyEvent.KEYCODE_MENU:
						keyCode = KeyEvent.KEYCODE_ESCAPE;
						break;
					case KeyEvent.KEYCODE_BACK:
						keyCode = KeyEvent.KEYCODE_ESCAPE;
						break;
					case KeyEvent.KEYCODE_BUTTON_SELECT:
						keyCode = KeyEvent.KEYCODE_ESCAPE;
						break;
					case KeyEvent.KEYCODE_BUTTON_START:
						keyCode = KeyEvent.KEYCODE_ESCAPE;
						break;
					default:
						return true;
				}
				break;
			
			case 0: //mando 2
				switch (keyCode) {
					case KeyEvent.KEYCODE_DPAD_LEFT:
						keyCode = KeyEvent.KEYCODE_DPAD_LEFT;
						break;
					case KeyEvent.KEYCODE_DPAD_RIGHT:
						keyCode = KeyEvent.KEYCODE_DPAD_RIGHT;
						break;
					case KeyEvent.KEYCODE_DPAD_UP:
						keyCode = KeyEvent.KEYCODE_DPAD_UP;
						break;
					case KeyEvent.KEYCODE_DPAD_DOWN:
						keyCode = KeyEvent.KEYCODE_DPAD_DOWN;
						break;
					case KeyEvent.KEYCODE_BUTTON_X:
						keyCode = KeyEvent.KEYCODE_S;
						break;
					case KeyEvent.KEYCODE_BUTTON_A:
						keyCode = KeyEvent.KEYCODE_A;
						break;
					case KeyEvent.KEYCODE_BUTTON_B:
						keyCode = KeyEvent.KEYCODE_D;
						break;
					case KeyEvent.KEYCODE_BUTTON_Y:
						keyCode = KeyEvent.KEYCODE_F;
						break;
					case KeyEvent.KEYCODE_MENU:
						keyCode = KeyEvent.KEYCODE_ESCAPE;
						break;
					case KeyEvent.KEYCODE_BACK:
						keyCode = KeyEvent.KEYCODE_ESCAPE;
						break;
					case KeyEvent.KEYCODE_BUTTON_SELECT:
						keyCode = KeyEvent.KEYCODE_ESCAPE;
						break;
					case KeyEvent.KEYCODE_BUTTON_START:
						keyCode = KeyEvent.KEYCODE_ESCAPE;
						break;
					default:
						return true;
				}
				break;
		}

		if (event.getAction() == KeyEvent.ACTION_DOWN) {
			//Log.v("SDL", "key down: " + keyCode);
			SDLActivity.onNativeKeyDown(keyCode);
		} else if (event.getAction() == KeyEvent.ACTION_UP) {
			//Log.v("SDL", "key up: " + keyCode);
			SDLActivity.onNativeKeyUp(keyCode);
		}

        return true;
    }

    // Touch events
    @Override
    public boolean onTouch(View v, MotionEvent event) {
        final int touchDevId = event.getDeviceId();
        final int pointerCount = event.getPointerCount();
        // touchId, pointerId, action, x, y, pressure
        int actionPointerIndex = (event.getAction() & MotionEvent.ACTION_POINTER_ID_MASK) >> MotionEvent.ACTION_POINTER_ID_SHIFT; /* API 8: event.getActionIndex(); */
        int pointerFingerId = event.getPointerId(actionPointerIndex);
        int action = (event.getAction() & MotionEvent.ACTION_MASK); /* API 8: event.getActionMasked(); */

        float x = event.getX(actionPointerIndex) / mWidth;
        float y = event.getY(actionPointerIndex) / mHeight;
        float p = event.getPressure(actionPointerIndex);

        if (action == MotionEvent.ACTION_MOVE && pointerCount > 1) {
            // TODO send motion to every pointer if its position has
            // changed since prev event.
            for (int i = 0; i < pointerCount; i++) {
                pointerFingerId = event.getPointerId(i);
                x = event.getX(i) / mWidth;
                y = event.getY(i) / mHeight;
                p = event.getPressure(i);
                SDLActivity.onNativeTouch(touchDevId, pointerFingerId, action, x, y, p);
            }
        } else {
            SDLActivity.onNativeTouch(touchDevId, pointerFingerId, action, x, y, p);
        }
        return true;
    }
}

/* This is a fake invisible editor view that receives the input and defines the
 * pan&scan region
 */
class DummyEdit extends View implements View.OnKeyListener {
    InputConnection ic;

    public DummyEdit(Context context) {
        super(context);
        setFocusableInTouchMode(true);
        setFocusable(true);
        setOnKeyListener(this);
    }

    @Override
    public boolean onCheckIsTextEditor() {
        return true;
    }

    @Override
    public boolean onKey(View v, int keyCode, KeyEvent event) {

        // This handles the hardware keyboard input
        if (event.isPrintingKey()) {
            if (event.getAction() == KeyEvent.ACTION_DOWN) {
                ic.commitText(String.valueOf((char) event.getUnicodeChar()), 1);
            }
            return true;
        }

        if (event.getAction() == KeyEvent.ACTION_DOWN) {
            SDLActivity.onNativeKeyDown(keyCode);
            return true;
        } else if (event.getAction() == KeyEvent.ACTION_UP) {
            SDLActivity.onNativeKeyUp(keyCode);
            return true;
        }

        return false;
    }

    @Override
    public InputConnection onCreateInputConnection(EditorInfo outAttrs) {
        ic = new SDLInputConnection(this, true);

        outAttrs.imeOptions = EditorInfo.IME_FLAG_NO_EXTRACT_UI
                | 33554432 /* API 11: EditorInfo.IME_FLAG_NO_FULLSCREEN */;

        return ic;
    }
}

class SDLInputConnection extends BaseInputConnection {

    public SDLInputConnection(View targetView, boolean fullEditor) {
        super(targetView, fullEditor);

    }

    @Override
    public boolean sendKeyEvent(KeyEvent event) {

        /*
         * This handles the keycodes from soft keyboard (and IME-translated
         * input from hardkeyboard)
         */
        int keyCode = event.getKeyCode();
        if (event.getAction() == KeyEvent.ACTION_DOWN) {
            if (event.isPrintingKey()) {
                commitText(String.valueOf((char) event.getUnicodeChar()), 1);
            }
            SDLActivity.onNativeKeyDown(keyCode);
            return true;
        } else if (event.getAction() == KeyEvent.ACTION_UP) {

            SDLActivity.onNativeKeyUp(keyCode);
            return true;
        }
        return super.sendKeyEvent(event);
    }

    @Override
    public boolean commitText(CharSequence text, int newCursorPosition) {

        nativeCommitText(text.toString(), newCursorPosition);

        return super.commitText(text, newCursorPosition);
    }

    @Override
    public boolean setComposingText(CharSequence text, int newCursorPosition) {

        nativeSetComposingText(text.toString(), newCursorPosition);

        return super.setComposingText(text, newCursorPosition);
    }

    public native void nativeCommitText(String text, int newCursorPosition);

    public native void nativeSetComposingText(String text, int newCursorPosition);

}
