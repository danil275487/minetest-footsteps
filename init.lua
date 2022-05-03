local opacity = tonumber(minetest.settings:get("footstep_opacity")) or 85
local lifetime = tonumber(minetest.settings:get("footstep_lifetime")) or 30

function math.random_float(lower, greater)
	return lower + math.random() * (greater - lower);
end

minetest.register_chatcommand("remove_footsteps", {
	description = "Removes all footsteps in the world",
	privs = {debug=true},
	func = 	function(name, param)
				for _, object in pairs(minetest.object_refs) do
					local ent = object:get_luaentity()
					if ent and ent.name == "footsteps:footstep" then
						object:remove()
					end
				end
			end,
})

minetest.register_entity("footsteps:footstep", {
	initial_properties = {
		visual = "cube",
		textures = 	{
						"^[resize:8x8^[colorize:black:255^[opacity:"..opacity,
						"^[resize:8x8^[colorize:black:255^[opacity:"..opacity,
						"^[resize:8x8^[colorize:black:255^[opacity:"..opacity,
						"^[resize:8x8^[colorize:black:255^[opacity:"..opacity,
						"^[resize:8x8^[colorize:black:255^[opacity:"..opacity,
					},
		use_texture_alpha = true,
		visual_size = {x = 0.2, y = 0.001, z = 0.2},
		static_save = false,
		pointable = false,
	},
	on_activate =	function(self, timer)
						self.timer = 0
					end,
	on_step =	function(self, dtime)
					local pos = self.object:get_pos()
					local node = minetest.get_node({x=pos.x, y=pos.y-0.1, z=pos.z})
					local def = minetest.registered_nodes[node.name]
					self.timer = self.timer + dtime
					if self.timer >= lifetime or def.walkable == false then
						self.object:remove()
					end
				end,
})

local step_timer = {}

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local vel = player:get_velocity()
		local pos = player:get_pos()
		local name = player:get_player_name()
		local node = minetest.get_node({x=pos.x, y=pos.y-0.1, z=pos.z})
		local def = minetest.registered_nodes[node.name]
		step_timer[name] = (step_timer[name] or 0) + dtime
		if def and def.walkable then
			if vel.x >= 0.01 or vel.z >= 0.01 then
				if step_timer[name] >= 0.2 then
					pos.x = pos.x + math.random_float(-0.2,0.2)
					pos.z = pos.z + math.random_float(-0.2,0.2)
					minetest.add_entity(pos, "footsteps:footstep")
					step_timer[name] = 0
				end
			end
		end
	end
end)
