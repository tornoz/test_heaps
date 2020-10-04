package en;

class Block extends Entity {


	var path:Array<String>;
	public var goal:Goal;

	var move = 500;

	var idx = -1;

		
	var initX:Int;
	var initY:Int;
	public function new(x,y, color, path, goal) {
		super(x,y);

		this.initX = x;
		this.initY = y;
		// Some default rendering for our character
		var g = new h2d.Graphics(spr);
		g.beginFill(color);
		g.drawRect(0,0,64,64);
		this.path = path;
		this.goal = goal;
		isFrict = false;
    
    }
    


	override function update() { // the Entity main loop
		super.update();

		if(cd.has("move")) {

			var currentMove = "loop";
			if(idx < path.length) {
				currentMove = path[idx];
			}

			var acceleration = (1 / ((1*(move/1000)))*(tmod/60));
			switch(currentMove) {
				case "up": dy = -acceleration;
				case "down": dy = acceleration;
				case "left": dx = -acceleration;
				case "right": dx = acceleration;
				case "loop":
					cx = initX;
					cy = initY;
					xr = 0;
					yr = 0;

			}

			for (block in game.blocks) {
				if(block.uuid != uuid) {
					collideWithEntity(block);
				}
			}
			collideWithEntity(game.player);
		} else {
			dx = 0;
			dy = 0;
			// if(xr > 0.5) {
			// 	xr = 0;
			// 	cx++;
			// }
			// if(xr < 0.5) {
			// 	xr = 0;
			// }
			// if(yr > 0.5) {
			// 	yr = 0;
			// 	cy++;
			// }
			// if(yr < 0.5) {
			// 	yr = 0;
			// }
		}
			

	}

	public function tick() {
		cd.setMs("move", move);
		idx = idx + 1;
		if(idx > path.length) {
			idx = 0;
		}

		
	}
}