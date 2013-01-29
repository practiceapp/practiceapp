package TreeComponents
{
	internal class TreePartManager
	{
		private var partsList:Array;
		
		public function TreePartManager()
		{
			partsList = new Array();
		}
		
		internal function add(part:Object):void
		{
			if(!(partsList[part.level] is Array))
				partsList[part.level] = new Array();
			partsList[part.level].push(part);
		}
		
		internal function getPartByElement(elem:TreeElement):TreePart
		{
			for(var i:uint=0;i<partsList.length;i++)
				for(var n:uint=0;n<partsList[i].length;n++)
				{
					if(partsList[i][n].partElement == elem)
						return partsList[i][n];
				}
			return null;
		}
		
		internal function get list():Array
		{
			return partsList;
		}
	}
}