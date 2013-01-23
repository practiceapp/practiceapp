package appcomponents
{
	import com.adobe.serialization.json.JSON;
	
	import appcomponents.TreeGroup;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.core.UIComponent;
	
	import spark.components.BorderContainer;

	public class TreeManager
	{
		private var file:File;
		
		private var container:BorderContainer;
		
		private var dragManager:TreeDragManager;
		
		private var snapPreviewLine:UIComponent;
		
		private var groupManager:TreeGroupManager;
		
		
		//Manages the structure, storage, and graphical representation of the tree
		public function TreeManager(container:BorderContainer)
		{
			dragManager = new TreeDragManager(this,container);
			this.container = container;
		}
		
		//Loads a JSON tree structure from file
		//public function loadTree(file:File):Boolean
		public function loadTree(file:String):Boolean
		{
			//if(!file.exists)
			//	return false;
			//this.file = file;
			
			//var fstream:FileStream = new FileStream();
			//fstream.open(file,FileMode.READ);
			
			
			//var tree:Object = com.adobe.serialization.json.JSON.decode(fstream.readUTFBytes(fstream.bytesAvailable));
			var tree:Object = com.adobe.serialization.json.JSON.decode(file);
			
			var rootElem:TreeElement = new TreeElement();	//Create the tree root element and group manager
			rootElem.parentElement = null;
			rootElem.gapName = tree.name;
			rootElem.rootElement = true;
			rootElem.complete = tree.complete == "true" ? true : false;
			container.addElement(rootElem);
			dragManager.registerTreeElement(rootElem);
			groupManager = new TreeGroupManager(rootElem);
			
			createElements(tree.gaps,rootElem);
			
			container.callLater(drawElements);

			return true;
		}
		
		//Create elements and populate tree groups
		private function createElements(gaps:Array,parent:TreeElement):void
		{	
			var group:TreeGroup = new TreeGroup(parent);
			
			for(var n:uint = 0;n<gaps.length;n++)
			{
				var elem:TreeElement = new TreeElement();
				elem.parentElement = parent;
				elem.gapName = gaps[n].name;
				elem.desc = gaps[n].desc;
				elem.complete = gaps[n].complete == "true" ? true : false;
				container.addElement(elem);
				group.add(elem);
				dragManager.registerTreeElement(elem);
				if(gaps[n].gaps.length != 0)
					createElements(gaps[n].gaps,elem);
			}
			groupManager.add(group);
		}
		//Positions and draws the elements onscreen
		private function drawElements():void
		{
			var root:TreeElement = groupManager.root;
			root.x = container.width/2-root.width/2;
			root.y = 5;
			
			var groups:Array = groupManager.groups;
			for(var i:int=groups.length-1;i >= 0;i--)
			{
				var parent:TreeElement = groups[i].groupParent;
				var elements:Array = groups[i].elements;
				
				if(elements.length%2 == 0 || elements.length == 1)	//For even itemed groups or groups with one element, center the groups about the parent's x coordinate
				{
					groups[i].x = parent.x+parent.width/2-groups[i].width/2;
				}
				else	//For odd itemed groups, center the middle element with the parent's x coordinate
				{
					var median:uint = Math.floor(elements.length/2)+1;
					var lwidth:uint = 0;
					for(var n:uint=0;n<median-1;n++)
						lwidth += elements[n].width+16;
					lwidth += elements[median].width/2-3;

					groups[i].x = parent.x+parent.width/2-lwidth;
				}
				groups[i].y = parent.y+parent.height+16;
			}
			
			trace("Drawing lines");
			for(var y:uint=0;y<groups.length;y++)
			{
				trace(y);
				elements = groups[y].elements;
				parent = groups[y].groupParent;
				var line:UIComponent = new UIComponent();
				line.graphics.lineStyle(3,0x444444,1);
				for(var z:uint=0;z<elements.length;z++)
				{
					line.graphics.moveTo(elements[z].x+elements[z].width/2,elements[z].y+2);
					line.graphics.lineTo(parent.x+parent.width/2,parent.y+parent.height-1);
					container.addElement(line);
					container.setElementIndex(line,0);
				}
			}
		}
		
		//Draws a line between two colliding tree elements
		internal function snapPreviewElement(draggedElement:TreeElement,collidingElement:TreeElement,top:Boolean):void
		{
			var line:UIComponent = new UIComponent();
			line.graphics.lineStyle(3,0x444444,1);
			if(top)
				line.graphics.moveTo(draggedElement.x+(draggedElement.width/2),draggedElement.y);
			else
				line.graphics.moveTo(draggedElement.x+(draggedElement.width/2),draggedElement.y+draggedElement.height);
			line.graphics.lineTo(collidingElement.x+(collidingElement.width/2),collidingElement.y+collidingElement.height);
			container.addElement(line);
			snapPreviewLine = line;
			container.setElementIndex(line,0);
		}
		
		//Moves TreeElements to acommodate newly snapped element, draws lines, and updates tree file
		internal function snapElem(draggedElement:TreeElement,collidingElement:TreeElement,above:Boolean):void
		{
			//TODO: this method
		}

		//Removes the snap preview line
		internal function removeSnapPreview():void
		{
			if(snapPreviewLine != null)
			{
				container.removeElement(snapPreviewLine);
				snapPreviewLine = null;
			}
		}
	}
}