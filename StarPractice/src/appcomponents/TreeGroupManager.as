package appcomponents
{
	import mx.core.UIComponent;
	
	internal class TreeGroupManager
	{
		private var treeRoot:TreeElement;
		private var treeGroups:Array;
				
		private var lines:Array;
		
		//Stores and manages the tree groups
		public function TreeGroupManager(root:TreeElement)
		{
			treeRoot = root;
			treeGroups = new Array();
		}
		
		//Adds a tree group to the list of tree groups
		internal function add(group:TreeGroup):void
		{
			treeGroups.push(group);
		}
		
		internal function addLine(line:UIComponent):void
		{
			lines.push(line);
		}
		
		//Returns the list of tree groups
		internal function get groups():Array
		{
			return treeGroups;
		}
		
		//Returns the group with the specified parent
		internal function getGroupByParent(parent:TreeElement):TreeGroup
		{
			for(var i:uint=0;i<groups.length;i++)
			{
				if(treeGroups[i].groupParent == parent)
					return treeGroups[i];
			}
			return null;
		}
		
		internal function getGroupBoundsX(group:TreeGroup):Array
		{
			var maxLeft:uint = group.elements[0].x;
			var maxRight:uint = group.elements[0].x+group.width;
			
			trace(group.groupParent);
			for(var i:uint;i<group.elements.length;i++)
			{
				
			}
			
			return [maxLeft,maxRight];
		}
		internal function getGroupBoundsY(group:TreeGroup):Array
		{
			return [];
		}
		
		//Returns the tree's root
		internal function get root():TreeElement
		{
			return treeRoot;
		}	
	}
}