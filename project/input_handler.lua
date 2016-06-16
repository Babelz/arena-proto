require "babytils"

triggers = {
	RELEASED 	= 0,
	PRESSED     = 1,
	DOWN 	    = 2
}

key_states = {
	RELEASED = 0,
	DOWN     = 1
}

function new_mapping(name, key_string, action, trigger) 
	assert(string_is_nil_or_empty(name), "name can't be nil or empty");
	assert(string_is_nil_or_empty(key_string), "key string can't be nil or empty");
	assert(action == nil, "action can't be nil");
	assert(trigger == nil, "trigger can't be nil");

	local this = { };

	-- init "object"
	this.name 		= name;
	this.key_string = key_string;
	this.action 	= action;
	this.trigger 	= trigger;
	-- set default states
	this.state_old 	= key_states.RELEASED;
	this.state_new 	= key_states.RELEASED;

	return this;
end

function new_input_handler()
	local this = { };

	this.mappings = { };

	this.map = function(name, key_string, trigger, action)
		-- check that the mapping name is not in use
		foreach(this.mappings, 
			function(mapping)
				assert(not mapping.name == name, "mapping with name " .. name .. " already exists");
			end);

		-- add the new mapping
		local mapping = new_mapping(name, key_string, action, trigger);

		table.insert(this.mappings, mapping);
	end

	this.unmap = function(name)
		local mapping = table_find(this.mappings, function(m) return m.name == name end);

		if mapping == nil then return end

		table_erase(this.mappings, mapping);
	end

	this.listen = function(dt) 
		foreach(this.mappings, 
			function(mapping)	
				-- get current key state from input and store it here
				local new_state 	= 0;
				local last_state 	= mapping.state_new;
				local key_trigger 	= mapping.trigger;

				-- don't you ffaaahhen dare to touch this 

				if love.keyboard.isDown(mapping.key_string) then 
					new_state = key_states.DOWN 
				else 
					new_state = key_states.RELEASED 
				end
				-- store new and old states
				mapping.state_old = last_sate;
				mapping.state_new = new_state;
				
				if key_trigger == triggers.RELEASED then
					-- handle released
					if last_state == key_states.DOWN and new_state == key_states.RELEASED then mapping.action(dt) end
				elseif key_trigger == triggers.DOWN then
					-- handle down
					if new_state == key_states.DOWN then mapping.action(dt) end
				elseif key_trigger == triggers.PRESSED then
					-- handle pressed
					if last_state == key_states.RELEASED and new_state == key_states.DOWN then mapping.action(dt) end   
				end 
			end);
		end

	return this;
end