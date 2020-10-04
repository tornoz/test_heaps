import uuid.Uuid;

class Entity {
    public static var ALL : Array<Entity> = [];
    public static var GC : Array<Entity> = [];

	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;
	public var destroyed(default,null) = false;
	public var ftime(get,never) : Float; inline function get_ftime() return game.ftime;
	public var tmod(get,never) : Float; inline function get_tmod() return Game.ME.tmod;
	public var hud(get,never) : ui.Hud; inline function get_hud() return Game.ME.hud;

	public var cd : dn.Cooldown;

	public var uid : Int;
    public var cx = 0;
    public var cy = 0;
    public var xr = 0.;
    public var yr = 0.;

    public var dx = 0.;
    public var dy = 0.;
    public var bdx = 0.;
    public var bdy = 0.;
	public var dxTotal(get,never) : Float; inline function get_dxTotal() return dx+bdx;
	public var dyTotal(get,never) : Float; inline function get_dyTotal() return dy+bdy;
	public var frict = 0.82;
	public var bumpFrict = 0.93;
	public var hei : Float = Const.GRID;
	public var radius = Const.GRID*0.5;

	public var dir(default,set) = 1;
	public var sprScaleX = 1.0;
	public var sprScaleY = 1.0;
	public var entityVisible = true;

	public var width = 1;
	public var height = 1;

	public var uuid:String;

	public var isFrict = true;


    public var spr : HSprite;
	public var colorAdd : h3d.Vector;
	var debugLabel : Null<h2d.Text>;

	public var footX(get,never) : Float; inline function get_footX() return (cx+xr)*Const.GRID;
	public var footY(get,never) : Float; inline function get_footY() return (cy+yr)*Const.GRID;
	public var headX(get,never) : Float; inline function get_headX() return footX;
	public var headY(get,never) : Float; inline function get_headY() return footY-hei;
	public var centerX(get,never) : Float; inline function get_centerX() return footX;
	public var centerY(get,never) : Float; inline function get_centerY() return footY-hei*0.5;

	var actions : Array<{ id:String, cb:Void->Void, t:Float }> = [];

    public function new(x:Int, y:Int) {
        uid = Const.NEXT_UNIQ;
        ALL.push(this);

		cd = new dn.Cooldown(Const.FPS);
		setPosCase(x,y);

        spr = new HSprite();
		Game.ME.scroller.add(spr, Const.DP_MAIN);
		uuid = Uuid.v4();
		// spr.colorAdd = colorAdd = new h3d.Vector();
		// spr.setCenterRatio(0.5,1);
    }

	inline function set_dir(v) {
		return dir = v>0 ? 1 : v<0 ? -1 : dir;
	}

	public inline function isAlive() {
		return !destroyed;
	}

	public function kill(by:Null<Entity>) {
		destroy();
	}

	public function setPosCase(x:Int, y:Int) {
		cx = x;
		cy = y;
	}

	public function setPosPixel(x:Float, y:Float) {
		cx = Std.int(x/Const.GRID);
		cy = Std.int(y/Const.GRID);
		xr = (x-cx*Const.GRID)/Const.GRID;
		yr = (y-cy*Const.GRID)/Const.GRID;
	}

	public function bump(x:Float,y:Float) {
		bdx+=x;
		bdy+=y;
	}

	public function cancelVelocities() {
		dx = bdx = 0;
		dy = bdy = 0;
	}

	public function is<T:Entity>(c:Class<T>) return Std.is(this, c);
	public function as<T:Entity>(c:Class<T>) : T return Std.downcast(this, c);

	public inline function rnd(min,max,?sign) return Lib.rnd(min,max,sign);
	public inline function irnd(min,max,?sign) return Lib.irnd(min,max,sign);
	public inline function pretty(v,?p=1) return M.pretty(v,p);

	public inline function dirTo(e:Entity) return e.centerX<centerX ? -1 : 1;
	public inline function dirToAng() return dir==1 ? 0. : M.PI;
	public inline function getMoveAng() return Math.atan2(dyTotal,dxTotal);

	public inline function distCase(e:Entity) return M.dist(cx+xr, cy+yr, e.cx+e.xr, e.cy+e.yr);
	public inline function distCaseFree(tcx:Int, tcy:Int, ?txr=0.5, ?tyr=0.5) return M.dist(cx+xr, cy+yr, tcx+txr, tcy+tyr);

	public inline function distPx(e:Entity) return M.dist(footX, footY, e.footX, e.footY);
	public inline function distPxFree(x:Float, y:Float) return M.dist(footX, footY, x, y);

	public function makePoint() return new CPoint(cx,cy, xr,yr);

    public inline function destroy() {
        if( !destroyed ) {
            destroyed = true;
            GC.push(this);
        }
    }

    public function dispose() {
        ALL.remove(this);

		colorAdd = null;

		spr.remove();
		spr = null;

		if( debugLabel!=null ) {
			debugLabel.remove();
			debugLabel = null;
		}

		cd.destroy();
		cd = null;
    }

	public inline function debugFloat(v:Float, ?c=0xffffff) {
		debug( pretty(v), c );
	}
	public inline function debug(?v:Dynamic, ?c=0xffffff) {
		#if debug
		if( v==null && debugLabel!=null ) {
			debugLabel.remove();
			debugLabel = null;
		}
		if( v!=null ) {
			if( debugLabel==null )
				debugLabel = new h2d.Text(Assets.fontTiny, Game.ME.scroller);
			debugLabel.text = Std.string(v);
			debugLabel.textColor = c;
		}
		#end
	}

	function chargeAction(id:String, sec:Float, cb:Void->Void) {
		if( isChargingAction(id) )
			cancelAction(id);
		if( sec<=0 )
			cb();
		else
			actions.push({ id:id, cb:cb, t:sec});
	}

	public function isChargingAction(?id:String) {
		if( id==null )
			return actions.length>0;

		for(a in actions)
			if( a.id==id )
				return true;

		return false;
	}

	public function cancelAction(?id:String) {
		if( id==null )
			actions = [];
		else {
			var i = 0;
			while( i<actions.length ) {
				if( actions[i].id==id )
					actions.splice(i,1);
				else
					i++;
			}
		}
	}

	function updateActions() {
		var i = 0;
		while( i<actions.length ) {
			var a = actions[i];
			a.t -= tmod/Const.FPS;
			if( a.t<=0 ) {
				actions.splice(i,1);
				if( isAlive() )
					a.cb();
			}
			else
				i++;
		}
	}


    public function preUpdate() {
		cd.update(tmod);
		updateActions();
    }

    public function postUpdate() {
        spr.x = (cx+xr)*Const.GRID;
        spr.y = (cy+yr)*Const.GRID;
        spr.scaleX = dir*sprScaleX;
        spr.scaleY = sprScaleY;
		spr.visible = entityVisible;

		if( debugLabel!=null ) {
			debugLabel.x = Std.int(footX - debugLabel.textWidth*0.5);
			debugLabel.y = Std.int(footY+1);
		}
	}

	public function fixedUpdate() {} // runs at a "guaranteed" 30 fps

    public function update() { // runs at an unknown fps
		// X
		xr+=dx;
		if(isFrict)
			dx*=Math.pow(frict,tmod);

		// Y
		yr+=dy;
		if(isFrict)
			dy*=Math.pow(frict,tmod);

		collideWithLevel();

		if((dx > 0 && dx < 0.00005)
			|| dx < 0 && dx > -0.00005)
			dx = 0;
		if((dy > 0 && dy < 0.00005)
			|| dy < 0 && dy > -0.00005)
			dy = 0;



		
	}
	
	public function overlap(footX, footY, e:Entity) {
		var collide = (
			e.footX+e.hei >= footX 
			&& e.footY + e.hei >= footY 
			&& footX + hei >= e.footX 
			&& footY+hei >= e.footY);
			return collide;
		
	}

	public function collideWithEntity(e:Entity) {
		if(overlap(footX+dx*2*Const.GRID,footY, e)) {
			dx = 0;
		}

		if(overlap(footX-dx*2*Const.GRID,cy, e) ) {
			dx = 0;
		}

		if(overlap(footX, footY+dy*2*Const.GRID, e)) {
			dy = 0;
		}

		if( yr<=0 && overlap(footX, footY-dy*2*Const.GRID, e)) {
			dy = 0;
		}
	}

	public function collideWithLevel() {

		if( xr>=1 && (
			level.hasCollision(cx+1+width,cy+width)
			|| level.hasCollision(cx+1,cy)
			|| level.hasCollision(cx+1,cy+width)
			|| level.hasCollision(cx+1+width,cy) )) {
			xr = 1;
			dx = 0;
		}

		if( xr<=0 && (
			level.hasCollision(cx-1,cy)
			|| level.hasCollision(cx-1,cy+width) )) {
			xr = 0;
			dx = 0;
		}

		while( xr>1 ) { xr--; cx++; }
		while( xr<0 ) { xr++; cx--; }
			
		if( yr>=1 && (level.hasCollision(cx+width,cy+1+width) 
			|| level.hasCollision(cx,cy+1+width)
			|| level.hasCollision(cx+width,cy+1) 
			|| level.hasCollision(cx,cy+1)
			)) {
			yr = 1;
			dy = 0;
		}

		if( yr<=0 && (level.hasCollision(cx,cy-1) 
			|| level.hasCollision(cx+width,cy-1))) {
			yr = 0;
			dy = 0;
		}
		while( yr>1 ) { yr--; cy++; }
		while( yr<0 ) { yr++; cy--; }
	}
}