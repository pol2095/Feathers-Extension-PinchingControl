package com.examples
{
	import feathers.extensions.zoomable.PinchingControl;
	import feathers.controls.LayoutGroup;
	import feathers.controls.ScrollContainer;
	import feathers.layout.VerticalLayout;
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.themes.MetalWorksDesktopTheme;
	import feathers.events.FeathersEventType;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	import flash.display.Bitmap;
	import starling.display.Image;
	
	public class PinchingControlExample extends LayoutGroup
	{
		[Embed(source="../../spritesheet/images/mediumIcons.png")]
		private const close_imageSpriteSheet:Class;
		[Embed(source="../../spritesheet/images/mediumIcons.xml", mimeType="application/octet-stream")]
		private const close_atlas:Class;
		private var xml:XML = XML(new close_atlas());
		private var bitmap:Bitmap = new close_imageSpriteSheet;
		private var texture:Texture = Texture.fromBitmap(bitmap, false, false, 0.2);
		private var textureAtlas:TextureAtlas = new TextureAtlas(texture, xml);
		private var folderTexture:Texture = textureAtlas.getTexture("folder-icon0000");
		
		private var pinchingControl:PinchingControl;
		private var image:ImageLoader;
		
		public function PinchingControlExample()
		{
			new MetalWorksDesktopTheme();
			super();
			
			var scrollContainer:ScrollContainer = new ScrollContainer();
			scrollContainer.layout = new VerticalLayout();
			this.addChild( scrollContainer );
			
			var pinch:Button = new Button();
			pinch.label = "pinch";
			pinch.addEventListener( Event.TRIGGERED, buttonHandler );
			scrollContainer.addChild( pinch );
			
			pinchingControl = new PinchingControl();
			pinchingControl.scroller = scrollContainer;
			pinchingControl.minScale = 0.5;
			pinchingControl.isCentered = true;
			pinchingControl.height = 250;
			pinchingControl.layout = new VerticalLayout();
			scrollContainer.addChild( pinchingControl );
			
			image = new ImageLoader();
			pinchingControl.addChild( image );
			
			this.addEventListener( FeathersEventType.CREATION_COMPLETE, creationCompleteHandler );
		}
		
		private function creationCompleteHandler( event:Event ):void
		{
			this.removeEventListener( FeathersEventType.CREATION_COMPLETE, creationCompleteHandler );
			
			onResize(event);
			stage.addEventListener(Event.RESIZE, onResize);
			image.source = folderTexture;
		}
		
		private function buttonHandler( event:Event ):void
		{
			pinchingControl.reset();
		}
		
		private function onResize(event:Event):void
		{
			pinchingControl.width = stage.stageWidth;
		}
	}
}