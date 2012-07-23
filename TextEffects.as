
package com.smp.effects{

	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.text.*;
	import flash.utils.Timer;
	import flash.events.*;
	
	/**
	 * @dependencies : com.gskinner.motion.GTween
	 */
	import com.smp.common.text.TextUtils;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.*;
	
	
	
	public class TextEffects{

		/**
		 * Add an object with properties target and timer
		 */
		private var _calls:Array = new Array();

		public function TextEffects() {
			//
		}
		
		private function clearCall(target:Object, timer:Timer):Boolean 
		{
			var exists:Boolean = false;
			for (var i:uint = 0; i < _calls.length; i++) {
				if (_calls[i].target == target && _calls[i].timer == timer) 
				{
					_calls[i].timer.reset();
					
					/*
					delete _calls[i].target;
					delete _calls[i].timer;
					*/
					
					_calls.splice(i, 1);
					
					exists = true;
					return exists;
				}
			}
			return exists;
		}
		
		public function destroyEffects(target:Object):void 
		{
			for (var i:uint = 0; i < _calls.length; i++) {
				if (_calls[i].target == target) {
					_calls[i].timer.reset();
					
					clearCall(target, _calls[i].timer);
				}
			}
		}
		
		/**
		 * 
		 * @param	textField
		 * @param	text
		 * @param 	nChar : de incremento. Como o timer delay pode resultar em valores não compatíveis com o processador, este valor pode optimizar a animação. 
		 * @param	time : milisegundos de duração da animação total. Controlar a performance com nChar
		 */
		public function flowText(textField:TextField, text:String, nChar:Number, time:Number) {
			
			textField.text = text;
			var i:uint;
			var numlines:uint = textField.numLines;
			for (i = 0; i < numlines; i++){
				var lineTxt:String = textField.getLineText(i);
				var lineLength:Number = lineTxt.length;
				if (lineTxt.substr(lineLength - 1, 1) == " ") {
					textField.replaceText(textField.getLineOffset(i)+lineLength -1, lineLength, "\n");
				}
			}
			text = textField.text;
			textField.text = "";
			
			var totalChar:Number = text.length;
			var posChar:Number = 0;
			var textProg:String = "";
			var interval:Number = time / (totalChar / nChar);
			//trace(interval)
			var timer:Timer = new Timer(interval);
			
			destroyEffects(textField);
			_calls.push({target:textField, timer:timer});
			
			
			timer.removeEventListener(TimerEvent.TIMER, incrementText);
			timer.addEventListener(TimerEvent.TIMER, incrementText);
			timer.start();
			
			function incrementText(evt:TimerEvent):void {

				if (posChar <= totalChar) {
									
					for (var n=posChar; n<=posChar+nChar; n++) {
						textProg += text.charAt(n);
					}
					
					textField.text = textProg;

				} else {
					timer.removeEventListener(TimerEvent.TIMER, incrementText);
					timer.reset();
					
					clearCall(textField, timer);
					
				}
				posChar += nChar+1;
			}
		}
		
		/**
		 * 
		 * @param	textField
		 * @param	text
		 * @param 	numWords : de incremento. Como o timer delay pode resultar em valores não compatíveis com o processador, este valor pode optimizar a animação. 
		 * @param	time : milisegundos de duração da animação total. Controlar a performance com numWords
		 */
		public function flowWords(textField:TextField, text:String, numWords:Number, time:Number):void{
			
			var indexWord:uint = 0;
			var arrayWords:Array = text.split(" ");
			var textProg:String = "";
			
			var interval:Number = time / (arrayWords.length/numWords);
			var timer:Timer = new Timer(interval);
			
			destroyEffects(textField);
			_calls.push( { target:textField, timer:timer } );
			
			textField.text = "";
			
			
			for(var i:uint = 0; i<arrayWords.length; i++){
				arrayWords[i] = arrayWords[i]+" ";
			}
			
			timer.removeEventListener(TimerEvent.TIMER, incrementText);
			timer.addEventListener(TimerEvent.TIMER, incrementText);
			timer.start();
			
			
			function incrementText(evt:TimerEvent):void{
			
				if(indexWord < arrayWords.length){
					
					for (var n = indexWord; n <= indexWord + numWords; n++) {
						if(arrayWords[n]!=undefined){
							textProg += arrayWords[n];
						}
					}
					
					textField.htmlText = textProg;

				} else {
					timer.removeEventListener(TimerEvent.TIMER, incrementText);
					timer.reset();
					clearCall(textField, timer);
				}
				
				indexWord += numWords+1;
			}
		}
		
		
		
		
		/**
		 * ex: TextEffects.flowSentences(container, str, txtformat, 50, 2, 500, 50);
		 * @param	container -> onde irá ser integrado o TextField
		 * @param	text -> text
		 * @param	textFormat
		 * @param	maxSentenceLength -> valor máximo de caracteres por linha. É procurado o espaço em branco imediatamente anterior para definir a quebra de linha. É possível usar \n e <br> para forçar quebras de linha.
		 * @param	numberCharactersIncrement -> número de caracteres por cada incremento da animação
		 * @param	time -> tempo de duração total em milisegundos
		 * @param	delay -> tempo de espera antes de começar a segunda linha (e entre as seguintes)
		 * @param	embedFont -> defaults to false; 
		 * @param	antiAlias -> if not null, antialias is set to ADVANCED. Pass thickness and sharpness as properties of this object (eg: 100, -100)
		 */
		public function flowSentences(container:DisplayObjectContainer, text:String, textFormat:TextFormat, maxSentenceLength:Number, numberCharactersIncrement:Number, time:Number, delay:Number, embedFont:Boolean = false, antiAlias:Object = null, lineSpacing:Number = 0 ) {

			
			var totalChar:Number = text.length;
			var interval:Number = time / (maxSentenceLength / numberCharactersIncrement);
			var timer:Timer = new Timer(interval);
			var timerdelay:Timer = new Timer(delay);
			
			_calls.push({target:container, timer:timer});
			
			var sentences:Array = new Array();
			var txtFields:Array = new Array();
			var textProg:Array = new Array();
			
			//constrói as linhas, garantindo que a quebra é feita num espaço branco:
			var i:uint = 0;
			var j:uint;
			while (i < text.length) {
				
				var sentence:String = text.substr(i, maxSentenceLength);
				var breakposn:int = sentence.search("\\n");
				var breakposbr:int = sentence.search("<br>");
				
				if (breakposbr >= 0) 
				{
					trace("breakposbr "+breakposbr)
					sentence = sentence.substr(0, breakposbr - 1);
					sentences.push(sentence);
					i += sentence.length + 5;
				}else
				if (breakposn >= 0) 
				{
					sentence = sentence.substr(0, breakposn - 1);
					sentences.push(sentence);
					i += sentence.length + 2;
					
				}else
				if (sentence.length >= maxSentenceLength)
				{
					j = sentence.length - 1;
					
					while (!isWhitespace(sentence.charAt(j))) 
					{
						if (j > 0) {
							j--;
						}else {
							break;
						}
					}
					//trace(j);
					sentence = sentence.substr(0, j);
					//trace(sentence)
					sentences.push(sentence);
					i += (j + 1);
				}
				else
				{
					sentences.push(sentence);
					i = text.length;
				}

				//trace(i);
			}
			
			var posChars:Array = new Array();
			
			for (i = 0; i < sentences.length; i++) 
			{
				var txtField:TextField = TextUtils.createTextField("", textFormat);
				if (embedFont) {
					txtField.embedFonts = true;
				}
				if(antiAlias != null){
					txtField.antiAliasType = AntiAliasType.ADVANCED;
					txtField.thickness = antiAlias.thickness;
					txtField.sharpness = antiAlias.sharpness;
				}
				
				switch(textFormat.align) {
					case "left":
						txtField.autoSize = TextFieldAutoSize.LEFT;
						break;
					case "right":
						txtField.autoSize = TextFieldAutoSize.RIGHT;
						break;
					case "center":
						txtField.autoSize = TextFieldAutoSize.CENTER;
						break;
					default:
						txtField.autoSize = TextFieldAutoSize.LEFT;
						break;
				}
				
				txtField.text = " ";
				txtField.y = (txtField.textHeight+lineSpacing) * i;
				txtField.text = "";
				container.addChild(txtField);
				txtFields.push(txtField);
				textProg[i] = "";
				posChars.push(0);
				
			}
			
			var looplength:Number = 0;
			//timerdelay.removeEventListener(TimerEvent.TIMER, incrementLoopLength);
			timerdelay.addEventListener(TimerEvent.TIMER, incrementLoopLength);
			timerdelay.start();
			
			//timer.removeEventListener(TimerEvent.TIMER, incrementText);
			timer.addEventListener(TimerEvent.TIMER, incrementText);
			timer.start();
			
			
			function incrementText(evt:TimerEvent):void {
				
				for (i = 0; i < looplength; i++) {
					
					if (posChars[i]<=maxSentenceLength) {
						for (var n=posChars[i]; n<=posChars[i]+numberCharactersIncrement; n++) {
							textProg[i] += sentences[i].charAt(n);
						}
						txtFields[i].text = textProg[i];
						posChars[i] += numberCharactersIncrement + 1;
					} 
				}
				
				if (posChars[looplength - 1] > maxSentenceLength) {
					timer.removeEventListener(TimerEvent.TIMER, incrementText);
					timer.stop();
					
					clearCall(container, timer);
				}
				
				
			}
			
			
			function incrementLoopLength(evt:TimerEvent):void {
				if (looplength < txtFields.length) {
					looplength++;
				}else {
					timerdelay.removeEventListener(TimerEvent.TIMER, incrementLoopLength);
					timerdelay.reset();
				}
			}
			
		}
		
		
		private function isWhitespace( ch:String ):Boolean {
			return ch == '\r' || 
					ch == '\n' ||
					ch == '\f' || 
					ch == '\t' ||
					ch == ' '; 
		}
		
		
		/**
		 * 
		 * @param	container
		 * @param	text
		 * @param	textFormat
		 * @param	scale -> scale to start from
		 * @param	alpha -> alpha transparency to start from
		 * @param	time -> overall time length (miliseconds)
		 * @param	scaleTime -> scale out time length (miliseconds)
		 * @param	embedFont -> use just if the font is included in the project as an asset
		 * @param	antiAlias -> if not null, antialias is set to ADVANCED. Pass thickness and sharpness as properties of this object (eg: 100, -100)
		 */
		public  function scaleOutLetters(container:DisplayObjectContainer, text:String, textFormat:TextFormat, scale:Number, alpha:Number, time:Number, scaleTime:Number, embedFont:Boolean = false, antiAlias:Object = null):void {
			
			var totalChar:Number = text.length;
			
			var interval:Number;
			if (totalChar <= 0) {
				return
				
			}else {
				interval = time / totalChar;
			}
			
			var timer:Timer = new Timer(interval);
			
			_calls.push({target:container, timer:timer});
			
			timer.addEventListener(TimerEvent.TIMER, incrementText);
			timer.start();
			
			var i:uint = 0;
			var textFields:Array = new Array();
			var txtField:TextField;
			var letterContainer:Sprite;
			var heightCorrection:Number = 0;
			
			
			function incrementText(evt:TimerEvent):void 
			{
				if (i <= totalChar) {
						
					
					txtField = TextUtils.createTextField(text.substr(i, 1), textFormat);
					letterContainer = new Sprite();
					letterContainer.addChild(txtField);
					
					if (embedFont) {
						txtField.embedFonts = true;
					}
					if(antiAlias != null){
						txtField.antiAliasType = AntiAliasType.ADVANCED;
						txtField.thickness = antiAlias.thickness;
						txtField.sharpness = antiAlias.sharpness;
					}
					
					if (heightCorrection == 0) {
						heightCorrection = txtField.textHeight / 1.5;
					}
					
					txtField.y = -heightCorrection;
					letterContainer.y = heightCorrection;
					
					if(textFields.length>0){
						letterContainer.x = textFields[i-1].x + (textFields[i-1].getChildAt(0) as TextField).textWidth;
					}
					
					letterContainer.scaleX = letterContainer.scaleY = scale;
					new GTween(letterContainer, scaleTime/1000, {scaleX:1, scaleY:1}, {ease:Sine.easeIn});
					
					if (alpha < 1) {
						letterContainer.alpha = alpha;
						new GTween(letterContainer, scaleTime/1000, {alpha:1}, {ease:Sine.easeIn});
					}
					
					textFields.push(letterContainer);
					container.addChild(letterContainer);
					

				} else {
					timer.removeEventListener(TimerEvent.TIMER, incrementText);
					timer.reset();
					
					clearCall(container, timer);
					
					
				}
				
				i++;
			
			}
		}
	
	}
	
	
}