package appcomponents
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import spark.components.Group;
	
	import appcomponents.TreeManager;

	internal class TreeDragManager
	{
		private var treeManager:TreeManager;
		
		private var container:Group;
		
		private var clickCoords:Point;	//Coordinates of mouse relative to container
		private var elemCoords:Point;	//Initial position of dragged element
		private var elemRelCoords:Point;	//Coordinates of mouse down relative to dragged element
		
		private var draggedElement:TreeElement;	//Element being dragged
		
		private var snapPreviewLine:UIComponent = null;
		
		private var registeredElements:Array = new Array();
		
		private var colliding:Array = new Array();
		
		public function TreeDragManager(treeManager:TreeManager,container:Group)
		{
			this.treeManager = treeManager;
			this.container = container;
			container.addEventListener(MouseEvent.MOUSE_UP,endDragElem);
		}
		
		//Allows dragging and colliding
		internal function registerTreeElement(elem:TreeElement):void
		{
			if(elem.isRootElement())
				elem.addEventListener(MouseEvent.CLICK,clickElem);
			else
				elem.addEventListener(MouseEvent.MOUSE_DOWN,startDragElem);
			registeredElements.push(elem);
		}

		public function startDragElem(e:MouseEvent):void
		{
			clickCoords = new Point(container.mouseX,container.mouseY);
			elemCoords = new Point(e.currentTarget.x,e.currentTarget.y)
			draggedElement = TreeElement(e.currentTarget);
			elemRelCoords = new Point(draggedElement.mouseX,draggedElement.mouseY);
			draggedElement.mouseEnabled = false;
			draggedElement.mouseChildren = false;
			container.setElementIndex(draggedElement,container.numElements-1);
			container.addEventListener(MouseEvent.MOUSE_MOVE,dragMoveElem);
		}
		internal function dragMoveElem(e:MouseEvent):void
		{
			if(container.getChildByName(draggedElement.id+":line"))
			{
				var line:UIComponent = container.getChildByName(draggedElement.id+":line") as UIComponent;
				container.removeElement(line);
			}
			treeManager.removeSnapPreview();
			draggedElement.x = container.mouseX-elemRelCoords.x;	//Moves element maintaining relative mouse position
			draggedElement.y = container.mouseY-elemRelCoords.y;
			
			//Make into a dispatch event for processing by not this class
			if(checkColliding())
			{
				treeManager.snapPreviewElement(draggedElement,colliding);	//This should be processed by the not this class
			}
		}
		internal function endDragElem(e:MouseEvent):void
		{
			if(draggedElement == null)
				return;
			draggedElement.mouseEnabled = true;
			draggedElement.mouseChildren = true;
			container.removeEventListener(MouseEvent.MOUSE_MOVE,dragMoveElem);
			if(draggedElement.x == elemCoords.x && draggedElement.y == elemCoords.y)
			{
				clickElem(null,draggedElement);
			}
			else if(colliding.length != 0)
			{
				if(colliding[1].isRootElement() && colliding[0] == false)
				{
					//This should move tree down and make new element root node
				}
				else
				{
					trace("Start snapping");
					treeManager.snapElem(draggedElement,colliding[1],colliding[0]);
				}
			}
			else
			{
				trace("Abort abort abort");
				treeManager.undoMove(draggedElement,elemCoords);
			}
			draggedElement = null;
		}
		
		internal function dragMouseOver(e:MouseEvent):void
		{
		}
		internal function dragMouseOut(e:MouseEvent):void
		{
		}
		
		private function checkColliding():Boolean		//Returns [true,elem] for collision above, [false,elem] for below
		{
			var hitPointTop:Point = new Point(draggedElement.x+(draggedElement.width/2),draggedElement.y-20);
			var hitPointBot:Point = new Point(draggedElement.x+(draggedElement.width/2),draggedElement.y+draggedElement.height+30);
			for each(var elem:TreeElement in registeredElements)
			{
				if(elem != draggedElement)
				{
					if(elem.hitTestPoint(hitPointTop.x,hitPointTop.y,true))
					{
						colliding[0] = true;
						colliding[1] = elem;
						return true;
					}
					if(elem.hitTestPoint(hitPointBot.x,hitPointBot.y,true))
					{
						colliding[0] = false;
						colliding[1] = elem;
						return true;
					}
				}
			}
			colliding = [];
			return false;
		}
		
		//Manages mouse clicks
		private function clickElem(e:MouseEvent=null,elem:TreeElement=null):void
		{
			if(e != null && elem == null)
				elem = TreeElement(e.currentTarget);
			trace("Clicked element "+elem.width);
		}
		
		//Draws a line between two colliding tree elements
	}
}