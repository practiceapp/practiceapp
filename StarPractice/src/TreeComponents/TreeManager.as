package TreeComponents
{
	import com.adobe.serialization.json.JSON;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import spark.components.Group;

	public class TreeManager
	{
		private var file:File;
		
		private var container:Group;
		
		private var dragManager:TreeDragManager;
		
		private var snapPreviewLine:UIComponent;
		
		private var treeRoot:TreeElement;
		
		private var partManager:TreePartManager;
		
		
		//Manages the structure, storage, and graphical representation of the tree
		public function TreeManager(container:Group)
		{
			dragManager = new TreeDragManager(this,container);
			partManager = new TreePartManager();
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
			
			var rootElem:TreeElement = new TreeElement();	//Create the tree root element
			rootElem.parentElement = null;
			rootElem.elemName = tree.name;
			rootElem.rootElement = true;
			rootElem.id = "root";
			rootElem.complete = tree.complete == "true" ? true : false;
			container.addElement(rootElem);
			dragManager.registerTreeElement(rootElem);
			treeRoot = rootElem;
			
			createElements(tree.gaps,rootElem);
			
			container.callLater(makeTree);

			return true;
		}
		
		//Create elements and populate tree groups
		//Lower indexed groups are at the bottom of the tree
		private function createElements(elements:Array,parent:TreeElement,iteration:uint=0):void
		{
			for(var n:uint = 0;n<elements.length;n++)
			{
				var elem:TreeElement = new TreeElement();
				var treePart:TreePart = new TreePart(elem,parent,iteration+1);
				partManager.add(treePart);
				elem.id = parent.id+"/"+n;
				elem.elemName = elements[n].name;
				elem.elemDesc = elements[n].desc;
				elem.complete = elements[n].complete == "true" ? true : false;
				elem.parentElement = parent;
				container.addElement(elem);
				dragManager.registerTreeElement(elem);
				if(elements[n].gaps.length != 0)
					createElements(elements[n].gaps,elem,iteration+1);
			}
		}
		
		private function makeTree():void
		{
			var rootPart:TreePart = new TreePart(treeRoot,null,0);
			partManager.add(rootPart);
			rootPart.x = (container.width-treeRoot.width)/2;
			rootPart.y = 15;
			
			var partslist:Array = partManager.list;
			var linearparts:Array = new Array();
			for(var i:int=partslist.length-1;i>0;i--)
				for(var n:uint=0;n<partslist[i].length;n++)
				{
					partManager.getPartByElement(partslist[i][n].parent).merge(partslist[i][n]);
					linearparts.push(partslist[i][n]);
				}
			
			if((partslist[0][0].x+partslist[0][0].partElement.width/2-partslist[0][0].width/2) <= 0)
				partslist[0][0].x = partslist[0][0].x - (partslist[0][0].x+partslist[0][0].partElement.width/2-partslist[0][0].width/2)+50;
			
			for(var y:uint=0;y<linearparts.length;y++)
			{
				var line:UIComponent = new UIComponent();
				line.graphics.lineStyle(3,0x444444,1);
				line.name = linearparts[y].partElement.id+":line";
				line.graphics.moveTo(linearparts[y].partElement.x+linearparts[y].partElement.width/2,linearparts[y].partElement.y+2);
				line.graphics.lineTo(linearparts[y].parent.x+linearparts[y].parent.width/2,linearparts[y].parent.y+linearparts[y].parent.height-1);
				container.addElement(line);
				container.setElementIndex(line,0);
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
				trace("Swap dragged element with colliding element and make colliding element child of dragged");
				//line.graphics.moveTo(draggedElement.x+(draggedElement.width/2),draggedElement.y+draggedElement.height);
				//line.graphics.lineTo(collidingElement.x+(collidingElement.width/2),collidingElement.y);
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
			line.graphics.moveTo(draggedElement.x+(draggedElement.width/2),draggedElement.y+2);
			line.graphics.lineTo(draggedElement.parentElement.x+draggedElement.parentElement.width/2,draggedElement.parentElement.y+draggedElement.parentElement.height-1);
			container.addElement(line);
			container.setElementIndex(line,0);
		}	
	}
}