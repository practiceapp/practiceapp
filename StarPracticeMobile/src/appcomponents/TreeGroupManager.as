package appcomponents
{
	internal class TreeGroupManager
	{
		private var treeRoot:TreeElement;
		private var treeGroups:Array;
		
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
				if(treeGroups[i].getGroupParent() == parent)
					return treeGroups[i];
			}
			return null;
		}
		
		//Returns the tree's root
		internal function get root():TreeElement
		{
			return treeRoot;
		}		
	}
}