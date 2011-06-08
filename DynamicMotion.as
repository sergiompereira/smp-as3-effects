package com.smp.effects {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import fl.motion.Animator;
	import fl.motion.MotionEvent;
	
	
	import srg.data.LoadXML;
	
	
	public class DynamicMotion extends Sprite{
		
		private var _obj:*;
		private var _loadXml:LoadXML;
		private var _xml:XML;
		private var _anim:Animator;
		
		
		public function DynamicMotion(obj:*){
			
			_obj = obj;		
			addChild(_obj);
			
		}
		
		public function load(xmlpath:String):void{
			_loadXml = new LoadXML(xmlpath, true, null, false);
			_loadXml.addEventListener(Event.COMPLETE, onXmlLoaded, false, 0, true);
		}
		
		private function onXmlLoaded(evt:Event):void{
			
			_xml = _loadXml.XMLTree;
			_anim = new Animator(_xml, _obj);
			_anim.addEventListener(MotionEvent.MOTION_END, onMotionEnd, false,0,true);
			_anim.play();
			
		}
		
		private function onMotionEnd(evt:MotionEvent):void {
			_anim.removeEventListener(MotionEvent.MOTION_END, onMotionEnd);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
	}
}