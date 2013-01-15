package appcomponents
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import spark.components.BorderContainer;
	
	import appcomponents.TreeManager;

	public class TreeDragManager
	{
		private var treeManager:TreeManager;
		
		private var container:BorderContainer;
		
		private var clickCoords:Point;	//Coordinates of mouse relative to container
		private var elemCoords:Point;	//Initial position of dragged element
		private var elemRelCoords:Point;	//Coordinates of mouse down relative to dragged element
		
		private var draggedElement:TreeElement;	//Element being dragged
		
		private var snapPreviewLine:UIComponent = null;
		
		private var registeredElements:Array = new Array();
		
		private var colliding:Array;
		
		public function TreeDragManager(treeManager:TreeManager)
		{
			this.treeManager = treeManager;
			this.container = treeManager.getCanvas();
			container.addEventListener(MouseEvent.MOUSE_UP,endDragElem);
		}
		
		public function registerTreeElement(elem:TreeElement):void	//Allows dragging and colliding
		{
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
		public function dragMoveElem(e:MouseEvent):void
		{
			treeManager.removeSnapPreview();
			draggedElement.x = container.mouseX-elemRelCoords.x;	//Moves element maintaining relative mouse position
			draggedElement.y = container.mouseY-elemRelCoords.y;
			
			//Make into a dispatch event for processing by not this class
			if(checkColliding())
			{
				treeManager.snapPreviewElement(draggedElement,colliding[1]);	//This should be processed by the not this class
			}
		}
		public function endDragElem(e:MouseEvent):void
		{
			if(draggedElement != null)
			{
				draggedElement.mouseEnabled = true;
				draggedElement.mouseChildren = true;
			}
			container.removeEventListener(MouseEvent.MOUSE_MOVE,dragMoveElem);
			if(Math.abs(clickCoords.x-container.mouseX) < 1 && Math.abs(clickCoords.y-container.mouseY) < 1)
			{
				draggedElement.x = elemCoords.x;	//Slightly unneccessary because moves > 1 when moved and then snapping
				draggedElement.y = elemCoords.y;
				clickElem(draggedElement);
			}
			treeManager.snapElem(draggedElement,colliding[1],colliding[0]);
			draggedElement = null;
		}
		
		public function dragMouseOver(e:MouseEvent):void
		{
		}
		public function dragMouseOut(e:MouseEvent):void
		{
		}
		
		private function checkColliding():Boolean		//Returns [true,elem] for collision above, [false,elem] for below
		{
			var hitPointTop:Point = new Point(draggedElement.x+(draggedElement.width/2),draggedElement.y-25);
			var hitPointBot:Point = new Point(draggedElement.x+(draggedElement.width/2),draggedElement.y+draggedElement.height+35);
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
		
		private function clickElem(elem:TreeElement):void
		{
		}
	}
}