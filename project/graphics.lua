colors = {
	red 	= { r = 255, g = 0, b = 0, a = 255 },
	green 	= { r = 0, g = 255, b = 0, a = 255 },
	pink 	= { r = 255, g = 125, b = 125, a = 255 },
	gray 	= { r = 128, g = 128, b = 128, a = 128 },
	white 	= { r = 255, g = 255, b = 255, a = 255 }
}

function love_ext_set_color(colors_color)
	love.graphics.setColor(colors_color.r, colors_color.g, colors_color.b, colors_color.a);
end