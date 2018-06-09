/*
Copyright 2016 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.extensions.zoomable
{
	import feathers.core.FeathersControl;
	import feathers.controls.LayoutGroup;
	import feathers.controls.ScrollContainer;
	import feathers.events.FeathersEventType;
	import feathers.core.IFeathersControl;
	import feathers.layout.ILayoutDisplayObject;
	import feathers.layout.ILayout;
	
    import feathers.extensions.utils.TouchSheet;
	import feathers.extensions.utils.events.TouchSheetEvent;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	import starling.display.Sprite;
	import flash.geom.Point;
	
	import flash.geom.Rectangle;
	
    /**
	 * Pinching control that allows a pinch to zoom mechanic using the multitouch inputs of a mobile device.
	 */
	public class PinchingControl extends ScrollContainer
    {
		private var sheet:TouchSheet;
		private var layoutGroup:LayoutGroup;
		private var pinchingContentsEnabled:Boolean;
		/**
		 * Determines if the layout is centered.
		 *
		 * @default false
		 */
		public var isCentered:Boolean;
		
		private var _minScale:Number = 1;
		/**
		 * The minimum scale.
		 *
		 * @default 1
		 */
		public function get minScale():Number
		{
			return this._minScale;
		}
		public function set minScale(value:Number):void
		{
			this._minScale = value;
		}
		
		private var _maxScale:Number = NaN;
		/**
		 * The maximum scale.
		 *
		 * @default NaN
		 */
		public function get maxScale():Number
		{
			return this._maxScale;
		}
		public function set maxScale(value:Number):void
		{
			this._maxScale = value;
		}
		
		/**
		 * A ScrollContainer that stops scrolling when this control scroll or is pinched.
		 */
		public var scroller:ScrollContainer;
		private var isFirstTouched:Boolean;
		
		public function PinchingControl()
        {
			this.addEventListener(Event.SCROLL, onScroll);
			
			sheet = new TouchSheet(this);
			sheet.addEventListener(TouchSheetEvent.PINCHING, onPinching);
			layoutGroup = new LayoutGroup();
			layoutGroup.includeInLayout = false;
			layoutGroup.addChild(sheet);
            this.addChild(layoutGroup);
			this.pinchingContentsEnabled = true;
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
		
		private function onAddedToStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.addEventListener(Event.RESIZE, onResize);
        }
		/**
		 * @private
		 */
		public function onResize(event:Event = null):void
        {
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}
				
		private function adjust():void
        {			
			layoutGroup.x = sheet.width > this.width || !isCentered ? -sheet.x : -sheet.x + (this.width - sheet.width) / 2;
			layoutGroup.pivotX = -sheet.pivotX * sheet.scaleX;
			layoutGroup.y = sheet.height > this.height || !isCentered ? -sheet.y : -sheet.y + (this.height - sheet.height) / 2;
			layoutGroup.pivotY = -sheet.pivotY * sheet.scaleY;
			
			viewPortResize();
			
			this.scrollTo();
			this.validate();
		}
		
		private function onPinching(event:TouchSheetEvent = null):void
        {
			if(scroller) scroller.stopScrolling();
			this.stopScrolling();
			
			adjust();
			
			isFirstTouched = true;
		}
		
		private function scrollTo():void
		{
			var position:Number;
			if(sheet.width > this.width)
			{
				position = sheet.contentsPt.x - sheet.scrollerPt.x;
				if(position >= 0 && position <= this.maxHorizontalScrollPosition) this.horizontalScrollPosition = position;
				else if(position < 0) this.horizontalScrollPosition = 0;
				else if(position > this.maxHorizontalScrollPosition) this.horizontalScrollPosition = this.maxHorizontalScrollPosition;
			}
			
			if(sheet.height > this.height)
			{
				position = sheet.contentsPt.y - sheet.scrollerPt.y;
				if(position >= 0 && position <= this.maxVerticalScrollPosition) this.verticalScrollPosition = position;
				else if(position < 0) this.verticalScrollPosition = 0;
				else if(position > this.maxVerticalScrollPosition) this.verticalScrollPosition = this.maxVerticalScrollPosition;
			}
		}
		
		private function onScroll(event:Event):void
        {
			if(scroller) scroller.stopScrolling();
			if(!this.isScrolling) return;
			isFirstTouched = true;
		}
		
		/**
		 * @private
		 */
		public function _autoSizeIfNeeded():void
        {
			adjust();
			if(!isFirstTouched)
			{
				if(sheet.width > this.width)
				{
					if(this.maxHorizontalScrollPosition == 0) viewPortResize();
					if(this.maxHorizontalScrollPosition == 0) this.invalidate(INVALIDATION_FLAG_SIZE); //bug correction at start
					else if(isCentered) this.horizontalScrollPosition = this.maxHorizontalScrollPosition / 2;
				}
				
				if(sheet.height > this.height)
				{
					if(this.maxVerticalScrollPosition == 0) viewPortResize();
					if(this.maxVerticalScrollPosition == 0) this.invalidate(INVALIDATION_FLAG_SIZE); //bug correction at start
					else if(isCentered) this.verticalScrollPosition = this.maxVerticalScrollPosition / 2;
				}
			}
		}
		
		/**
		 * @private
		 */
		override public function get numChildren():int
		{
			if(!this.displayListBypassEnabled)
			{
				return super.numChildren;
			}
			if(!this.pinchingContentsEnabled)
			{
				return DisplayObjectContainer(this.viewPort).numChildren;
			}
			return DisplayObjectContainer(this.sheet.contents).numChildren;
		}
		
		/**
		 * @private
		 */
		override public function getChildByName(name:String):DisplayObject
		{
			if(!this.displayListBypassEnabled)
			{
				return super.getChildByName(name);
			}
			if(!this.pinchingContentsEnabled)
			{
				return DisplayObjectContainer(this.viewPort).getChildByName(name);
			}
			return DisplayObjectContainer(this.sheet.contents).getChildByName(name);
		}
		
		/**
		 * @private
		 */
		override public function getChildAt(index:int):DisplayObject
		{
			if(!this.displayListBypassEnabled)
			{
				return super.getChildAt(index);
			}
			if(!this.pinchingContentsEnabled)
			{
				return DisplayObjectContainer(this.viewPort).getChildAt(index);
			}
			return DisplayObjectContainer(this.sheet.contents).getChildAt(index);
		}
		
		/**
		 * @private
		 */
		override public function addChild(child:DisplayObject):DisplayObject
		{
			return this.addChildAt(child, this.numChildren);
		}
		
		/**
		 * @private
		 */
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			if(!this.displayListBypassEnabled)
			{
				return super.addChildAt(child, index);
			}
			if(!this.pinchingContentsEnabled)
			{
				var result:DisplayObject = DisplayObjectContainer(this.viewPort).addChildAt(child, index);
				if(result is IFeathersControl)
				{
					result.addEventListener(Event.RESIZE, child_resizeHandler);
				}
				if(result is ILayoutDisplayObject)
				{
					result.addEventListener(FeathersEventType.LAYOUT_DATA_CHANGE, child_layoutDataChangeHandler);
				}
				this.invalidate(INVALIDATION_FLAG_SIZE);
				return result;
			}
			var _result:DisplayObject = DisplayObjectContainer(this.sheet.contents).addChildAt(child, index);
			this.invalidate(INVALIDATION_FLAG_SIZE);
			return _result;
		}
		
		/**
		 * @private
		 */
		override public function removeChildAt(index:int, dispose:Boolean = false):DisplayObject
		{
			if(!this.displayListBypassEnabled)
			{
				return super.removeChildAt(index, dispose);
			}
			if(!this.pinchingContentsEnabled)
			{
				var result:DisplayObject = DisplayObjectContainer(this.viewPort).removeChildAt(index, dispose);
				if(result is IFeathersControl)
				{
					result.removeEventListener(Event.RESIZE, child_resizeHandler);
				}
				if(result is ILayoutDisplayObject)
				{
					result.removeEventListener(FeathersEventType.LAYOUT_DATA_CHANGE, child_layoutDataChangeHandler);
				}
				this.invalidate(INVALIDATION_FLAG_SIZE);
				return result;
			}
			var _result:DisplayObject = DisplayObjectContainer(this.sheet.contents).removeChildAt(index, dispose);
			this.invalidate(INVALIDATION_FLAG_SIZE);
			return _result;
		}
		
		/**
		 * @private
		 */
		override public function getChildIndex(child:DisplayObject):int
		{
			if(!this.displayListBypassEnabled)
			{
				return super.getChildIndex(child);
			}
			if(!this.pinchingContentsEnabled)
			{
				return DisplayObjectContainer(this.viewPort).getChildIndex(child);
			}
			return DisplayObjectContainer(this.sheet.contents).getChildIndex(child);
		}
		
		/**
		 * @private
		 */
		override public function setChildIndex(child:DisplayObject, index:int):void
		{
			if(!this.displayListBypassEnabled)
			{
				super.setChildIndex(child, index);
				return;
			}
			if(!this.pinchingContentsEnabled)
			{
				DisplayObjectContainer(this.viewPort).setChildIndex(child, index);
			}
			DisplayObjectContainer(this.sheet.contents).setChildIndex(child, index);
		}
		
		/**
		 * @private
		 */
		override public function swapChildrenAt(index1:int, index2:int):void
		{
			if(!this.displayListBypassEnabled)
			{
				super.swapChildrenAt(index1, index2);
				return;
			}
			if(!this.pinchingContentsEnabled)
			{
				DisplayObjectContainer(this.viewPort).swapChildrenAt(index1, index2);
			}
			DisplayObjectContainer(this.sheet.contents).swapChildrenAt(index1, index2);
		}
		
		/**
		 * @private
		 */
		override public function sortChildren(compareFunction:Function):void
		{
			if(!this.displayListBypassEnabled)
			{
				super.sortChildren(compareFunction);
				return;
			}
			if(!this.pinchingContentsEnabled)
			{
				DisplayObjectContainer(this.viewPort).sortChildren(compareFunction);
			}
			DisplayObjectContainer(this.sheet.contents).sortChildren(compareFunction);
		}
		
		/**
		 * @private
		 */
		override public function set layout(value:ILayout):void
		{
			if(this.processStyleRestriction(arguments.callee))
			{
				return;
			}
			if(this._layout === value)
			{
				return;
			}
			this._layout = value;
			this.sheet.contents.layout = this._layout;
			this.invalidate(INVALIDATION_FLAG_LAYOUT);
		}
		
		/**
		 * Reposition and rescale this layout.
		 */
		public function reset():void
        {
			sheet.scaleX = sheet.scaleY = 1;
			layoutGroup.x = layoutGroup.y = layoutGroup.pivotX = layoutGroup.pivotY = sheet.x = sheet.y = sheet.pivotX = sheet.pivotY = 0;
			viewPortResize();
			reposition();
		}
		
		/**
		 * Reposition this layout.
		 */
		public function reposition():void
        {
			isFirstTouched = false;
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		private function viewPortResize():void
        {
			layoutGroup.validate();
			this.viewPort.setSize(sheet.width, sheet.height);
			this.validate();
		}
		
		/**
		 * @private
		 */
		override protected function draw():void
		{
			super.draw();
			if( this.isInvalid(INVALIDATION_FLAG_SIZE) ) this._autoSizeIfNeeded();
		}
		
		/**
		 * @private
		 */
		override public function dispose():void
		{
			this.removeEventListener(Event.SCROLL, onScroll);
			sheet.removeEventListener(TouchSheetEvent.PINCHING, onPinching);
			if(stage) stage.removeEventListener(Event.RESIZE, onResize);
			super.dispose();
		}
	}
}