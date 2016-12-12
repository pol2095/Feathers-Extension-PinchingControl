/*
Copyright 2016 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.extensions.utils.events {
	import starling.events.Event;
	import flash.geom.Point;
	
	/**
	 * A event dispatched when a zoomable control is pinch to zoom.
	 *
	 * @see feathers.extensions.zoomable.PinchingControl
	 * @see feathers.extensions.zoomable.ZoomableControl
	 */
	public class TouchSheetEvent extends Event {
		
		/**
		 * Dispatched when a zoomable control is pinch to zoom.
		 */
		public static var PINCHING:String = "pinching";
		
		public function TouchSheetEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}