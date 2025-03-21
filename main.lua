local rock 			= {}
local tweenS 		= game:GetService("TweenService")
local trove 		= require(game.ReplicatedStorage.Trove)
rock.__index 		= rock

function rock.new(lifetime,sizex,sizey,sizeZ,maxparts,radius,target,cancollide,anchored)
	local self			= setmetatable({},rock)
	self.vector 		= Vector3.new
	self.tInfo 			= TweenInfo.new
	self.enumAxis 		= Enum.Axis
	self.delay 			= task.delay
	self.angle 			= CFrame.fromEulerAnglesXYZ
	self.axisAngle 		= CFrame.fromAxisAngle
	self.axis 			= Vector3.FromAxis
	self.debris 		= Instance.new("Folder",workspace)
	self.debris.Name 	= "DEBRIS"
	self._trove 		= trove.new()
	self.lifetime 		= lifetime
	self.sizeX 			= sizex
	self.sizeY 			= sizey
	self.sizeZ 			= sizeZ
	self.maxparts 		= maxparts
	self.radius 		= radius
	self.target 		= target
	self.cancollide 	= cancollide
	self.anchored 		= anchored
	return self
end

function rock:clear()
	self._trove:Destroy()
end

function rock:raycast(part)
	local param = RaycastParams.new()
	param.FilterType = Enum.RaycastFilterType.Exclude
	param.FilterDescendantsInstances = {part}
	local ray = workspace:Raycast(part.Position,self.axis(self.enumAxis.Y) * -15,param)
	return ray
end

function rock:Tween(p,tweenT)
	tweenS:Create(p,self.tInfo(tweenT),{Position = p.Position + self.axis(self.enumAxis.Y) * 5}):Play()
	self.delay(
		self.lifetime,function()
			tweenS:Create(p,self.tInfo(tweenT),{Position = p.Position + self.axis(self.enumAxis.Y) * -5}):Play()
			self.delay(
				.7, function()
					self:clear()
				end
			)
		end
	)
end

function rock:spawn()
	for i = 1,self.maxparts do
		local rotational = math.random() * (math.pi * 2) - (math.pi)
		local angle = (math.pi * 2) / self.maxparts * i
		local rock = self._trove:Add(Instance.new("Part"))
		local adjustPos = self.vector(math.cos(angle) * self.radius,self.target.Size.Y + 3,math.sin(angle) * self.radius)
		rock.Anchored = self.anchored
		rock.Position = self.target.Position + adjustPos
		rock.CanCollide = self.cancollide
		local shotray = self:raycast(rock)
		if shotray then
			print('RAYCAST FOUND!')
			rock.Parent = self.debris
			rock.CFrame = rock.CFrame * self.axisAngle(Vector3.one, rotational)
			rock.Size = self.vector(self.sizeX,self.sizeY,self.sizeZ)
			rock.Material = shotray.Instance.Material
			rock.Color = shotray.Instance.Color
			rock.Position = shotray.Position + (self.axis(self.enumAxis.Y) * -5)
			self:Tween(rock,.5)
			continue
		end
		print('OBJECT IS TOO HIGH')
	end
end


return rock
