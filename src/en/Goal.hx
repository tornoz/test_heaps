package en;

class Goal extends Entity {
    
	public function new(x,y, color) {
		super(x,y);

		// Some default rendering for our character
		var g = new h2d.Graphics(spr);
		g.beginFill(color);
        g.drawCircle(32,32,32);
        
    }
    



	override function update() { // the Entity main loop
		super.update();
	}
}