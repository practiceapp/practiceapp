package appcomponents
{
	import com.adobe.serialization.json.JSON;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import spark.components.Group;
	
	import appcomponents.TreeGroup;

	public class TreeManager
	{
		private var file:File;
		
		private var container:Group;
		
		private var dragManager:TreeDragManager;
		
		private var snapPreviewLine:UIComponent;
		
		private var groupManager:TreeGroupManager;
		
		
		//Manages the structure, storage, and graphical representation of the tree
		public function TreeManager(container:Group)
		{
			dragManager = new TreeDragManager(this,container);
			this.container = container;
		}
		
		//Loads a JSON tree structure from file
		public function loadTree(file:File):Boolean
		{
			if(!file.exists)
				return false;
			this.file = file;
			
			var fstream:FileStream = new FileStream();
			fstream.open(file,FileMode.READ);
			
			
			var tree:Object = com.adobe.serialization.json.JSON.decode(fstream.readUTFBytes(fstream.bytesAvailable));
			
			var rootElem:TreeElement = new TreeElement();	//Create the tree root element and group manager
			rootElem.parentElement = null;
			rootElem.elemName = tree.name;
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
		private function createElements(gaps:Array,parent:TreeElement,iteration:uint=0):void
		{	
			var group:TreeGroup = new TreeGroup(parent);	
			
			for(var n:uint = 0;n<gaps.length;n++)
			{
				var elem:TreeElement = new TreeElement();
				elem.id = iteration+"."+n;
				elem.parentElement = parent;
				elem.elemName = gaps[n].name;
				elem.elemDesc = gaps[n].desc;
				elem.complete = gaps[n].complete == "true" ? true : false;
				container.addElement(elem);
				group.add(elem);
				dragManager.registerTreeElement(elem);
				if(gaps[n].gaps.length != 0)
					createElements(gaps[n].gaps,elem,iteration+1);
			}
			groupManager.add(group);
		}
		//Positions and draws the elements onscreen
		private function drawElements():void
		{
			var root:TreeElement = groupManager.root;
			root.x = container.width/2-root.width/2;
			root.y = 15;
			
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
					lwidth += elements[median].width/2;

					groups[i].x = parent.x+parent.width/2-lwidth;
				}
				groups[i].y = parent.y+parent.height+16;
			}
			trace(groupManager.getGroupBoundsX(groups[0]));
			
			
			//Draw lines
			for(var y:uint=0;y<groups.length;y++)
			{
				elements = groups[y].elements;
				parent = groups[y].groupParent;
				for(var z:uint=0;z<elements.length;z++)
				{
					var line:UIComponent = new UIComponent();
					line.graphics.lineStyle(3,0x444444,1);
					line.name = elements[z].id+":line";
					line.graphics.moveTo(elements[z].x+elements[z].width/2,elements[z].y+2);
					line.graphics.lineTo(parent.x+parent.width/2,parent.y+parent.height-1);
					container.addElement(line);
					container.setElementIndex(line,0);
				}
			}
		}
		internal function snapPreviewElement(draggedElement:TreeElement,colliding:Array):void
		{
			var collidingElement:TreeElement = colliding[1];
			var isAbove:Boolean = colliding[0];
			
			/*if(!collidingElement.isRootElement())
				groupManager.getGroupByParent(colliding[1].parentElement).nudgeElement(0,1);*/
			
			var line:UIComponent = new UIComponent();
			line.graphics.lineStyle(3,0x444444,1);
			if(isAbove)
			{
				line.graphics.moveTo(draggedElement.x+(draggedElement.width/2),draggedElement.y);
				line.graphics.lineTo(collidingElement.x+(collidingElement.width/2),collidingElement.y+collidingElement.height);
			}
			else
			{
				line.graphics.moveTo(draggedElement.x+(draggedElement.width/2),draggedElement.y+draggedElement.height);
				line.graphics.lineTo(collidingElement.x+(collidingElement.width/2),collidingElement.y);
			}
			container.addElement(line);
			snapPreviewLine = line;
			container.setElementIndex(line,0);
		}
		//Remove snap preview line
		internal function removeSnapPreview():void
		{
			if(snapPreviewLine != null)
			{
				container.removeElement(snapPreviewLine);
				snapPreviewLine = null;
			}
		}
		//Moves TreeElements to acommodate newly snapped element, draws lines, and updates tree file
		internal function snapElem(draggedElement:TreeElement,collidingElement:TreeElement,above:Boolean):void
		{
			//TODO: this method
		}
		
		internal function undoMove(draggedElement:TreeElement,elemCoords:Point):void
		{
			draggedElement.x = elemCoords.x;
			draggedElement.y = elemCoords.y;
			var line:UIComponent = new UIComponent();
			line.name = draggedElement.id+":line";
			line.graphics.lineStyle(3,0x444444,1);
			line.graphics.moveTo(draggedElement.x+(draggedElement.width/2),draggedElement.y);
			line.graphics.lineTo(draggedElement.parentElement.x+draggedElement.parentElement.width/2,draggedElement.parentElement.y+draggedElement.parentElement.height);
			container.addElement(line);
			container.setElementIndex(line,0);
		}	
	}
}