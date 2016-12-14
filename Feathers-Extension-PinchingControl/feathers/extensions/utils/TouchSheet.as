/*
Copyright 2016 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.extensions.utils
{
    import flash.geom.Point;

    import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
    import starling.display.Sprite;
	import starling.events.Event;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
	
	import feathers.core.FeathersControl;
	import feathers.controls.LayoutGroup;
	import feathers.controls.ScrollContainer;

	import feathers.extensions.zoomable.PinchingControl;
	import feathers.extensions.utils.events.TouchSheetEvent;
	
    public class TouchSheet extends LayoutGroup
    {
		private var getPreviousLocationA:Point;
		private var getPreviousLocationB:Point;
		public var contents:LayoutGroup = new LayoutGroup();
		public var scrollerPt:Point = new Point(0, 0);
		public var contentsPt:Point = new Point(0, 0);
		private var pinchingControl:PinchingControl;
		
		public function TouchSheet(pinchingControl:PinchingControl)
        {
            this.pinchingControl = pinchingControl;
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			this.addChild(contents);
		}
		private function onAddedToStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.addEventListener(TouchEvent.TOUCH, onTouch);
        }
        
        private function onTouch(event:TouchEvent):void
        {
			var touchStationary:Vector.<Touch> = event.getTouches(stage, TouchPhase.STATIONARY);
			var touchMoved:Vector.<Touch> = event.getTouches(stage, TouchPhase.MOVED);
			var touches:Vector.<Touch> = touchStationary.concat(touchMoved);
			if (touches.length != 0) if( !touches[0].isTouching(pinchingControl) ) return;
            
            if (touches.length == 2)
            {
				var _x:Number = x;
				var _y:Number = y;
				var _pivotX:Number = pivotX;
				var _pivotY:Number = pivotY;
				var _scaleX:Number = scaleX;
				// two fingers touching -> scale
                var touchA:Touch = touches[0];
                var touchB:Touch = touches[1];
                
                var currentPosA:Point  = touchA.getLocation(parent);
                var previousPosA:Point = touchA.getPreviousLocation(parent);
                var currentPosB:Point  = touchB.getLocation(parent);
                var previousPosB:Point = touchB.getPreviousLocation(parent);
				
				if(getPreviousLocationA && getPreviousLocationB)
				{
					if( getPreviousLocationA.equals(previousPosA) && getPreviousLocationB.equals(previousPosB) ) return;
				}
				getPreviousLocationA = previousPosA;
				getPreviousLocationB = previousPosB;
                
                var currentVector:Point  = currentPosA.subtract(currentPosB);
                var previousVector:Point = previousPosA.subtract(previousPosB);
                
                // update pivot point based on previous center
                var previousLocalA:Point  = touchA.getPreviousLocation(this);
                var previousLocalB:Point  = touchB.getPreviousLocation(this);
								
                pivotX = (previousLocalA.x + previousLocalB.x) * 0.5;
                pivotY = (previousLocalA.y + previousLocalB.y) * 0.5;
				
                // update location based on the current center
                x = (currentPosA.x + currentPosB.x) * 0.5;
                y = (currentPosA.y + currentPosB.y) * 0.5;

                // scale
                var sizeDiff:Number = currentVector.length / previousVector.length;
                scaleX *= sizeDiff;
                scaleY *= sizeDiff;
				
				currentPosA  = touchA.getLocation(pinchingControl);
                currentPosB  = touchB.getLocation(pinchingControl);
				scrollerPt = new Point( (currentPosA.x + currentPosB.x) * 0.5, (currentPosA.y + currentPosB.y) * 0.5 );
				
				var currentLocalA:Point  = touchA.getLocation(contents);
                var currentLocalB:Point  = touchB.getLocation(contents);
				contentsPt = new Point( (currentLocalA.x + currentLocalB.x) * 0.5 * scaleX, (currentLocalA.y + currentLocalB.y) * 0.5 * scaleY );
				
				if(scaleX < pinchingControl.minScale)
				{
					pivotX = _pivotX;
					pivotY = _pivotY;
					x = _x;
					y = _y;
					scaleX = scaleY = pinchingControl.minScale;
				}
				dispatchEvent( new TouchSheetEvent( TouchSheetEvent.PINCHING ) );
            }
			
			var touch:Touch = event.getTouch(pinchingControl, TouchPhase.ENDED);
            if (touch && touch.tapCount == 2)
			{
				scrollerPt = touch.getLocation(pinchingControl);
				var currentLocal:Point = touch.getLocation(contents);
				this.scaleX = this.scaleY = 1;
				contentsPt = new Point( currentLocal.x * scaleX, currentLocal.y * scaleY );
				dispatchEvent( new TouchSheetEvent( TouchSheetEvent.PINCHING ) );
			}
        }
        
        public override function dispose():void
        {
            if(stage) stage.removeEventListener(TouchEvent.TOUCH, onTouch);
            super.dispose();
        }
    }
}