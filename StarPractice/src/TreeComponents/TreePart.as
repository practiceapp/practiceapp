package TreeComponents
{
	internal class TreePart
	{
		private const DEFAULT_VSPACER:uint = 30;
		private const DEFAULT_HSPACER:uint = 20;
		
		private var partWidth:uint = 0;
		private var partHeight:uint = 0;
		
		private var xCoord:Number;
		private var yCoord:Number;
		
		private var childParts:Array;
		private var element:TreeElement;
		private var parentPart:TreeElement;
		
		private var partLevel:uint;
		
		public function TreePart(element:TreeElement,parent:TreeElement,level:uint)
		{
			this.element = element;
			parentPart = parent;
			partLevel = level;
			childParts = new Array();
			
			xCoord = element.x;
			yCoord = element.y;
		}
		
		internal function merge(part:TreePart):void
		{
			for(var i:uint=0;i<childParts.length;i++)
				childParts[i].offsetX(-(part.width/2+DEFAULT_HSPACER/2));
			part.y = element.y+element.height+DEFAULT_VSPACER;
			part.x = element.x+element.width/2-part.partElement.width/2+(childParts.length > 0 ? partWidth/2 : 0)+(childParts.length > 0 ? DEFAULT_HSPACER/2 : 0);
			
			partWidth += part.width+(childParts.length > 0 ? DEFAULT_HSPACER : 0);
			partHeight = Math.max(part.height,height);	//This probably needs fixing
			childParts.push(part);
		}
		
		internal function get width():uint
		{
			return Math.max(partWidth,element.width);
		}
		internal function get height():uint
		{
			return partHeight+element.height+DEFAULT_VSPACER;
		}
		
		internal function set x(pos:Number):void
		{
			element.x = pos;
			var xOffset:Number = pos-xCoord;
			xCoord = pos;
			for(var i:uint=0;i<childParts.length;i++)
				childParts[i].offsetX(xOffset);
		}
		internal function get x():Number
		{
			return xCoord;
		}
		internal function set y(pos:Number):void
		{
			element.y = pos;
			var yOffset:Number = pos-yCoord;
			yCoord = pos;
			for(var i:uint=0;i<childParts.length;i++)
				childParts[i].offsetY(yOffset);
		}
		internal function get y():Number
		{
			return xCoord;
		}
		
		private function offsetX(offset:Number):void
		{
			xCoord += offset;			
			element.x += offset;
			for(var i:uint=0;i<childParts.length;i++)
				childParts[i].offsetX(offset);
		}
		private function offsetY(offset:Number):void
		{
			yCoord += offset;			
			element.y += offset;
			for(var i:uint=0;i<childParts.length;i++)
				childParts[i].offsetY(offset);
		}
		
		internal function get level():uint
		{
			return partLevel;
		}
		
		internal function get parent():TreeElement
		{
			return parentPart;
		}
		
		internal function get partElement():TreeElement
		{
			return element;
		}
	}
}