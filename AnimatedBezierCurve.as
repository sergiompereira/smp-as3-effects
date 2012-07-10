package com.smp.effects
{
	import com.smp.common.math.BezierCurve;
	import com.smp.common.math.Geometry2D;
	import flash.errors.IOError;
	
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * @example
	 * 		path = new Sprite();
			
			var curver:AnimatedBezierCurve = new AnimatedBezierCurve(path.graphics);
			curver.lineStyle(7, 0x990000, 10,5);
			curver.animateCubic(new Point(20,20), new Point(300,20), new Point(200,0), new Point(100,200),1.5);
			
			addChild(path);
	 */

	public class  AnimatedBezierCurve extends BezierCurve
	{
		public function AnimatedBezierCurve(graphics:Graphics) {
			super(graphics);
		}
		
		public function animateCubic(startpoint:Point, destpoint:Point, control1:Point, control2:Point,timespan:Number):void {
			if (!options) {
				throw IOError('Line style was not set.');
			}
			
			graphics.lineStyle(1, options.color);
			graphics.beginFill(options.color);
			
			var inc:Number = 0.001;
			var i:Number = 0;
			var point:Point;
			var length:Number = 0;
			var stroke:Boolean = true;
			var lastPoint:Point;
			var nextPoint:Point;
			var timer:Timer;
			
			var steps:Number = Math.floor(timespan * 30);
			var tstrokes:Number = Math.floor(1 / inc);
			var loopcount:Number = Math.floor(tstrokes / steps);
			var delay:Number = Math.floor(timespan * 1000 / steps);
			trace(steps+' // '+ tstrokes+' // '+loopcount+' // '+ delay);
			
			timer = new Timer(delay);
			timer.addEventListener(TimerEvent.TIMER, draw);
			timer.start();
			
			function draw(evt:TimerEvent):void {
				var count:int;
				for (count = 0; count <= loopcount; count++) {
					if (i > 1) {
						timer.stop();
						timer.removeEventListener(TimerEvent.TIMER, draw);
						//timer = null;
					}else{
						if (nextPoint) {
							point = nextPoint;
						}else {
							point = interpolatePoint(startpoint,destpoint, control1, control2,i);
						}
						
						if(lastPoint){
							length += Geometry2D.getDistance(lastPoint.x, lastPoint.y, point.x, point.y);
						}
						
						nextPoint = interpolatePoint(startpoint,destpoint, control1, control2, i + inc);
						if (stroke) {
							var angle:Number = 0;
							if (nextPoint) {
								angle = Geometry2D.getLineAngle(point, nextPoint);
							}
							drawRect(point, angle);
						}
						
						if ((stroke && length > options.dashlen) || (!stroke && length > options.spacelen)) {
							stroke = !stroke;
							length = 0;
						}
						
						lastPoint = point;
					}
					i+=inc;
				}
			}
		}
	}
	
}