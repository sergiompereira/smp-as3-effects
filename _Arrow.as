package app
{
	import com.smp.effects.AnimatedBezierCurve;
	import com.smp.common.math.Geometry2D;
	import flash.events.Event;
	
	import flash.display.Graphics;
	import flash.geom.Point;
	
	
	public class Arrow extends AnimatedBezierCurve
	{
		private var params:Object = { };
		
		public function Arrow(graphics:Graphics) {
			super(graphics);
		}
		override public function animateCubic(startpoint:Point, destpoint:Point, control1:Point, control2:Point, timespan:Number):void {
			super.animateCubic(startpoint, destpoint, control1, control2, timespan);
		
			params.startpoint = startpoint;
			params.destpoint = destpoint;
			params.control1 = control1;
			params.control2 = control2;
			
			addEventListener(Event.COMPLETE, onAnimationComplete);
			
		}
		
		function onAnimationComplete(evt):void {
			removeEventListener(Event.COMPLETE, onAnimationComplete);
			drawArrow();
		}
		
		function drawArrow():void {
			var lastPoint:Point = interpolatePoint(params.startpoint, params.destpoint, params.control1, params.control2, 1);
			var prevPoint:Point = interpolatePoint(params.startpoint, params.destpoint, params.control1, params.control2, 1 - 0.01);
			var angle = Geometry2D.getLineAngle(prevPoint, lastPoint);
			
			trace(Geometry2D.radianToDegree(angle))
			var point1:Point = new Point(lastPoint.x, lastPoint.y+2*options.thickness);
			var point2:Point = new Point(lastPoint.x, lastPoint.y - 2 * options.thickness);
			var point3:Point = new Point(lastPoint.x + 3 * options.thickness, lastPoint.y);
			point1 = Geometry2D.rotatePoint(lastPoint, point1, angle);
			point2 = Geometry2D.rotatePoint(lastPoint, point2, angle);
			point3 = Geometry2D.rotatePoint(lastPoint, point3, angle);
			
			graphics.moveTo(point1.x, point1.y);
			graphics.lineTo(point2.x, point2.y);
			graphics.lineTo(point3.x, point3.y);
			graphics.lineTo(point1.x, point1.y);
		}
	}
	
}