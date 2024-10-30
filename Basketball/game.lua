-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

local _ENV = require 'std.strict' (_G)

local class = require 'middleclass'
local Player = class('Player')
local Ball = class('Ball')

local Vector2 = class('Vector2')

function Vector2:initialize(x, y)
   self.x = x or 0
   self.y = y or 0 
end

function Vector2:addNum(x, y)
   self.x = self.x + x
   self.y = self.y + y
end

function Vector2:add(o)
   self.x = self.x + o.x
   self.y = self.y + o.y
end

function Vector2:mult(s)
   self.x = self.x * s
   self.y = self.y * s
end
local initialV = 0
local t_diff = 0
local t = 0
local level = 0
local v = Vector2:new(96, 24)
local up = Vector2:new(0, -1)
local down = Vector2:new(0, 1)
local left = Vector2:new(-1, 0)
local right = Vector2:new(1, 0)

RIGHT_BOUNDARY = 178
LEFT_BOUNDARY = 45
UP_BOUNDARY = 35
DOWN_BOUNDARY = 102
GRAVITY = 0.5
local g = Vector2:new(0, 0.5)
local zero = Vector2:new(0,0)

plr1_spr = {
   ["1"] = 256,
   ["2"] = 258,
   ["3"] = 260,
   ["4"] = 262,
   ["5"] = 384,
   ["6"] = 388,
   ["7"] = 264,
   ["8"] = 328
}

plr2_spr = {
   ["1"] = 320,
   ["2"] = 322,
   ["3"] = 324,
   ["4"] = 326,
   ["5"] = 392,
   ["6"] = 396,
   ["7"] = 268,
   ["8"] = 332

}

ball_spr = {
   ["0"] = 507,
   ["1"] = 508,
   ["2"] = 509,
   ["3"] = 510,
}

function Ball:initialize(x, y)
   self.x = x 
   self.y = y 
   self.vx = 0
   self.vy = -4
   self.is_shot = false
   self.possession = -1
   self.ground_position = 0
   self.bounce_count = 0
   self.bounce_time = 0
   self.bounce_vy = self.vy
   self.shoot_time = 0
   self.scored = false
   self.roll = false
   self.position = Vector2:new()
   self.velocity = Vector2:new()
   self.acceleration = Vector2:new()
   self.t_velo = 0
   self.id = 0
end

function Ball:reset()
   -- self.vx = 0
   -- self.vy = -4
   self.is_shot = false
   self.possession = -1
   self.ground_position = 0
   self.bounce_count = 0
   self.bounce_time = 0
   self.bounce_vy = self.vy
   self.shoot_time = 0
   self.roll = false
   self.position = Vector2:new()
   self.velocity = Vector2:new()
   self.acceleration = Vector2:new()
end

function Ball:bounce()
   if self.vx == 0 then
      if self.bounce_time == 0 then
         if self.scored then
            self.ground_position = 96
         else
            self.ground_position = self.y
         end
      end
      
      self.vy = self.vy + GRAVITY 
      self.y = self.y + self.vy
      self.bounce_time = self.bounce_time + 1
      if self.y > self.ground_position then
         self.y = self.ground_position
         self.bounce_count = self.bounce_count + 1
         self.vy = self.bounce_vy
         self.vy = self.vy / 2
         self.bounce_vy = self.vy
         self.bounce_time = 0
      end
   end
end

function Ball:applyForce(force)
   self.acceleration:add(force)
end

function Ball:update() 
    self.velocity:add(self.acceleration)
    self.position:add(self.velocity)
    self.acceleration:mult(0)
    self.x = self.position.x
    self.y = self.position.y
end

function Ball:maybeRoll()
   if self.roll and self.possession == -1 then
      local switch = self.bounce_time % 4
      if self.x < 120 then
         self.x = self.x + 1
      else
         self.x = self.x - 1
      end
     
      self.id = switch
      
      self.bounce_time = self.bounce_time + 1
      if self.x == 120 or self.x == 121 then
         self.roll = false
         self.bounce_time = 0
      end
   else
      self.roll = false
   end
end

function Player:initialize(x, y, flip)
   self.has_ball = false
   self.is_jumping = false
   self.x = x
   self.y = y
   self.vy = 0
   self.ground_position = 0
   self.jump_time = 0
   self.id = 1
   self.dribble = 0
   self.flip = flip
   self.shoot_state = 0
   self.score = 0
end

function Player:update()
   
end

function Player:reset()
   self.is_jumping = false
   self.vy = 0
   self.jump_time = 0
   self.ground_position = 0
   if not self.has_ball then
      self.dribble = 0
      self.id = 1
   else
      self.id = 5
   end
end

function manager()
   local s = {}
   s.states = {}
   s.current_state = ""

   function s:add(state, name)
      s.states[name] = state
   
   end

   function s:active(name)
      s.current_state = name
      s.states[s.current_state]:onActive()
   end
   
   function s:update()
      s.states[s.current_state]:update()
   end

   function s:reset()
      s.states = {}
   end

   return s
end

local mgr = manager()

local player1 = Player:new(136, 68, 0)
local player2 = Player:new(104, 68, 1)
local ball = Ball:new(123, 92)

function updatePlayers()
   local s = {}
   function s:onActive()
      if not player1.is_jumping then
         if btn(0) then mgr:add(move_up(1), "move_up") mgr:active("move_up") end
         if btn(1) then mgr:add(move_down(1), "move_down") mgr:active("move_down") end
         if btn(2) then mgr:add(move_left(1), "move_left") mgr:active("move_left") end
         if btn(3) then mgr:add(move_right(1), "move_right") mgr:active("move_right") end
         if not player1.has_ball then
            if btn(4) then mgr:add(jump(1), "jump") mgr:active("jump") sfx(00 , 'G-3', 20, 2, 15, 1) end
         end
         if player1.has_ball and not ball.is_shot then
            ball.x = player1.x
            ball.y = player1.y
            player1.id = tostring(math.random(5,6))
         end
         if player1.shoot_state == 0 then
            if btn(6) and player1.has_ball then
               sfx(-1,14,0,0,0,0)
               player1.id = 7
               player1.dribble = 2
               level = 0
               player1.shoot_state = 1
               t = 0
            end
         end
         if player1.shoot_state == 1 then
            t = t + 1
            level = level + 1
            player1.id = 7
            player1.dribble = 2
            if not btn(6) and t > 0 then
               mgr:add(shoot(t), "shoot")
               mgr:active("shoot")
               player1.shoot_state = 2
               t_diff = t
            end
         end
         if player1.shoot_state == 2 then
            t = t + 1
            if t - t_diff > 60 then
               t = 0
               level = 0
               player1.shoot_state = 0
            end
         end
         if t > 0 and ball.possession == 1 then
            if btn(6) then initialV = calcT(30) end
            if level <= initialV / 6 then
                spr(484, player1.x+16, player1.y, 11)
            elseif level <= initialV / 3 then
                spr(468, player1.x+16, player1.y, 11)
            elseif level <= initialV / 2 then
                spr(452, player1.x+16, player1.y, 11)
            elseif level <= initialV / (3/2) then
                spr(453, player1.x+16, player1.y, 11)
            elseif level <= initialV / (6/5) then
                spr(469, player1.x+16, player1.y, 11)
            elseif level < initialV - 1 then
                spr(485, player1.x+16, player1.y, 11)
            elseif level <= initialV + 1.5 then
                spr(486, player1.x+16, player1.y, 11)
            else
                spr(501, player1.x+16, player1.y, 11)
            end
        end     
      end
      if player1.is_jumping and not player1.has_ball then
          player1.id = "8"
          player1.dribble = 2
         if not ball.is_shot then
            if player1.jump_time == 0 then
               player1.ground_position = player1.y
               player1.vy = -6
            end
            player1.vy = player1.vy + GRAVITY
            player1.y = player1.y + player1.vy
            player1.jump_time = player1.jump_time + 1
            if player1.y > player1.ground_position then
               player1.y = player1.ground_position
               player1:reset()
            end
         end
      end
   
      if not player2.is_jumping then
         if btn(8) then mgr:add(move_up(0), "move_up") mgr:active("move_up") end
         if btn(9) then mgr:add(move_down(0), "move_down") mgr:active("move_down") end
         if btn(10) then mgr:add(move_left(0), "move_left") mgr:active("move_left") end
         if btn(11) then mgr:add(move_right(0), "move_right") mgr:active("move_right") end
         if not player2.has_ball then
            if btn(12) then mgr:add(jump(0), "jump") mgr:active("jump") sfx(00 , 'G-3', 20, 2, 15, 1) end
         end
         if player2.has_ball and not ball.is_shot then
            ball.x = player2.x
            ball.y = player2.y
            player2.id = tostring(math.random(5,6))
         end
         if player2.shoot_state == 0 then
            if btn(14) and player2.has_ball then
               player2.id = 7
               player2.dribble = 2
               sfx(-1,14,0,0,0,0)
               level = 0
               player2.shoot_state = 1
               t = 0
            end
         end
         if player2.shoot_state == 1 then
            t = t + 1
            level = level + 1
            player2.id = 7
            player2.dribble = 2
            if not btn(14) and t > 0 then
               mgr:add(shoot(t), "shoot")
               mgr:active("shoot")
               player2.shoot_state = 2
               t_diff = t
            end
         end
         if player2.shoot_state == 2 then
            t = t + 1
            if t - t_diff > 60 then
               t = 0
               level = 0
               player2.shoot_state = 0
            end
         end
         if t > 0 and ball.possession == 0 then
            if btn(14) then initialV = calcT(193) end
            if level <= initialV / 6 then
                spr(484, player2.x -8, player2.y, 11)
            elseif level <= initialV / 3 then
                spr(468, player2.x -8, player2.y, 11)
            elseif level <= initialV / 2 then
                spr(452, player2.x -8, player2.y, 11)
            elseif level <= initialV / (3/2) then
                spr(453, player2.x -8, player2.y, 11)
            elseif level <= initialV / (6/5) then
                spr(469, player2.x -8, player2.y, 11)
            elseif level < initialV - 1 then
                spr(485, player2.x-8, player2.y, 11)
            elseif level <= initialV + 1.5 then
                spr(486, player2.x -8, player2.y, 11)
                
            else
                spr(501, player2.x -8, player2.y, 11)
            end
        end     
      end
      if player2.is_jumping and not player2.has_ball then
          player2.id = "8"
          player2.dribble = 2
         if not ball.is_shot then
            if player2.jump_time == 0 then
               player2.ground_position = player2.y
               player2.vy = -6
            end
            player2.vy = player2.vy + GRAVITY
            player2.y = player2.y + player2.vy
            player2.jump_time = player2.jump_time + 1
            if player2.y > player2.ground_position then
               player2.y = player2.ground_position
               player2:reset()
            end
         end
      end
   end

   function s:update()
   
   end
   return s
end

function move_left(player_flag)
   local s = {}
   function s:onActive()
      if player_flag == 1 then
         if checkInBounds(player1.x, player1. y, 2) then
            player1.x = player1.x - 1.5
            if player1.has_ball == true then
               player1.id = math.random(5,6)
            else
               player1.id = math.random(4)
               if player1.x < player2.x and player2.has_ball then
                  player1.flip = 1
               else
                  player1.flip = 0
               end
            end
         end
      else
         if checkInBounds(player2.x, player2. y, 2) then
            player2.x = player2.x - 1.5
            if player2.has_ball == true then
               player2.id = math.random(5,6)
            else
               player2.id = math.random(4)
               if player2.x > player1.x and player1.has_ball then
                  player2.flip = 0
               else
                  player2.flip = 1
               end
            end
         end
      end
   end

   function s:update()
      
   end
   return s
end

function move_right(player_flag)
   local s = {}
   function s:onActive()
      if player_flag == 1 then
         if checkInBounds(player1.x, player1. y, 3) then
            player1.x = player1.x + 1.5
            if player1.has_ball == true then
               player1.id = math.random(5,6)
            else
               player1.id = math.random(4)
               if player1.x < player2.x and player2.has_ball then
                  player1.flip = 1.5
               else
                  player1.flip = 0
               end
            end
            
         end
      else
         if checkInBounds(player2.x, player2. y, 3) then
            player2.x = player2.x + 1.5
            if player2.has_ball == true then
               player2.id = math.random(5,6)
            else
               player2.id = math.random(4)
               if player2.x > player1.x and player1.has_ball then
                  player2.flip = 0
               else
                  player2.flip = 1
               end
            end
         end
      end
   end

   function s:update()

   end
   return s
end

function move_up(player_flag)
   local s = {}
   function s:onActive()
      if player_flag == 1 then
         if checkInBounds(player1.x, player1. y, 0) then
            player1.y = player1.y - 1.5
            if player1.has_ball == true then
               player1.id = math.random(5,6)
            else
               player1.id = math.random(4)
               if player1.x < player2.x and player2.has_ball then
                  player1.flip = 1
               else
                  player1.flip = 0
               end
            end
         end
      else
         if checkInBounds(player2.x, player2. y, 0) then
            player2.y = player2.y - 1.5
            if player2.has_ball == true then
               player2.id = math.random(5,6)
            else
               player2.id = math.random(4)
               if player2.x > player1.x and player1.has_ball then
                  player2.flip = 0
               else
                  player2.flip = 1
               end
            end
         end
      end
   end

   function s:update()

   end
   return s
end

function move_down(player_flag)
   local s = {}
   function s:onActive()
      if player_flag == 1 then
         if checkInBounds(player1.x, player1. y, 1) then
            player1.y = player1.y + 1.5
            if player1.has_ball == true then
               player1.id = math.random(5,6)
            else
               player1.id = math.random(4)
               if player1.x < player2.x and player2.has_ball then
                  player1.flip = 1
               else
                  player1.flip = 0
               end
            end
         end
      else
         if checkInBounds(player2.x, player2. y, 1) then
            player2.y = player2.y + 1.5
            if player2.has_ball == true then
               player2.id = math.random(5,6)
            else
               player2.id = math.random(4)
               if player2.x > player1.x and player1.has_ball then
                  player2.flip = 0
               else
                  player2.flip = 1
               end
            end
         end
      end
   end

   function s:update()

   end
   return s
end

function jump(player_flag)
   local s = {}
   function s:onActive()
      if player_flag == 1 then
         if player1.is_jumping == false then
            player1.is_jumping = true
         end
      end
      if player_flag == 0 then
         if player2.is_jumping == false then
            player2.is_jumping = true
         end
      end
   end

   function s:update()

   end
   return s
end

function shoot(t)
   local s={}
   function s:onActive()
      if t == 0 then
         return
      end
      ball.acceleration = zero
      ball.is_shot = true
      player1.has_ball = false
      player2.has_ball = false
      player1.id = 1
      player2.id = 1
      player1.dribble = 0
      player2.dribble = 0
     ball.position = Vector2:new(ball.x, ball.y)
     if ball.possession == 1 then
      ball.velocity = Vector2:new(-t/4.25, -t/4.25)
     elseif ball.possession == 0 then
      ball.velocity = Vector2:new(t/4.25, -t/4.25)
     end
   end

   function s:update()

   end
   return s
end

function Game()
   local s = {}
   function s:onActive()
      -- draw sprites and map
      map(0,0,30,17)
      s:update()
      
      if player1.score >= 21 then
         s:gameOver(6)
         return
      end 
      if player2.score >= 21 then
         s:gameOver(2)
         return
      end 

      local bucket = false

      if ball.scored and ball.possession == 1 then
         spr(455, -15, 36, 11, 2, 0, 0, 4, 4)
         spr(448, 190, 36, 11, 2, 1, 0, 4, 4)
         ball.possession = -1
         bucket = true
      elseif ball.scored and ball.possession == 0 then
         spr(455, -15, 36, 11, 2, 1, 0, 4, 4)
         spr(448, -15, 36, 11, 2, 0, 0, 4, 4)
         ball.possession = -1
         bucket = true
      else
         spr(448, -15, 36, 11, 2, 0, 0, 4, 4)
         spr(448, 190, 36, 11, 2, 1, 0, 4, 4)
      end
      spr(plr1_spr[tostring(player1.id)], player1.x, player1.y, 11, 1, player1.flip, 0, 2 + player1.dribble, 4)
      spr(plr2_spr[tostring(player2.id)], player2.x, player2.y, 11, 1, player2.flip, 0, 2 + player2.dribble, 4)
      if not player1.has_ball and not player2.has_ball then
         if not bucket then
            spr(ball_spr[tostring(ball.id)], ball.x, ball.y, 11, 1, 0, 0, 1, 1)
         end
      end
   end

   function s:gameOver(color)
      cls(color)
      if color == 6 then
         print("Player 1 Wins!", 99, 11, 10, false, 1, false)
         sfx(03 , 'A-2', 120, 2, 15, 1)
         print("Press Y to play again!", 99, 56, 10, false, 1, false)
            if btn(7) then
               s:gameReset()
            end
      else
         print("Player 2 Wins!", 99, 11, 10, false, 1, false)
         sfx(03 , 'A-2', 120, 2, 15, 1)
         print("Press Y to play again!", 99, 56, 10, false, 1, false)
         if btn(15) then
            s:gameReset()
         end
      end
      

   
   end
   function s:gameReset()
      player1 = Player:new(136, 68, 0)
      player2 = Player:new(104, 68, 1)
      ball = Ball:new(123, 92)

   end 

   function s:update()
      
      print("First To", 99, 11, 10, false, 1, false)
      print("21!", 114, 19, 15, false, 1, false)
      print("21!", 113, 19, 10, false, 1, false)
      if player1.score < 10 then
         print(player1.score, 109, 30, 15, false, 1, false)
         print(player1.score, 108, 30, 6, false, 1, false)
      elseif player1.score >= 10 then
         print(player1.score, 107, 30, 15, false, 1, false)
         print(player1.score, 106, 30, 6, false, 1, false)
      end
      if player2.score < 10 then
         print(player2.score, 127, 30, 15, false, 1, false)
         print(player2.score, 126, 30, 2, false, 1, false)
      else
         print(player2.score, 125, 30, 15, false, 1, false)
         print(player2.score, 124, 30, 2, false, 1, false)
      end

      -- update score
   end
   return s
end

function checkInBounds(x, y, dir)
   if dir == 0 then
      if y > UP_BOUNDARY then
         return true
      end
   end

   if dir == 1 then
      if y < DOWN_BOUNDARY then
         return true
      end
   end

   if dir == 2 then
      if x > LEFT_BOUNDARY then
         return true
      end
   end

   if dir == 3 then
      if x < RIGHT_BOUNDARY then
         return true
      end
   end

   return false
end

function checkBallInBounds()
   if checkInBounds(ball.x, ball.y, 2) then
      if checkInBounds(ball.x, ball.y, 3) then
         return true
      end
   end
   return false
end

function calcT(basket)
   local dy = 0 - (56 - ball.y)
   local dx = math.abs(basket - (ball.x))
   local dxsqu = dx*dx
   local numerator = GRAVITY * dxsqu
   local denom = 0
   if dx > dy then
      denom = 2*(dx - dy)
   else
      denom = 2*(dy - dx)
   end
   return 4.25 * math.sqrt(numerator/denom)
end

function ToInteger(number)
   return math.floor(toNumber(number) or error("Could not cast"))
end

function ensureGameConstants()
   if ball.possession == -1 then
      sfx(-1,14,0,0,0,0)
      if ball.bounce_count < 4 then
         ball:bounce()
      end
   end

   if player1.is_jumping and player1.has_ball then
      if player1.y < UP_BOUNDARY then
         player1.y = UP_BOUNDARY + 33
      end
      player1.is_jumping = false
   elseif player1.has_ball and player1.y < UP_BOUNDARY then
      player1.y = UP_BOUNDARY - 1
   end

   if player2.is_jumping and player2.has_ball then
      if player2.y < UP_BOUNDARY then
         player2.y = UP_BOUNDARY + 33
      end
      player2.is_jumping = false
   elseif player2.has_ball and player2.y < UP_BOUNDARY then
      player2.y = UP_BOUNDARY - 1
   end

   if ball.scored and ball.y == 96 then
      ball.roll = true
      ball.scored = false
   end

      -- PLAYER HAS MISSED
      if ball.x < 0 or ball.x > 240 then
      if ball.y > 96 then
         ball.y = 125
      else
         ball.y = 96
      end
      ball.roll = true
      ball.is_shot = false
      ball.possession = -1
      ball.acceleration = zero
   elseif ball.y > 96 and ball.x < (LEFT_BOUNDARY - 8) then
      ball.roll = true
      ball.is_shot = false
      ball.possession = -1
      ball.acceleration = zero
   elseif ball.y > 96 and ball.x > (RIGHT_BOUNDARY + 8) then
      ball.roll = true
      ball.is_shot = false
      ball.possession = -1
      ball.acceleration = zero
   end
   if ball.y > 136 then
      ball.y = 128
      ball.is_shot = false
      ball.roll = false
      ball.is_shot = false
      ball.possession = -1
      ball.acceleration = zero
   end

end

function checkCollision()
   -- pick up ball checks
   if not player1.has_ball and not player2.has_ball then
      if ball.y <= player1.y + 32 and ball.y >= player1.y + 16 then
         if player1.x >= ball.x and player1.x <= ball.x+8 then
            sfx(01 , 'A-2', -1, 0, 6, 0)
            ball.possession = 1
            ball.is_shot = false
            player1.has_ball = true
            player1.id = 5
            player1.dribble = 2
            player1.flip = 0
            return
         end
      end
   end

   if not player1.has_ball and not player2.has_ball then
      if ball.y <= player2.y + 32 and ball.y >= player2.y + 16 then
         if player2.x + 16 >= ball.x and player2.x + 16 <= ball.x+8 then
            sfx(01 , 'A-2', -1, 0, 6, 0)
            ball.possession = 0
            ball.is_shot = false
            player2.has_ball = true
            player2.id = 5
            player2.dribble = 2
            player2.flip = 1
            return
         end
      end
   end

   -- steal checks

   if player1.has_ball then
      if math.sqrt((player2.x - player1.x)^2) <= 3 and math.sqrt((player2.y - player1.y)^2) <=2 then
         player1.has_ball = false
         player1.dribble = 0
         player2.has_ball = true
         ball.possession = 0
         player1.id = 1
         player2.id = 5
         player2.dribble = 2
         player2.flip = 1
         return
      end
   end

   if player2.has_ball then
      if math.sqrt((player2.x - player1.x)^2) <= 3 and math.sqrt((player2.y - player1.y)^2) <=2 then
         player2.has_ball = false
         player2.dribble = 0
         player1.has_ball = true
         ball.possession = 1
         player2.id = 1
         player1.id = 5
         player1.dribble = 2
         player1.flip = 0
         return
      end
   end

   -- score checks

   if math.sqrt((30 - ball.x)^2) <= 15 and math.sqrt((56 - ball.y)^2) <=3 then
     if not player1.has_ball and not player2.has_ball then
     
         ball.scored = true
         ball.x = 30
         ball.y = 71
         ball:reset()
         sfx(02, 'C-7', 60, 1, 15, -3)
         trace("player1's score: " .. player1.score)
         if player1.x > 100 then
            player1.score = player1.score + 2
         else
            player1.score = player1.score + 1
         end
      end
   end

   if math.sqrt((193 - ball.x)^2) <= 12 and math.sqrt((56 - ball.y)^2) <=3 then
      if not player1.has_ball and not player2.has_ball then
     
         ball.scored = true
         ball.x = 193
         ball.y = 71 
         ball:reset()
         sfx(02, 'C-7', 60, 1, 15, -3)
         if player2.x < 140 then
            player2.score = player2.score + 2
         else
            player2.score = player2.score + 1
         end
      end
   end
      
   
end

function TIC()
   mgr:add(Game(), "game")
   mgr:active("game")
   
   ensureGameConstants()

   checkCollision()

   mgr:add(updatePlayers(), "updatePlayers")
   mgr:active("updatePlayers")
   
   
   if ball.is_shot then
      ball:applyForce(g)
      ball:update()
   end

   ball:maybeRoll()

   mgr:reset()
end

-- <TILES>
-- 000:6666666665566655655665556556655765566556655555566755557666777766
-- 001:6666666055555660555555607777556066665560666555606665576066667660
-- 002:4444444444444444000000004444444444444444444444444444444444444444
-- 003:4334444444444444000000004444443344444444444444444433344444444444
-- 004:4444444444444444000004444444000044444440444444443334444444444444
-- 005:4444444444444334444444443444444400044444440004444444000444444400
-- 006:4334444444444444444444444444443344444444444444444433344404444444
-- 007:4444444444444444444444444444444444444444444444334444444444444444
-- 008:4334444444444444444444444444443344444444444444444433344444444444
-- 009:4444444444444444333344444444444444444444433334444444444444444444
-- 010:4444444444444444444333444444444444444444444444444444444444444444
-- 011:4334444444444444444444444444443344444444444444444433344444444444
-- 012:4444444444444444333344444444444444444444433334444444444444444444
-- 013:4444444444444444444333444444444444444444444444444444444444444444
-- 014:0222222202333333023333330211111102222223022223330233333102333112
-- 015:2222222233333332333333321331133233322332333333321333333221111112
-- 016:6666666665555555677555556667777566665555666555576555555565555555
-- 017:6666666055555560555555605555576055577660777666605555556055555560
-- 018:4444444444444334444444443444444444444444444444444444444444444444
-- 019:4334444444444444444444444444443344444444444444444433344444444444
-- 020:4444444444444444444444444444444444433344444444444444444444444444
-- 021:4444444444444444333344444444444444444444433334444444444444444444
-- 022:0044444444004444444003444444004444444400444444404444444444444444
-- 023:4444444444444444444444444444444444433344044444440044444444004444
-- 024:4334444444444444444444444444443344444444444444444433344444444444
-- 025:4444444444444444444444444444344444444444444444443334444444444444
-- 026:4444444444444444333344444444444444444444433334444444444444444444
-- 027:4444444444444444444443334444444444444444444444444444444444444444
-- 028:4334444444444444444444444444443344444444444444444433344444444444
-- 029:4444444444444444333344444444444444444444433334444444444444444444
-- 030:0211122202222222023333330233333302333111023332220233333302333333
-- 031:2222222222222222333333323333333211111332222223323333333233333332
-- 032:6777777766666666655555556555555567777777666666666666666666666666
-- 033:7777776066666660555555605555556077777760666666606666556066665560
-- 034:4444444444444444444443334444444444444444444444444444444400000000
-- 035:4334444444444444444444444444443344444444444444444433344400000000
-- 036:4444444444444444444444444444344444444444444444443334444400000000
-- 037:4444444444444334444444443444444444444444444444444444444400000000
-- 038:4444433444444444444444443344444444444444444444444443334400044444
-- 039:4440004444444004444444004444444044433344444444444444444444444444
-- 040:4334444444444444444444444444443304444444004444444403344444404444
-- 041:4444444444444444444444444444344444444444444444443334444444444444
-- 042:4444444444444444444444444444344444444444444444443334444444444444
-- 043:4444444444444334444444443444444444444444444444444444444444444444
-- 044:4334444444444444444444444444443344444444444444444433344444444444
-- 045:4444444444444444444444444444344444444444444444443334444444444444
-- 046:0211111102222222022222220222222202222222022222230222233302333331
-- 047:1111111222222222222223322223333223333112333112223112222212222222
-- 048:6666666665555555655555556777777766666666666666666655555565577555
-- 049:6666556055555560555557607777766066666660555556605555556077775560
-- 050:4334444444444444444444444444443344444444444444444433344444444444
-- 051:4444444444444444444333444444444444444444444444444444444444444444
-- 052:4444444444444444333444444444444444444444444444444444444444444444
-- 053:4444044444440444444303444444044444440444444404444444044444440444
-- 054:4300044444440004444444004444443044444444444444444433344444444444
-- 055:4444444444444444333344440444444400444444403334444004444444044444
-- 056:4440044444440444444300444444404444444044444440444444404444444044
-- 057:4444444444444444444333444444444444444444444444444444444444444444
-- 058:4334444444444444444444444444443344444444444444444433344444444444
-- 059:4444444444444444333344444444444444444444433334444444444444444444
-- 060:4444444444444444444333444444444444444444444444444444444444444444
-- 061:4444444444444444333444444444444444444444444444444444444444444444
-- 062:0233311202333222023333320211133302222113022222210222222202222222
-- 063:2222222222222222222222223222222233322222133332222113333222211332
-- 064:6576675765666656655555556777777766666666665555556555555565577777
-- 065:6666556066665560555557607777766066666660555556605555556077775560
-- 066:4444444444444444444443334444444444444444444444444444444444444444
-- 067:4444444444444444444444444444344444444444444444443334444444444444
-- 068:4334444444444444444444444444443344444444444444444433344444444444
-- 069:4444044444440444333304444444044444440444433304444444044444440444
-- 070:4444444444444444444443334444444444444444444444404444440044440004
-- 071:4304444444044444400444444044443300444444044444444433344444444444
-- 072:4444404444444044333340444444404444444044433300444444044444440444
-- 073:4444444444444444444444444444344444444444444444443334444444444444
-- 074:4444444444444444444444444444344444444444444444443334444444444444
-- 075:4444444444444444444443334444444444444444444444444444444444444444
-- 076:4334444444444444444444444444443344444444444444444433344444444444
-- 077:4444444444444444333344444444444444444444433334444444444444444444
-- 078:0222222202333333023333330233311102333222023332220233322202111222
-- 079:2222211233333332333333323311133233222332112223322222233222222112
-- 080:6556666665555555675555556677777766666666665666666556666565566665
-- 081:6666556055555560555557607777766066666660555556605555556057775560
-- 082:4444444444444334000000003444444444444444444444444444444444444444
-- 083:4334444444444444000000004444443344444444444444444433344444444444
-- 084:4444444444444444000000004444444444444444444444444444444444444444
-- 085:4444044444440444000000004444344444444444444444443334444444444444
-- 086:4400044400044334044444443444444444444444444444444444444444444444
-- 087:4334444444444444444444444444443344444444444444404433340044444004
-- 088:4440044444404444440044444004344440444444044444443334444444444444
-- 089:4444444444444334444444443444444444444444444444444444444444444444
-- 090:4444444444444444444444444444444444433344444444444444444444444444
-- 091:4444444444444334444444443444444444444444444444444444444444444444
-- 092:4334444444444444444444444444443344444444444444444433344444444444
-- 093:4444444444444444444444444444344444444444444444443334444444444444
-- 094:0222222202333333023333330222222202222223022223330233333102333112
-- 095:2222222233333332333333322331133233322332333333321333333221111112
-- 096:6556666565566665655666676556666665555555675555556677777766666666
-- 097:5666556076665560666655606666556055555560555557607777766066666660
-- 098:4444444444444444444444444444344444444444444444443334444444444444
-- 099:4444444444444334444444443444444444444444444444444444444444444444
-- 100:4334444444444444444444444444443344444444444444444433344444444444
-- 101:4444444444444444444443334444444444444444444444444444444444444444
-- 102:4444444444444444444444444444344444444400444400043300044400044444
-- 103:4444044444400444440444440044344404444444444444443334444444444444
-- 104:4334444444444444444444444444443344444444444444444433344444444444
-- 105:4444444444444444333344444444444444444444433334444444444444444444
-- 106:4334444444444444444444444444443344444444444444444433344444444444
-- 107:4444444444444444333344444444444444444444433334444444444444444444
-- 108:4444444444444444444333444444444444444444444444444444444444444444
-- 109:4444444444444444333444444444444444444444444444444444444444444444
-- 110:0211122202333223023332230233322302333223023333330233333302111111
-- 111:2222222233333332333333323111133232222332322223323222233212222112
-- 112:6666666666666666666666666666666666666666666666666666666666666666
-- 113:6666666066666660666666606666666066666660666666606666666066666660
-- 114:4444444444444334444444443444444440000000444444444444444444444444
-- 115:4444444444444444444444444444440000000004444444444444444444444444
-- 116:4444444444444444444333440000000044444444444444444444444444444444
-- 117:4444440044440004440004440004444444444444444444444444433344444444
-- 118:0444444444444334444444443444444444444444444444444444444444444444
-- 119:4444444444444444444444444444444444433344444444444444444444444444
-- 120:4444444444444444444333444444444444444444444444444444444444444444
-- 121:4444444444444444444333444444444444444444444444444444444444444444
-- 122:4444444444444444444333444444444444444444444444444444444444444444
-- 123:4444444444443344444444444444444444444444444444444444433344444444
-- 124:4444444444444334444444443444444444444444444444444444444444444444
-- 125:4444444444444444444444444444444444433344444444444444444444444444
-- 126:2222222222222222222222222222222222222222222222222222222222222222
-- 127:2222222222222222222222222222222222222222222222222222222222222222
-- 128:6666666666666666666666666666666666666666666666666666666666666666
-- 129:6666666666666666666666666666666666666666666666666666666666666666
-- 130:0000000000000000f00f0006f0000005f000000cf000000cff00000cff00f00c
-- 131:00000000000000006765775575557666cccccccccccccccccccccccccccccccc
-- 132:000000000000000055000f0077000000cc000000cc000000cc00f000cc000000
-- 133:00000000000f00000000023300000211f0000ccc00000ccc00000ccc00000ccc
-- 134:00000000000000003311321222213331cccccccccccccccccccccccccccccccc
-- 135:000000000000000000f0000f0000000f000f000f0000000f000000ff000000ff
-- 136:4444444444444444444444444444444444444444443334444444444444444444
-- 137:4444444444444444444444444444444444444444443334444444444444444444
-- 138:4444444444444444444444444433344444444444444444444444444444444444
-- 139:4444444444444444444444444444444444444443444444444334444444444440
-- 140:4444444433344444444444444444444444444000444000444000444400444444
-- 141:4444444444444444444444444444444400000000443334444444444444444444
-- 142:4444444444444444444444444000000000444444444444444444444444444444
-- 143:4444444444444444444444440000000444444443444444444334444444444444
-- 144:00000000f000000000000f000000000000000000000000000000f00000000000
-- 145:00000000000f00000000000000000000f000f00000000000000000f000000000
-- 146:ff00000cfff0000cfff0000cffff000cffff0000ffff0000ffff0000fffff000
-- 147:cccccccccccccccccccccccccccccccc0000000000f0000000000f0000000000
-- 148:cc00000fcc000000cc000000cc00f0000000000000f000000000000000000000
-- 149:00f00ccc00000ccc00000ccc00000ccc00f0000000000000f000000000000000
-- 150:cccccccccccccccccccccccccccccccc0000000000f00000000000e000000000
-- 151:00f000ff00000fff00000fff0000ffff0000ffff0000fffff000ffff000fffff
-- 152:4444444444444444444333344444444444444444444433334444444444444444
-- 153:4444444444433344444444444444444433444444444444444444444444444334
-- 154:4444444444444333444444444444444044434400444440444440044444404444
-- 155:4444400044400033400044440044444444434444444444444444444444444444
-- 156:4444444444444444444444444444444444444444333444444444444444444444
-- 157:4444444444433344444444444444444433444444444444444444444444444334
-- 158:4444444444444444444444444444444444444443444444444334444444444444
-- 159:4444444444444333444444444444444444434444444444444444444444444444
-- 160:000f000ff0000000000000000000f0000000000000f000000000000000000000
-- 161:00f0000000000000000000000000000000f000f000000000f000000000000000
-- 162:0000000000000000002321230021133300cccccc00cccccc00cccccc00cccccc
-- 163:00000000000000001133330012221100cccccc00cccccc00cccccc00cccccc00
-- 164:00000000f000000000000f000000000000000000000000000000f00000000000
-- 165:00000000000f00000000000000000000f000f00000000000000000f000000000
-- 166:0000000000000000006567650067755500cccccc00cccccc00cccccc00cccccc
-- 167:00000000000000007755550076667700cccccc00cccccc00cccccc00cccccc00
-- 168:4444444444444444444444444444444444444443444444444334444444444444
-- 169:4444444444444333444444404444440444434004444400444444044444400444
-- 170:4004444400433344044444444444444433444444444444444444444444444334
-- 171:4444444444444444444444444444444444444443444444404334400044400044
-- 172:4444444444444333444444444444444444434444000000004440444444404444
-- 173:4444444444444444444444444444444444444444000000004444444444444444
-- 174:4444444444433344444444444444444433444444000000004444444444444334
-- 175:4444444444444444444444444444444444444443000000004334444444444444
-- 176:00000000f000000000000f000000000000000000000000000000f00000000000
-- 177:00000000000f00000000000000000000f000f00000000000000000f000000000
-- 178:00cccccc00cccccc00cccccc00cccccc0000000000f0000000000f0000000000
-- 179:cccccc0fcccccc00cccccc00cccccc000000000000f000000000000000000000
-- 180:000f000ff0000000000000000000f0000000000000f000000000000000000000
-- 181:00f0000000000000000000000000000000f000f000000000f000000000000000
-- 182:00cccccc00cccccc00cccccc00cccccc0000000000f0000000000f0000000000
-- 183:cccccc0fcccccc00cccccc00cccccc000000000000f000000000000000000000
-- 184:4444444444444333444444444444444444434444444444444444444444444444
-- 185:4440444444404444440033344404444444044444440433334404444444044444
-- 186:4444444444433344444444404444440033444404444440044444404444444034
-- 187:4000444400444444044444444444444444444444333444444444444444444444
-- 188:4440444444404444444033344440444444404444444033334440444444404444
-- 189:4444444444433344444444444444444433444444444444444444444444444334
-- 190:4444444444444333444444444444444444434444444444444444444444444444
-- 191:4444444444444444444444444444444444444444333444444444444444444444
-- 192:000f000ff0000000000000000000f0000000000000f000000000000000000000
-- 193:00f0000000000000000000000000000000f000f000000000f000000000000000
-- 194:fffffffff999ff99f999ff99f599ff99f555f555fe5fffe5fe5fffe5fe5fffe5
-- 195:9fffff995fffff995fffe5555ffff9ee5ffffe555ffffe555ffffeee5fffffff
-- 196:ffffffffffffffff5fffffff9fffffffffffffffffffffffefffffffffffffff
-- 197:fffffffff999ff99f999ff99f299ff99f222f222fe2fffe2fe2fffe2fe2fffe2
-- 198:9fffff992fffff992fffe2222ffff9ee2ffffe222ffffe222ffffeee2fffffff
-- 199:ffffffffffffffff2fffffff9fffffffffffffffffffffffefffffffffffffff
-- 200:4444444444444444444444444444444444444444443334444444444444444444
-- 201:4404444444044444440444444404444444044444440034444440444444400444
-- 202:4444404444444004444333044444440044444440444433334444444444444444
-- 203:4444444444433344444444444444444403444444004444444000444444400034
-- 204:4440444444404444444044444440444444404444443034444440444444404444
-- 205:4444444444444444444444444444444444444444444443334444444444444444
-- 206:4444444444444444444444444444444444444444443334444444444444444444
-- 207:4444444444433344444444444444444433444444444444444444444444444334
-- 208:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 209:bbbbdbbbbbbbdbbbbbbbdbbbbbbbdbbbbbbbdbbbbbbbdbbbbbbbddddbbbbbbbb
-- 210:ffffffffffffffff9ffff9ff5f99f5ef5f99f5ef5f55f5efe5555eefffffffff
-- 211:ff9fffffff5eff5fff5eff5f995eff55995efff5555effff55efffff55ffffff
-- 212:ffffffff99ffffff99f5ffff9955ffff555fffff55ffffffffffffffffffffff
-- 213:ffffffffffffffff9ffff9ff2f99f2ef2f99f2ef2f22f2efe2222eefffffffff
-- 214:ff9fffffff2eff2fff2eff2f992eff22992efff2222effff22efffff22ffffff
-- 215:ffffffff99ffffff99f2ffff9922ffff222fffff22ffffffffffffffffffffff
-- 216:4444444444444333444444444444444444434444444444444444444444444444
-- 217:4444044444433044444444004444444033444444444444444444444444444334
-- 218:4444444444444444444444444433344404444444004444444004444444000444
-- 219:4444400044333444444444444444444444444433444444444444444443344444
-- 220:0000000044444444444444444444444444444443444444444334444444444444
-- 221:0000000044444333444444444444444444434444444444444444444444444444
-- 222:0000000044433344444444444444444433444444444444444444444444444334
-- 223:0000000044444444444444444444444444444444333444444444444444444444
-- 224:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 225:bbbbbbbebbbbbbeebbbbbbeebbbbbeeebbbbbeeebbbbbe9cbbbbbe9cbbbbbec9
-- 226:9fffffff5fffffff55999ffff5999ffff55555fff55559fff5555fffffffffff
-- 227:ffffffffffffffffff99ffffff99ffff9555ffff55559ffff555fffff5fffffc
-- 228:fffffffffffffffff99fffffc99fffff9c5cffffc0cfffffc5cffffffffcffff
-- 229:9fffffff2fffffff22999ffff2999ffff22222fff22229fff2222fffffffffff
-- 230:ffffffffffffffffff99ffffff99ffff9222ffff22229ffff222fffff2fffffc
-- 231:fffffffffffffffff99fffffc99fffff9c2cffffc0cfffffc2cffffffffcffff
-- 232:4444444444444333444444444444444444434444444444444444444444444444
-- 233:4444444444433344444444444444444433444444444444444444444444444334
-- 234:4444004444444400444444404433344444444444444444444444444444444444
-- 235:4444444444444444044444440044444444004444443004444444004444444400
-- 236:4444444444444444444333344444444444444444444433334444444444444444
-- 237:4444444444444444444444444433344444444444444444444444444444444444
-- 238:4444444444433344444444444444444433444444444444444444444444444334
-- 239:4444444444444444444444444444444444444443444444444334444444444444
-- 240:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 241:bbbeee99bbeeee99bbeeeeeebeeeeeeebeeeeeeebeeeeeeebeeeeeeebbbbbbbb
-- 242:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 243:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 244:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 245:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 246:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 247:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 248:4444444444444444444333344444444444444444444433334444444444444444
-- 249:4444444444433344444444444444444433444444444444444444444444444334
-- 250:4444444444444444334444444444444444444444444444444444444444444444
-- 251:4444444044433344444444444444444433444444444444444444444444444334
-- 252:0044444440004444444000444444400044444443444444444334444444444444
-- 253:4444444444444333444444440444444400004444444000004444444444444444
-- 254:4444444444433344444444444444444433444444000000004444444444444334
-- 255:4444444444444444444444444444444444444444000000004444444444444444
-- </TILES>

-- <SPRITES>
-- 000:bbbb1111bbb11111bb777777bb766666bb899999bb891119bb890dd9bb890cc9
-- 001:1111bbbb11111bbb777777bb666667bb999998bb911198bb90dd18bb90cc98bb
-- 002:bbbb1111bbb11111bb777777bb766666bb899999bb891119bb890dd9bb890cc9
-- 003:1111bbbb11111bbb777777bb666667bb999998bb911198bb90dd18bb90cc98bb
-- 004:bbbb1111bbb11111bb777777bb766666bb899999bb891119bb890dd9bb890cc9
-- 005:1111bbbb11111bbb777777bb666667bb999998bb911198bb90dd18bb90cc98bb
-- 006:bbbb1111bbb11111bb777777bb766666bb899999bb891119bb890dd9bb890cc9
-- 007:1111bbbb11111bbb777777bb666667bb999998bb911198bb90dd18bb90cc98bb
-- 008:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbfffbbb
-- 009:bbbb1111bbb11111bb777777bb766666bb899999bb891119bb890dd9bb890cc9
-- 010:1111bbbb11111bbb777777bb666667bb999998bb911198bb90dd18bb90cc98bb
-- 011:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 012:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbfffbbb
-- 013:bbbb1111bbb11111bb222222bb233333bb899999bb891119bb890dd9bb890cc9
-- 014:1111bbbb11111bbb222222bb333332bb999998bb911198bb90dd18bb90cc98bb
-- 015:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 016:bb890cc9bb899999bb899999bbb89900bbbb8999bbbbb888bbbbb899bbbb8659
-- 017:90cc98bb999998bb909998bb09998bbb9998bbbb888bbbbb998bbbbb9568bbbb
-- 018:bb890cc9bb899999bb899999bbb89900bbbb8999bbbbb888bbbbb899bbbb8659
-- 019:90cc98bb999998bb909998bb09998bbb9998bbbb888bbbbb998bbbbb9568bbbb
-- 020:bb890cc9bb899999bb899999bbb89900bbbb8999bbbbb888bbbbb899bbbb8659
-- 021:90cc98bb999998bb909998bb09998bbb9998bbbb888bbbbb998bbbbb9568bbbb
-- 022:bb890cc9bb899999bb899999bbb89900bbbb8999bbbbb888bbbbb899bbbb8659
-- 023:90cc98bb999998bb909998bb09998bbb9998bbbb888bbbbb998bbbbb9568bbbb
-- 024:bf333fbbf33333fbf33333fbf33888bbbf89998bbb899998bb888999bbbb8999
-- 025:bb890cc9bb899999bb899999bbb89900bbbb8999bbbbb8888bbbb89998bb8659
-- 026:90cc98bb999998bb909998bb09998bbb9998bbbb888bbbbb998bbbbb9568bbbb
-- 027:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 028:bf333fbbf33333fbf33333fbf33888bbbf89998bbb899998bb888999bbbb8999
-- 029:bb890cc9bb899999bb899999bbb89900bbbb8999bbbbb8888bbbb89998bb8239
-- 030:90cc98bb999998bb909998bb09998bbb9998bbbb888bbbbb998bbbbb9328bbbb
-- 031:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 032:bb889665b8999666b8996666b8996666b8996666b8997666b8997666b8997777
-- 033:566988bb6669998b6666998b6666998b6666998b6666998b6666998b7766998b
-- 034:bb889665b8999666b8996666b8996666b8996666b8997666b8997666b8997777
-- 035:566988bb6669998b6666998b6666998b6666998b6666998b6666998b7766998b
-- 036:bb889665b8999666b8996666b8996666b8996666b8997666b8997666b8997777
-- 037:566988bb6669998b6666998b6666998b6666998b6666998b6666998b7766998b
-- 038:bb889665b8999666b8996666b8996666b8996666b8997666b8997666b8997777
-- 039:566988bb6669998b6666998b6666998b6666998b6666998b6666998b7766998b
-- 040:bbbb8899bbbbb888bbbbbbb8bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 041:99889665999996668999888888999999b8899999bb888888bbb87666bbb87777
-- 042:56698bbb888998bb999998bb999998bb999998bb88888bbb66668bbb77668bbb
-- 043:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 044:bbbb8899bbbbb888bbbbbbb8bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 045:99889223999992228999888888999999b8899999bb888888bbb81222bbb81111
-- 046:32298bbb888998bb999998bb999998bb999998bb88888bbb22228bbb11228bbb
-- 047:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 048:b8985555bb887666bbb87666bbb87668bbb8998bbbb8de8bbb8dee88bbb888bb
-- 049:5555898b666688bb76668bbb87668bbb8998bbbb8de8bbbbdee8bbbb888bbbbb
-- 050:b8985555bb887666bbb87666bbb87668bb89988bbb8de8bbb8dee8b8bb888bbb
-- 051:5555898b666688bb76668bbb87668bbb8998bbbb8de8bbbbdee8bbbb888bbbbb
-- 052:b8985555bb887666bbb87666bbb87668bb899888bb8de8b8b8dee88dbb888bb8
-- 053:5555898b666688bb76668bbb87668bbb998bbbbbde8bbbbbee8bbbbb88bbbbbb
-- 054:b8985555bb887666bbb87666bbb87668bbb89988bbb8de88bb8dee8dbbb888b8
-- 055:5555898b666688bb76668bbb87668bbb9988bbbbde8bbbbbee8bbbbb88bbbbbb
-- 056:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 057:bbb85555bbb87666bbb87666bbb87668bbb89988bbb8de88bb8dee8dbbb888b8
-- 058:55558bbb66668bbb76668bbb87668bbb9988bbbbde8bbbbbee8bbbbb88bbbbbb
-- 059:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 060:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 061:bbb83333bbb81222bbb81222bbb81228bbb89988bbb8de88bb8dee8dbbb888b8
-- 062:33338bbb22228bbb12228bbb81228bbb9988bbbbde8bbbbbee8bbbbb88bbbbbb
-- 063:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 064:bbbb1111bbb11111bb222222bb233333bb899999bb891119bb890dd9bb890cc9
-- 065:1111bbbb11111bbb222222bb333332bb999998bb911198bb90dd18bb90cc98bb
-- 066:bbbb1111bbb11111bb222222bb233333bb899999bb891119bb890dd9bb890cc9
-- 067:1111bbbb11111bbb222222bb333332bb999998bb911198bb90dd18bb90cc98bb
-- 068:bbbb1111bbb11111bb222222bb233333bb899999bb891119bb890dd9bb890cc9
-- 069:1111bbbb11111bbb222222bb333332bb999998bb911198bb90dd18bb90cc98bb
-- 070:bbbb1111bbb11111bb222222bb233333bb899999bb891119bb890dd9bb890cc9
-- 071:1111bbbb11111bbb222222bb333332bb999998bb911198bb90dd18bb90cc98bb
-- 072:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8bbbbbb898bbbbb899bbbbb899bbbbb899
-- 073:bbbb1111bbb11111bb777777bb766666bb8999998b8911198b890dd98b890cc9
-- 074:1111bbbb11111bbb777777bb666667bb999998bb911198bb90dd18bb90cc98b8
-- 075:bbbbbbbbbbbbbbbbbbbbbbbbb8bbbbbb898bbbbb8998bbbb8998bbbb9998bbbb
-- 076:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8bbbbbb898bbbbb899bbbbb899bbbbb899
-- 077:bbbb1111bbb11111bb222222bb233333bb8999998b8911198b890dd98b890cc9
-- 078:1111bbbb11111bbb222222bb333332bb999998bb911198bb90dd18bb90cc98b8
-- 079:bbbbbbbbbbbbbbbbbbbbbbbbb8bbbbbb898bbbbb8998bbbb8998bbbb9998bbbb
-- 080:bb890cc9bb899999bb899999bbb89900bbbb8999bbbbb888bbbbb899bbbb8239
-- 081:90cc98bb999998bb909998bb09998bbb9998bbbb888bbbbb998bbbbb9328bbbb
-- 082:bb890cc9bb899999bb899999bbb89900bbbb8999bbbbb888bbbbb899bbbb8239
-- 083:90cc98bb999998bb909998bb09998bbb9998bbbb888bbbbb998bbbbb9328bbbb
-- 084:bb890cc9bb899999bb899999bbb89900bbbb8999bbbbb888bbbbb899bbbb8239
-- 085:90cc98bb999998bb909998bb09998bbb9998bbbb888bbbbb998bbbbb9328bbbb
-- 086:bb890cc9bb899999bb899999bbb89900bbbb8999bbbbb888bbbbb899bbbb8239
-- 087:90cc98bb999998bb909998bb09998bbb9998bbbb888bbbbb998bbbbb9328bbbb
-- 088:bbbbb899bbbbb899bbbbb899bbbbb899bbbbbb89bbbbbb89bbbbbbb8bbbbbbbb
-- 089:8b890cc98b8999998b89999998b8990098bb8999998bb8889998b89989998659
-- 090:90cc98b8999998b8909998b809998bb89998bb89888bb899998b899995689999
-- 091:9998bbbb9998bbbb9998bbbb9998bbbb9998bbbb998bbbbb98bbbbbb8bbbbbbb
-- 092:bbbbb899bbbbb899bbbbb899bbbbb899bbbbbb89bbbbbb89bbbbbbb8bbbbbbbb
-- 093:8b890cc98b8999998b89999998b8990098bb8999998bb8889998b89989998239
-- 094:90cc98b8999998b8909998b809998bb89998bb89888bb899998b899993289999
-- 095:9998bbbb9998bbbb9998bbbb9998bbbb9998bbbb998bbbbb98bbbbbb8bbbbbbb
-- 096:bb889223b8999222b8992222b8992222b8992222b8991222b8991222b8991111
-- 097:322988bb2229998b2222998b2222998b2222998b2222998b2222998b1122998b
-- 098:bb889223b8999222b8992222b8992222b8992222b8991222b8991222b8991111
-- 099:322988bb2229998b2222998b2222998b2222998b2222998b2222998b1122998b
-- 100:bb889223b8999222b8992222b8992222b8992222b8991222b8991222b8991111
-- 101:322988bb2229998b2222998b2222998b2222998b2222998b2222998b1122998b
-- 102:bb889223b8999222b8992222b8992222b8992222b8991222b8991222b8991111
-- 103:322988bb2229998b2222998b2222998b2222998b2222998b2222998b1122998b
-- 104:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 105:89999665b8999666b8996666bb886666bbb86666bbb87666bbb87666bbb87777
-- 106:566999986669998b6666998b666688bb66668bbb66668bbb66668bbb77668bbb
-- 107:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 108:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 109:89999223b8999222b8992222bb882222bbb82222bbb81222bbb81222bbb81111
-- 110:322999982229998b2222998b222288bb22228bbb22228bbb22228bbb11228bbb
-- 111:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 112:b8983333bb881222bbb81222bbb81228bbb8998bbbb8de8bbb8dee88bbb888bb
-- 113:3333898b222288bb12228bbb81228bbb8998bbbb8de8bbbbdee8bbbb888bbbbb
-- 114:b8983333bb881222bbb81222bbb81228bb89988bbb8de8bbb8dee8b8bb888bbb
-- 115:3333898b222288bb12228bbb81228bbb8998bbbb8de8bbbbdee8bbbb888bbbbb
-- 116:b8983333bb881222bbb81222bbb81228bb899888bb8de8b8b8dee88dbb888bb8
-- 117:3333898b222288bb12228bbb81228bbb998bbbbbde8bbbbbee8bbbbb88bbbbbb
-- 118:b8983333bb881222bbb81222bbb81228bbb89988bbb8de88bb8dee8dbbb888b8
-- 119:3333898b222288bb12228bbb81228bbb9988bbbbde8bbbbbee8bbbbb88bbbbbb
-- 120:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 121:bbb85555bbb87666bbb87666bbb87668bbb8998bbbb8de8bbb8dee88bbb888bb
-- 122:55558bbb66668bbb76668bbb87668bbb8998bbbb8de8bbbbdee8bbbb888bbbbb
-- 123:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 124:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 125:bbb83333bbb81222bbb81222bbb81228bbb8998bbbb8de8bbb8dee88bbb888bb
-- 126:33338bbb22228bbb12228bbb81228bbb8998bbbb8de8bbbbdee8bbbb888bbbbb
-- 127:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 128:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 129:bbbb1111bbb11111bb777777bb766666bb899999bb891119bb890dd9bb890cc9
-- 130:1111bbbb11111bbb777777bb666667bb999998bb911198bb90dd18bb90cc98bb
-- 131:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 132:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 133:bbbb1111bbb11111bb777777bb766666bb899999bb891119bb890dd9bb890cc9
-- 134:1111bbbb11111bbb777777bb666667bb999998bb911198bb90dd18bb90cc98bb
-- 135:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 136:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 137:bbbb1111bbb11111bb222222bb233333bb899999bb891119bb890dd9bb890cc9
-- 138:1111bbbb11111bbb222222bb333332bb999998bb911198bb90dd18bb90cc98bb
-- 139:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 140:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 141:bbbb1111bbb11111bb222222bb233333bb899999bb891119bb890dd9bb890cc9
-- 142:1111bbbb11111bbb222222bb333332bb999998bb911198bb90dd18bb90cc98bb
-- 143:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 144:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 145:bb890cc9bb899999bb899999bbb89900bbbb8999bbbbb888bbbbb899bbbb8659
-- 146:90cc98bb999998bb909998bb09998bbb9998bbbb888bbbbb998bbbbb9568bbbb
-- 147:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 148:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 149:bb890cc9bb899999bb899999bbb89900bbbb8999bbbbb888bbbbb899bbbb8659
-- 150:90cc98bb999998bb909998bb09998bbb9998bbbb888bbbbb998bbbbb9568bbbb
-- 151:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 152:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 153:bb890cc9bb899999bb899999bbb89900bbbb8999bbbbb888bbbbb899bbbb8239
-- 154:90cc98bb999998bb909998bb09998bbb9998bbbb888bbbbb998bbbbb9328bbbb
-- 155:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 156:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 157:bb890cc9bb899999bb899999bbb89900bbbb8999bbbbb888bbbbb899bbbb8239
-- 158:90cc98bb999998bb909998bb09998bbb9998bbbb888bbbbb998bbbbb9328bbbb
-- 159:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 160:bbbbbbbbbbbbbbbbbbbbbbb8bbbbbb89bbbbb899bbbbb899bbbbbb88bbbbbfff
-- 161:bb88966588999666999966669988666698b866668bb87666bbb87666bbb87777
-- 162:566988bb6669998b6666998b6666998b6666998b6666998b6666998b7766998b
-- 163:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 164:bbbbbbbbbbbbbbbbbbbbbbb8bbbbbb89bbbbbb89bbbbbb89bbbbbb89bbbbbbb8
-- 165:bb88966588999666999966669988666698b8666698b8766698b8766698b87777
-- 166:566988bb6669998b6666998b6666998b6666998b6666998b6666998b7766998b
-- 167:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 168:bbbbbbbbbbbbbbbbbbbbbbb8bbbbbb89bbbbbb89bbbbbb89bbbbbb89bbbbbbb8
-- 169:bb88922388999222999922229988222298b8222298b8122298b8122298b81111
-- 170:322988bb2229998b2222998b2222998b2222998b2222998b2222998b1122998b
-- 171:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 172:bbbbbbbbbbbbbbbbbbbbbbb8bbbbbb89bbbbb899bbbbb899bbbbbb88bbbbbfff
-- 173:bb88922388999222999922229988222298b822228bb81222bbb81222bbb81111
-- 174:322988bb2229998b2222998b2222998b2222998b2222998b2222998b1122998b
-- 175:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 176:bbbbf333bbbf3333bbbf3333bbbf3333bbbbf333bbbbbfffbbbbbbbbbbbbbbbb
-- 177:fbb855553fb876663fb876663fb87668fbb8998bbbb8de8bbb8dee88bbb888bb
-- 178:5555898b666688bb76668bbb87668bbb8998bbbb8de8bbbbdee8bbbb888bbbbb
-- 179:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 180:bbbbbbbbbbbbbfffbbbbf333bbbf3333bbbf3333bbbf3333bbbbf333bbbbbfff
-- 181:8bb85555bbb87666fbb876663fb876683fb8998b3fb8de8bfb8dee88bbb888bb
-- 182:5555898b666688bb76668bbb87668bbb8998bbbb8de8bbbbdee8bbbb888bbbbb
-- 183:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 184:bbbbbbbbbbbbbfffbbbbf333bbbf3333bbbf3333bbbf3333bbbbf333bbbbbfff
-- 185:8bb83333bbb81222fbb812223fb812283fbb89983fbb8de8fbb8dee8bbbb888b
-- 186:3333898b222288bb12228bbb81228bbbb8998bbbb8de8bbbbdee8bbbb888bbbb
-- 187:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 188:bbbbf333bbbf3333bbbf3333bbbf3333bbbbf333bbbbbfffbbbbbbbbbbbbbbbb
-- 189:fbb833333fb812223fb812223fb81228fbb8998bbbb8de8bbb8dee88bbb888bb
-- 190:3333898b222288bb12228bbb81228bbb8998bbbb8de8bbbbdee8bbbb888bbbbb
-- 191:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 192:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 193:bbbbbbbbbbbbbbbbbbbbbbbbbbbbddddbbbbdbbbbbbbdbbbbbbbdbbbbbbbdbbb
-- 194:bbbbbbbbbbbbbbbbbbbbbbbbddddddddbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 195:bbbbbbbbbbbbbbbbbbbbbbbbddddddbbbbbbbdbbbbbbbdbbbbbbbdbbbbbbbdbb
-- 196:ddddddddddddddddbddddddbb444444bbb3333bbbb3333bbbbb11bbbbbb11bbb
-- 197:ddddddddddddddddb444444bb444444bbb3333bbbb3333bbbbb11bbbbbb11bbb
-- 198:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 199:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 200:bbbbbbbbbbbbbbbbbbbbbbbbbbbbddddbbbbdbbbbbbbdbbbbbbbdbbbbbbbdbbb
-- 201:bbbbbbbbbbbbbbbbbbbbbbbbddddddddbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 202:bbbbbbbbbbbbbbbbbbbbbbbbddddddbbbbbbbdbbbbbbbdbbbbbbbdbbbbbbbdbb
-- 203:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 204:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 205:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 206:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 207:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 208:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 209:bbbbdbbbbbbbdbbbbbbbdbbbbbbbdbbbbbbbdbbbbbbbdbbbbbbbddddbbbbbbbb
-- 210:bcccccccbcbbbbbbbcbbbbbbbcbee333bcee3ecebceee333dddddcdceeeeebcb
-- 211:cbbbbdbbcbbbbdbbcbbbbdbb333bbdbbcbc3bdbb333bbdbbdcddddbbcbcbbbbb
-- 212:ddddddddddddddddbddddddbbddddddbbb3333bbbb3333bbbbb11bbbbbb11bbb
-- 213:dddddddd55555555b444444bb444444bbb3333bbbb3333bbbbb11bbbbbb11bbb
-- 214:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 215:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 216:bbbbdbbbbbbbdbbbbbbbdbbbbbbbdbbbbbbbdbbbbbbbdbbbbbbbddddbbbbbbbb
-- 217:bcccccccbcbbbbbbbcbbbbbbbcbee222bcee2ecebceee222dddddc0ceeeee0c3
-- 218:cbbbbdbbcbbbbdbbcbbbbdbb222bbdbbcbc2bdbb222bbdbb0cddddbbc0cbbbbb
-- 219:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 220:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 221:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 222:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 223:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 224:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 225:bbbbbbbebbbbbbeebbbbbbeebbbbbeeebbbbbeeebbbbbe9cbbbbbe9cbbbbbec9
-- 226:eeeebcbceeeebbcbeeebbbbbeeebbbbbeeebbbbb22ebbbbbc2ebbbbbc2ebbbbb
-- 227:bcbbbbbbcbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 228:ddddddddddddddddbddddddbbddddddbbbddddbbbbddddbbbbbddbbbbbb11bbb
-- 229:6666666655555555b444444bb444444bbb3333bbbb3333bbbbb11bbbbbb11bbb
-- 230:5666666566665666b666656bb565666bbb6666bbbb6656bbbbb66bbbbbb66bbb
-- 231:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 232:bbbbbbbebbbbbbeebbbbbbeebbbbbeeebbbbbeeebbbbbe9cbbbbbe9cbbbbbec9
-- 233:eeeef33ceeeef333eeebf333eeebbf33eeebbbff22ebbbbbc2ebbbbbc2ebbbbb
-- 234:3cfbbbbb33fbbbbb33fbbbbb3fbbbbbbfbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 235:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 236:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 237:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 238:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 239:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 240:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 241:bbbeee99bbeeee99bbeeeeeebeeeeeeebeeeeeeebeeeeeeebeeeeeeebbbbbbbb
-- 242:c2eeebbbc2eeeebbeeeeeebbeeeeeeebeeeeeeebeeeeeeebeeeeeeebbbbbbbbb
-- 243:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 244:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 245:1111111111111111b111111bb111111bbb1111bbbb1111bbbbb11bbbbbb11bbb
-- 246:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 247:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 248:bbbeee99bbeeee99bbeeeeeebeeeeeeebeeeeeeebeeeeeeebeeeeeeebbbbbbbb
-- 249:c2eeebbbc2eeeebbeeeeeebbeeeeeeebeeeeeeebeeeeeeebeeeeeeebbbbbbbbb
-- 250:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 251:bbfffbbbbf333fbbf33333fbf33333fbf33333fbbf333fbbbbfffbbbbbbbbbbb
-- 252:bbbbbbbbbbfffbbbbf333fbbf33333fbf33333fbf33333fbbf333fbbbbfffbbb
-- 253:bbbbbbbbbbbfffbbbbf333fbbf33333fbf33333fbf33333fbbf333fbbbbfffbb
-- 254:bbbfffbbbbf333fbbf33333fbf33333fbf33333fbbf333fbbbbfffbbbbbbbbbb
-- 255:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- </SPRITES>

-- <MAP>
-- 000:2c3c2c2e2c2e2c2d2c3d4d3c3d4d3c5d5d5c6c5d5c6c5d5d5c6c5d5d5c6c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 001:2c2d2d3d2c2d2c2e2c2d3d3c4a5a4a5a4a5a6c5e5e5c6c6c5e5c5c6c5e5e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:2c2e2c2d3d2e2c3c2c2d3d2d4b5b4b5b4b5b6d5e5d6d5c6c6d5e5d6d6c5d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:2e3c2c2e3e4e2d2d3d2d2c3c28387a2a68786d5c6c5c6c6d6e5d6d5c6d5e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:2c3c2c3c2c2d2e2e2c2e2c3c29397b2b69796e5d6d5d6d5e5c6d6e5c6e5e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:2c2d2e2d2c3c2c2e2c3c2d3d2e2c3c5d5c6c7e5c6c5d6e5d5d6e7e5c6c5d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 006:2c3c2c2e2e2e2c3c2c3c2e3e4e3d4d5e5e5c6c5e5e5c6c5e5c6c5c6c5e5e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 007:181807070818181818081818180818e7f7e7f7e7f7e7f7e7f7e7f7e7f7f7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 008:070708082030405060708090a09090a0b4c48898a8b8c8d8e8f8e7f7e7f7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 009:070700102131415161718191a19191a1a5c58999a9b9c9d9e9f9e0f0e7f7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 010:070701112232425262728292708090a292928a9aaabacadaeafae1f1e7f7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 011:070702122333435363738393a39393a393938b9babbbcbdbebfbe2f2e7f7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 012:0707031324344454647484b4c490947080908c9cacbcccdcecfce3f3e7f7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 013:0707041425354555657585b5c59595a595958d9dadbdcdddedfde4f4e7f7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 014:070705152636465666768696a696708090b48e9eaebecedeeefee5f5e7f7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 015:070706162737475767778797a79797a797b58f9fafbfcfdfefffe6f6e7f7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 016:070818081808081808080818080818e7f7e7f7e7f7e7f7e7f7e7f7e7e7f7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 017:070717171717171717171717171717f8f8f8f8f8f8f8f8f8f8f8f8f8f8f7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 018:070727272727272727272727272727272727272727272727272727272727000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </MAP>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:22082208d2f5d2b4d282d270d25ed25d023c023a024a026c027e029002c302f5c205c200c200c200c2000200020002000200020002000200020002002070001f1f1f
-- 001:d009d00ad00ad00ad00ad00bd00bd00bd00ad00ad00ad00ad00a000a00090009700990099009000900090009000900090009000900090009000900091090006e0000
-- 002:701370326053506550a740b730c720c720d710e600e6f0d7f007f007f007f007f007f007f007f007f007f007f006f005f003f000f001f002f003f004650000000000
-- 003:02000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020010a000000000
-- 004:0080008000700070008000f000f000f000f000f000000000000000000000000000000000000000000000000000000000000000000000000000000000469000000800
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>
