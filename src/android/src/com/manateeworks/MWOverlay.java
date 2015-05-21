package com.manateeworks;

import com.manateeworks.BarcodeScanner;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;

import android.widget.LinearLayout;
import android.widget.TextView;
import android.view.Gravity;
import android.util.Log;
import android.graphics.Color;
import android.util.TypedValue;
import android.graphics.Typeface;
import android.view.Display;
import android.view.WindowManager;

public class MWOverlay extends View {
	
  private static final String TAG = "Barcodescanner Overlay";
  
	private static boolean isAttached = false;

	private static MWOverlay viewportLayer;
  private static TextView textView;
  private static TextView viewFinderView;
  
	public static MWOverlay addOverlay (ScannerActivity context, View previewLayer) {	
		isAttached = true;
    
    Display display = ((WindowManager) context.getSystemService(context.WINDOW_SERVICE)).getDefaultDisplay();

    int width = display.getWidth();
    int height = display.getHeight();
    int orientation = display.getOrientation();
		
		ViewGroup parent = (ViewGroup) previewLayer.getParent();
    
		viewportLayer = new MWOverlay(context);
    
		ViewGroup.LayoutParams rl = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.FILL_PARENT, ViewGroup.LayoutParams.FILL_PARENT);
    parent.addView(viewportLayer, rl);
    
    textView = new TextView(context); 
    textView.setVisibility(View.VISIBLE);
    
    String prompt = (String) context.customParams.get("PROMPT");
    textView.setText(prompt);

    textView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 25.f);
    textView.setGravity(Gravity.CENTER);
    textView.setTextColor(Color.parseColor("#FFFFFFFF"));
    textView.setShadowLayer(4.f, 0.f, 2.f, Color.parseColor("#80333333"));
    textView.setTranslationY(height / 4.f);
    ViewGroup.LayoutParams textLayoutParameters = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.FILL_PARENT, ViewGroup.LayoutParams.FILL_PARENT);
    parent.addView(textView, textLayoutParameters);
    
    Typeface typeface = null;
    try {
      typeface = Typeface.createFromAsset(context.getAssets(), "www/fonts/ionicons.ttf");
    } catch (RuntimeException e) {
      Log.e(TAG, "Could not find ionicons");
    }
    
    if (typeface != null) {
      viewFinderView = new TextView(context); 
      viewFinderView.setTypeface(typeface);
      viewFinderView.setVisibility(View.VISIBLE);
      viewFinderView.setText("\uf346");
      
      viewFinderView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, (int) ((float) width / 2.5));
      viewFinderView.setGravity(Gravity.CENTER);
      viewFinderView.setTextColor(Color.parseColor("#FFFFFFFF"));
      viewFinderView.setShadowLayer(4.f, 0.f, 2.f, Color.parseColor("#80333333"));
      ViewGroup.LayoutParams viewFinderLayoutParams = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.FILL_PARENT, ViewGroup.LayoutParams.FILL_PARENT);
      parent.addView(viewFinderView, viewFinderLayoutParams);
    }
    
    viewportLayer.postInvalidate();
		
		return viewportLayer;		
	}
	
	public static void removeOverlay () {
		
		if (!isAttached)
			return;
		
		if (viewportLayer == null) {
			return;
    }
		
		ViewGroup viewParent = (ViewGroup) viewportLayer.getParent();
		
		if (viewParent != null) {
			viewParent.removeView(viewportLayer);
      viewParent.removeView(textView);
      viewParent.removeView(viewFinderView);
		}
	}
	
	public MWOverlay(Context context) {
		super(context);
	}
  
}
