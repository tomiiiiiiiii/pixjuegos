package org.bennugd.iap;

import org.libsdl.app.SDLActivity;
import com.pixjuegos.pato.R;
import android.os.Bundle;
import android.util.Base64;
import android.util.Log;
import android.content.Context;
import org.json.JSONException;
import org.json.JSONObject;
import tv.ouya.console.api.*;
import java.util.*;
import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.security.spec.X509EncodedKeySpec;
import java.security.GeneralSecurityException;
import java.security.PublicKey;
import java.security.KeyFactory;
import java.security.SecureRandom;
import java.security.spec.X509EncodedKeySpec;
import java.text.ParseException;


/*
 * This class holds the in-app purchase code.
 * This one in particular handles Ouya's iap process.
 * This code is pretty much based in Ouya's, publicly available in their ODK and
 * licensed under an Apache license (http://www.apache.org/licenses/LICENSE-2.0)
 */
public class iap {
    private static OuyaFacade ouyaFacade;
    private static List<Receipt> mReceiptList = null;
    private static PublicKey mPublicKey = null;
    private static boolean fetchingreceipts = false;
    private static boolean performingpurchase = false;
    private static Context iapContext = null;
    
    // The C functions we can call
    public static native void setJNI();
    public static native void updatePurchaseStatus(int value);

    // Get this from https://devs.ouya.tv/developers
    //public static final String DEVELOPER_ID = "1e37ab03-246b-42ad-b90d-62bca1eaf3b2";
    private static final Map<String, Product> mOutstandingPurchaseRequests = new HashMap<String, Product>();
    
    // Are we running in ouya hardware?
    public static boolean isOuya() {
        return OuyaFacade.getInstance().isRunningOnOUYAHardware();
    }
    
    // Are the receipts already available?
    public static boolean receiptsReady() {
        return (mReceiptList != null);
    }
    
    /**
     * Get the list of products the user can purchase from the server.
     */
    private static void purchaseProduct(String product) {
        performingpurchase = true;
        ouyaFacade.requestProductList(Arrays.asList(new Purchasable(product)), new CancelIgnoringOuyaResponseListener<ArrayList<Product>>() {
            @Override
            public void onSuccess(ArrayList<Product> products) {
                try {
                    requestPurchase(products.get(0));
                } catch(Exception ex) {
                    Log.e("IAP", "Error requesting purchase", ex);
                }
            }
            
            @Override
            public void onFailure(int errorCode, String errorMessage, Bundle errorBundle) {
                Log.v("IAP", errorMessage);
            }
        });
    }
    
    /**
     * Get/Refresh the receipts from the users previous purchases from the server.
     */
    private static void requestReceipts() {
        if(fetchingreceipts) {
            return;
        }
        
        fetchingreceipts = true;
        ouyaFacade.requestReceipts(new ReceiptListener());
    }
    
    /**
     * The callback for when the list of user receipts has been requested.
     */
    private static class ReceiptListener implements OuyaResponseListener<String>
    {
        /**
         * Handle the successful fetching of the data for the receipts from the server.
         *
         * @param receiptResponse The response from the server.
         */
        @Override
        public void onSuccess(String receiptResponse) {
            OuyaEncryptionHelper helper = new OuyaEncryptionHelper();
            List<Receipt> receipts;
            try {
                JSONObject response = new JSONObject(receiptResponse);
                if(response.has("key") && response.has("iv")) {
                    receipts = helper.decryptReceiptResponse(response, mPublicKey);
                } else {
                    receipts = helper.parseJSONReceiptResponse(receiptResponse);
                }
            } catch (ParseException e) {
                throw new RuntimeException(e);
            } catch (JSONException e) {
                throw new RuntimeException(e);
            } catch (GeneralSecurityException e) {
                throw new RuntimeException(e);
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
            Collections.sort(receipts, new Comparator<Receipt>() {
                @Override
                public int compare(Receipt lhs, Receipt rhs) {
                    return rhs.getPurchaseDate().compareTo(lhs.getPurchaseDate());
                }
            });
            
            mReceiptList = receipts;
            fetchingreceipts = false;
        }
        
        /**
         * Handle a failure. Because displaying the receipts is not critical to the application we just show an error
         * message rather than asking the user to authenticate themselves just to start the application up.
         *
         * @param errorCode An HTTP error code between 0 and 999, if there was one. Otherwise, an internal error code from the
         *                  Ouya server, documented in the {@link OuyaErrorCodes} class.
         *
         * @param errorMessage Empty for HTTP error codes. Otherwise, a brief, non-localized, explanation of the error.
         *
         * @param optionalData A Map of optional key/value pairs which provide additional information.
         */
        
        @Override
        public void onFailure(int errorCode, String errorMessage, Bundle optionalData) {
            Log.d("IAP", "Request Receipts error (code " + errorCode + ": " + errorMessage + ")");
            fetchingreceipts = false;
        }
        
        /*
         * Handle user canceling
         */
        @Override
        public void onCancel()
        {
            Log.d("IAP", "User cancelled getting receipts");
            fetchingreceipts = false;
        }
    }
    
    /*
     * Actually request a purchase.
     */
    public static void requestPurchase(final Product product)
    throws GeneralSecurityException, UnsupportedEncodingException, JSONException {
        SecureRandom sr = SecureRandom.getInstance("SHA1PRNG");
        
        // This is an ID that allows you to associate a successful purchase with
        // it's original request. The server does nothing with this string except
        // pass it back to you, so it only needs to be unique within this instance
        // of your app to allow you to pair responses with requests.
        String uniqueId = Long.toHexString(sr.nextLong());
        
        JSONObject purchaseRequest = new JSONObject();
        purchaseRequest.put("uuid", uniqueId);
        purchaseRequest.put("identifier", product.getIdentifier());
        purchaseRequest.put("testing", "true"); // This value is only needed for testing, not setting it results in a live purchase
        String purchaseRequestJson = purchaseRequest.toString();
        
        byte[] keyBytes = new byte[16];
        sr.nextBytes(keyBytes);
        SecretKey key = new SecretKeySpec(keyBytes, "AES");
        
        byte[] ivBytes = new byte[16];
        sr.nextBytes(ivBytes);
        IvParameterSpec iv = new IvParameterSpec(ivBytes);
        
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding", "BC");
        cipher.init(Cipher.ENCRYPT_MODE, key, iv);
        byte[] payload = cipher.doFinal(purchaseRequestJson.getBytes("UTF-8"));
        
        cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding", "BC");
        cipher.init(Cipher.ENCRYPT_MODE, mPublicKey);
        byte[] encryptedKey = cipher.doFinal(keyBytes);
        
        Purchasable purchasable =
        new Purchasable(
                        product.getIdentifier(),
                        Base64.encodeToString(encryptedKey, Base64.NO_WRAP),
                        Base64.encodeToString(ivBytes, Base64.NO_WRAP),
                        Base64.encodeToString(payload, Base64.NO_WRAP) );
        
        synchronized (mOutstandingPurchaseRequests) {
            mOutstandingPurchaseRequests.put(uniqueId, product);
        }
        ouyaFacade.requestPurchase(purchasable, new PurchaseListener(product));
    }
    
    /**
     * The callback for when the user attempts to purchase something. We're not worried about
     * the user cancelling the purchase so we extend CancelIgnoringOuyaResponseListener, if
     * you want to handle cancelations differently you should extend OuyaResponseListener and
     * implement an onCancel method.
     *
     * @see tv.ouya.console.api.CancelIgnoringOuyaResponseListener
     * @see tv.ouya.console.api.OuyaResponseListener#onCancel()
     */
    private static class PurchaseListener implements OuyaResponseListener<String> {
        /**
         * The ID of the product the user is trying to purchase. This is used in the
         * onFailure method to start a re-purchase if they user wishes to do so.
         */
        
        private Product mProduct;
        
        /**
         * Constructor. Store the ID of the product being purchased.
         */
        
        PurchaseListener(final Product product) {
            mProduct = product;
        }
        
        /**
         * Handle a successful purchase.
         *
         * @param result The response from the server.
         */
        @Override
        public void onSuccess(String result) {
            Product product;
            String id;
            try {
                OuyaEncryptionHelper helper = new OuyaEncryptionHelper();
                
                JSONObject response = new JSONObject(result);
                if(response.has("key") && response.has("iv")) {
                    id = helper.decryptPurchaseResponse(response, mPublicKey);
                    Product storedProduct;
                    synchronized (mOutstandingPurchaseRequests) {
                        storedProduct = mOutstandingPurchaseRequests.remove(id);
                    }
                    if(storedProduct == null || !storedProduct.getIdentifier().equals(mProduct.getIdentifier())) {
                        onFailure(OuyaErrorCodes.THROW_DURING_ON_SUCCESS, "Purchased product is not the same as purchase request product", Bundle.EMPTY);
                        return;
                    }
                } else {
                    product = new Product(new JSONObject(result));
                    if(!mProduct.getIdentifier().equals(product.getIdentifier())) {
                        onFailure(OuyaErrorCodes.THROW_DURING_ON_SUCCESS, "Purchased product is not the same as purchase request product", Bundle.EMPTY);
                        return;
                    }
                }
            } catch (ParseException e) {
                onFailure(OuyaErrorCodes.THROW_DURING_ON_SUCCESS, e.getMessage(), Bundle.EMPTY);
            } catch (JSONException e) {
                onFailure(OuyaErrorCodes.THROW_DURING_ON_SUCCESS, e.getMessage(), Bundle.EMPTY);
                return;
            } catch (IOException e) {
                onFailure(OuyaErrorCodes.THROW_DURING_ON_SUCCESS, e.getMessage(), Bundle.EMPTY);
                return;
            } catch (GeneralSecurityException e) {
                onFailure(OuyaErrorCodes.THROW_DURING_ON_SUCCESS, e.getMessage(), Bundle.EMPTY);
                return;
            }
            
            requestReceipts();
            updatePurchaseStatus(1);
        }
        
        @Override
        public void onFailure(int errorCode, String errorMessage, Bundle optionalData) {
            Log.d("IAP", "Request Receipts error (code " + errorCode + ": " + errorMessage + ")");
            updatePurchaseStatus(-1);
        }
        
        /*
         * Handling the user canceling
         */
        @Override
        public void onCancel() {
            updatePurchaseStatus(0);
        }
    }
    
    /*
     * Read the list of receipts to check if the user has already purchased the
     * item given by product_id
     */
    public static boolean isPurchased(String product_id) {
        if(mReceiptList == null) {
            if(fetchingreceipts == false) {
                requestReceipts();
            }
            return false;
        }
        
        for(Receipt r : mReceiptList) {
            if(r.getIdentifier().equals(product_id)) {
                return true;
            }
        }
        
        return false;
        
    }

    /*
     * Read the list of receipts to check the price of product_id
     */
    public static int getPrice(String product_id) {
        if(mReceiptList == null) {
            if(fetchingreceipts == false) {
                requestReceipts();
            }
            return -1;
        }
        
        for(Receipt r : mReceiptList) {
            if(r.getIdentifier().equals(product_id)) {
                return r.getPriceInCents();
            }
        }
        
        return -1;
        
    }
    
    /*
     * Init Ouya's IAP process, and acquire all the required stuff
     * The user must provide us with their developer ID, as found in the developer portal
     * The user must've also placed their key.der file (fromthe portal) in the appropriate
     * folder
     */
    public static int init(String DEVELOPER_ID) {
        ouyaFacade = OuyaFacade.getInstance();
        ouyaFacade.init(iapContext, DEVELOPER_ID);
        
        try {
            // Read in the key.der file (downloaded from the developer portal)
            InputStream inputStream = iapContext.getResources().openRawResource(R.raw.key);
            byte[] applicationKey = new byte[inputStream.available()];
            inputStream.read(applicationKey);
            inputStream.close();
            X509EncodedKeySpec keySpec = new X509EncodedKeySpec(applicationKey);
            KeyFactory keyFactory = KeyFactory.getInstance("RSA");
            mPublicKey = keyFactory.generatePublic(keySpec);
        } catch (Exception e) {
            Log.e("IAP", "Unable to create encryption key, make sure that your key.der file is in res/raw", e);
            return -1;
        }
        
        // Request the receipt list, if not available
        if(mReceiptList == null) {
            requestReceipts();
        }
        
        return 0;
    }
    
    // It's a polite thing to say goodbye
    public static void shutdown() {
        ouyaFacade.shutdown();
    }
    
    // This function is called to allow C code to call us back
    public static void onCreate(Context context) {
        iapContext = context;
        
        setJNI();
    }
}

