package appcomponents
{
	import com.adobe.serialization.json.JSON;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.core.UIComponent;
	
	import spark.components.BorderContainer;

	public class TreeManager	//Manages tree display, structure, and storage
	{
		private var file:File;
		
		private var container:BorderContainer;
		
		private var snapPreviewLine:UIComponent;
		
		public function TreeManager(container:BorderContainer)
		{
			this.container = container;
		}
		
		public function loadTree(file:File):Boolean
		{
			if(!file.exists)
				return false;
			this.file = file;
			
			var fstream:FileStream = new FileStream();
			fstream.open(file,FileMode.READ);
			
			
			var json:Object = com.adobe.serialization.json.JSON.decode(fstream.readUTFBytes(fstream.bytesAvailable));
			
			trace(json.test1);

			return true;
		}
		
		//Draws a line between two colliding tree elements
		public function snapPreviewElement(draggedElement:TreeElement,collidingElement:TreeElement):void
		{
			var line:UIComponent = new UIComponent();
			line.graphics.lineStyle(3,0x444444,1);
			line.graphics.moveTo(draggedElement.x+(draggedElement.width/2),draggedElement.y+(draggedElement.height/2));		
			line.graphics.lineTo(collidingElement.x+(collidingElement.width/2),collidingElement.y+(collidingElement.height/2));
			container.addElement(line);
			snapPreviewLine = line;
			container.setElementIndex(line,0);
		}
		
		//Moves TreeElements to acommodate newly snapped element, draws lines, and updates tree file
		public function snapElem(draggedElement:TreeElement,collidingElement:TreeElement,above:Boolean):void
		{
			//This should also be processed by not this class
		}
		
		//Returns the container upon which the tree is drawn
		public function getCanvas():BorderContainer
		{
			return container;
		}

		//Removes the snap preview line
		public function removeSnapPreview():void
		{
			if(snapPreviewLine != null)
			{
				container.removeElement(snapPreviewLine);
				snapPreviewLine = null;
			}
		}
	}
}