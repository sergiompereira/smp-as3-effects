package com.smp.effects
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import com.smp.common.math.ColorUtils;
	import com.smp.common.events.CustomEvent;
	
	
	public class ColorTweener extends EventDispatcher 
	{
		
		private var _timer:Timer;
		private var _colorIndex:uint;
		private var _processing:Boolean = false;
		private var _gradientColl:Array;
		
		public function ColorTweener() {
			_timer = new Timer(1000);
			
		}
		
		/**
		 * Listen for Event.CHANGE. Expect a CustomEvent with a color property in the data property
		 * @param	startColor
		 * @param	endColor
		 * @param	steps		: gradient resolution
		 * @param	time		: in seconds
		 */
		public function tweenColors(startColor:uint, endColor:uint, steps:uint, time:Number):void {
			
			if(_processing){
				_timer.reset();
				_timer.removeEventListener(TimerEvent.TIMER, onUpdate);
			}
			_processing = true;
			_gradientColl = ColorUtils.getGradient([startColor, steps, endColor]);
				
			_colorIndex = 0;
			_timer.delay = time / steps;
			_timer.addEventListener(TimerEvent.TIMER, onUpdate);
			_timer.start();
			
		}
		
		private function onUpdate(evt:TimerEvent):void 
		{
			dispatchEvent(new CustomEvent(Event.CHANGE, { color: _gradientColl[_colorIndex] } ));
			_colorIndex++;
			if (_colorIndex == _gradientColl.length) {
				_processing = false;
				_timer.reset();
				_timer.removeEventListener(TimerEvent.TIMER, onUpdate);
				dispatchEvent(new Event(Event.COMPLETE));
		
			}
		}
	}
	
}