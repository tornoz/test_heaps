
import led.Project;
import h2d.col.Point;

class Level extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;

	public var wid(get,never) : Int; inline function get_wid() return 64;
	public var hei(get,never) : Int; inline function get_hei() return 64;

	public var playerStart: Point;

	var invalidated = true;

	var number:Int;

	public function new(number) {
		super(Game.ME);
		createRootInLayers(Game.ME.scroller, Const.DP_BG);
		this.number = number;
	}

	public inline function isValid(cx,cy) return cx>=0 && cx<wid && cy>=0 && cy<hei;
	public inline function coordId(cx,cy) return cx + cy*wid;

	public var ledProject : led.Project;
	public var level:led.Level;


	var collMap : Map<Int,Bool> = new Map();

	public function render() {
		// Debug level render
		root.removeChildren();

		// var pouet = led.Project.build("maps/MyMap.json");
		// Layer data
		var project = new _Project();


		var level = project.levels[number];

		// Load L-Ed project
		// var raw = hxd.Res.maps.MyMap.entry.getText();
		// var json = haxe.Json.parse(raw);
		// ledProject = new led.Project();
		// ledProject.parseJson(json);
		// level  = ledProject.[number];
		

		// Load atlas h2d.Tile from the disk
		var atlasTile = hxd.Res.atlas.tileset_dirt.toTile();

		var layer = level.l_Tiles;

		for( cx in 0...layer.cWid )
			for( cy in 0...layer.cHei ) {
				if( !layer.hasTileAt(cx,cy) )
					continue;

				// Get corresponding H2D tile from tileset
				var tile = layer.tileset.getHeapsTile(atlasTile, layer.getTileIdAt(cx,cy), 0);

				// Display it
				var bitmap = new h2d.Bitmap(tile, root);
				bitmap.x = cx*layer.gridSize;
				bitmap.y = cy*layer.gridSize;
			}


		var colLayer = level.l_IntGrid;

		for(cy in 0...colLayer.cHei)
			for(cx in 0...colLayer.cWid)
				if( colLayer.getInt(cx,cy)==1 )
					setCollision(cx,cy,true);
		var entityLayer = level.l_Entities;

		var goals = new Map<Int, en.Goal>();
		for (entity in entityLayer.all_Goal ) {
			var goal=new en.Goal(entity.cx, entity.cy, entity.f_color_int);
			goals.set(entity.f_id, goal);
			game.goals.push(goal);
		}
		for (entity in entityLayer.all_Block ) {
			var goal = goals.get(entity.f_id);
			var block=new en.Block(entity.cx, entity.cy, entity.f_color_int, entity.f_path, goal);
			game.blocks.push(block);
		}
		for (entity in entityLayer.all_PlayerStart ) {
			game.createPlayer(entity.cx, entity.cy);
		}

	}



	public inline function setCollision(cx,cy,v) {
		if( isValid(cx,cy) )
			if( v )
				collMap.set( coordId(cx,cy), true );
			else
				collMap.remove( coordId(cx,cy) );
	}

	public inline function hasCollision(cx,cy) {
		return isValid(cx,cy) ? collMap.get(coordId(cx,cy))==true : true;
	}

	override function postUpdate() {
		super.postUpdate();

		if( invalidated ) {
			invalidated = false;
			render();
		}
	}
}