package appcomponents
{
	internal class TreeGroup
	{
		private var parent:TreeElement;
		
		private var elems:Array;	//List of elements in group
		
		private var groupWidth:uint = 0;
		private var groupHeight:uint = 0;
		
		private var groupX:uint;
		private var groupY:uint;
		
		public function TreeGroup(parent:TreeElement)	//Represents a group of TreeElements and their positions
		{
			this.parent = parent;
			elems = new Array();
		}
		
		internal function add(elem:TreeElement):void	//Adds a TreeElement to the list
		{
			elems.push(elem);
			if(elem.width != 0 || elem.height != 0)
			{
				groupWidth += elem.width+16;
				if(elem.height > groupHeight)
					groupHeight = elem.height;
			}
		}
	
		//Moves the group left or right by a specified offset
		internal function set x(offset:int):void
		{
			groupX += offset;
			elems[0].x = groupX;
			for(var i:uint=1;i<elems.length;i++)
			{
				elems[i].x = elems[i-1].x+elems[i-1].width+16;
			}
		}
		//Moves the gorup up or down by a specified offset
		internal function set y(offset:int):void
		{
			groupY += offset;
			for(var i:uint=0;i<elems.length;i++)
			{
				elems[i].y = groupY;
			}
		}
		
		//Returns the parent of the elements in the group
		internal function get groupParent():TreeElement
		{
			return parent;
		}
		
		//Returns the list of elements
		internal function get elements():Array
		{
			return elems;
		}
		
		//Returns the width of the elements in the group and padding
		internal function get width():uint
		{
			if(groupWidth == 0)
			{
				groupWidth = (elems.length-1)*16;
				for(var i:uint=0;i<elems.length;i++)
					groupWidth += elems[i].width;
			}
			if(groupWidth%2 != 0)
				groupWidth--;
			return groupWidth;
		}
		//Returns the height of the tallest element in the group
		internal function get height():uint
		{
			if(groupHeight == 0)
			{
				for(var i:uint=0;i<elems.length;i++)
					if(elems[i].height > groupHeight)
						groupHeight = elems[i].height;
			}
			return groupHeight;
		}
	}
}