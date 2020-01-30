AddCSLuaFile()

ENT.Type = "anim"

ENT.NextUse = 0
function ENT:Initialize()
	self:SetModel("models/props_c17/suitcase_passenger_physics.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)

	if SERVER then
		self.Entity:NextThink(CurTime() + 1.5)
	end
end

function ENT:Draw()
	if IsValid(self) then
		self:DrawModel()
		local pos = self:GetPos() + Vector(0, 0, 20)
		local ang = Angle(0, LocalPlayer():GetAngles().y - 90, 90)
		surface.SetFont("Default")
		local width = surface.GetTextSize("What could be in here?") + 120

		cam.Start3D2D(pos, ang, 0.3)

		draw.RoundedBox( 5, -width / 2 , -5, width, 15, Color(10, 90, 140, 100) )
		draw.SimpleText("Press [E] to receive your Item!", "ChatFont", 0, -5, Color(255,255,255,255), TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end
end

function ENT:PickAndGiveRandomEquipFromTable(ply, t_equip, try)
	local class = nil
	if #t_equip > 0 then
		class = t_equip[math.random(1,#t_equip)]
	end

	if not class then return end

	local isItem = items.IsItem(class)

	local equip = isItem and items.GetStored(class) or weapons.GetStored(class)

	if not equip then return end

	if isItem and ply:HasBought(class) or not isItem and not ply:CanCarryWeapon(equip) then
		if try < 8 then
			self:PickAndGiveRandomEquipFromTable(ply, t_equip, try + 1)
			return
		else
			LANG.Msg(ply, "Sorry, please try again.", nil, MSG_MSTACK_ROLE)
			self:EmitSound("buttons/button9.wav",75, 150)
			return
		end
	end

	local effect = EffectData()
	effect:SetOrigin(self:GetPos() + Vector(0,0, 10))
	effect:SetStart(self:GetPos() + Vector(0,0, 10))

	util.Effect("cball_explode", effect, true, true )

	sound.Play("ambient/levels/labs/electric_explosion3.wav", self:GetPos())

	if isItem then
		local item = ply:GiveEquipmentItem(class)
		if isfunction(item.Bought) then
			item:Bought(ply)
		end
	else
		ply:GiveEquipmentWeapon(class, function(ply, cls, wep)
			if isfunction(wep.WasBought) then
				wep:WasBought(ply)
			end
		end)
	end

	self:Remove()
end

function ENT:Use(ply)
	if (self.NextUse < CurTime()) then
		if not IsFirstTimePredicted() then
			return
		end

		self.NextUse = CurTime() + 2

		local t_equip = {}

		local ignoreNotBuyable = GetConVar("ttt_tc_ignore_not_buyable"):GetBool()
		local maxCredits = GetConVar("ttt_tc_max_credits"):GetInt()

		for _, v in pairs(weapons.GetList()) do
			if table.HasValue(v.CanBuy, self.Role or ROLE_TRAITOR) then
				if ignoreNotBuyable or !(v.notBuyable) then
					if v.credits and v.credits <= maxCredits then
						table.insert(t_equip, v.ClassName)
					end
				end
			end
		end

		for _, v in pairs(items.GetList()) do
			if table.HasValue(v.CanBuy, self.Role or ROLE_TRAITOR) then
				if ignoreNotBuyable or !(v.notBuyable) then
					if v.credits and v.credits <= maxCredits then
						table.insert(t_equip, v.ClassName)
					end
				end
			end
		end

		self:PickAndGiveRandomEquipFromTable(ply, t_equip, 0)
	end
end
