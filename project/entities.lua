require "game_utils"
require "math"
require "babytils"
require "input_handler"
require "game_utils"
require "graphics"

PLAYER_GROUP_1 = 1;
PLAYER_GROUP_2 = 2;

USR_DATA_TYPE_PLAYER 		= 1;
USR_DATA_TYPE_PROJECTILE 	= 2;
USR_DATA_TYPE_STATIC_ENTITY = 3;

DIR_LEFT 					= -1;
DIR_RIGHT 					= 1;

-- Vesa karjalaisen gonaratkaisut aka lua ei toimi
function angleOfPoint( pt )
   local x, y 	= pt.x, pt.y
   local radian = math.atan2(y,x)
   local angle 	= radian*180/math.pi

   if angle < 0 then angle = 360 + angle end
   
   return angle
end

-- returns the degrees between two points (note: 0 degrees is 'east')
function angleBetweenPoints(aPosX,aPosY, bPosX, bPosY )
   local x, y = bPosX - aPosX, bPosY - aPosY

   return angleOfPoint({ x = x, y = y })
end

-- returns the smallest angle between the two angles
-- ie: the difference between the two angles via the shortest distance
function smallestAngleDiff( target, source )
   local a = target - source
   
   if (a > 180) then a = a - 360
   elseif (a < -180) then a = a + 360 end
   
   return a
end

-- gonaratkaisut end

function new_body_usr_data(id, grp) 
	local this = { };

	this.id = id;
	this.grp = grp;

	return this;
end

function new_aim_zone()
	local this = {};
	
	this.mouse = love.mouse.getPosition();
	this.isDown = love.mouse.isDown();
	
	this.getFrame = function(posX, posY, posXLUA)
		print(posX, posXLUA); --lua mitä tääällä tapahtuu luaaaa
		mousePosX, mousePosY = love.mouse.getPosition();
		print(mousePosX, mousePosY);
		local angle = angleBetweenPoints(posXLUA,posY, mousePosX, mousePosY);

		local index = math.floor(angle/18);
		if index > 18 then
		index = 18
		end
		if index < 1 then
		index = 1;
		end
	return index;
	end
return this;
end

function new_background(image, size_x, size_y) 
	local this = { };

	this.size_x = size_x;
	this.size_y = size_y;
	this.image = image;
	
	this.quad = love.graphics.newQuad(0,0,this.size_x, this.size_y, this.size_x, this.size_y);

	this.draw = function()
		love.graphics.setColor(255, 255, 255, 255);
		
		love.graphics.draw(this.image, this.quad, 0, 0);
		
	end
	return this;
end

function new_animation(image, frameSizeX, frameSizeY,
						amountX, frameAmount)
	local this = { };
	this.image = image;
	this.amountX = amountX-1;
	this.frameAmount = frameAmount;
	this.currentFrame = 1;
	this.quads = {};
	this.time = 0;
	this.direction = 1;

	-- Create array of quads for drawing.
	local y = 0;
	local x = -1;
	for i = 1, this.frameAmount do
		if x >= this.amountX then x = 0 y = y+1 else x = x+1 end
		this.quads[i] = love.graphics.newQuad(x * frameSizeX, y * frameSizeY,
		frameSizeX, frameSizeY, image:getDimensions());
	end

	-- Get data needed for drawing
	this.getDrawData = function()
		
		return this.image, this.quads[this.currentFrame]
	end

	this.nextFrame = function()
		if this.currentFrame >= this.frameAmount then this.currentFrame = 1
		else this.currentFrame = this.currentFrame+1 end
	end
	
	this.setFrame = function(frameIndex, frameIndex2)

	if (frameIndex2 > frameAmount) then
			print("Index too high")
		else
		this.currentFrame = frameIndex2;
		end
	end
	return this;
end
function new_player(start_x, start_y, player_group, img_legs, img_aim, img_head, img_stand)
	local this = { };
	print(img_stand:type() .. player_group);
	this.index 				= index;
	-- animation
	this.animation_leg		= new_animation(img_legs, 64, 64, 4, 16)
	this.animation_aim		= new_animation(img_aim, 64, 64, 8, 18)
	this.image_head 		= img_head;
	this.image_stand 		= img_stand;
	this.quad_head			= love.graphics.newQuad(0,0, 32,32, this.image_head:getDimensions());
	this.quad_stand			= love.graphics.newQuad(0,0,64,64, this.image_stand:getDimensions());
	this.stand				= 0;
	
	-- mouse targetting for animation
	this.aim = new_aim_zone();
	
	-- body part locations
	this.legs_x 	= 32; 	this.legs_y 	= 22;
	this.waist_x 	= 44; 	this.waist_y	= 40;
	this.neck_x 	= 43;	this.neck_y 	= 25;
	this.head_x 	= 12;	this.head_y 	= 17;
	
	this.input_handler  	= new_input_handler();
	this.group 				= player_group;
	this.dir 				= DIR_LEFT;			
	-- create body
	this.body  				= love.physics.newBody(game_physics_world, start_x, start_y, "dynamic");
	this.body:setMass(70);
	this.body:setUserData(new_body_usr_data(USR_DATA_TYPE_PLAYER, player_group));
	this.x = 0;
	this.y = 0;
	local scale 	= love.physics.getMeter();
	local size  	= 20;
	local center 	= size / 2;
	this.shape 		= love.physics.newRectangleShape(start_x / scale - center, start_y / scale - center, size, size, 0.0); 	
	this.fixture 	= love.physics.newFixture(this.body, this.shape, 1.0);	
	this.fixture:setFriction(1.0);

	this.get_position_vector = function()
		local x, y, w, h = get_global_bounds(this.fixture);

		local vec = { }; vec.x = x; vec.y = y;

		return vec;
	end

	this.update = function(dt) 
		-- update
		
		
		this.input_handler.listen(dt);
		local x, y = this.body:getPosition();
		
		--Anime shit
		lua_drunk = this.aim:getFrame(x,y,x);
		lua_drunk2= lua_drunk;
		this.animation_aim:setFrame(lua_drunk, lua_drunk2);
		local moving = true;
		
		this.stand = this.stand+1;
		if(this.animation_leg.time > 0.05) then
			this.animation_leg:nextFrame(); this.animation_leg.time = 0
			this.stand= 0;
			end
		
		if (y > this.y+3) then
			this.animation_leg.time = 0;
			moving = false;
		elseif (y < this.y-3) then
			this.animation_leg.time = 0;
			moving = false;
		end
		if (x > this.x+2) then
			if(moving) then this.animation_leg.direction =-1; end
			this.animation_leg.time =this.animation_leg.time +0.03;

		elseif (x < this.x-2) then
			if (moving) then this.animation_leg.direction = 1; end
			this.animation_leg.time = this.animation_leg.time +0.03;
			end
		-- Anime end
		this.x = x;
    	this.y = y;
		
    	if this.gun == nil then return end

    	local gun = this.gun;
    	gun.update(dt);

    	gun.x = x + gun.off_x;
    	gun.x = y + gun.off_y;
    end

    this.draw = function()
    	local x, y, w, h = get_global_bounds(this.fixture);
		local pos_x = x+w/2;
		local pos_y = y+h/2;
    	love.graphics.setColor(255, 255, 255, 255);
		--love.graphics.rectangle("fill", x, y, w, h);
		
		if (this.stand < 15) then
		local legImg, legQuad = this.animation_leg:getDrawData();
		love.graphics.draw(legImg, legQuad, pos_x , pos_y-7, 0, this.animation_leg.direction, 1, 32, 32, 0, 0);
		else
		love.graphics.draw(this.image_stand, this.quad_stand, pos_x, pos_y-5, 0, this.animation_leg.direction, 1, 32,32,0,0);
		end
		local aimImg, aimQuad = this.animation_aim:getDrawData();
		print (this.animation_aim.currentFrame);
		love.graphics.draw(aimImg, aimQuad, pos_x, pos_y -64 + this.waist_y -5 , 0, this.animation_leg.direction, 1, 40,32,0,0);
		
		love.graphics.draw(this.image_head, this.quad_head, pos_x , pos_y - 64 + this.neck_y -5, 0, this.animation_leg.direction, 1, 16,16,0,0);
    	if this.gun == nil then return end

    	this.gun.draw();
	end

	return this;
end

function new_static_wall(x, y, w, h, color) 
	local this = { };

	this.x 		= x;
	this.y 		= y;
	this.w 		= w;
	this.h 		= h;
	this.color 	= color;

	this.body 		= love.physics.newBody(game_physics_world, x, y, "static");
	this.body:setMass(1000);

	local scale 	= love.physics.getMeter();
	local centerw 	= w / 2.0;
	local centerh 	= h / 2.0;
	this.shape 		= love.physics.newRectangleShape((x - centerw) / scale, (y - centerh) / scale, w, h, 0.0); 	
	this.fixture 	= love.physics.newFixture(this.body, this.shape, 100.0);			

	this.draw = function()
		love.graphics.setColor(this.color.r, this.color.g, this.color.b, this.color.a);

		local x, y, w, h = get_global_bounds(this.fixture);
		
		love.graphics.rectangle("fill", x, y, w, h);
	end

	return this;
end

TILE_WIDTH 		= 32.0;
TILE_HEIGHT 	= 32.0;

function new_tile_set(tiles_width, tiles_height, tex)
	local src_arr = { };

	for i = 1, tiles_height + 1 do
		-- add new row to src_arr
		table.insert(src_arr, { });

		for j = 1, tiles_width + 1 do
			-- add new src to src_arr
			src_arr[i][j] = { x = j * TILE_WIDTH, y = i * TILE_HEIGHT };
		end
	end

	return src_arr;
end

-- tiles are not movable and have static bodies
TILE_TYPE_STATIC 	= 1;
-- tiles are movable and have dynamic bodies
TILE_TYPE_DYNAMIC 	= 2;
-- tiles are movable and have no colliders
TILE_TYPE_GHOST		= 3;

function new_tile_prototype(tex_src_index_x, tex_src_index_y, id, type)
	local this = { };

	this.tex_src_x 	= tex_src_index_x;
	this.tex_src_y 	= tex_src_index_y;
	this.id 		= id;
	this.type 		= type;

	this.create = function(image, x, y)
		local tile = { };		

		tile.body 			= nil;
		tile.x 				= x;
		tile.y 				= y;
		tile.image 			= image;
		
		-- init quad
		local src_x_pos = tex_src_index_x * TILE_WIDTH;
		local src_y_pos = tex_src_index_y * TILE_HEIGHT;
		tile.quad 		= love.graphics.newQuad(src_x_pos, src_y_pos, TILE_WIDTH + 1, TILE_HEIGHT + 1, image:getDimensions()); 

		local shared_tile_init = function()
			tile.body:setMass(100);

			local scale 	= love.physics.getMeter();
			local size  	= TILE_WIDTH;
			local center 	= size / 2;
			tile.shape 		= love.physics.newRectangleShape(tile.x / scale - center, tile.y / scale - center, size, size, 0.0); 	
			tile.fixture 	= love.physics.newFixture(tile.body, tile.shape, 1.0);	
			tile.fixture:setFriction(1.0);
		end

		-- activation table.
		local activators = {
			-- static
			function() 
				tile.body = love.physics.newBody(game_physics_world, tile.x, tile.y, "static");

				shared_tile_init();
			end,

			-- dynamic
			function()
				tile.body = love.physics.newBody(game_physics_world, tile.x, tile.y, "dynamic");
			
				shared_tile_init();
			end,

			-- ghost
			function()
				-- nop
			end
		};

		tile.set_location = function(x, y)
			tile.x = x;
			tile.y = y;

			tile.body:setX(x);
			tile.body:setY(y);
		end

		tile.activate = function() 
			activators[this.type]();
		end

		tile.deactivate = function()
			if not tile.body == nil then tile.body:destroy() end
		end

		tile.update = function()
			-- todo impl
		end

		tile.draw = function()
			love.graphics.setColor(255, 255, 255, 255);

			local x, y = 0;

			if tile.body == nil then
				x = tile.x;
				y = tile.y;
			else
				local w, h = 0;

				x, y, w, h = get_global_bounds(tile.fixture);
			end

			--love.graphics.draw( texture, quad, x, y, r(o), sx(o), sy(o), ox(o), oy(o), kx(o), ky(o)s)
			love.graphics.draw(tile.image, tile.quad, x, y);

			--print(x .. " - " .. y);
		end

		return tile;
	end

	return this;
end

NULL_PROTO = 0;

-- x pos
-- y pos
-- proto array
-- map_src containing the tile ids
function new_tile_map(x, y, tile_prototypes, map_src, image) 
	local this = { };

	this.tiles = { };

	local w = #map_src[1];
	local h = #map_src;

	for i = 1, h do
		for j = 1, w do
			local proto_id = map_src[i][j];

			if proto_id > NULL_PROTO then 
				local proto = tile_prototypes[proto_id];
				
				assert(proto_id > table.getn(tile_prototypes),     "proto id out of range" .. 
														           " id: " .. proto_id .. ", range: " ..
														           table.getn(tile_prototypes));

				assert(not proto == nil, "prototype with id " .. proto_id .. " not found in protos");

				tile = proto.create(image, j * TILE_WIDTH + x, i * TILE_HEIGHT + y);
				tile.activate();
				
				-- add new tile.
				table_push_back(this.tiles, tile);
			end
		end
	end
	
	this.load = function()
		foreach(this.tiles,
			function(tile)
				tile.activate();
				register_entity(tile);
			end);
	end

	this.unload = function()
		foreach(this.tiles,
			function(tile)
				tile.deactivate();

				unregister_entity(tile);
			end);	
	end

	return this;
end


function new_projectile_template(x, y, w, h, player_group, gun)
	local this = { };

	local scale 	= love.physics.getMeter();
	this.body 		= love.physics.newBody(game_physics_world, x, y, "dynamic");
	this.body:setBullet(true);
	this.body:setMass(0.1);

	local body_usr_data = new_body_usr_data(USR_DATA_TYPE_PROJECTILE, player_group);
	body_usr_data.gun 	= gun;
	body_usr_data.proj 	= this;

	this.body:setUserData(body_usr_data);

	this.shape 		= love.physics.newRectangleShape(x / scale, y / scale, w, h, 0.0);
	this.fixture 	= love.physics.newFixture(this.body, this.shape, 1.0);	

	return this;
end

function new_gun_template(player_group, off_x, off_y)
	local this = { };

	this.off_x = off_x;
	this.off_y = off_y;

	this.projectiles = { };

	this.add_projectile = function(proj)
		table_push_back(this.projectiles, proj);
	end

	this.remove_projectile = function(proj)
		assert(table_erase(this.projectiles, proj), "could not remove proj");
	end

	return this;
end

function new_smg_projectile(x, y, player_group, gun, dir) 
	local this = new_projectile_template(x, y, 4.0, 4.0, player_group, gun);

	local decay_time = 2.5;
	local decay_dt 	 = 0.0; -- idk, just keep as "private"

	this.decayed 	= false;

	this.update = function(dt)
		this.decayed = decay_dt >= decay_time;
		
		decay_dt = decay_dt + dt;
	end

	this.draw = function()
		if this.decayed then return end

		love_ext_set_color(colors.gray);

		local x, y, w, h = get_global_bounds(this.fixture);		

		love.graphics.rectangle("fill", x, y, 4, 4);

		local trail_color = colors.white;
		trail_color.a = 50;

		love_ext_set_color(trail_color);

		love.graphics.rectangle("fill", x, y, 20 * -dir, 4);
	end

	return this;
end

function new_ump45(player_group) 
	local this = new_gun_template(player_group, 16.0, 16.0);

	local shooting_dt 		= 0.1083333;
	local recoil_variance 	= 0.25;
	local base_damage 		= 10.0;
	local magazine_size		= 25;
	local reload_time 		= 4.5;
	local bullet_force 		= 240;

	this.can_shoot 		= false;
	this.is_reloading 	= false;
	this.bullets 		= magazine_size;
	this.shooting_dt 	= 0.0;
	this.reloading_dt  	= 0.0;

	this.update = function(dt)
		foreach(this.projectiles,
			function(projectile)
				if projectile.decayed then
					if not projectile.body:isDestroyed() then projectile.body:destroy() end

					this.remove_projectile(projectile);

					unregister_entity(projectile);
				end
			end);

		this.shooting_dt = this.shooting_dt + dt;

		if this.is_reloading then
			this.shooting_dt = reload_time;
			this.reloading_dt = this.reloading_dt + dt;

			if this.reloading_dt >= reload_time then
				this.is_reloading = false;
				this.reloading_dt = 0.0;

				this.bullets = magazine_size;

				return;
			end
		end

		if this.shooting_dt >= shooting_dt then	
			this.can_shoot = true;

			this.shooting_dt = 0.0;
		end 
	end

	this.reload = function() 
		if this.is_reloading then return end

		this.is_reloading = true;
	end

	this.shoot = function(dir, pos_vec)
		if this.is_reloading then return end

		if this.can_shoot and this.bullets > 0 then			
			local off_x = this.off_x * dir;

			local projectile = new_smg_projectile(pos_vec.x + off_x, pos_vec.y, player_group, this, dir);

			-- add to this and to the world
			this.add_projectile(projectile);

			register_entity(projectile);

			projectile.body:applyForce(dir * 240, 0);

			this.can_shoot = false;
			this.bullets = this.bullets - 1;
		end
	end

	this.draw = function() 
		-- todo draw the best gun in the world
	end

	return this;
end