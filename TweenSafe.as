package com.smp.effects{

	import flash.utils.Dictionary;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	import caurina.transitions.Tweener;
	import caurina.transitions.Equations;
	
	import com.smp.common.events.CustomEvent;
/**
 * @version This is a migration of the previous TweenSafe (that used the native fl.transitions package) to the caurina.transitions package.
 * This allows for the use of this class (and all classes within srg that depends on this) in the Flex SDK (which does not include the fl.transitions package)
 * Look for TweenSafe_fl.as for the previous version
 */
	public class TweenSafe extends EventDispatcher{
		
		public static const LINEAR:Function = Equations.easeNone;
		public static const REG_EASEIN:Function = Equations.easeInCubic;
		public static const REG_EASEOUT:Function = Equations.easeOutCubic;
		public static const REG_EASEINOUT:Function = Equations.easeInOutCubic;
		public static const STR_EASEIN:Function = Equations.easeInExpo;
		public static const STR_EASEOUT:Function = Equations.easeOutExpo;
		public static const STR_EASEINOUT:Function = Equations.easeInOutExpo;
		public static const BACK_EASEIN:Function = Equations.easeInBack;
		public static const BACK_EASEOUT:Function = Equations.easeOutBack;
		public static const BACK_EASEINOUT:Function = Equations.easeInOutBack;
		public static const ELASTIC_EASEIN:Function = Equations.easeInElastic;
		public static const ELASTIC_EASEOUT:Function = Equations.easeOutElastic;
		public static const ELASTIC_EASEINOUT:Function = Equations.easeInOutElastic;
		public static const EQUATIONS:Class = Equations;
		
		
		private var _active:Boolean;
		// dictionary that will hold my tweens
		private var _tweens:Dictionary;
		private var _objects:Array;
		private var _props:Array;


		/**
		 * @usage Uses caurina.transitions. 
		 * Dispatches CustomEvent on update and on complete (listen for Event.CHANGE and Event.COMPLETE).
		 * Look for the params property (Object) within this event, and expect target and property as inner properties of this object  
		 */
		public function TweenSafe() {

			// instantiate dictionary
			_tweens = new Dictionary();
			_objects = new Array();
			_props = new Array();
			_active = false;



		}
		/**
		 * 
		 * @param	obj
		 * @param	prop
		 * @param	func
		 * @param	begin
		 * @param	finish
		 * @param	duration
		 * @param	useSeconds: Ignored. Defaults to seconds.
		 * @param	forced : if set to false, it will ignore the tween if there is already an active tweening for both the specified object and property.
		 */
		public function setTween(obj:Object, prop:String, func:Function, begin:Number, finish:Number, duration:Number, useSeconds:Boolean = true, forced:Boolean = true, callback:Function = null):void {
			if (forced || !existElement(_objects, obj) || !existElement(_props, prop)) {

				_active = true;

				// create tween
				//var tween:Tween = new Tween(obj, prop, func, begin, finish, duration, useSeconds);
				obj[prop] = begin;
				
				var params:Object = new Object();
				params[prop] = finish;
				params.time = duration;
				params.transition = func;
				params.onComplete = onTweenFinish;
				var tween:TweenObject = new TweenObject();
				tween.target = obj;
				tween.property = prop;
				tween.callback = callback;
				params.onCompleteParams = [tween];
				params.onUpdate = onTweenChange;
				params.onUpdateParams = [tween];
				
				Tweener.addTween(obj, params);
								
				_tweens[tween] = true;
				_objects.push(obj);
				_props.push(prop);
			}
		}
		private function existElement(arr:Array, el:*):Boolean {
			for (var i:Object in arr) {
				if (arr[i] == el) {
					return true;
				}
			}
			return false;
		}
		// method called when tween is complete
		private function onTweenFinish(tween:TweenObject):void {

			for (var i:Object in _objects) {
				if (_objects[i] == tween.target) {
					_objects.splice(i,1);
				}
			}
			for (var j:Object in _props) {
				if (_props[j] == tween.property) {
					_props.splice(j,1);
				}
			}
			if (_objects.length == 0) {
				_active = false;
			}
			
			dispatchEvent(new CustomEvent(Event.COMPLETE, tween ));
			if (tween.callback != null) {
				tween.callback(tween);
			}
			// delete the tween object, freeing up the memory
			delete _tweens[tween];
		}
		
		private function onTweenChange(params:Object):void {
			
			var event:Event = new CustomEvent(Event.CHANGE, params);
			dispatchEvent(event);
			
		}
		
		public function removeTween(obj:Object, prop:String):Boolean {
			return Tweener.removeTweens(obj, prop);
		}
		
		public function get active():Boolean{
			return _active;
		}
	}
}