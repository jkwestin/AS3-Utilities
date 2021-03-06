package skyboy.text {
	/**
	 * Typewriter by skyboy. March 18th 2012.
	 * Visit http://github.com/skyboy for documentation, updates
	 * and more free code.
	 *
	 *
	 * Copyright (c) 2010, skyboy
	 *    All rights reserved.
	 *
	 * Permission is hereby granted, free of charge, to any person
	 * obtaining a copy of this software and associated documentation
	 * files (the "Software"), to deal in the Software with
	 * restriction, with limitation the rights to use, copy, modify,
	 * merge, publish, distribute, sublicense copies of the Software,
	 * and to permit persons to whom the Software is furnished to do so,
	 * subject to the following conditions and limitations:
	 *
	 * ^ Attribution will be given to:
	 *  	skyboy, http://www.kongregate.com/accounts/skyboy;
	 *  	http://github.com/skyboy; http://skybov.deviantart.com
	 *
	 * ^ Redistributions of source code must retain the above copyright notice,
	 * this list of conditions and the following disclaimer in all copies or
	 * substantial portions of the Software.
	 *
	 * ^ Redistributions of modified source code must be marked as such, with
	 * the modifications marked and ducumented and the modifer's name clearly
	 * listed as having modified the source code.
	 *
	 * ^ Redistributions of source code may not add to, subtract from, or in
	 * any other way modify the above copyright notice, this list of conditions,
	 * or the following disclaimer for any reason.
	 *
	 * ^ Redistributions in binary form must reproduce the above copyright
	 * notice, this list of conditions and the following disclaimer in the
	 * documentation and/or other materials provided with the distribution.
	 *
	 * THE SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
	 * IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
	 * NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
	 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
	 * OR COPYRIGHT HOLDERS OR CONTRIBUTORS  BE LIABLE FOR ANY CLAIM, DIRECT,
	 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	 * OR OTHER LIABILITY,(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
	 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
	 * WHETHER AN ACTION OF IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
	 * NEGLIGENCE OR OTHERWISE) ARISING FROM, OUT OF, IN CONNECTION OR
	 * IN ANY OTHER WAY OUT OF THE USE OF OR OTHER DEALINGS WITH THIS
	 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	 */
	import flash.events.*;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Timer;
	public class Typewriter extends TextField {
		public static const FRAME:String = "frame";
		public static const TIME:String = "time";
		public var stutterTime:int;
		private var _stutter:Boolean, _speed:int, _type:String, timer:Timer, pos:int, d:int, buffer:ByteArray = new ByteArray, s:Boolean, stutterOn:Array, sOt:String;
		public function Typewriter(speed:int = 1, stutter:Boolean = false, type:String = "frame", stutterTime:int = 4) {
			this.stutter = stutter;
			this.speed = speed;
			this.type = type;
			this.stutterTime = stutterTime;
			stutterText = ",-.!:;?\n\u2013-\u2015\u2026";
		}
		public function get stutter():Boolean { return _stutter; }
		public function set stutter(value:Boolean):void {
			_stutter = value;
			s = value;
		}
		public function get stutterText():String { return sOt; }
		public function set stutterText(a:String):void {
			var i:int, e:int = a.length - 1, q:Array = [];
			for (var p:int, c:int, n:int; i <= e; p = c, ++i ) {
				c = a.charCodeAt(i);
				if (p && c == 0x2D) {
					if (i != e) for (n = a.charCodeAt(++i), c = p, p = 0; c < n; ++c) {
						q[c] = true;
					}
				}
				q[c] = true;
			}
			stutterOn = q;
			sOt = a;
		}
		public override function appendText(str:String):void {
			buffer.writeUTFBytes(str);
		}
		public override function get type():String {return _type;}
		public override function set type(a:String):void {
			if (a == _type) return;
			switch (a) {
			case FRAME:
				addEventListener(Event.ENTER_FRAME, oE);
				if (timer) {
					timer.stop(); timer.removeEventListener(TimerEvent.TIMER, oT);
					timer = null;
				}
				break;
			case TIME:
				removeEventListener(Event.ENTER_FRAME, oE);
				timer = new Timer(speed);
				timer.addEventListener(TimerEvent.TIMER, oT);
				timer.start();
				break;
			default:
				throw new ArgumentError("Unknown type: " + type);
			}
			_type = a;
		}
		public function get speed():int {return _speed;}
		public function set speed(a:int):void {
			if (a == _speed) return;
			if (timer) {
				timer.delay = a;
			}
			_speed = a;
		}
		public override function set text(a:String):void {
			var b:String = text;
			if (a.indexOf(b) == 0) {
				if (a != b) {
					buffer.clear();
					appendText(a.substr(b.length));
				}
			} else {
				buffer.clear();
				appendText(a);
				super.text = '';
				pos = 0;
			}
		}
		private function readUTFChar():int {
			var buffer:ByteArray = this.buffer;
			var i:uint = buffer[pos++], a:int = i >>> 4;
			if (!(a & 8))
				return i & 0x7F;
			if ((a & 14) === 12)
				return ((i & 31) <<  6) | ((buffer[pos++] & 0x3F));
			if (a === 14)
				return ((i & 15) << 12) | ((buffer[pos++] & 0x3F) <<  6) | ((buffer[pos++] & 0x3F));
			if (a === 15) if (i & 15 < 8)
				return ((i &  7) << 18) | ((buffer[pos++] & 0x3F) << 12) | ((buffer[pos++] & 0x3F) <<  6) | (buffer[pos++] & 0x3F);
			return 0x3F;
		}
		private function addCharacter():Boolean {
			var i:int = pos, a:int = readUTFChar();
			if (_stutter) {
				s = (int(d % stutterTime) === 0);
				if (s) {
					if (stutterOn[a]) ++d;
				} else {
					++d;
					pos = i;
					return false
				}
			}
			super.appendText(String.fromCharCode(a));
			return true;
		}
		private function oE(e:Event):void {
			if (pos < buffer.length) {
				var i:int = _speed;
				if (!i) {
					buffer.position = pos;
					super.appendText(buffer.readUTFBytes(buffer.length));
					buffer.clear(); pos = 0;
					return;
				}
				while (i-- && pos < buffer.length) {
					addCharacter();
				}
			} else {
				buffer.clear(); pos = 0;
			}
		}
		private function oT(e:TimerEvent):void {
			if (pos < buffer.length) {
				addCharacter();
			} else {
				buffer.clear(); pos = 0;
			}
		}
	}
}
