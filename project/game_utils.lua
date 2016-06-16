-- extracts x, y, w and h from 
-- the given fixture
-- returns: x, y, w, h
function get_global_bounds(fixture) 
	local tlx, tly, brx, bry 	= fixture:getBoundingBox();
	local w 					= brx - tlx;
	local h 					= bry - tly;

	return tlx, tly, w, h;
end