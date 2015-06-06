package lycan;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.TweenOptions;
import flixel.util.FlxColor;
import lycan.world.World;
import openfl.filters.BlurFilter;

/**
 * Extends basic FlxState with additional functionality
 * 
 * @author Joe Williamson
 */
class GameState extends FlxState {
	
	public var world:World;
	public var uiGroup:FlxSpriteGroup;
	
	public var uiCamera:FlxCamera;
	public var worldCamera:FlxCamera;
	
	public var worldZoom(default, set):Float;
	public var baseZoom:Float;
	
	public var zoomTween:FlxTween;
	/** Map of IDs to tweens that should be cancelled before another tween of the same ID plays */
	public var exclusiveTweens:Map<String, FlxTween>;
	
	override public function create():Void {
		super.create();
		
		// TODO
		
		/*
		exclusiveTweens = new Map<String, FlxTween>();
		
		// Cameras
		worldCamera = FlxG.camera;
		uiCamera = new FlxCamera(Std.int(FlxG.camera.x), Std.int(FlxG.camera.y), 
		                         FlxG.camera.width, FlxG.camera.height, FlxG.camera.zoom);
		uiCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(uiCamera);
		FlxCamera.defaultCameras = [worldCamera];
		
		baseZoom = worldCamera.zoom;
		worldZoom = 1;
		
		// Groups
		uiGroup = new FlxSpriteGroup();
		uiGroup.cameras = [uiCamera];
		
		add(uiGroup);
		
		var blur:BlurFilter = new BlurFilter();
		worldCamera.flashSprite.filters.push(blur);
		worldCamera.flashSprite.filters = worldCamera.flashSprite.filters;
		*/
	}
	
	public function exclusiveTween(id:String, object:Dynamic, values:Dynamic, duration:Float = 1, ?options:TweenOptions):FlxTween {
		if (exclusiveTweens.exists(id)) {
			exclusiveTweens.get(id).cancel();
		}
		var tween:FlxTween = FlxTween.tween(object, values, duration, options);
		exclusiveTweens.set(id, tween);
		return tween;
	}
	
	public function zoomTo(zoom:Float, duration:Float = 0.5, ?ease:Float->Float):FlxTween {
		if (ease == null) ease = FlxEase.quadInOut;
		
		if (zoomTween != null) {
			zoomTween.cancel();
		}
		zoomTween = FlxTween.tween(this, { worldZoom: zoom }, duration, { type: FlxTween.ONESHOT, ease: ease } ); 
		return zoomTween;
	}
	
	private function set_worldZoom(worldZoom:Float):Float {
		// Set world and camera zoom
		worldCamera.zoom = baseZoom * worldZoom;
		return this.worldZoom = worldZoom;
	}
	
	//TODO autotweening
	//TODO camera targetting
	//TODO sound fading
}