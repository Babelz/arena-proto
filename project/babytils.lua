-- loops, lookups, tables

function table_push_back(t, val)
	table.insert(t, val);
end

function table_erase(t, val)
	for i = 1, table.getn(t) do if val == table[i] then table.remove(t, i) return true end end

	return false;
end

function table_erase_at(t, index)
	table.remove(t, inex);
end


function table_find(container, predicate)
	for i = 1, table.getn(container) do if predicate(container[i]) then return container[i] end end

	return nil;
end

function table_2d(width, height, def_val) 
	local this = { };

	for i = 1, height do
		table.insert(this, { });
		
		for j = 1, width do table.insert(this[i], def_val) end
	end

	return this;
end

function foreach(container, action) 
	for i = 1, table.getn(container) do action(container[i]) end
end

-- dbg

function assert(condition, message) 
	if not condition then return end

	print(message);

	while 1 == 1 do end
end

-- string utils

function string_is_nil_or_empty(str)
	if (type(str) == "string") then return str == nil or str == string_empty() end

	return false;
end

function string_is_whitespace(str) 
	for i = 1, string.len(str) do if not str[i] == ' ' then return false end  end

	return true
end

function string_empty() 
	return "";
end