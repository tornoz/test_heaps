package en;

class Player extends Entity {


	var skewX = 0.5;
	var skewY = 0.5;

	var maxVelocityX = 0.15; 

	var maxVelocityY = 0.15;
	var acceleration = 0.02;

    var ca : dn.heaps.Controller.ControllerAccess;
    
	public function new(x,y) {
		super(x,y);

		// Some default rendering for our character
		var g = new h2d.Graphics(spr);
		g.beginFill(0xffff00);
        g.drawRect(0,0,64,64);
        
        ca = Main.ME.controller.createAccess("hero"); 
    }
    

	override function dispose() { // call on garbage collection
		super.dispose();
		ca.dispose(); // release on destruction
	}


	public inline function skew(x:Float, y:Float) {
		skewX = x;
		skewY = y;
	}

	function moveXY() {
		
	}

	override function update() { // the Entity main loop
		super.update();
		// trace(dx);
		// trace(dy);
		if( ca.leftDown() || ca.isKeyboardDown(hxd.Key.LEFT) && dx > -maxVelocityX) 
			dx += -acceleration*tmod;

		if( ca.rightDown() || ca.isKeyboardDown(hxd.Key.RIGHT) && dx < maxVelocityX )
			dx += acceleration*tmod;

		if( ca.upDown() || ca.isKeyboardDown(hxd.Key.UP) && dy < maxVelocityY )
			dy += -acceleration*tmod;

		if( ca.downDown() || ca.isKeyboardDown(hxd.Key.DOWN) && dy > -maxVelocityY)
			dy += acceleration*tmod;

		// trace("p :" + acceleration*tmod);

		for (block in game.blocks)
			collideWithEntity(block);
	}
}