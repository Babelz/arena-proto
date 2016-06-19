require "entities"
require "graphics"

-- b2 world
game_physics_world 			= nil;

window_width 				= 1920;

window_height 				= 1080;

local meter 				= 128.0; -- b2 meters, works as a scale as well

local player_desired_vel    = 250.0;

local player_jumping_force  = 15.0;

local physics_gravity 		= 9.81;

local physics_allow_sleep 	= false;

local create_world_bounds	= false;

-- player
local player;
local player2;

local entities = { };

function register_entity(entity)
	table.insert(entities, entity);
end

function unregister_entity(entity)
	for i = 1, #entities do  
		if entities[i] == entity then table.remove(entities, i) break end
	end
end

function begin_contact(a, b, coll)
	local a_usr_data = a:getUserData();
	local b_usr_data = b:getUserData();
end

function end_contact(a, b, coll)
end

function pre_solve(a, b, coll)
end

function post_solve(a, b, coll, normal_impulse, tangent_impulse)
end

function love.load() 
	-- setup window
	love.window.setTitle("ebin arena");

	local success = love.window.setMode(window_width, window_height, { vsync = true });

	if not success then assert(false, "could not change window mode") end

	-- setup worlds
	love.physics.setMeter(meter);
	game_physics_world = love.physics.newWorld(0.0, physics_gravity * meter, physics_allow_sleep);
	game_physics_world:setCallbacks(begin_contact, end_contact, pre_solve, post_solve);

	-- setup player
	local scale = love.physics.getMeter();

	local playermodelLegs		= love.graphics.newImage("assets/jalat1_juoksu_ss.png");
	local playermodelAim 		= love.graphics.newImage("assets/tahtays1_ss.png");
	local playermodelHead 		= love.graphics.newImage("assets/kypara.png");
	local playermodelStand		= love.graphics.newImage("assets/hahmo1_seisonta.png");
	-- p1
	player = new_player(window_width / 2.0 - 32, window_height / 2.0, 1, playermodelLegs, playermodelAim, playermodelHead, playermodelStand);
	local player_input_handler = player.input_handler;
	
	player_input_handler.map("right", "d", triggers.DOWN, 
		function(dt)
			local x, y 		= player.body:getLinearVelocity();
			local vchange 	= player_desired_vel - x;
			local impulse 	= player.body:getMass() * vchange;
			player.dir 		= DIR_RIGHT;

			player.body:applyLinearImpulse(impulse, 0);
		end);

	player_input_handler.map("left", "a", triggers.DOWN, 
		function(dt)
			local x, y 		= player.body:getLinearVelocity();
			local vchange 	= -player_desired_vel - x;
			local impulse 	= player.body:getMass() * vchange;
			player.dir 		= DIR_LEFT;
			
			player.body:applyLinearImpulse(impulse, 0);
		end);

	player_input_handler.map("jump", "w", triggers.PRESSED,
		function(dt)
			player.body:applyLinearImpulse(0, -player_jumping_force);
		end);

	player_input_handler.map("shoot", "v", triggers.DOWN,
		function(dt)
			player.gun.shoot(player.dir, player.get_position_vector());
		end);

	player_input_handler.map("reload", "r", triggers.PRESSED,
		function(dt)
			if player.gun.is_reloading then return end

			player.gun.reload();
		end);

	player.gun = new_ump45(PLAYER_GROUP_1); 

	-- p2
	
	player2 = new_player(window_width / 2.0 - 32, window_height / 2.0,2, playermodelLegs, playermodelAim, playermodelHead, playermodelStand);
	local player_input_handler = player2.input_handler;
	
	player_input_handler.map("right", "l", triggers.DOWN, 
		function(dt)
			local x, y 		= player2.body:getLinearVelocity();
			local vchange 	= player_desired_vel - x;
			local impulse 	= player2.body:getMass() * vchange;
			player2.dir 	= DIR_RIGHT;

			player2.body:applyLinearImpulse(impulse, 0);
		end);

	player_input_handler.map("left", "j", triggers.DOWN, 
		function(dt)
			local x, y 		= player2.body:getLinearVelocity();
			local vchange 	= -player_desired_vel - x;
			local impulse 	= player2.body:getMass() * vchange;
			player2.dir 	= DIR_LEFT;
			
			player2.body:applyLinearImpulse(impulse, 0);
		end);

	player_input_handler.map("jump", "i", triggers.PRESSED,
		function(dt)
			player2.body:applyLinearImpulse(0, -player_jumping_force);
		end);

	player_input_handler.map("shoot", "o", triggers.DOWN,
		function(dt)
			player2.gun.shoot(player2.dir, player2.get_position_vector());
		end);

	player_input_handler.map("reload", "p", triggers.PRESSED,
		function(dt)
			if player2.gun.is_reloading then return end
			player2.gun.reload();
		end);

	player2.gun = new_ump45(PLAYER_GROUP_1); 

	-- create walls.
	if create_world_bounds then
		local wall_thickness = 32;

		local left_wall = new_static_wall(
			wall_thickness / 2.0,
			window_height / 2.0,
			wall_thickness,
			window_height,
			colors.red);
		
		local bottom_wall = new_static_wall(
			window_width / 2.0,
			window_height - wall_thickness / 2.0,
			window_width - wall_thickness * 2.0,
			wall_thickness,
			colors.green);
		
		local right_wall = new_static_wall(
			window_width - wall_thickness * 0.8, 
			window_height / 2.0,
			wall_thickness,
			window_height,
			colors.pink);

		local top_wall = new_static_wall(
			window_width / 2.0,
			wall_thickness / 2.0,
			window_width - wall_thickness * 2.0,
			wall_thickness,
			colors.green);

		register_entity(left_wall);
		register_entity(bottom_wall);
		register_entity(right_wall);
		register_entity(top_wall);
	end

	local fps_str = "";
	local mem_str = "";
	local eco_str = "";

	local dbg_text_renderer = {
		update = function(dt)
			fps_str = "FPS: " .. love.timer.getFPS();

			local kb = gcinfo();

			mem_str = "Mem-usage: " .. kb .. "kb";
			
			eco_str = "Entitites: " .. #entities;
		end,
		
		draw = function()
			if true then return end
			love.graphics.setColor(255, 255, 255, 255);
			love.graphics.print(mem_str, 32, 32, 0, 1, 1, 0, 0);
			love.graphics.print(fps_str, 32, 64, 0, 1, 1, 0, 0);
			love.graphics.print(eco_str, 32, 96, 0, 1, 1, 0, 0);
		end
	};

	-- setup map
	
	-- setup protos
	-- Background tiles
	local bg_protos = {
		new_tile_prototype(0, 0, 1, TILE_TYPE_GHOST),
		new_tile_prototype(1, 0, 2, TILE_TYPE_GHOST),
		new_tile_prototype(2, 0, 3, TILE_TYPE_GHOST),
		new_tile_prototype(3, 0, 4, TILE_TYPE_GHOST),
		new_tile_prototype(4, 0, 5, TILE_TYPE_GHOST),
		new_tile_prototype(0, 1, 6, TILE_TYPE_GHOST),
		new_tile_prototype(1, 1, 7, TILE_TYPE_GHOST),
		new_tile_prototype(2, 1, 8, TILE_TYPE_GHOST),
		new_tile_prototype(3, 1, 9, TILE_TYPE_GHOST),
		new_tile_prototype(4, 1, 10, TILE_TYPE_GHOST),
		new_tile_prototype(0, 2, 11, TILE_TYPE_GHOST),
		new_tile_prototype(1, 2, 12, TILE_TYPE_GHOST),
		new_tile_prototype(2, 2, 13, TILE_TYPE_GHOST),
		new_tile_prototype(3, 2, 14, TILE_TYPE_GHOST),
		new_tile_prototype(4, 2, 15, TILE_TYPE_GHOST),
		new_tile_prototype(0, 3, 16, TILE_TYPE_GHOST),
		new_tile_prototype(1, 3, 17, TILE_TYPE_GHOST),
		new_tile_prototype(2, 3, 18, TILE_TYPE_GHOST),
		new_tile_prototype(3, 3, 19, TILE_TYPE_GHOST),
		new_tile_prototype(4, 3, 20, TILE_TYPE_GHOST),
		new_tile_prototype(0, 4, 21, TILE_TYPE_GHOST),
		new_tile_prototype(1, 4, 22, TILE_TYPE_GHOST),
		new_tile_prototype(2, 4, 23, TILE_TYPE_GHOST),
		new_tile_prototype(3, 4, 24, TILE_TYPE_GHOST),
		new_tile_prototype(4, 4, 25, TILE_TYPE_GHOST),
	};
	
	local static_protos = {
		new_tile_prototype(3, 3, 1, TILE_TYPE_STATIC),
		new_tile_prototype(4, 3, 2, TILE_TYPE_STATIC),
		new_tile_prototype(4, 3, 3, TILE_TYPE_STATIC),
		new_tile_prototype(4, 3, 4, TILE_TYPE_STATIC),
	};

	local bg_src = {
		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1 },
		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1 },
		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1 },
		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0,14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0,14, 0, 0, 1, 1, 1, 1 },
		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 9, 8, 9,14,10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 5, 9, 8, 9,14,10, 0, 0, 1, 1, 1, 1 },
		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8,16, 0, 0,17,13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 8,16, 0, 0,17,13, 0, 0, 1, 1, 1, 1 },
		{ 0, 2,10, 0, 0, 0, 0, 0, 0, 0, 0,24,15, 0, 0,18,21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 24,15,0, 0,18,21, 0, 0, 1, 1, 1, 1 },
		{ 2, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8,15, 0, 0,18,10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 8,15, 0, 0,18,10, 0, 0, 1, 1, 1, 1 },
		{ 1, 1, 0, 0, 0, 0, 0, 0, 0, 5, 2, 1,15, 0, 0,18, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1,15, 0, 0,18, 4, 0, 0, 1, 1, 1, 1 },
		{ 1, 1,14, 0, 0, 0, 0, 0, 0, 0, 1, 1,15, 0, 0,18,13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1,15, 0, 0,18,13, 0, 0, 1, 1, 1, 1 },
		{ 1,12, 8, 7, 0, 0, 0, 0, 0, 5, 1, 1,15, 0, 0,18, 1,14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1,15, 0, 0,18, 1, 0, 0, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
	};

	local static_src = {
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,2,2,2,2,0,0,0,0,0,0,0,0,0,0,2,2,2,0,2,0,0,2,0,0,2,0,0,0,0,0,0,0,0,0,4,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,2,4,0,0,0,0,0,0,4,2,2,4,0,0,2,2,2,0,0,0,2,4,2,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,2,0,0,0,0,0,2,4,0,0,0,0,4,0,0,4,0,0,0,0,0,0,4,0,0,0,0,4,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,2,4,0,0,0,0,2,4,0,0,0,0,2,4,0,0,4,0,0,0,0,0,0,0,0,0,0,2,4,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,2,4,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,4,0,0,0,0,0,0,0,0,0,0,0,4,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,4,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,2,2,0,0,0,0,0,0,2,2,2,2,2,2,2,0,0,0,4,0,0,4,0,0,0,4,2,0,0,0,2,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,2,0,0,4,0,0,4,0,0,0,0,0,0,0,0,4,2,2,2,2,2,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,2,2,2,2,0,0,0,0,0,4,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,4,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,2,2,0,0,4,0,0,0,0,0,0,0,0,0,0,0,2,4,4,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,4,0,0,0,2,2,2,2,2,2,2,2,4,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,2,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,4,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0,4,2,2,2,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,3,4,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,3,4,4,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,3,0,0,4,4,0,0,3,3,3,0,0,0,0,0,3,3,3,3,3,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,2,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,3,0,0,2,0,0,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,2,3,3,3,0,0,0,3,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,3,3,2,3,3,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,2,2,2,2,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	};
	local sunset_bg = love.graphics.newImage("assets/Sunset.png");
	local bg_set = love.graphics.newImage("assets/tileSheet.png");
	local static_set = love.graphics.newImage("assets/tileSheet.png");
	background = new_background(sunset_bg, window_width, window_height);
	register_entity(background);

	local bg = new_tile_map(-30, -28, bg_protos, bg_src, bg_set);
	bg.load();

	local static = new_tile_map(0, 0, static_protos, static_src, static_set);
	static.load();

	register_entity(player);
	register_entity(player2);

	register_entity(dbg_text_renderer);
end

function love.update(dt)
	-- allow the game to exit.
	if love.keyboard.isDown("escape") then os.exit() end

	game_physics_world:update(dt);

	foreach(entities,
		function(entity)
			-- todo fix
			if entity == nil then return end

			fnc = entity["update"];

			if fnc == nil then return end

			fnc(dt);
		end);
end

function love.draw() 
	foreach(entities,
		function(entity)
			-- todo fix
			if entity == nil then return end

			fnc = entity["draw"];

			if fnc == nil then return end

			fnc();
		end);
end