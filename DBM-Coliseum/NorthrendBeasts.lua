local mod	= DBM:NewMod("NorthrendBeasts", "DBM-Coliseum")
local L		= mod:GetLocalizedStrings()

local CL = DBM_COMMON_L

mod:SetRevision("20220518110528")
mod:SetMinSyncRevision(7007)
mod:SetCreatureID(34796, 35144, 34799, 34797)
mod:SetMinCombatTime(30)
mod:SetUsedIcons(1, 2, 3, 4, 5, 6, 7, 8)
mod:SetBossHPInfoToHighest()

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)
mod:RegisterEventsInCombat(
	"SPELL_CAST_START 66313 66330 67647 67648 67649 66683 67660 66794 67644 67645 67646 66796 67632 66880 67606 66821 66818 66901 67615 67616 67617 66902 67627 67628 67629",
	"SPELL_CAST_SUCCESS 66689 67650 67651 67652 67641 66883 67642 67643 66824 67612 67613 67614 66879 67624 67625 67626 66734",
	"SPELL_AURA_APPLIED 67477 66331 67478 67479 67657 66759 67658 67659 66823 67618 67619 67620 66869 66758 66636 68335",
	"SPELL_AURA_APPLIED_DOSE 67477 66331 67478 67479 66636",
	"SPELL_AURA_REMOVED 66869",
	"SPELL_DAMAGE 66320 67472 67473 67475 66317 66881 67638 67639 67640",
	"SPELL_MISSED 66320 67472 67473 67475 66317 66881 67638 67639 67640",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"UNIT_DIED"
)

local myPomoi5 = select(4, DBM:GetMyPlayerInfo())

local warnImpaleOn			= mod:NewStackAnnounce(66331, 2, nil, "Tank|Healer")
local warnFireBomb			= mod:NewSpellAnnounce(66317, 3, nil, false)
local warnBreath			= mod:NewSpellAnnounce(66689, 2)
local warnRage				= mod:NewSpellAnnounce(67657, 3)
local warnSlimePool			= mod:NewSpellAnnounce(66883, 2, nil, "Melee")
local warnToxin				= mod:NewTargetAnnounce(66823, 3)
local warnBile				= mod:NewTargetAnnounce(66869, 3)
local WarningSnobold		= mod:NewAnnounce("WarningSnobold", 4)
local warnEnrageWorm		= mod:NewSpellAnnounce(68335, 3)
local warnCharge			= mod:NewTargetNoFilterAnnounce(52311, 4)

local specWarnImpale3		= mod:NewSpecialWarningStack(66331, nil, 3, nil, nil, 1, 6)
local specWarnAnger3		= mod:NewSpecialWarningStack(66636, "Tank|Healer", 3, nil, nil, 1, 6)
local specWarnGTFO			= mod:NewSpecialWarningGTFO(66317, nil, nil, nil, 1, 2)
local specWarnToxin			= mod:NewSpecialWarningMoveTo(66823, nil, nil, nil, 1, 2)
local specWarnBile			= mod:NewSpecialWarningYou(66869, nil, nil, nil, 1, 2)
local specWarnSilence		= mod:NewSpecialWarningSpell(66330, "SpellCaster", nil, nil, 1, 2)
local specWarnCharge		= mod:NewSpecialWarningRun(52311, nil, nil, nil, 4, 2)
local specWarnChargeNear	= mod:NewSpecialWarningClose(52311, nil, nil, nil, 3, 2)
local specWarnFrothingRage	= mod:NewSpecialWarningDispel(66759, "RemoveEnrage", nil, nil, 1, 2)

local enrageTimer			= mod:NewBerserkTimer(223)
local timerCombatStart		= mod:NewCombatTimer(12)
local timerNextBoss			= mod:NewTimer(190, "TimerNextBoss", 2457, nil, nil, 1)
local timerSubmerge			= mod:NewTimer(45, "TimerSubmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp", nil, nil, 6)
local timerEmerge			= mod:NewTimer(10, "TimerEmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp", nil, nil, 6)

local timerBreath			= mod:NewCastTimer(5, 66689, nil, nil, nil, 3)
local timerBreathCD		= mod:NewCDTimer(19, 66689, nil, nil, nil, 3)
local timerNextFireBomb		= mod:NewNextTimer(2.7, 66313, nil, nil, nil, 3)
local timerNextStomp		= mod:NewNextTimer(20.9, 66330, nil, nil, nil, 2, nil, CL.INTERRUPT_ICON, nil, mod:IsSpellCaster() and 3 or nil, 3)
local timerNextImpale		= mod:NewNextTimer(9.2, 66331, nil, "Tank|Healer", nil, 5, nil, CL.TANK_ICON)
local timerRisingAnger      = mod:NewNextTimer(16.1, 66636, nil, nil, nil, 1)
local timerStaggeredDaze	= mod:NewBuffActiveTimer(15, 66758, nil, nil, nil, 5, nil, CL.DAMAGE_ICON)
local timerNextCrash		= mod:NewCDTimer(58.8, 66683, nil, nil, nil, 2, nil, CL.MYTHIC_ICON)
local timerSweepCD			= mod:NewCDTimer(16.2, 66794, nil, "Melee", nil, 3)
local timerSlimePoolCD		= mod:NewCDTimer(12, 66883, nil, "Melee", nil, 3)
local timerAcidSpitCD		= mod:NewCDTimer(2.5, 66880, nil, "Tank", 2, 5, nil, CL.TANK_ICON)
local timerFireSpitCD		= mod:NewCDTimer(2.6, 66796, nil, "Tank", 2, 5, nil, CL.TANK_ICON)
local timerAcidicSpewCD		= mod:NewCDTimer(21, 66818, nil, "Tank", 2, 5, nil, CL.TANK_ICON)
local timerMoltenSpewCD		= mod:NewCDTimer(16.4, 66821, nil, "Tank", 2, 5, nil, CL.TANK_ICON)
local timerParalyticSprayCD	= mod:NewCDTimer(20, 66901, nil, nil, nil, 3)
local timerBurningSprayCD	= mod:NewCDTimer(20, 66902, nil, nil, nil, 3)
local timerParalyticBiteCD	= mod:NewCDTimer(20, 66824, nil, "Melee", nil, 3)
local timerBurningBiteCD	= mod:NewCDTimer(20, 66879, nil, "Melee", nil, 3)

mod:AddSetIconOption("SetIconOnChargeTarget", 52311, true, 0, {8})
mod:AddSetIconOption("SetIconOnBileTarget", 66869, false, 0, {1, 2, 3, 4, 5, 6, 7, 8})
mod:AddBoolOption("ClearIconsOnIceHowl", true)
mod:AddRangeFrameOption("10")
mod:AddBoolOption("IcehowlArrow")

mod:GroupSpells(66902, 66869)
mod:GroupSpells(66901, 66823)

local bileName = DBM:GetSpellInfo(66869)
local phases = {}

local icehowlCrashSequence = {45.0, 42.6, 72.1, 54.3, 72.7, 56.8, 47.2, 60.0, 53.9, 65.6, 59.3, 58.0}

mod.vb.burnIcon = 1
mod.vb.DreadscaleActive = true
mod.vb.DreadscaleDead = false
mod.vb.AcidmawDead = false
mod.vb.startedByYell = false
mod.vb.crashCount = 0
mod.vb.lastCrashEnd = 0
mod.vb.crashBreaths = 0
mod.vb.crashSawWall = false
mod.vb.crashPendingCharge = false
mod.vb.crashSawAdrenaline = false

function mod:IcehowlCrashCastEnded()
	if self:GetStage() ~= 3 then
		return
	end
	self.vb.lastCrashEnd = GetTime()
	self.vb.crashBreaths = 0
	self.vb.crashSawWall = false
	self.vb.crashPendingCharge = false
	self.vb.crashSawAdrenaline = false
	timerNextCrash:Start(57.0)
end

function mod:IcehowlResolveCharge()
	if self:GetStage() ~= 3 then
		return
	end
	if not self.vb.crashPendingCharge then
		return
	end

	if not self.vb.crashSawWall and not self.vb.crashSawAdrenaline and self.vb.lastCrashEnd and self.vb.lastCrashEnd > 0 then
		local remain = 42.1 - (GetTime() - self.vb.lastCrashEnd)
		if remain > 0.1 then
			timerNextCrash:Start(remain)
		end
	end
	self.vb.crashPendingCharge = false
	self.vb.crashSawAdrenaline = false
	self.vb.crashSawWall = false
end

local function updateHealthFrame(phase)
	if phases[phase] then
		return
	end
	phases[phase] = true
	mod.vb.phase = phase
	if phase == 1 then
		DBM.BossHealth:Clear()
		DBM.BossHealth:AddBoss(34796, L.Gormok)
	elseif phase == 2 then
		DBM.BossHealth:AddBoss(35144, L.Acidmaw)
		DBM.BossHealth:AddBoss(34799, L.Dreadscale)
	elseif phase == 3 then
		DBM.BossHealth:AddBoss(34797, L.Icehowl)
	end
end

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 34796, "The Beasts of Northrend")
	table.wipe(phases)
	self.vb.burnIcon = 8
	self.vb.DreadscaleActive = true
	self.vb.DreadscaleDead = false
	self.vb.AcidmawDead = false
	self.vb.crashCount = 0
	self.vb.lastCrashEnd = 0
	self.vb.crashBreaths = 0
	self.vb.crashSawWall = false
	self.vb.crashPendingCharge = false
	self.vb.crashSawAdrenaline = false
	self:SetStage(1)
	if self:IsHeroic() then
		timerNextBoss:Start(152-delay)
		timerNextBoss:Schedule(147)
	end
	if self.vb.startedByYell then
		timerNextImpale:Start(21.5-delay)
		timerNextFireBomb:Start(18.2-delay)
		timerNextStomp:Start(27.3-delay)
		timerRisingAnger:Start((self:IsHeroic() and 18 or 36.6)-delay)
		specWarnSilence:Schedule(25.8-delay)
		specWarnSilence:ScheduleVoice(25.8-delay, "silencesoon")
	else
		timerNextImpale:Start(9.3-delay)
		timerNextFireBomb:Start(6-delay)
		timerNextStomp:Start(15-delay)
		timerRisingAnger:Start((self:IsHeroic() and 18 or 24.3)-delay)
		specWarnSilence:Schedule(13.5-delay)
		specWarnSilence:ScheduleVoice(13.5-delay, "silencesoon")
	end
	self.vb.startedByYell = false
	updateHealthFrame(1)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 34796, "The Beasts of Northrend", wipe)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:WormsEmerge(firstEmerge)
	if not self.vb.AcidmawDead then
		if self.vb.DreadscaleActive then
			timerAcidSpitCD:Start(4.5)
			timerParalyticSprayCD:Start(21.5)
		else
			timerAcidSpitCD:Start(firstEmerge and 3 or 3)
			timerParalyticBiteCD:Start(20)
			timerAcidicSpewCD:Start(25)
		end
	end
	if not self.vb.DreadscaleDead then
		if self.vb.DreadscaleActive then
			timerSlimePoolCD:Start(15)
			timerMoltenSpewCD:Start(26.5)
			timerBurningBiteCD:Start(16.5)
		else
			timerSweepCD:Start(2.4)
			timerFireSpitCD:Start(3)
		end
	end
end

function mod:WormsPhaseOpen()
	self:WormsEmerge()
	timerSubmerge:Start(48.9)
end

function mod:WormsAfterBurrowStateA()
	timerSubmerge:Start(45)
	timerAcidSpitCD:Start(3)
	timerParalyticBiteCD:Start(20)
	timerSweepCD:Start(27.9)
	timerBurningSprayCD:Start(15)
	timerFireSpitCD:Start(5)
end

function mod:WormsAfterBurrowStateB()
	timerSubmerge:Start(45)
	timerAcidSpitCD:Start(3)
	timerSweepCD:Start(16.8)
	timerParalyticSprayCD:Start(21.5)
	timerBurningBiteCD:Start(16.5)
	timerMoltenSpewCD:Start(26)
end

function mod:WormsSubmerge()
	timerSubmerge:Cancel()
	timerEmerge:Start(10)
	timerSweepCD:Cancel()
	timerSlimePoolCD:Cancel()
	timerMoltenSpewCD:Cancel()
	timerParalyticSprayCD:Cancel()
	timerBurningBiteCD:Cancel()
	timerAcidicSpewCD:Cancel()
	timerBurningSprayCD:Cancel()
	timerParalyticBiteCD:Cancel()
	timerAcidSpitCD:Cancel()
	timerFireSpitCD:Cancel()
	self:UnscheduleMethod("WormsAfterBurrowStateA")
	self:UnscheduleMethod("WormsAfterBurrowStateB")
	self.vb.DreadscaleActive = not self.vb.DreadscaleActive
	if self.vb.DreadscaleActive then
		self:ScheduleMethod(10, "WormsAfterBurrowStateB")
	else
		self:ScheduleMethod(10, "WormsAfterBurrowStateA")
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 66313 then
		warnFireBomb:Show()
		timerNextFireBomb:Start()
	elseif args:IsSpellID(66330, 67647, 67648, 67649) then
		timerNextStomp:Start()
		specWarnSilence:Schedule(19.4)
		specWarnSilence:ScheduleVoice(19.4, "silencesoon")
	elseif args:IsSpellID(66683, 67660) then
		self:UnscheduleMethod("IcehowlCrashCastEnded")
		self:ScheduleMethod(1, "IcehowlCrashCastEnded")
		return
	elseif args:IsSpellID(66794, 67644, 67645, 67646) then
		timerSweepCD:Start()
	elseif spellId == 66880 or spellId == 67606 then
		timerAcidSpitCD:Start()
	elseif spellId == 66796 or spellId == 67632 then
		timerFireSpitCD:Start()
	elseif spellId == 66821 then
		timerMoltenSpewCD:Start()
	elseif spellId == 66818 then
		timerAcidicSpewCD:Start()
	elseif args:IsSpellID(66901, 67615, 67616, 67617) then
		timerParalyticSprayCD:Start()
	elseif args:IsSpellID(66902, 67627, 67628, 67629) then
		self.vb.burnIcon = 1
		timerBurningSprayCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if args:IsSpellID(66689, 67650, 67651, 67652) then
		timerBreath:Start()
		timerBreathCD:Start()
		warnBreath:Show()
	elseif args:IsSpellID(66683, 67660) then
	elseif args:IsSpellID(67641, 66883, 67642, 67643) then
		warnSlimePool:Show()
		timerSlimePoolCD:Show()
	elseif args:IsSpellID(66824, 67612, 67613, 67614) then
		timerParalyticBiteCD:Start()
	elseif args:IsSpellID(66879, 67624, 67625, 67626) then
		timerBurningBiteCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 68667 and self:GetStage() == 3 then
		self.vb.crashSawAdrenaline = true
	elseif args:IsSpellID(67477, 66331, 67478, 67479) then
		timerNextImpale:Start()
		warnImpaleOn:Show(args.destName, 1)
	elseif args:IsSpellID(67657, 66759, 67658, 67659) then
		warnRage:Show()
		specWarnFrothingRage:Show()
		specWarnFrothingRage:Play("trannow")
	elseif args:IsSpellID(66823, 67618, 67619, 67620) then
		warnToxin:CombinedShow(0.3, args.destName)
		if args:IsPlayer() then
			specWarnToxin:Show(bileName)
			specWarnToxin:Play("targetyou")
		end
	elseif spellId == 66869 then
		warnBile:CombinedShow(0.3, args.destName)
		if args:IsPlayer() then
			specWarnBile:Show()
			specWarnBile:Play("targetyou")
		end
		if self.Options.SetIconOnBileTarget and self.vb.burnIcon < 9 then
			self:SetIcon(args.destName, self.vb.burnIcon)
			self.vb.burnIcon = self.vb.burnIcon + 1
		end
	elseif spellId == 66758 then
		timerStaggeredDaze:Start()
	elseif spellId == 66636 then
		WarningSnobold:Show(args.destName)
		timerRisingAnger:Show()
	elseif spellId == 68335 then
		warnEnrageWorm:Show()
	end
end

function mod:SPELL_AURA_APPLIED_DOSE(args)
	if args:IsSpellID(67477, 66331, 67478, 67479) then
		local amount = args.amount or 1
		timerNextImpale:Start()
		if (amount >= 3) or (amount >= 2 and self:IsHeroic()) then
			if args:IsPlayer() then
				specWarnImpale3:Show(amount)
				specWarnImpale3:Play("stackhigh")
			else
				warnImpaleOn:Show(args.destName, amount)
			end
		end
	elseif args.spellId == 66636 then
		local amount = args.amount or 1
		WarningSnobold:Show()
		if amount <= 3 then
			timerRisingAnger:Show()
		elseif amount >= 3 then
			specWarnAnger3:Show(amount)
			specWarnAnger3:Play("stackhigh")
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 66869 then
		if self.Options.SetIconOnBileTarget then
			self:RemoveIcon(args.destName)
		end
	end
end

function mod:SPELL_DAMAGE(_, _, _, destGUID, _, _, spellId, spellName)
	if (spellId == 66320 or spellId == 67472 or spellId == 67473 or spellId == 67475 or spellId == 66317) and destGUID == UnitGUID("player") then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("runaway")
	elseif (spellId == 66881 or spellId == 67638 or spellId == 67639 or spellId == 67640) and destGUID == UnitGUID("player") then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("runaway")
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg, _, _, _, target)
	local targetName = target and DBM:GetUnitFullName(target) or nil
	if self:GetStage() == 3 then
		if msg:find("врезается в стену") or msg:find("crashes into the Coliseum wall") then
			self.vb.crashSawWall = true
			return
		end
	end
	if self:GetStage() == 2 then
		if msg:find("buries itself in the earth") or msg:find("зарывается") then
			self:WormsSubmerge()
			return
		elseif msg:find("вылезает") or msg:find("emerges") then
			local isAcidmaw = msg:find(L.Acidmaw) or targetName == L.Acidmaw
			local isDreadscale = msg:find(L.Dreadscale) or targetName == L.Dreadscale
			if isAcidmaw then
				if not self.vb.DreadscaleDead then
					timerEmerge:Start(1.8)
				else
					timerEmerge:Cancel()
				end
				return
			elseif isDreadscale then
				timerEmerge:Cancel()
				return
			end
		elseif msg:find("После гибели товарища") or msg:find("After its companion dies") then
			timerSubmerge:Cancel()
			timerEmerge:Cancel()
			self:UnscheduleMethod("WormsAfterBurrowStateA")
			self:UnscheduleMethod("WormsAfterBurrowStateB")
		end
	end
	if (msg:match(L.Charge) or msg:find(L.Charge)) and targetName then
		if self:GetStage() == 3 then
			self.vb.crashCount = (self.vb.crashCount or 0) + 1
			self.vb.crashPendingCharge = true
			self.vb.crashSawAdrenaline = false
			self:UnscheduleMethod("IcehowlResolveCharge")
			self:ScheduleMethod(5, "IcehowlResolveCharge")
		end
		warnCharge:Show(targetName)
		if self.Options.ClearIconsOnIceHowl then
			self:ClearIcons()
		end
		if targetName == UnitName("player") then
			specWarnCharge:Show()
			specWarnCharge:Play("justrun")
			if self.Options.PingCharge then
				Minimap:PingLocation()
			end
		else
			local uId = DBM:GetRaidUnitId(targetName)
			if uId then
				local inRange = CheckInteractDistance(uId, 2)
				local x, y = GetPlayerMapPosition(uId)
				if x == 0 and y == 0 then
					SetMapToCurrentZone()
					x, y = GetPlayerMapPosition(uId)
				end
				if inRange then
					specWarnChargeNear:Show()
					specWarnChargeNear:Play("runaway")
					if self.Options.IcehowlArrow then
						DBM.Arrow:ShowRunAway(x, y, 12, 5)
					end
				end
			end
		end
		if self.Options.SetIconOnChargeTarget then
			self:SetIcon(targetName, 8, 5)
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.CombatStart or msg:find(L.CombatStart) then
		if not self.inCombat then
			self.vb.startedByYell = true
			DBM:StartCombat(self, 0, "MONSTER_YELL")
		end
		timerCombatStart:Start()
	elseif msg == L.Phase2 or msg:find(L.Phase2) then
		self:ScheduleMethod(15.4, "WormsPhaseOpen")
		timerCombatStart:Start(15.4)
		updateHealthFrame(2)
		self:SetStage(2)
		if self.Options.RangeFrame then
			DBM.RangeCheck:Show(10)
		end
	elseif msg == L.Phase3 or msg:find(L.Phase3) then
		updateHealthFrame(3)
		self:SetStage(3)
		if self:IsHeroic() then
			enrageTimer:Start()
		end
		self:UnscheduleMethod("WormsSubmerge")
		self:UnscheduleMethod("WormsEmerge")
		self:UnscheduleMethod("WormsAfterBurrowStateA")
		self:UnscheduleMethod("WormsAfterBurrowStateB")
		timerCombatStart:Start(11.4)
		self.vb.crashCount = 0
		self.vb.lastCrashEnd = 0
		self.vb.crashBreaths = 0
		self.vb.crashSawWall = false
		timerNextCrash:Start(44.1)
		timerBreathCD:Start(25.1)
		timerNextBoss:Cancel()
		timerSubmerge:Cancel()
		timerEmerge:Cancel()
		timerSweepCD:Cancel()
		timerSlimePoolCD:Cancel()
		timerMoltenSpewCD:Cancel()
		timerParalyticSprayCD:Cancel()
		timerBurningBiteCD:Cancel()
		timerAcidicSpewCD:Cancel()
		timerBurningSprayCD:Cancel()
		timerParalyticBiteCD:Cancel()
		timerAcidSpitCD:Cancel()
		timerFireSpitCD:Cancel()
		if self.Options.RangeFrame then
			DBM.RangeCheck:Hide()
		end
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 34796 then
		specWarnSilence:Cancel()
		specWarnSilence:CancelVoice()
		timerNextStomp:Stop()
		timerNextImpale:Stop()
		timerNextFireBomb:Stop()
		timerRisingAnger:Stop()
		DBM.BossHealth:RemoveBoss(cid)
	elseif cid == 35144 then
		self.vb.AcidmawDead = true
		timerParalyticSprayCD:Cancel()
		timerParalyticBiteCD:Cancel()
		timerAcidicSpewCD:Cancel()
		timerAcidSpitCD:Cancel()
		if self.vb.DreadscaleActive then
			timerSweepCD:Cancel()
		else
			timerSlimePoolCD:Cancel()
		end
		if self.vb.DreadscaleDead then
			timerNextBoss:Cancel()
			DBM.BossHealth:RemoveBoss(35144)
			DBM.BossHealth:RemoveBoss(34799)
		end
	elseif cid == 34799 then
		self.vb.DreadscaleDead = true
		timerBurningSprayCD:Cancel()
		timerBurningBiteCD:Cancel()
		timerMoltenSpewCD:Cancel()
		timerFireSpitCD:Cancel()
		if self.vb.DreadscaleActive then
			timerSlimePoolCD:Cancel()
		else
			timerSweepCD:Cancel()
		end
		if self.vb.AcidmawDead then
			timerNextBoss:Cancel()
			DBM.BossHealth:RemoveBoss(35144)
			DBM.BossHealth:RemoveBoss(34799)
		end
	elseif cid == 34797 then
		timerBreathCD:Cancel()
		DBM:EndCombat(self)
	end
end