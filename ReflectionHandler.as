package com.smp.effects
{
	
	
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	
	
	import com.smp.common.display.ShapeUtils;

	/**
	 * Nota: se o objecto tiver animações e a área se expandir além da área inicial, 
	 * indicar um flash.geom.Rectangle
	 * com as dimensões máximas que o objecto atinge durante a animação.
	 * ex: new Rectangle(0,0, 300, 300);
	 * Se o objecto se estender para coordenadas negativas, usar os valores mínimos destas, em vez da origem 0,0
	 * Pode ser necessário forçar as dimensões da área, definindo explicitamente o argumento 'area'
	 */
	
	
	public class  ReflectionHandler extends Sprite
	{
	
		public static const BOTTOM:uint = 0;
		
		protected var type:uint
		protected var original:DisplayObject;
		protected var bmpData:BitmapData;
		protected var bitmap:Bitmap;
		protected var reflectionMasker:Shape;
		protected var originalMasker:Shape;
		protected var area:Rectangle;
		protected var updateInterval:Number = 0;
		protected var updater:Timer;
		
		public function ReflectionHandler(type:uint = 0)
		{
			this.type = type;
			
			
		}
		
		/**
		 * 
		 * @param	obj				Object to which apply the reflection. The object is centered horizontally, so usually a left side displacement occurs.
		 * @param	alphaRatio		Alpha values. In general would [1,0], the default.
		 * @param	ratio			From 0 to 255. 255 is equivalent to the object height (if BOTTOM)
		 * @param	area			Object map to be reflected. Defaults to object dimensions, but it may be necessary to force it, using this argument explicitly. 
		 * 							If the object dimensions change with time, define the maximum area expected (be aware of performance).
		 * 							Use Rectangle properties x and y if the object is not at 0,0.  
		 * @param	updateInterval	If the object is animated, define in miliseconds the update interval. If 0, no update occurs (it is drawn just once).
		 */
		public function create(obj:DisplayObject, alphaRatio:Array = null, ratio:Number = 255, area:Rectangle = null, updateInterval:Number = 0):void {
			switch(this.type) {
				case BOTTOM:
					this.createBottomReflection(obj, alphaRatio, ratio, area, updateInterval);
					break;
			}
		}
		
		protected function createBottomReflection(obj:DisplayObject, alphaRatio:Array = null, ratio:Number = 255, area:Rectangle = null, updateInterval:Number = 0):void {
			
			if (area == null) {
				area = new Rectangle(0, 0, obj.width, obj.height);
			}
			
			this.area = area;
			
			original = obj;
			original.x = -area.width/2 + area.x;
			original.y = area.y;
			
			
			if (alphaRatio == null) {
				alphaRatio = new Array(1, 0);
			}
			
			bmpData = new BitmapData(area.width, area.height, true, 0x00000000);
			bmpData.draw(original);
			bitmap = new Bitmap(bmpData, "auto", true);
			bitmap.scaleY = -1;
			bitmap.x = original.x;
			bitmap.y = 2 * area.height;
			
			
			reflectionMasker = new Shape();
			with (reflectionMasker.graphics) {
				var matrix:Matrix = new Matrix();
				matrix.createGradientBox(area.width, area.height, Math.PI/2,0,0);
				beginGradientFill(GradientType.LINEAR, new Array(0x000000, 0x000000), new Array(alphaRatio[0],alphaRatio[1]), new Array(0,ratio), matrix);
				drawRect(0,0, area.width, area.height);
				endFill();
			}
			
			//position the gradient mask
			reflectionMasker.y = area.height;
			
			//cache the bitmap holding movieclips as bitmaps
			bitmap.cacheAsBitmap = true;
			reflectionMasker.cacheAsBitmap = true;
			reflectionMasker.x  = original.x;
			bitmap.mask = reflectionMasker;
			
			
			originalMasker = ShapeUtils.createRectangle(area.width, area.height);
			original.cacheAsBitmap = true;
			originalMasker.cacheAsBitmap = true;
			originalMasker.x =  original.x;
			original.mask = originalMasker;
			
			
			addChild(original);
			addChild(originalMasker);
			addChild(bitmap);
			addChild(reflectionMasker);
			
			this.updateInterval = updateInterval;
			//just initialize...
			updater = new Timer(1000);
			
			if (updateInterval>0)
			{
				updater.delay = updateInterval;
				updater.addEventListener(TimerEvent.TIMER, update);
				updater.start();
			}

		}
		
		
		protected function update(evt:TimerEvent):void {
				
			//actualiza a máscara para se adaptar à animação interna do mc original
			originalMasker.width = area.width;
			originalMasker.height = area.height;
			
			//evita qualquer actualização do reflexo (bitmap) enquanto é limpa a informação anterior no bmpData
			bmpData.lock();
			//limpa o bmpData (desenha um rectangulo transparente)
			bmpData.fillRect(bmpData.rect, 0);
			//remove a máscara sobre o original (há um problema de recorte que não consegui resolver)
			original.mask = null;
			//actualiza
			bmpData.draw(original);
			//volta a aplicar a máscara
			original.mask = originalMasker;
			//liberta o bmpData para ser novamente acessível pelo bitmap
			bmpData.unlock();
			
			
			
			
		}
		
		public function set distance(value:Number):void {
			
			value = -value;
			
			switch(this.type) {
				case BOTTOM:
					original.y = value;
					bitmap.y = 2 * area.height - value;
					
					if(value<0){
						originalMasker.height = area.height - value;
						originalMasker.y = value;
						
						reflectionMasker.height = area.height - value;
					}
					
					break;
			}
		}
		
		public function get distance():Number {
			switch(this.type) {
				case BOTTOM:
					return -original.y;
					break;
			}
			return 0;
		}
		
		public function freeze():void 
		{
			if(updateInterval > 0){
				updater.stop();
			}
		}
		
		public function defrost(time:Number = 0):void 
		{
			if (time != 0) {
				if (updateInterval == 0) {
					updater.addEventListener(TimerEvent.TIMER, update);
				}
				updateInterval = time;
				updater.delay = updateInterval;
			}
			if (updateInterval > 0) {
				updater.start();
			}
		}
	}
	
}