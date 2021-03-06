package lycan.components;

import lycan.LateUpdatable;

interface Attachable extends LateUpdatable extends Entity {
	public var attachable:AttachableComponent;
	public var x(get, set):Float;
	public var y(get, set):Float;
	
	// TODO: decide if this is worthwhile after a bit of use
	public var active(get, set):Bool;
	public var visible(get, set):Bool;
	public var exists(get, set):Bool;
	
	public function update(dt:Float):Void;
	public function draw():Void;
}

class AttachableComponent extends Component<Attachable> {
	public var parent:Attachable;
	public var children:Array<Attachable>;
	public var isRoot(get, never):Bool;
	
	public var x(default, set):Float;
	public var y(default, set):Float;
	public var originX(default, set):Float;
	public var originY(default, set):Float;
	// Whether this atachable should be updated and drawn by the attachable chain
	public var updateAndDraw:Bool;
	
	// True if attached position or origin have changed since last update
	private var dirty:Bool;
	
	public function new(entity:Attachable) {
		super(entity);
		
		x = 0;
		y = 0;
		originX = 0;
		originY = 0;
		
		updateAndDraw = true;
		
		// Todo use metadata instead!
		requiresLateUpdate = true;
		requiresUpdate = true;
		requiresDraw = true;
	}
	
	override public function update(dt):Void {
		super.update(dt);
		if (children != null) {
			for (child in children) {
				if (child.entity_exists && child.entity_active && child.attachable.updateAndDraw) {
					child.update(dt);
				}
				
			}
		}
	}
	
	override public function draw():Void {
		super.draw();
		if (children != null) {
			for (child in children) {
				if (child.entity_exists && child.entity_visible && child.attachable.updateAndDraw) {
					child.draw();
				}
			}
		}
	}
	
	override public function lateUpdate(dt:Float):Void {
		// The root is responsible for recursively updating its children
		// However, children must also update if their attached position or origin
		// have changed, which is indicated by the dirty flag
		if (isRoot || dirty) {
			recursiveUpdate(dt);
		}
	}
	
	/**
	 * Attach a child to this object at the given position
	 * @param   child The child to attach
	 * @param   x The x position of the attachment
	 * @param   y The y position of the attachment
	 */
	public function attach(child:Attachable, x:Float, y:Float, ?originX:Float, ?originY:Float, ?updateAndDraw:Bool):Void {
		Sure.sure(child != null);
		
		if (updateAndDraw != null) {
			child.attachable.updateAndDraw = updateAndDraw;
		}
		
		// Detach child from current parent
		if (child.attachable.parent != null) {
			child.attachable.parent.attachable.remove(child);
		}
		
		// satiate properties if necessary
		if (children == null) children = new Array<Attachable>();
		
		// Attach child to this attachable
		children.push(child);
		child.attachable.parent = entity;
		
		// Set child's attached position
		child.attachable.x = x;
		child.attachable.y = y;
		
		// Set child's attachment origin if given
		if (originX != null) { child.attachable.originX = originX; }
		if (originY != null) { child.attachable.originY = originY; }
	}
	
	/**
	 * Remove a child of this attachable
	 * @param   child The child to remove
	 */
	public function remove(child:Attachable):Void {
		// Return if attachable is not a valid child
		if (child.attachable.parent.attachable != this) return;
		
		children.remove(child);
		child.attachable.parent = null;
	}
	
	@:access(AttachableComponent)
	private function recursiveUpdate(dt:Float):Void {       
		if (children == null) return;
		// Recursively update children
		for (child in children) {
			// Update child's position
			child.entity_x = entity.entity_x + child.attachable.x - child.attachable.originX;
			child.entity_y = entity.entity_y + child.attachable.y - child.attachable.originY;
			// Update child's children
			child.attachable.recursiveUpdate(dt);
		}
		dirty = false;
	}
	
	private inline function get_isRoot():Bool {
		return parent == null;
	}
	
	private function set_x(x:Float):Float {
		this.x = x;
		dirty = true;
		return x;
	}
	private function set_y(y:Float):Float {
		this.y = y;
		dirty = true;
		return y;
	}
	
	private function set_originX(x:Float):Float {
		this.originX = x;
		dirty = true;
		return x;
	}
	private function set_originY(y:Float):Float {
		this.originY = y;
		dirty = true;
		return y;
	}
}