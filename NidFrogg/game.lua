-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua


-- end screen
-- start screen

local _ENV = require 'std.strict' (_G)
local class = require 'middleclass'
local Player = class('Player')
local Sword = class('Sword')

GRAVITY = 0.2
LOW_GROUND = 80
SCREEN_START = 0
SCREEN_END = 220
TARGET = -1000
TIME = 0

local position_updated = false
local position = 0
local map_x = 0

function Player:initialize(x, y, direction, p_offset, name)
	self.name = name
	self.x = x
	self.y = y
	self.speed = 1.5
	self.p_offset = p_offset
	self.S_STATES = {
		UP = 0,
		MIDDLE = 1,
		DOWN = 2,
	}
	self.sword_state = self.S_STATES.MIDDLE
	self.IDS = {
		START = 256 + p_offset,
		RUN = {
			258 + p_offset,
			260 + p_offset,
			262 + p_offset,
			264 + p_offset,
		},
		UP_RUN = {
			322 + p_offset,
			324 + p_offset,
			326 + p_offset,
			328 + p_offset,
		},
		UP_STAND = 320 + p_offset,
		IN_AIR = 392 + p_offset,
		FALLING = 394 + p_offset,
		CROUCH = 266 + p_offset,
		CROUCH_W = {
			266 + p_offset,
			268 + p_offset,
			270 + p_offset,
		},
		ATTACK = {
			[0] = 448 + p_offset,
			[1] = 450 + p_offset,
			[2] = 452 + p_offset,
			[3] = 457 + p_offset,
			[4] = 454 + p_offset,
			[5] = 330 + p_offset
		},
		PUNCH = {
			[0] = 384 + p_offset,
			[1] = 386 + p_offset,
			[2] = 388 + p_offset,
			[3] = 390 + p_offset,
			[4] = 390 + p_offset,
			[5] = 390 + p_offset,
		},
		ATTACK_HIGH = 457 + p_offset,
		ATTACK_MEDIUM = 454 + p_offset,
		ATTACK_LOW =  330 + p_offset,
		DEAD = 334 + p_offset
	}
	self.spr_id = self.IDS.START
	self.hurt = false
	self.direction = direction
	self.dx = 0
	self.dy = 0
	self.has_sword = true
	self.is_jumping = false
	self.ground_position = y
	self.health = 2
	self.run_sprite_index = 1
	self.crouch_sprite_index = 1
	self.jump_state = 0
	self.is_attacking = false
	self.bigger_sprite_flag = 0
	self.is_bouncing_back = false
	self.won_round = false
end
local plr1 = Player:new(20, LOW_GROUND, 0, 0, "One")
local plr2 = Player:new(200, LOW_GROUND, 1, 32, "Two")

function Player:equals(other)
	return self.name == other.name
end

function Player:draw()
	local offset = 0
	if self.direction == 1 and self.bigger_sprite_flag == 1 then offset = - 8 end
	spr(self.spr_id,self.x + offset,self.y,11,1,self.direction,0,2 + self.bigger_sprite_flag,2)
end

function Player:jump()
	if self.is_bouncing_back then return end
	if self.jump_state == 1 then 
		self.sword_state = self.S_STATES.DOWN
		if not self.is_jumping then
			self.ground_position = LOW_GROUND 
			self.is_jumping = true
			self.dy = -4
		end
		return 
	end
	self.dy = self.dy + GRAVITY
	self.y = self.y + self.dy
	self.spr_id = self.dy > 0 and self.IDS.FALLING or self.IDS.IN_AIR
	self.sword_state = self.dy > 0 and self.S_STATES.UP or self.S_STATES.MIDDLE
	if self.y >= self.ground_position then
		self.y = self.ground_position
		self.is_jumping = false
		self.jump_state = 0
		self.sword_state = self.S_STATES.MIDDLE
	end
end	

function Player:bounce_back()
	if not self.is_bouncing_back then
		self.is_bouncing_back = true
		self.dy = -5
		self.dx = self.direction == 0 and -2 or 2
		self.ground_position = LOW_GROUND
	end
	self.dy = self.dy + GRAVITY
	self.y = self.y + self.dy
	self.x = self.x + self.dx
	if not self.is_attacking then 
		self.spr_id = self.dy > 0 and self.IDS.FALLING or self.IDS.IN_AIR
		self.sword_state = self.dy > 0 and self.S_STATES.UP or self.S_STATES.MIDDLE
	end
	if self.y >= self.ground_position then
		self.y = self.ground_position
		self.is_bouncing_back = false
		self.sword_state = self.S_STATES.MIDDLE
	elseif self.x >= SCREEN_END or self.x <= SCREEN_START then
		self.x = 120 - self.x >= 0 and SCREEN_START + 3 or SCREEN_END - 3
		self.dx = 0
	end
end

function Player:move()
	if self.health <= 0 then 
		self:update_sprite()
		return

	end
	if self.is_bouncing_back then self:bounce_back() return end
	if not self.won_round then 
		if self.x + self.dx >= SCREEN_END or self.x + self.dx <= SCREEN_START then return end
	end
	self.x = (self.sword_state == self.S_STATES.DOWN or self.is_attacking) and self.x + self.dx/2 or self.x + self.dx

	if self.dx ~= 0 then
		self.direction = self.dx > 0 and 0 or 1
	end
	if TARGET > SCREEN_END then
		if self.x >= TARGET then
			new_round(self.x)
		end
	else
		if self.x <= TARGET then
			new_round(self.x)
		end
	end
	if not self.is_attacking then self:update_sprite() end
	self.dx = 0
end

function Player:check_punch()
	if self.health <= 0 then return end

	local other = self:equals(plr1) and plr2 or plr1
	if self.x + 4 <= other.x + 16 and self.x + 4 >= other.x then
		if self.y >= other.y and self.y <= other.y + 16 then
			-- kill and stuff
			if not other.has_sword then 
				other.health = other.health - 1 
			end
			if other.health <= 0 then self.won_round = true end
			self.is_attacking = false
			self:bounce_back()
			other.hurt = true

		end
	end

end


function Player:update_sprite()
	if self.health <= 0 then self.spr_id = self.IDS.DEAD return end
	local i = 0
	if self.dx ~= 0 and self.jump_state ~= 2 then
		if self.sword_state == self.S_STATES.MIDDLE then
			self.run_sprite_index = self.run_sprite_index + 1
			self.run_sprite_index = self.run_sprite_index % 28 + 1
			i = self.run_sprite_index // 7 + 1
			self.spr_id = self.IDS.RUN[i] 
		elseif self.sword_state == self.S_STATES.DOWN then
			self.crouch_sprite_index = self.crouch_sprite_index + 1
			self.crouch_sprite_index = self.crouch_sprite_index % 42 + 1
			i = self.crouch_sprite_index // 14 + 1
			self.spr_id = self.IDS.CROUCH_W[i] 
		elseif self.sword_state == self.S_STATES.UP then
			self.run_sprite_index = self.run_sprite_index + 1
			self.run_sprite_index = self.run_sprite_index % 28 + 1
			i = self.run_sprite_index // 7 + 1
			self.spr_id = self.IDS.UP_RUN[i] 
		end
    elseif self.jump_state ~= 2 then
		if self.sword_state == self.S_STATES.DOWN then
			self.spr_id = self.IDS.CROUCH
		elseif self.sword_state == self.S_STATES.UP then
			self.spr_id = self.IDS.UP_STAND
		else
			self.spr_id = self.IDS.START
		end
	end
end

function Player:reset(x, y, direction)
    self.x = x
    self.y = y
    self.sword_state = self.S_STATES.MIDDLE
    self.spr_id = self.IDS.START
    self.hurt = false
    self.direction = direction
    self.dx = 0
    self.dy = 0
    self.has_sword = true
    self.is_jumping = false
    self.ground_position = y
    self.health = 2
    self.run_sprite_index = 1
    self.crouch_sprite_index = 1
    self.jump_state = 0
    self.is_attacking = false
    self.bigger_sprite_flag = 0
    self.is_bouncing_back = false
    self.won_round = false
end

--local plr1 = Player:new(20, LOW_GROUND, 0, 0, "One")
--local plr2 = Player:new(200, LOW_GROUND, 1, 32, "Two")

function Sword:initialize(plr)
    self.player = plr
    local metatable = {
        __index = function(table, key)
            if key == 'x' then
                if rawget(table, 'on_screen_x') ~= nil then
                    return rawget(table, 'on_screen_x')
                else
                    return plr.direction == 0 and plr.x + 14 or plr.x - 6
                end
            elseif key == 'y' then
                if rawget(table, 'on_screen_y') ~= nil then
                    return rawget(table, 'on_screen_y')
                elseif plr.sword_state == plr.S_STATES.MIDDLE then
                    return plr.y + 8
                elseif plr.sword_state == plr.S_STATES.UP then
                    return plr.y + 2
                else
                    return plr.y + 10
                end
            elseif key == 'state' then
                return plr.sword_state
            end
        end,
        __newindex = function(table, key, value)
            if key == 'x' then
                rawset(table, 'on_screen_x', value)
            elseif key == 'y' then
                rawset(table, 'on_screen_y', value)
            end
        end
    }

    self.id = 508
    self.dx = 0
	self.dy = 0
    self.on_screen = true
	self.animate_throw = 0
	self.animate_stab = 0
	self.is_disarming = false
	self.landing_spot = 0
	self.rotate = 0
    self.THROW_SPRITES = { 
		[0] = 492, 
		[1] = 493, 
		[2] = 494, 
		[3] = 495 
	}

    self.throw = function()
        if self.animate_throw < 9 then
			if self.animate_throw == 1 then sfx(1,'B-4', 20, 1, 15, 5) end
			local x = self.animate_throw // 3
			self.player.spr_id = self.player.IDS.ATTACK[x]
			if self.animate_throw == 0 then
				self.on_screen = false
				local temp_y = self.y
				self.y = temp_y
				self.player.is_attacking = true
				self.x = self.player.direction == 0 and self.player.x + 14 or self.player.x - 6
			end
			self.animate_throw = self.animate_throw + 1
			return
		end
		
		if not self.on_screen then
			self.on_screen = true
			self.player.has_sword = false
			self.player.is_attacking = false
			self.dx = self.player.direction == 0 and 4 or -4
		end
		
		local result = self.x + self.dx
		self.x = result
		self.animate_throw = self.animate_throw + 1
		self.id = self.THROW_SPRITES[self.animate_throw % 4]
		self:check_collision()
    end

	self.stab = function()
		local sword_state = self.player.sword_state or self.player.S_STATES.MIDDLE

		if self.animate_stab < 16 then
			local z = self.animate_stab // 4
			if self.animate_stab >= 12 then 
				z = z + sword_state 
			end
			self.player.spr_id = self.player.has_sword and self.player.IDS.ATTACK[z] or self.player.IDS.PUNCH[z]
			if self.animate_stab == 0 then
				self.player.is_attacking = true
				if self.player.has_sword then self.on_screen = false end
			elseif self.animate_stab == 12 and self.player.has_sword then
				self.player.bigger_sprite_flag = 1
			end
			self.animate_stab = self.animate_stab + 1
			return
		end
		if self.player.has_sword then sfx(3,'A#4',5,1,15,5)
		else sfx(3,'C-4',5,1,15,5) end
		
		self.player.is_attacking = false
		self.on_screen = true
		self.animate_stab = 0
		self.player.bigger_sprite_flag = 0
		self.player:check_punch()
		self:check_collision()
	end

	
		

	self.disarm = function()
		if not self.is_disarming then 
			self.dx = self.player.direction == 0 and -0.5 or 0.5
			self.dy = -4
			self.player.has_sword = false
			self.is_disarming = true
			self.landing_spot = LOW_GROUND + 8
			self.player.sword_state = self.player.S_STATES.MIDDLE
		end
	
		local result = self.x + self.dx
		self.x = result
		
		self.dy = self.dy + GRAVITY
		local y_result = self.y + self.dy
		self.y = y_result
	
		self.animate_throw = self.animate_throw + 1
		self.id = self.THROW_SPRITES[self.animate_throw % 4]
		
		if self.x < SCREEN_START then self.x = SCREEN_START + 2 end
		if self.x > SCREEN_END then self.x = SCREEN_END - 2 end
	
		if self.y >= self.landing_spot then
			self.y = self.landing_spot
			self.rotate = 3
			self.dx = 0
			self.dy = 0
			self.id = 508
			self.animate_throw = 0
			self.is_disarming = false
			self.player.sword_state = self.player.S_STATES.MIDDLE
			self.player.hurt = false
		end
	end

	self.check_pickup = function()
		if self.rotate ~= 3 or self.dx ~= 0 then return end
		if self.x >= self.player.x - 3 and self.x <= self.player.x + 16 then
			self.player.has_sword = true
			rawset(self, 'on_screen_x', nil)
			rawset(self, 'on_screen_y', nil)
			self.player.sword_state = self.player.S_STATES.MIDDLE
			self.rotate = 0
		end
	end

	self.draw = function()
		local i = 0
		if self.player.has_sword and self.on_screen then
			if self.player.run_sprite_index <= 21 
			  and self.player.run_sprite_index >= 8 then
				i = 1
			end
			spr(self.id+i,self.x,self.y,11,1,self.player.direction,0,1,1)
		elseif self.dx ~= 0 then
			spr(self.id,self.x,self.y,11,1,0,0,1,1)
		elseif self.on_screen then
			spr(self.id,self.x,self.y,11,1,0,self.rotate,1,1)
		end
	end

	self.reset = function()
		self.id = 508
		self.dx = 0
		self.dy = 0
		self.on_screen = true
		self.animate_throw = 0
		self.animate_stab = 0
		self.is_disarming = false
		self.landing_spot = 0
		self.rotate = 0
		position_updated = false
		rawset(self, 'on_screen_x', nil)
		rawset(self, 'on_screen_y', nil)
	end

	self.check_collision = function()
		if self.player.health <= 0 then return end
		local other = self.player:equals(plr1) and plr2 or plr1
		if self.x+4 <= other.x + 16 and self.x + 4 >= other.x then
            if self.y >= other.y and self.y <= other.y + 16 then
                if not is_same_state() or self.player.direction == other.direction or not other.has_sword then
                -- kill and stuff
					if not other.has_sword and (self.player.has_sword or self.dx > 0) then 
						other.health = 0
					elseif not other.has_sword then 
						if self.animate_throw > 0 then other.health = 0
						else other.health = other.health - 1 end
					end
					if other.health <= 0 then self.player.won_round = true end
					self.spr_id = 508
					self.rotate = 3
					self.dx = 0
					self.animate_throw = 0
					self.animate_stab = 0
					self.player.is_attacking = false
					self.player.sword_state = self.player.S_STATES.MIDDLE
					if not self.player.has_sword then self:disarm() else self.player:bounce_back() end
					other.hurt = true
					
                end
            end
        end
		if self.x <= SCREEN_START or self.x >= SCREEN_END then
			self.animate_throw = 0
			self.player.sword_state = self.player.S_STATES.MIDDLE
			self.player.is_attacking = false
			self:disarm()
		end
	end

    setmetatable(self, metatable)
end


local sw1 = Sword:new(plr1)
local sw2 = Sword:new(plr2)

function sceneManager()
	local s = {}
	s.scenes = {}
	s.current_scene = ""
	
	function s:add(scene, name)
	   s.scenes[name] = scene
	end
	
	function s:active(name)
	   s.current_scene = name
	   s.scenes[s.current_scene]:onActive()
	end
	
	function s:update()
	   s.scenes[s.current_scene]:update()
	end
	
	function s:draw()
	   s.scenes[s.current_scene]:draw()
	end
	
	return s
 end

 local mgr = sceneManager()

function Opening()
	local s = {}
   function s:onActive()
      
   end
   
   function s:update()
   end
   
   function s:draw()
	  cls()
      map(0, 34, 30, 17, 0, 0, -1, 1)
	  print("B for Instructions->", 120, 130, 1, false, 1, false)
	  print("B for Instructions->", 119, 131, 4, false, 1, false)
	  print("Y to Play!->", 21, 130, 1, false, 1, false)
	  print("Y to Play!->", 20, 131, 4, false, 1, false)
	  if btnp(7) or btnp(15) then
		mgr:active("game")
	  elseif btnp(5) or btnp(13) then
		mgr:active("instructions")
	  end
	end
   return s
end

function How_To_Play()
	local s = {}
   function s:onActive()
      
   end
   
   function s:update()
   end
   
   function s:draw()
	  cls()
	  map(120,17 , 30, 17, 0, 0, -1, 1)
	  print("How To Play", 36, 4, 11, false, 3, false)
	  print("How To Play", 35, 5, 4, false, 3, false)
	  print("Eliminate your opponent and ", 46, 29, 1, false, 1, false)
	  print(" defend yourself to advance! ", 41, 39, 1, false, 1, false)
	  print("Eliminate your opponent and ", 45, 30, 4, false, 1, false)
	  print(" defend yourself to advance! ", 40, 40, 4, false, 1, false)
	  print("Press X to attack", 76, 79, 1, false, 1, false)
	  print("Press X to attack", 75, 80, 4, false, 1, false)
	  print("Press A to jump", 151, 99, 1, false, 1, false)
	  print("Press A to jump", 150, 100, 4, false, 1, false)
	  print("Press B to throw", 74, 119, 1, false, 1, false)
	  print("Press B to throw", 75, 120, 4, false, 1, false)
	  print("Press Y to pickup", 6, 99, 1, false, 1, false)
	  print("Press Y to pickup", 5, 100, 4, false, 1, false)
	  print("Use up and down to manuever", 50, 59, 1, false, 1, false)
	  print("Use up and down to manuever", 50, 60, 4, false, 1, false)
	  print("<- Y", 21, 119, 1, false, 1, false)
	  print("<- Y", 20, 120, 4, false, 1, false)



	 
      if btnp(7) or btnp(15) then
	 	mgr:active("opening")
	  end
	 
	
   end
   return s
end

function Game()
	local s = {}
   function s:onActive()
      
   end
   
   function s:update()
		buttonListener()
		plr1:move()
		plr2:move()
   end
   
   function s:draw()
		cls()
		draw_map()
		draw_players()
   end
   return s
end

function Game_Over()
	
	local winner = 0
	local s = {}
   function s:onActive()
	if position > 0 then winner = plr1 else winner = plr2 end
	cls()
   end
   
   function s:update()
   end
   
   function s:draw()
	map(90, 17, 30, 17, 0, 0, -1, 1)
	if winner == plr1 then
		spr(394,  110, 72, 11, 2, 0, 0, 2, 2)
		print("RED WINS!", 46, 4, 2, false, 3, false)
	  	print("RED WINS!", 45, 5, 3, false, 3, false)
	elseif winner == plr2 then
		spr(394+32, 110, 72, 11, 2, 1, 0, 2, 2)
		print("GREEN WINS!", 36, 4, 6, false, 3, false)
	  	print("GREEN WINS!", 35, 5, 5, false, 3, false)
	end
	print("<-Y Play Again!", 21, 119, 1, false, 1, false)
	print("<-Y Play Again!", 20, 120, 4, false, 1, false)



	 
      if btnp(7) or btnp(15) then
		position = 0
	 	mgr:active("opening")
	  end
   end
   return s
end

function is_same_state()
	return (plr1.sword_state) == (plr2.sword_state)
end

function plr1_buttons()
	if plr1.health >= 0 then 
		if plr1.is_jumping then
			if not btn(4) then plr1.jump_state = 2 end
			plr1:jump()
			if btn(3) then plr1.dx = plr1.speed end
			if btn(2) then plr1.dx = -plr1.speed end
		elseif not plr1.is_bouncing_back then
			if btn(2) then plr1.dx = -plr1.speed end
			if btn(3) then plr1.dx = plr1.speed end
			if btn(4) then 
				plr1.jump_state = 1 
				plr1:jump() 
			end
		end

		if sw1.animate_stab == 0 then
			if btn(6) then sw1:stab() end
		elseif sw1.animate_stab > 0 then
			sw1:stab()
		end 

		if not sw1.player.has_sword and btn(7) then sw1:check_pickup() end
	end

	if sw1.animate_throw == 0 then
		if btn(5) and plr1.has_sword then sw1:throw() end
	elseif sw1.animate_throw > 0 then
		sw1:throw()
	end

	if sw1.is_disarming then sw1:disarm() end
	if sw1.player.hurt and sw1.player.has_sword then sw1:disarm() end
end

function plr2_buttons()
	if plr2.health >= 0 then 
		if plr2.is_jumping then
			if not btn(12) then plr2.jump_state = 2 end
			plr2:jump()
			if btn(11) then plr2.dx = plr2.speed end
			if btn(10) then plr2.dx = -plr2.speed end
		elseif not plr2.is_bouncing_back then
			if btn(10) then plr2.dx = -plr2.speed end
			if btn(11) then plr2.dx = plr2.speed end
			if btn(12) then 
				plr2.jump_state = 1	
				plr2:jump()
			end
		end
		
		if sw2.animate_stab == 0 then
			if btn(14) then sw2:stab() end
		elseif sw2.animate_stab > 0 then
			sw2:stab()
		end
		
		if not sw2.player.has_sword and btn(15) then sw2:check_pickup() end
	end
	
	if sw2.animate_throw == 0 then
		if btn(13) and plr2.has_sword then sw2:throw() end
	elseif sw2.animate_throw > 0 then
		sw2:throw()
	end
	
	
	
	if sw2.is_disarming then sw2:disarm() end
	if sw2.player.hurt and sw2.player.has_sword then sw2:disarm() end
end

function buttonListener()
	TIME = TIME + 1
	change_state()
	if TIME % 2 == 0 then
		plr1_buttons()
		plr2_buttons()
	else
		plr2_buttons()
		plr1_buttons()
	end

end



function new_round(xpos)
	if position == -3 then 
		mgr:active("game_over")
		mgr:draw()
		return
	elseif position == -2 then
		map_x = 180
	elseif position == -1 then
		map_x = 210
	elseif position == 0 then
		map_x = 0
	elseif position == 1 then
		map_x = 30
		trace("next map")
	elseif position == 2 then
		map_x = 60
	elseif position == 3 then
		mgr:active("game_over")
		mgr:draw()
		return
	end
	reset_actors()
end

function reset_actors()
   plr1:reset(20, LOW_GROUND, 0)
   plr2:reset(200, LOW_GROUND, 1)
   sw1:reset()
   sw2:reset()
end

function draw_map()
	map(map_x, 0, 30, 17, 0, 0, -1, 1)
	draw_arrow()
end


function draw_arrow()
    local id = 0
    local direction = -1
    local x = 120
    if plr1.won_round then 
        id = 396
        direction = 0
        x = x - 16
        TARGET = 240
        if not position_updated then
            position = position + 1
            position_updated = true  
        end
    elseif plr2.won_round then
        id = 398
        direction = 1
        x = x - 24
        TARGET = 0
        if not position_updated then
            position = position - 1
            position_updated = true  
        end
    else
        return
    end
    spr(id, x, 5, 11, 2, direction, 0, 2, 2)
end
function draw_players()
	plr1:draw()
	plr2:draw()
	sw1:draw()
	sw2:draw()
end

function change_state()
	-- add crouch to low state and default to middle
	if not plr1.has_sword and plr1.animate_throw == 0 and plr1.animate_stab == 0 then plr1.sword_state = plr1.S_STATES.MIDDLE end
	if plr1.has_sword then
		if plr1.sword_state == plr1.S_STATES.UP then
			if btnp(1) then plr1.sword_state = plr1.S_STATES.MIDDLE end
		elseif plr1.sword_state == plr1.S_STATES.MIDDLE then
			if btnp(0) then plr1.sword_state = plr1.S_STATES.UP end
			if btnp(1) then plr1.sword_state = plr1.S_STATES.DOWN end
		else
			if btnp(0) then plr1.sword_state = plr1.S_STATES.MIDDLE end
		end
	end

	if not plr2.has_sword and plr2.animate_throw == 0 and plr2.animate_stab == 0 then plr2.sword_state = plr2.S_STATES.MIDDLE end
	if plr2.has_sword then
		if plr2.sword_state == plr2.S_STATES.UP then
			if btnp(9) then plr2.sword_state = plr2.S_STATES.MIDDLE end
		elseif plr2.sword_state == plr2.S_STATES.MIDDLE then
			if btnp(8) then plr2.sword_state = plr2.S_STATES.UP end
			if btnp(9) then plr2.sword_state = plr2.S_STATES.DOWN end
		else
			if btnp(8) then plr2.sword_state = plr2.S_STATES.MIDDLE end
		end
	end
end

mgr:add(Opening(), "opening")
mgr:add(How_To_Play(), "instructions")
mgr:add(Game(), "game")
mgr:add(Game_Over(), "game_over")
mgr:active("opening")
mgr:draw()

function TIC()
	mgr:draw()
	mgr:update()
end

-- <TILES>
-- 000:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 001:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 002:4444444444444444444444444444444444444444444444444444444444444444
-- 003:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 005:4444bbbb4444bbbb4444bbbb4444bbbb4444bbbb4444bbbb4444bbbb4444bbbb
-- 006:0000444400004444000044440000444400004444000044440000444400004444
-- 007:bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000
-- 008:0000000000000000000000000000000011111111111111111111111111111111
-- 009:1111111111111111111111111111111100000000000000000000000000000000
-- 010:666aa5aa57aa566aa6a99a6a6a88886989999999899999999999899999988889
-- 011:66666656aa566aaa9aa96a6599a69aa6888889aa999888869999988899998888
-- 012:a6566aa767aa95799977a9999997a9999977a999977a999977a999997a999999
-- 013:9997aa99997aa99997aa999997a9999997a9999997aa9999997aaa9999977a99
-- 014:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66bbbbbbbb6bbbabbaa56567a5aaa667
-- 015:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbba7b5bbbabb66aa566a
-- 016:00000000000777000070cc7700700c6607666666076666660076667700076666
-- 017:000000000777000070cc7000600c670066666670667666707766670066667000
-- 018:0000000000000000f0000000feeeeee0fccccccef00000000000000000000000
-- 019:00000000000000000000000f0eeeeeefeccccccf0000000f0000000000000000
-- 020:bbbb4444bbbb4444bbbb4444bbbb4444bbbb4444bbbb4444bbbb4444bbbb4444
-- 021:fffffffffffffffffffff000fffff000ffffff0044ffffffff6fffaffaa56567
-- 022:ffffffffffffffffffffffffffffffffffffffff66ffffffff6fffaffaa56567
-- 023:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbabbbbbbbbabbb665a5a7656aa666
-- 024:999111a99991aaa9997aa999997a999997aa999897a999989999998899999988
-- 025:00000000000000000000000000000000001c10000a0a0a0007a0a700007a7000
-- 026:9988888899988889999998899999888988888889888888999899999999999999
-- 027:9998888999988899998899999988899999888899999888889999988899999999
-- 028:ffffbbbbffbbbbbbffbbbbbbfbbbbbbbfbbbabbbbbbbbabbb665a5a7656aa666
-- 029:bbbbffffbbbbbbffbbbbbbffbbbbbbff66bbbbbfbb6bbbabbaa56567a5aaa667
-- 030:000000000000000000000000000000000000000066000000006000a00aa56567
-- 031:0000000000000000000000000000000000000000000000a705000a0066aa566a
-- 032:0076666600766655076675557667655507707655000766660007666700007770
-- 033:6666670055666670555766675556766755666770776667000766670000777000
-- 034:0000000000000000004440000040400000444000004000000040000000000000
-- 035:0000000000000000004440000040000000444000004000000044400000000000
-- 036:0000000000000000004440000040000000444000000040000044400000000000
-- 037:0000000000000000004440000040400000444000004400000040400000000000
-- 038:0000000000000000000400000004000000040000000000000004000000000000
-- 039:ffffffffffffffff000fffff000fffff00ffffffffffff66fafff6ff76565aaf
-- 040:76a65676a5576a7799a79a7999a79aa999a7997a9a77997a9a79997a9a79997a
-- 041:000000000000000000000000000000000000a00000000a000665a5a7656aa666
-- 042:9999999899999998999999989999999899889988998888889998888899999999
-- 043:8899999988999999889999998889999988888888888888888988898899988999
-- 044:9999888899988888998888999988899999999999999999889998888899988888
-- 045:8999999988999999889999998899999988999999889999998888888888888888
-- 048:00000000000011100001cc010012c00201222222012221220012221100012222
-- 049:000000000011100011cc010022c0010022222210222222101122210022221000
-- 050:0000000000000000004440000040400000444000004040000040400000000000
-- 051:0000000000000000004040000040400000444000000400000004000000000000
-- 058:9999999999999999889999998899999988899888888888889888888899888888
-- 059:9998899999988999998889998888899988889999888999998899999989999999
-- 060:9988888899888988998899999988999999889999998899999999999999999999
-- 061:8899998888999999888899999888899999888999999888999998889999998899
-- 064:0012222201222233122213331221233301122233001222110012221000011100
-- 065:2222210033222100333122103332122133210110222210001222100001110000
-- 085:000000000000000000000000000fffff000fffff000fffff00ffffffffffffff
-- 086:000000000000000000ffffffffffffffffffffffffffffffffffffffffffffff
-- 087:0000000000000000ffffffffffffffffffffffffffffffffffffffffffffffff
-- 088:0000000000000000ffffffffffffffffffffffffffffffffffffffffffffffff
-- 089:00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 090:00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 091:00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 092:00000000ffff0000fffff000ffffffffffffffffffffffffffffffffffffffff
-- 093:00000000000000000000000000000000ffffff00ffffffffffffffffffffffff
-- 094:0000000000000000000000000000000000000000fff00000ffff0000ffff0000
-- 100:000000ff000000ff00000fff00000fff00ffffff0fffffff0fffffff0000ffff
-- 101:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 102:fffffffffffffffffffffffffffffffffffffffffffffffffffffff1fffffff1
-- 103:fffffffffffffffffffffffffffffffffffffff1ff1111111111111111111111
-- 104:ffffffffffffffffffffffffffffffff11111111111111111111111111111111
-- 105:ffffffffffffffffff111ffff111111111111111111111111111111111111111
-- 106:ffffffffffffffffffffffff11111fff11111111111111111111111111111111
-- 107:ffffffffffffffffffffffffffffffff111fffff11111fff111111ff11111111
-- 108:ffffffffffffffffffffffffffffffffffffffffffffffffffffffff11ffffff
-- 109:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 110:fffffff0ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 111:0000000000000000fff00000ff000000ff000000ffff0000fffff000fff00000
-- 115:000fffff000fffff000000ff000000ff0000000f000000ff00000fff00000fff
-- 116:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 117:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 118:ffffff11ffffff11ffff1111fffffffffffffffffffffffffff1111111111111
-- 119:111111111111111111111111fff11111fffff111fffff1111111111111111111
-- 120:1111111111111111111111111111111b11111bbb11111bbb11bbbbbb11111bbb
-- 121:111111111111111111111bb1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 122:1111111111111111111b1111bbbbb111bbbbb111bbbbbbbbbbbbbbbbbbbbbbbb
-- 123:1111111111111111111111111111111111111111b1111111bbbbb111bbbb1111
-- 124:11ffffff11111fff111111ff11111111111111111111111f11111fff111fffff
-- 125:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 126:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 127:fffffff0fffffff0fff00000ff000000ff000000ffff0000ffff0000ffffff00
-- 131:0000ffff0000ff0000000000000000000000000f000000000000000000000000
-- 132:ffffffff000fffff000fffff000fffffffffffffffffffffffffffffffffffff
-- 133:fffffff1fffffff1ffffff11ffffff11ffffffffffffffffffffffffffffffff
-- 134:11111111111111111111111111111111f11111111111111111111111ff111111
-- 135:1111111111111111111111111111111111111111111111111111111111111111
-- 136:11111bbb11bbbbbb11bbbbbb111bbbbb11111bbb11111bbbbbb11bbb11bbbbbb
-- 137:bbbbbb44bbb44444bb444444b444444444444444444444444444444444444444
-- 138:4bbbbbbb44444bbb444444bb4444444b4444444b444444444444444444444444
-- 139:bbbb1111bbbb1111bbbb1111bbbb1111bbbbbb11bbbbbbb14bbbbbbb4bbbbb11
-- 140:111fffff11ffffff111111ff11111111111111111111111111111111111111ff
-- 141:ffffffffffffffffffffffff1111111111111111111111111111ffffffffffff
-- 142:ffffffffffffffffffffffff11ffffff11ffffff1fffffffffffffffffffffff
-- 143:ffff0000ffff0000fffff000fffff000f0000000f0000000fffff000fffff000
-- 147:00000fff000fffff000fffff000fffff0000000f0000000f00000fffffffffff
-- 148:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 149:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 150:fff11111fff11111fff11111fffffffffffffffffffffff1fffffff1ff111111
-- 151:111111111111111111111111f1111111f1111111111111111111111111111111
-- 152:11bbbbbb11bbbbbb1111bbbb1111bbbb1111bbbb11bbbbbb11bbbbbb1111111b
-- 153:44444444b4444444b4444444b4444444bb444444bbb44444bbbbb444bbbbbbbb
-- 154:4444444444444444444444444444444b444444bb4444bbbb4bbbbbbbbbbbbbbb
-- 155:4bbbbb114bbbbb11bbbbbb11bbbbb111bbbbb111bbbbb111bb11b111bb111111
-- 156:11ffffff1111111111111111111111111111111111111111111111ff11111111
-- 157:ffffffff111fffff111fffff1111ffff1111ffff11ffffffffffffff11ffffff
-- 158:fffffffffffffffff0000000f0000000ffff0000ffffffffffffffffffffffff
-- 159:ff000000f0000000000000000000000000000000f0000000f0000000fff00000
-- 163:0000ffff0000ffff0fffffffffffffff000fffff000fffff0000000000000000
-- 164:ffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000fff
-- 165:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 166:ffff1111ffff1111fff11111ff111111ff111111ffffff11ffffff11fffff111
-- 167:1111111111111111111111111111111111111111111111111111111111111111
-- 168:1111111b111111bb111111111111111111111111111111bb1bbbbbbb1bbbbbbb
-- 169:bbbbbbbbbbbbbbbb1bbbbbbb11bbbbbb11bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 170:bbbbbbbbbbbbbbbbbbbbbbbbbb111111bb111111bbbbbb11bbbb1111bbbb1111
-- 171:1111111111111111bb1111111111111111111111111111111111111111111111
-- 172:111111111111111f1111ffff111fffff111fffff111fffff111fffff1fffffff
-- 173:11ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 174:ffffffffffff0000ffff0000fffffff0ffffffffffffffffffffffffffffffff
-- 175:ff000000000000000000000000000000fff00000ff000000ff000000ff000000
-- 179:00000000000000ff000000ff000000000000000f00000fff0fffffff0fffffff
-- 180:00000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 181:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 182:f1111111f1111111f1111111111111111111111111111111ff111111ff111111
-- 183:1111111111111111111111111111111111111bbb111bbbbb111bbbbb1bbbbbbb
-- 184:bbbbbbbbbbbbbbbb11bbbbbb1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 185:bbbbbbbbbbbbbb11bbbbbbb1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1bbbbbbbb
-- 186:111111111111111111111111bbb11111bbb111111111111111111111bb111111
-- 187:1111111f111111ff111111ff1111111111111111111111ff111111ffffffffff
-- 188:ffffffffffffffffff1fffff111fffff111111ffffffffffffffffffffffffff
-- 189:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 190:fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000
-- 191:ff000000fffff000ffff0000fff00000ff000000ff000000f000000000000000
-- 195:000000000000000f000000ff000fffff000fffff0000ffff0000ffff0fffffff
-- 196:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 197:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 198:ffffff11ffffff11fffffbb1ffffffbbffffffbbffbbbbbbffbbbbbbfffbbbbb
-- 199:1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 200:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 201:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 202:bb111111b1111111bb111111bb111111bbbbbb11bbbbbbbbbbbbbbbbbbbbbbbb
-- 203:ffffffffffffffff1111ffff1111ffff1111ffff11111fff1111111111111111
-- 204:ffffffffffffffffffffffffffffffffffffffffffffffff1111ffffffffffff
-- 205:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 206:fffff000fffff000ffffffffffffffffffffffffffffffffffffffffffffffff
-- 207:0000000000000000f0000000fff00000ff000000f00000000000000000f000ff
-- 210:000000000000000f0000000f0000000000000000000000000000000000000000
-- 211:fffffffffff00ffff000000f000000000000000f0fffffffffffffffffffffff
-- 212:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 213:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 214:ffffbbbbffffbbbbffffbbbbfffffbbbfffffbbbfffffbbbfffbbbbbffbbbbbb
-- 215:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 216:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 217:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 218:bbbbbb11bbbbbb11bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbfbbbbbbbf
-- 219:111fffff111fffffbfffffffbfffffffbbffffffbbffffffffffffffffffffff
-- 220:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 221:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 222:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 223:ffffffffffffffffffffffffffffff00fffff000fffff000f0000000f0000000
-- 226:000000000000000f00000fff00000fff0000000000000000000000000000000f
-- 227:0ffffffffffffffffffffffffffffffffff000ff0000ffff000fffffffffffff
-- 228:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 229:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 230:ffbbbbbbffbbbbbbffffbbbbffbbbbbbffbbbbbbfffffbbbfbbbbbbbbbbbbbbb
-- 231:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 232:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 233:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 234:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 235:bfffffffbfffffffbbbbbbffbbbbbfffbbbbbfffbbbbbbbbbbbbbbbbbbbbbbbb
-- 236:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffbfffffff
-- 237:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 238:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 239:00000000000000000000000000000000fff00000fffffffffffffffffffffff0
-- 242:000000ff000000ff000000000000000000000000000000000000000000000000
-- 243:ffffffffffffffff00ffffff0fffffff0fffffff00000fff000000ff00000000
-- 244:fffffffffffffffffffffffffffffffffffffffffffffffbfffffbbbfffffbbb
-- 245:ffffffffffffffbbffffbbbbfffbbbbbffbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 246:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 247:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 248:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 249:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 250:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 251:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 252:bfffffffbbbfffffbbbfffffbbbbffffbbbbbbffbbbbbbbbbbbbbbbbbbbbbbbb
-- 253:ffffffffffffffffffffffffffffffffffffffffbfffffffbfffffffbbffffff
-- 254:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 255:fffff000fff00000fff00000f000000000000000f0000000ff000000ff000000
-- </TILES>

-- <SPRITES>
-- 000:bbbbbbbbbbbb111bbbb1cc01bb12c002b1222222b1222122bb122211bbb12222
-- 001:bbbbbbbbbb111bbb11cc01bb22c001bb2222221b2222221b112221bb22221bbb
-- 002:bbbbbbbbbbbb111bbbb1cc01bb12c002b1222222b1222122bb122211bbb12222
-- 003:bbbbbbbbbb111bbb11cc01bb22c001bb2222221b2222221b112221bb22221bbb
-- 004:bbbb111bbbb1cc01bb12c002b1222222b1222122bb122211bbb12222bb122222
-- 005:bb111bbb11cc01bb22c001bb2222221b2222221b112221bb22221bbb222221bb
-- 006:bbbb111bbbb1cc01bb12c002b1222222b1222122bb122211bbb12222bb122222
-- 007:bb111bbb11cc01bb22c001bb2222221b2222221b112221bb22221bbb222221bb
-- 008:bbbbbbbbbbbb111bbbb1cc01bb12c002b1222222b1222122bb122211bbb12222
-- 009:bbbbbbbbbb111bbb11cc01bb22c001bb2222221b2222221b112221bb22221bbb
-- 010:bbbbbbbbbbbbbbbbbbbb111bbbb1cc01bb12c002b1222222b1222122bb122211
-- 011:bbbbbbbbbbbbbbbbbb111bbb11cc01bb22c001bb2222221b2222221b112221bb
-- 012:bbbbbbbbbbbbbbbbbbbb111bbbb1cc01bb12c002b1222222b1222122bb122211
-- 013:bbbbbbbbbbbbbbbbbb111bbb11cc01bb22c001bb2222221b2222221b112221bb
-- 014:bbbbbbbbbbbbbbbbbbbb111bbbb1cc01bb12c002b1222222b1222122bb122211
-- 015:bbbbbbbbbbbbbbbbbb111bbb11cc01bb22c001bb2222221b2222221b112221bb
-- 016:bb122222b12222331222133312212333b1122233bb122211bb12221bbbb111bb
-- 017:222221bb332221bb3331221b333212213321b11b22221bbb12221bbbb111bbbb
-- 018:bb122222b12222331222133312212333b1122233b1222211b122211bbb111bbb
-- 019:222221bb332221bb3331221b333212213321b11b22221bbb122221bbb1111bbb
-- 020:b12222331222133312212333b1122233bb122211bbb1221bbbbb11bbbbbbbbbb
-- 021:332221bb3331221b333212213321b11b22221bbb122221bbb1111bbbbbbbbbbb
-- 022:b12222331222133312212333b1122233bb122221bbb12222bbbb1111bbbbbbbb
-- 023:332221bb3331221b333212213322211b12221bbb1211bbbbbbbbbbbbbbbbbbbb
-- 024:bb122222b12222331222133312212333b1122233bb122221bbb12221bbbb1111
-- 025:222221bb332221bb3331221b333212213321b11b22221bbb12221bbbb111bbbb
-- 026:bbb12222bb122222b12222331222133312212333b1122233bb122211bbb11bbb
-- 027:22221bbb222221bb332221bb3331221b333212213321b11b2221bbbb111bbbbb
-- 028:bbb12222bb122222b12222331222133312212333b1112223bbb12221bbbb111b
-- 029:22221bbb222221bb332221bb3331221b333212213321b11b12221bbbb111bbbb
-- 030:bbb12222bb122222b12222331222133312212333b1122233bb122111bbb11bbb
-- 031:22221bbb222221bb332221bb3331221b333212213321b11b22211bbb111bbbbb
-- 032:bbbbbbbbbbbb777bbbb7cc07bb76c006b7666666b7666766bb766677bbb76666
-- 033:bbbbbbbbbb777bbb77cc07bb66c007bb6666667b6666667b776667bb66667bbb
-- 034:bbbbbbbbbbbb777bbbb7cc07bb76c006b7666666b7666766bb766677bbb76666
-- 035:bbbbbbbbbb777bbb77cc07bb66c007bb6666667b6666667b776667bb66667bbb
-- 036:bbbb777bbbb7cc07bb76c006b7666666b7666766bb766677bbb76666bb766666
-- 037:bb777bbb77cc07bb66c007bb6666667b6666667b776667bb66667bbb666667bb
-- 038:bbbb777bbbb7cc07bb76c006b7666666b7666766bb766677bbb76666bb766666
-- 039:bb777bbb77cc07bb66c007bb6666667b6666667b776667bb66667bbb666667bb
-- 040:bbbbbbbbbbbb777bbbb7cc07bb76c006b7666666b7666766bb766677bbb76666
-- 041:bbbbbbbbbb777bbb77cc07bb66c007bb6666667b6666667b776667bb66667bbb
-- 042:bbbbbbbbbbbbbbbbbbbb777bbbb7cc07bb76c006b7666666b7666766bb766677
-- 043:bbbbbbbbbbbbbbbbbb777bbb77cc07bb66c007bb6666667b6666667b776667bb
-- 044:bbbbbbbbbbbbbbbbbbbb777bbbb7cc07bb76c006b7666666b7666766bb766677
-- 045:bbbbbbbbbbbbbbbbbb777bbb77cc07bb66c007bb6666667b6666667b776667bb
-- 046:bbbbbbbbbbbbbbbbbbbb777bbbb7cc07bb76c006b7666666b7666766bb766677
-- 047:bbbbbbbbbbbbbbbbbb777bbb77cc07bb66c007bb6666667b6666667b776667bb
-- 048:bb766666b76666557666755576676555b7766655bb766677bb76667bbbb777bb
-- 049:666667bb556667bb5557667b555676675567b77b66667bbb76667bbbb777bbbb
-- 050:bb766666b76666557666755576676555b7766655b7666677b766677bbb777bbb
-- 051:666667bb556667bb5557667b555676675567b77b66667bbb766667bbb7777bbb
-- 052:b76666557666755576676555b7766655bb766677bbb7667bbbbb77bbbbbbbbbb
-- 053:556667bb5557667b555676675567b77b66667bbb766667bbb7777bbbbbbbbbbb
-- 054:b76666557666755576676555b7766655bb766667bbb76666bbbb7777bbbbbbbb
-- 055:556667bb5557667b555676675566677b76667bbb7677bbbbbbbbbbbbbbbbbbbb
-- 056:bb766666b76666557666755576676555b7766655bb766667bbb76667bbbb7777
-- 057:666667bb556667bb5557667b555676675567b77b66667bbb76667bbbb777bbbb
-- 058:bbb76666bb766666b76666557666755576676555b7766655bb766677bbb77bbb
-- 059:66667bbb666667bb556667bb5557667b555676675567b77b6667bbbb777bbbbb
-- 060:bbb76666bb766666b76666557666755576676555b7776665bbb76667bbbb777b
-- 061:66667bbb666667bb556667bb5557667b555676675567b77b76667bbbb777bbbb
-- 062:bbb76666bb766666b76666557666755576676555b7766655bb766777bbb77bbb
-- 063:66667bbb666667bb556667bb5557667b555676675567b77b66677bbb777bbbbb
-- 064:bbbbbbbbbbbb111bbbb1cc01bb12c002b1222222b1222122bb122211bbb12222
-- 065:bbbbbbbbbb111bbb11cc01bb22c001bb2222221b2222221b1122212122221221
-- 066:bbbbbbbbbbbb111bbbb1cc01bb12c002b1222222b1222122bb122211bbb12222
-- 067:bbbbbbbbbb111bbb11cc01bb22c001bb2222221b2222221b1122212122221221
-- 068:bbbb111bbbb1cc01bb12c002b1222222b1222122bb122211bbb12222bb122222
-- 069:bb111bbb11cc01bb22c001bb2222221b2222221b11222121222212212222221b
-- 070:bbbb111bbbb1cc01bb12c002b1222222b1222122bb122211bbb12222bb122222
-- 071:bb111bbb11cc01bb22c001bb2222221b2222221b11222121222212212222221b
-- 072:bbbbbbbbbbbb111bbbb1cc01bb12c002b1222222b1222122bb122211bbb12222
-- 073:bbbbbbbbbb111bbb11cc01bb22c001bb2222221b2222221b1122212122221221
-- 074:bbbbbbbbbbbbbbbbbbbbbbbbbbbb111bbbb1cc01bb12c002bb122222bb122222
-- 075:bbbbbbbbbbbbbbbbbbbbbbbbbb111bbb11cc01bb22c001bb2222221b2222221b
-- 076:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 077:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 078:bbbbbbbbbbbbbbbbbbbbbbdbbbbbbbcdbbbbbcccbbbbbbccbbbbbbbcbbbbbbbc
-- 079:bbbbbbbbbbbbbbbbbdbbbbbbdcbbbbbbcccbbbbbccdbbbbbcdbbbbbbcdbbbbbb
-- 080:bb122222b12222331222133312212333b1122233bb122211bb12221bbbb111bb
-- 081:2222221b332221bb333221bb33321bbb33221bbb22221bbb12221bbbb111bbbb
-- 082:bb122222b12222331222133312212333b1122233b1222211b122211bbb111bbb
-- 083:2222221b332221bb33321bbb3331bbbb3321bbbb22221bbb122221bbb1111bbb
-- 084:b12222331222133312212333b1122233bb122211bbb1221bbbbb11bbbbbbbbbb
-- 085:332221bb333121bb33321bbb3321bbbb22221bbb122221bbb1111bbbbbbbbbbb
-- 086:b12222331222133312212333b1122233bb122221bbb12222bbbb1111bbbbbbbb
-- 087:332221bb333121bb33321bbb332221bb12221bbb1211bbbbbbbbbbbbbbbbbbbb
-- 088:bb122222b12222331222133312212333b1122233bb122221bbb12221bbbb1111
-- 089:2222221b3322221b333221bb33321bbb3321bbbb22221bbb12221bbbb111bbbb
-- 090:bb122211bbb12122bbb12222bbb12222bbb11222bbb12111bbbb121bbbbb11bb
-- 091:112221bb22221bbb22221bbf2211111f2222222f1111111f12221bbbb111bbbb
-- 092:bbbbbbbbbbbbbbbbbbbbbbbbeeeeeeebdddddddebbbbbbbbbbbbbbbbbbbbbbbb
-- 093:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 094:bbbbfffcbbbf222cbbbff222bbb12fffbb122233bb122211bb12221bbbb111bb
-- 095:cffbbbbb222fbbbb2222fbbbffff1bbb3321bbbb22221bbb12221bbbb111bbbb
-- 096:bbbbbbbbbbbb777bbbb7cc07bb76c006b7666666b7666766bb766677bbb76666
-- 097:bbbbbbbbbb777bbb77cc07bb66c007bb6666667b6666667b7766676766667667
-- 098:bbbbbbbbbbbb777bbbb7cc07bb76c006b7666666b7666766bb766677bbb76666
-- 099:bbbbbbbbbb777bbb77cc07bb66c007bb6666667b6666667b7766676766667667
-- 100:bbbb777bbbb7cc07bb76c006b7666666b7666766bb766677bbb76666bb766666
-- 101:bb777bbb77cc07bb66c007bb6666667b6666667b77666767666676676666667b
-- 102:bbbb777bbbb7cc07bb76c006b7666666b7666766bb766677bbb76666bb766666
-- 103:bb777bbb77cc07bb66c007bb6666667b6666667b77666767666676676666667b
-- 104:bbbbbbbbbbbb777bbbb7cc07bb76c006b7666666b7666766bb766677bbb76666
-- 105:bbbbbbbbbb777bbb77cc07bb66c007bb6666667b6666667b7766676766667667
-- 106:bbbbbbbbbbbbbbbbbbbbbbbbbbbb777bbbb7cc07bb76c006bb766666bb766666
-- 107:bbbbbbbbbbbbbbbbbbbbbbbbbb777bbb77cc07bb66c007bb6666667b6666667b
-- 108:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 109:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 110:bbbbbbbbbbbbbbbbbbbbbbdbbbbbbbcdbbbbbcccbbbbbbccbbbbbbbcbbbbbbbc
-- 111:bbbbbbbbbbbbbbbbbdbbbbbbdcbbbbbbcccbbbbbccdbbbbbcdbbbbbbcdbbbbbb
-- 112:bb766666b76666557666755576676555b7766655bb766677bb76667bbbb777bb
-- 113:6666667b556667bb555667bb55567bbb55667bbb66667bbb76667bbbb777bbbb
-- 114:bb766666b76666557666755576676555b7766655b7666677b766677bbb777bbb
-- 115:6666667b556667bb55567bbb5557bbbb5567bbbb66667bbb766667bbb7777bbb
-- 116:b76666557666755576676555b7766655bb766677bbb7667bbbbb77bbbbbbbbbb
-- 117:556667bb555767bb55567bbb5567bbbb66667bbb766667bbb7777bbbbbbbbbbb
-- 118:b76666557666755576676555b7766655bb766667bbb76666bbbb7777bbbbbbbb
-- 119:556667bb555767bb55567bbb556667bb76667bbb7677bbbbbbbbbbbbbbbbbbbb
-- 120:bb766666b76666557666755576676555b7766655bb766667bbb76667bbbb7777
-- 121:6666667b5566667b555667bb55567bbb5567bbbb66667bbb76667bbbb777bbbb
-- 122:bb766677bbb76766bbb76666bbb76666bbb77666bbb76777bbbb767bbbbb77bb
-- 123:776667bb66667bbb66667bbf6677777f6666666f7777777f76667bbbb777bbbb
-- 124:bbbbbbbbbbbbbbbbbbbbbbbbeeeeeeebdddddddebbbbbbbbbbbbbbbbbbbbbbbb
-- 125:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 126:bbbb777cbbb7222cbbb72222bbb76555bb766655bb766677bb76667bbbb777bb
-- 127:c777bbbb22177bbb22217bbb55567bbb5567bbbb66667bbb76667bbbb777bbbb
-- 128:bbbbbbbbbbbb111bbbb1cc01bb12c002b1222222b1222222bb122211bbb12122
-- 129:bbbbbbbbbb111bbb11cc01bb22c001bb2222221b2222221b112221bb22221bbb
-- 130:bbbbbbbbbbbb111bbbb1cc01bb12c002b1222222b1222222bb122211bbb12122
-- 131:bbbbbbbbbb111bbb11cc01bb22c001bb2222221b2222221b112221bb22221bbb
-- 132:bbbbbbbbbbbb111bbbb1cc01bb12c002b1222222b1222222bb122211bbb12122
-- 133:bbbbbbbbbb111bbb11cc01bb22c001bb2222221b2222221b112221bb22221bbb
-- 134:bbbbbbbbbbbb111bbbb1cc01bb12c002bb122222bb122222bb122211bbb12122
-- 135:bbbbbbbbbb111bbb11cc01bb22c001bb2222221b2222221b112221bb22221bbb
-- 136:bbbbbbbbbbbb111bbbb1cc01bb12c002b1222222b1222122bb122211bbb12222
-- 137:bbbbbbbbbb111bbb11cc01bb22c001bb2222221b2222221b112221bb22221bbb
-- 138:bbbbbbbbbbbb111bbbb1cc01bb12c002b1222222b12221221212221122212222
-- 139:bbbbbbbbbb111bbb11cc01bb22c001bb2222221b2222221b1122212122221221
-- 140:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333332222222
-- 141:bbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbbbbb33bbbbbb323bb3333223b22222223
-- 142:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb555555556666666
-- 143:bbbbbbbbbbbbbbbbbbbbbbbbbbb5bbbbbbb55bbbbbb565bb5555665b66666665
-- 144:bb122222b12222331222133312212333b1122233bb122211bb12221bbbb111bb
-- 145:222221bb3322221b333122213332111b3321bbbb22221bbb12221bbbb111bbbb
-- 146:bb122222b1221233b1222133b1222213bb112133bb122211bb12221bbbb111bb
-- 147:222221bb3322221b333122213332111b3321bbbb22221bbb12221bbbb111bbbb
-- 148:bb122222bb122221bb122222bb121111bbb12233bbb12211bbb1221bbbb111bb
-- 149:222221bb1322221b2131221b133211bb3321bbbb22221bbb12221bbbb111bbbb
-- 150:bbb12222bbb12222bbb11222bbb12111bbb12233bbbb1211bbbb121bbbbb11bb
-- 151:22221bbb2211111b222222211111111b3321bbbb2221bbbb12221bbbb111bbbb
-- 152:bb122222b12222331222133312212333b1122233bb122211bb1221bbbbb11bbb
-- 153:222221bb332221bb3331221b333212213321b11b2221bbbb1221bbbbb11bbbbb
-- 154:12222222b1222233bb122333bb122333bb122233bb122211bb1221bbbbb11bbb
-- 155:2222221b332221bb33321bbb33321bbb3321bbbb2221bbbb1221bbbbb11bbbbb
-- 156:32222222b3333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 157:222222233333223bbbb323bbbbb33bbbbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 158:56666666b5555555bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 159:666666655555665bbbb565bbbbb55bbbbbb5bbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 160:bbbbbbbbbbbb777bbbb7cc07bb76c006b7666666b7666666bb766677bbb76766
-- 161:bbbbbbbbbb777bbb77cc07bb66c007bb6666667b6666667b776667bb66667bbb
-- 162:bbbbbbbbbbbb777bbbb7cc07bb76c006b7666666b7666666bb766677bbb76766
-- 163:bbbbbbbbbb777bbb77cc07bb66c007bb6666667b6666667b776667bb66667bbb
-- 164:bbbbbbbbbbbb777bbbb7cc07bb76c006b7666666b7666666bb766677bbb76766
-- 165:bbbbbbbbbb777bbb77cc07bb66c007bb6666667b6666667b776667bb66667bbb
-- 166:bbbbbbbbbbbb777bbbb7cc07bb76c006bb766666bb766666bb766677bbb76766
-- 167:bbbbbbbbbb777bbb77cc07bb66c007bb6666667b6666667b776667bb66667bbb
-- 168:bbbbbbbbbbbb777bbbb7cc07bb76c006b7666666b7666766bb766677bbb76666
-- 169:bbbbbbbbbb777bbb77cc07bb66c007bb6666667b6666667b776667bb66667bbb
-- 170:bbbbbbbbbbbb777bbbb7cc07bb76c006b7666666b76667667676667766676666
-- 171:bbbbbbbbbb777bbb77cc07bb66c007bb6666667b6666667b7766676766667667
-- 172:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 173:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 174:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 175:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 176:bb766666b76666557666755576676555b7766655bb766677bb76667bbbb777bb
-- 177:666667bb5566667b555766675556777b5567bbbb66667bbb76667bbbb777bbbb
-- 178:bb766666b7667655b7666755b7666675bb776755bb766677bb76667bbbb777bb
-- 179:666667bb5566667b555766675556777b5567bbbb66667bbb76667bbbb777bbbb
-- 180:bb766666bb766667bb767666bb766777bbb76655bbb76677bbb7667bbbb777bb
-- 181:666667bb7566667b6757667b755677bb5567bbbb66667bbb76667bbbb777bbbb
-- 182:bbb76666bbb76666bbb77666bbb76777bbb76655bbbb7677bbbb767bbbbb77bb
-- 183:66667bbb6677777b666666677777777b5567bbbb6667bbbb76667bbbb777bbbb
-- 184:bb766666b76666557666755576676555b7766655bb766677bb7667bbbbb77bbb
-- 185:666667bb556667bb5557667b555676675567b77b6667bbbb7667bbbbb77bbbbb
-- 186:76666666b7666655bb766555bb766555bb766655bb766677bb7667bbbbb77bbb
-- 187:6666667b556667bb55567bbb55567bbb5567bbbb6667bbbb7667bbbbb77bbbbb
-- 192:bbbbbbbbbbbb111bbbb1cc01bb12c002b1222222b1222222bb122211bbb12122
-- 193:bbbbbbbbbb111bbb11cc01bb22c001bb2222221b2222221b112221bb22221bbb
-- 194:bbbbbbbbbbbb111bbbb1cc01bb12c002b1222222b1222222bb122211bbb12122
-- 195:bbbbbbbbbb111bbb11cc01bb22c001bb2222221b2222221b112221bb22221bbb
-- 196:bbbbbbbbbbbb111bbbb1cc01bb12c002b1222222b1222222bb122211bbb12122
-- 197:bbbbbbbbbb111bbb11cc01bb22c001bb2222221b2222221b112221bb22221bbb
-- 198:bbbbbbbbbbbb111bbbb1cc01bb12c002bb122222bb122222bb122211bbb12122
-- 199:bbbbbbbbbb111bbb11cc01bb22c001bb2222221b2222221b112221bb22221bbb
-- 200:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 201:bbbbbbbbbbbb111bbbb1cc01bb12c002b1222222b1222222bb122211bbb12122
-- 202:bbbbbbbbbb111bbb11cc01bb22c001bb2222221b2222221f1122212f2222122f
-- 203:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbeeeeeeebddddddde
-- 208:bb122222b1222233122213331221f333b11fe233bbfeed11bb12eedbbbb11eeb
-- 209:222221bb3322221b333122213332111b3321bbbb22221bbb12221bbbb111bbbb
-- 210:bb122222b12212feb12221feb122221ebb112122bb122221bb12221bbbb111bb
-- 211:222221bb3322221beeee2221dddde11b2221bbbb22221bbb12221bbbb111bbbb
-- 212:bb122222bb122221bb122222bb121111bbb12233bbb12211bbb1221bbbb111bb
-- 213:2f2221bb1feeee1b21ddddeb1f3211bb3321bbbb22221bbb12221bbbb111bbbb
-- 214:bbb12222bbb12222bbb11222bbb12111bbb12233bbbb1211bbbb121bbbbb11bb
-- 215:22221bbf2211111f2222222f1111111f3321bbbb2221bbbb12221bbbb111bbbb
-- 216:bbbbbbbbeeeeeebbddddddebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 217:bb122222b12222331222133312212333b1122233bb122211bb12221bbbb111bb
-- 218:2222221f332221bb333221bb33321bbb33221bbb22221bbb12221bbbb111bbbb
-- 219:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 220:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 221:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 222:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 223:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 224:bbbbbbbbbbbb777bbbb7cc07bb76c006b7666666b7666666bb766677bbb76766
-- 225:bbbbbbbbbb777bbb77cc07bb66c007bb6666667b6666667b776667bb66667bbb
-- 226:bbbbbbbbbbbb777bbbb7cc07bb76c006b7666666b7666666bb766677bbb76766
-- 227:bbbbbbbbbb777bbb77cc07bb66c007bb6666667b6666667b776667bb66667bbb
-- 228:bbbbbbbbbbbb777bbbb7cc07bb76c006b7666666b7666666bb766677bbb76766
-- 229:bbbbbbbbbb777bbb77cc07bb66c007bb6666667b6666667b776667bb66667bbb
-- 230:bbbbbbbbbbbb777bbbb7cc07bb76c006bb766666bb766666bb766677bbb76766
-- 231:bbbbbbbbbb777bbb77cc07bb66c007bb6666667b6666667b776667bb66667bbb
-- 232:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 233:bbbbbbbbbbbb777bbbb7cc07bb76c006b7666666b7666666bb766677bbb76766
-- 234:bbbbbbbbbb777bbb77cc07bb66c007bb6666667b6666667f7766676f6666766f
-- 235:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbeeeeeeebddddddde
-- 236:bcfffffbceeeeeeffdeeeedffdddeddffddedddffdeeeedffeeeeeefbffffffb
-- 237:bffffffbfeddddeffeeddeeffeeedeeffcedeeefceeddeeffcdcddefbfcffffb
-- 238:bfffccfbfeeeeecffdeeeedcfdddeddcfddedddffdeeeedffeeeeeefbffffffb
-- 239:bffffffbfeddddeffeeddeeffeeedeeffeedeeeffeeddeecfeddddecbffffccb
-- 240:bb766666b7666655766675557667f555b77fe655bbfeed77bb76eedbbbb77eeb
-- 241:666667bb5566667b555766675556777b5567bbbb66667bbb76667bbbb777bbbb
-- 242:bb766666b76676feb76667feb766667ebb776766bb766667bb76667bbbb777bb
-- 243:666667bb5566667beeee6667dddde77b6667bbbb66667bbb76667bbbb777bbbb
-- 244:bb766666bb766667bb766666bb767777bbb76655bbb76677bbb7667bbbb777bb
-- 245:6f6667bb7feeee7b67ddddeb7f5677bb5567bbbb66667bbb76667bbbb777bbbb
-- 246:bbb76666bbb76666bbb77666bbb76777bbb76655bbbb7677bbbb767bbbbb77bb
-- 247:66667bbf6677777f6666666f7777777f5567bbbb6667bbbb76667bbbb777bbbb
-- 248:bbbbbbbbeeeeeebbddddddebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 249:bb766666b76666557666755576676555b7766655bb766677bb76667bbbb777bb
-- 250:6666667f556667bb555667bb55567bbb55667bbb66667bbb76667bbbb777bbbb
-- 251:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 252:bbbbbbbbbbbbbbbbfbbbbbbbfeeeeeebfddddddefbbbbbbbbbbbbbbbbbbbbbbb
-- 253:bbbbbbbbfbbbbbbbfeeeeeebfddddddefbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 254:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 255:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- </SPRITES>

-- <MAP>
-- 000:748494a48494a494a42535455565758595a5b5c5d5e5f5849474748494a4748494a4b4c4d4d45565758595a5b5c5d5e574847484748494a4b4c4d43545455565758595a5b5c5d5e51525151525152515251525152515251515250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000919090909190a1a0a0a0a1a0a1a090a1a0a1a35455565758595a5b5c5d5152554647454647454546474841626455565758595a5b5c5d5e516261626
-- 001:84e2f2e2f2e2f2e2f2e236465666768696a6b6c6d6e6f6e2e2e2f2f2f2f284e2f2e2f2e236465666768696a6b6c6d6e6f6e2f2f2748494a4b4c4152536465666768696a6b6c6d6e6f6e3f3f2f2e3f3152515e3f3e3f3f2f2f2f20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a1a0a0a0a1af2e2f284e2f2e2f20a1ae2f2e236465666768696a6b6c6d61525e2e2f2e2f2e2f2f3e3f3f2e236465666768696a6b6c6d6e6f6e2f2f2
-- 002:e2f2f3e3f3e3f3e3f32737475767778797a7b7c7d7e7f7e3e3e3f3f3f3f3e2f2f3e3f32737475767778797a7b7c7d7e7f7e3f3f3f3e3e3e3f3f3152537475767778797a7b7c7d7e7f7e3e3f3f3f3e3e3f3f3e3f3e3e3f3f3f3f3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e2f2f30a1ae384e2f2e2f2e2f2e2f2e2f2e22737475767778797a7b7c7d71525e3e3f3e3f3e3f3f2e2f2f32737475767778797a7b7c7d7e7f7e3f3f3
-- 003:e3f3f2e2f2e2f2e2f2e238485868788898a8b8c8d8ddf8e4e2e2f2f4f4f4e3f3f2e2f2e238485868788898a8b8c8d8ddf8e2f2f4f4e4e2e2f2f4152538485868788898a8b8c8d8ddf8e3f3f2f4e3f3e3f3f3f4e4e3f3f2f4f4f4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e3f3f2e2f2e2e2f2f3e3f3e3f3e3f3e3f3e3e238485868788898a8b8c8d81525e4e2f2e2f2e2f2f3e3f3f2e238485868788898a8b8c8d8ddf8e4f4f4
-- 004:e3e3f3e3f3e3f3e3f32939495969798999a9b9c9d9def9e2f2e3e2f294e4e3e3f3e3f32939495969798999a9b9c9d9def9e3e2f294e2f2e3e2f2152539495969798999a9b9c9d9def9f2e3e3f3e3e3f3f3f2e3f3f3e3f3f294e4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e3e3f3e3f3e3e3f3f2e2f2e2f2e2f2e2f2e22939495969798999a9b9c9d91525e2e3f3e3f3e3f3f2e2f2f32939495969798999a9b9c9d9def9e294e4
-- 005:e4e2e3e294e3f3e3f32a3a4a5a6a7a8a9aaabacadaeafae3e2f2e3f3e2f2e4e2e3e2942a3a4a5a6a7a8a9aaabacadaeafaf2e3f3e2e3e2f2e3f315253a4a5a6a7a8a9aaabacadaeafae3f3e3f3e3f3f2e3f3e3f3e3f3e3e3f3f2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e4e2e3e294e3e3e3f3e3f3e3f3e3f3e3f3e32a3a4a5a6a7a8a9aaabacada1525e3e294e3f3e3f3f3e3f3f32a3a4a5a6a7a8a9aaabacadaeafae3e2f2
-- 006:e2e3e2f4e2e4e2e2f2e23b4b5b6b7b8b9babbbcbdbebfbe4e3f3e4f4e3f3e2e3e2f4e2e23b4b5b6b7b8b9babbbcbdbebfbf3e4f4e3e4e3f3e4f415253b4b5b6b7b8b9babbbcbdbebfbe3f3e4f4e3e3f3e4f4e3e4e3e3f3f4e3f3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e2e3e2f4e2e4e4e2e3e294e3f3e394e3f3e3e23b4b5b6b7b8b9babbbcbdb1525e4f4e2e4e2e2f294e3f3f2e23b4b5b6b7b8b9babbbcbdbebfbe4e3f3
-- 007:e3e2f4e2f2e2f2e3f32c3c4c5c6c7c8c9cacbcccdcecfce2f2f2e2e2f2f4e3e2f4e2f22c3c4c5c6c7c8c9cacbcccdcecfcf2e2e2f2e2f2f2e2e215253c4c5c6c7c8c9cacbcccdcecfcf2f2e3f3f2f2f2e3f3e3f3f2f2e3f3f2f4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e3e2f4e2f2e2e2e3e2f4e2e4e2e2e2e4e2e22c3c4c5c6c7c8c9cacbcccdc1525e2e2f2e2f2e3f3e2e4e2f32c3c4c5c6c7c8c9cacbcccdcecfce2f2f4
-- 008:e2e2f2f2e2f2f3e2f22d3d4d5d6d7d8d9dadbdcdddedfde3f3e2f2e2e2f2e2e2f2f2e22d3d4d5d6d7d8d9dadbdcdddedfde2f2e2e2e3f3e2f2e215253d4d5d6d7d8d9dadbdcdddedfdf3e3f3e3f3f3e3e3e3f3f3f3e3f3e3f3f2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e2e2f2f2e2f2e3e2f4e2f2e2f2e3f2e2f2e32d3d4d5d6d7d8d9dadbdcddd1525e3f2e2f2f3e2f2f2e2f2f22d3d4d5d6d7d8d9dadbdcdddedfde3e2f2
-- 009:e3f3f3f3e3f3f4e3f32e3e4e5e6e7e8e9eaebecedeeefee2f2e3f3e3e3f3e3f3f3f3e32e3e4e5e6e7e8e9eaebecedeeefee3f3e3e3e2f2e3f3e315253d4e5e6e7e8e9eaebecedeeefe94f2e3f3f2e3f3f2e3f3f2f2e3f3e3e3f3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e3f3f3f3e3f3e2e2f2f2e2f2f3e2e2f2f3e22e3e4e5e6e7e7d8daebecede1525e2f3e3f3f4e3f3e2f2f3f32e3e4e5e6e7e8e9eaebecedeeefee2e3f3
-- 010:e4f4f4f4e4f4e4f4e42f3f4f5f6f7f8f9fafbfcfdfefffe3f3e4f4e4e4f4e4f4f4f4e42f3f4f5f6f7f8f9fafbfcfdfefffe4f4e4e4e3f3e4f4e415253e4f5f6f7f8f9fafbfcfdfefffe3f3f2e3f3e3e3f3e3f3e3f3e4f4e4e4f4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e4f4f4f4e4f4e3f3f3f3e3f3f4e3e3f3f4e32f3d4f5f6f7f7e8eafbfcfdf1525e3f4e4f4e4f4e4e3f3f4e42f3f4f5f6f7f8f9fafbfcfdfefffe3e4f4
-- 011:92f1e192e1f192f1e1f172c171e071e071e071f0d151e1f1e1f1e1f1e1f192f1e192e1f172c171e071e071e071f0d151f1e1f1e1f1f1e1f1e1f1e1f172c171e071e071e071f0d151f1e1f1e1e1f1e1f1e1f1e1f1e1f1e1f1e1f100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000092f1e192e1f192f1e1f1e192e1f192e192e1f172c171e0f071f0717171d192f1e192e1f192f1e1f192f192f172c171e071f071e071e0d151e1f1e1f1
-- 012:a0b0a082a0b0c0b0a0b0a082a0b0a0a0c0a0b0c0b0a0b0a082a0b0a0a0b0a0b0a082a0b0a082a0b0a0a0c0a0b0c0b0a0b0c0b0a0b0a082a0b0a0a0b0a0b0a082a0b0c0b0a0b0a082a0b0a0a0c0a0b0c0b0a0b0a082a0b0a0a0b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0b0a082a0b0c0b0a0b0a082a0b0a0a0c0a0b0c0b0a0b0a082a0b0a0a0b0a0b0a082a0b0c0b0a0b0a082a0b0a0a0c0a0b0c0b0a0b0a082a0b0a0a0b0
-- 013:a1b1a1b1a1b1c2d2a1b1a1b1c2c2d2a1b1c2d2a1b1a1b1a1b1a1b1a1a1b1a1b1a1b1a1b1c2d2a1b1a1b1c2c2d2a1b1c2d2a1b1a1b1a1b1a1b1a1a1b1a1b1a1b1a1b1c2d2a1b1a1b1c2c2d2a1b1c2d2a1b1a1b1a1b1a1b1a1a1b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a1b1a1b1a1b1c2d2a1b1a1b1c2c2d2a1b1c2d2a1b1a1b1a1b1a1b1a1a1b1a1b1a1b1a1b1c2d2a1b1a1b1c2c2d2a1b1c2d2a1b1a1b1a1b1a1b1a1a1b1
-- 014:a1a1b1a1c2d2c3d3d2c2c2d2c3c3d3c2d2c3d3c2c2d2c2d2c2d2d2c2d2c2a1a1b1a1c2d2c3d3d2c2c2d2c3c3d3c2d2c3d3c2c2d2c2d2c2d2d2c2d2c2a1a1b1a1c2d2c3d3d2c2c2d2c3c3d3c2d2c3d3c2c2d2c2d2c2d2d2c2d2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000515000000000000000000000000000000000000000000000000000000000000000000000000a1a1b1a1c2d2c3d3d2c2c2d2c3c3d3c2d2c3d3c2c2d2c2d2c2d2d2c2d2c2a1a1b1a1c2d2c3d3d2c2c2d2c3c3d3c2d2c3d3c2c2d2c2d2c2d2d2c2d2c2
-- 015:a1a2b2a1c3d3c2d2c2c3c2d2a1b1a1c3d3b1c2c2d2c2d2c2c2d2c2d2c2d2a1a2b2a1c3d3c2d2c2c3c2d2a1b1a1c3d3b1c2c2d2c2d2c2c2d2c2d2c2d2a1a2b2a1c3d3c2d2c2c3c2d2a1b1a1c3d3b1c2c2d2c2d2c2c2d2c2d2c2d2000000000000000919091919190919191909191919091919000000000000000005150515000515000000000000000000000000051516051505150515150000000000000000000000000000000000000000000000000000000000a1a2b2a1c3d3c2d2c2c3c2d2a1b1a1c3d3b1c2c2d2c2d2c2c2d2c2d2c2d2a1a2b2a1c3d3c2d2c2c3c2d2a1b1a1c3d3b1c2c2d2c2d2c2c2d2c2d2c2d2
-- 016:a2b2b2a2b2b2c3d3c3d3c3d3a2b2a2b2a2b2c3c3d3c3d3c3c3d3c3d3c3d3a2b2b2a2b2b2c3d3c3d3c3d3a2b2a2b2a2b2c3c3d3c3d3c3c3d3c3d3c3d3a2b2b2a2b2b2c3d3c3d3c3d3a2b2a2b2a2b2c3c3d3c3d3c3c3d3c3d3c3d3000000000000000a1a0a1a1a1a0a1a1a1a0a1a1a1a0a1a1a000000000000051506160616150616051505150000051500000000061617061606160616160000000000000000000000000000000000000000000000000000000000a2b2b2a2b2b2c3d3c3d3c3d3a2b2a2b2a2b2c3c3d3c3d3c3c3d3c3d3c3d3a2b2b2a2b2b2c3d3c3d3c3d3a2b2a2b2a2b2c3c3d3c3d3c3c3d3c3d3c3d3
-- 017:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000616060616061606160b1b1b160b1b1b160b1b1b160b1b1b160616061616061607170717160717061606051505151605150515071718071707170717170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 018:0000000030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000717070717071706162434445464748494a4b4c4d4e4f407170717071717071708180818170818071707061606161706160616081819081808180818180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 019:0000000030203030302030202020202000202020000000202020202000202020000000002020200000002020200000002020200000000000000000000000000000000000000000000000000000000000000000000000000000000818080818081807172535455565758595a5b5c5d5e5f50818081808181808180919091918091908180807170717180717071709191a091909190919190000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 020:0000000030202030302030000020000000200000200000200000000000200020000000200000002000200000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000919090919091908182636465666768696a6b6c6d6e6f60919091909191909190a1a0a1a190a1a0919090818081819081808180a1a1b0a1a0a1a0a1a1a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 021:0000000030203020302030000020000000200000202000202020000000202020200000200000002000200000202000200000202000000000000000000000000000000000000000000000000000000000000000000000000000000a1a0a0a1a0a1a09192737475767778797a7b7c7d7e7f70a1a0a1a0a1a1a0a1a0b1b0b1b1a0b1b0a1a0a091909191a091909190b1b1c0b1b0b1b0b1b1b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 022:0000000030203030202030000020000000200000200000200000000000200000200000200000002000200000002000200000002000000000000000000000000000000000000000000000000000000000000000000000000000000b1b0b0b1b0b1b06162838485868788898a8b8c8d8e8f80b1b06160b1b1b0b1b0c1c0c1c1b0c1c0b1b0b0a1a0a1a1b0a1a0a1a0c1c1d0c1c0c1c0c1c1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 023:0000000030203030302030202020202000202020000000200000000000200000002000002020200000002020200000002020200000000000000000000000000000000000000000000000000000000000000000000000000000000c1c0c0c1c0c1c07172939495969798999a9b9c9d9e9f90c1c07170c1c1c0d0c0b1b0b091c090818081819081809081808181908181e0d1b1c0b0d1d1d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 024:0000000030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d1d0d0d1d0d1d08182a3a4a5a6a7a8a9aaabacadaeafa0d1d08180d1d1d0e0d03130c0a1d09081808181908180a091909191a09191f0e1c01110e1e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 025:000000000000000000000313000021310000011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000091919090d0d1d09192b3b4b5b6b7b8b9babbbcbdbebfb0919091909091915150414210b050908180818190809081808181908181f1f0f3102120f1f1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 026:0000000000000000000004140000000000000212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a1a1a0a1a0a1a0a1a2c3c4c5c6c7c8c9cacbcccdcecfc0a1a0a1a0a0a1a161606160606060a091909191a090a091909191a09191505150505150515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 027:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b1b1b0b1b0b1b0b1b2d3d4d5d6d7d8d9dadbdcdddedfd0b1b0b1b0b0b1b081808180818071707170717071707170717060616061606160616160616000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 028:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c1c1c0c1c0c1c0c1c2e3e4e4f8d7e8e9eaebecedeeefe0c1c0c1c0c0c1c091909190919081808180818081808180818070717071707170717170717000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 029:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d1d1d0d1d0d1d0d1d2f3f4fc171e0e0e0e0f0d1dfefff0d1d0d1d0d0d1d0a1a0a1a0a1a091909190919091909190919080818081808180818180818000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 030:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006160616061606160616163959a0b0a0a0b0a0a0b059eafa061606160606160b1b0b1b0b1b0a1a0a1a0a1a0a1a0a1a0a1a090919091909190919190919000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 031:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007170717071707170717173a59a1b1a1a1b1a1a1b159ebfb071707170707170c1c0c1c0c1c0b1b0b1b0b1b0b1b0b1b0b1b0a0a1a0a1a0a1a0a1a1a0a1a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 032:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008180818081808180818183b59a1b1a1b1a1b1a1b159ecfc081808180808180d1d0d1d0d1d0c1c0c1c0c1c0c1c0c1c0c1c0b0b1b0b1b0b1b0b1b1b0b1b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 033:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009190919091909190919193c59a2b2a2b2a2b2a2b259edfd091909190909190e1e0e1e0e1e0d1d0d1d0d1d0d1d0d1d0d1d0c0c1c0c1c0c1c0c1c1c0c1c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 034:4040404080808080808080808080808080808080808080808080404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002d3d00000000000000000000eefe000000000000000f1f0f1f0f1f0e1e0e1e0e1e0e1e0e1e0e1e0d0d1d0d1d0d1d0d1d1d0d1d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 035:4040404030203030302030303020202020303030202020303030404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002e3e00000000000000000000efff00000000000000000000000f1f0f1f0f1f0f1f0f1f0f1f0f1f0e0e1e0e1e0e1e0e1e1e0e1e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 036:4040404030202030302030303030415030303030203030203030404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002f3f000000000000000000000000000000000000000000000000000000000000000000000000000f0f1f0f1f0f1f0f1f1f0f1f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 037:404040403020302030203030303041503030303020303030203040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 038:404040403020303020203030303041503030303020303020303040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 039:404040403020303030203030302020202030303020202030303040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 040:404080803030303030303030303030303030303030303030303080804040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 041:404030202020203020203030303020203030202020303020202030304040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 042:404030203030303020302030302030302030203030303020303030304040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 043:404030202020303020202030302030302030203020203020302020304040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 044:404030203030303020303020302030302030203030203020303020304040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 045:404030203030303020303020303020203030202020203020202020304040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 046:404090909090909090909090909090909090909090909090909090904040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 047:404040404040404040404003134040404001114040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 048:404040404040404040404004142140403102124040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 049:404040404040404040404053535353535353534040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 050:404040404040404040404040404040404053404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 132:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061606060616061600061606160000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 133:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061606060616071707070717071706071707170000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 134:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000071707070717081808080818081807081808185464745464745464546474840000000000000000000000000000000000000000000000000000000000
-- 135:00000000000000000000000000000000000000000000000000000000000000000000000000005464748494a4b4c4d4e40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000818080808180919090909190919080919091934445464748494a4b4c4d4e4f400000000000000000000000000000000000000000000000000000000
-- </MAP>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:fedcba9876543210fedcba9876543210
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- 001:c200c200c200c200c200c200c220d220d220d230c230c230c232b231a241a2529252926282627253625352535253325422651266126702770277027739b000000000
-- 002:021002200220022e022c023a024a024902590259025a025c024d024f123012301220122012202220321142125202620372038203a203a203b202c201390000000000
-- 003:021002200220022e022c023a024a024902590259025a025c024d024f123012301220122012202220321142125202620372038203a203a203b202c20139a000000000
-- 004:c21ac22bb22b923c826c826d826e826f724f726f724f7260726072607260726072606270628f528f429e429d329c329b327b226b226b229b12eb02fb4aa000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:0008045d275db13e53ef7d57bab2eea7f07038b7642571797950006120008d8900794c9df4f4f494b0c2566c86333c57
-- </PALETTE>
