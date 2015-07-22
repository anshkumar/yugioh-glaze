--ゴーストリックの雪女
function c1019.initial_effect(c)
	--sum limit
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c1019.sumlimit)
	c:RegisterEffect(e1)
	--turn set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1019,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c1019.settg)
	e2:SetOperation(c1019.setop)
	c:RegisterEffect(e2)
	--to set oppo
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1019,1))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCondition(c1019.condition)
	e3:SetTarget(c1019.target)
	e3:SetOperation(c1019.operation)
	c:RegisterEffect(e3)
end
function c1019.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8c)
end
function c1019.sumlimit(e)
	return not Duel.IsExistingMatchingCard(c1019.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function c1019.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(1019)==0 end
	c:RegisterFlagEffect(1019,RESET_EVENT+0x1fc0000+RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
function c1019.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENCE)
	end
end
function c1019.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
end
function c1019.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=e:GetHandler():GetReasonCard()
	Duel.SetTargetCard(rc)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,rc,1,0,0)
end
function c1019.operation(e,tp,eg,ep,ev,re,r,rp)
	local rc=Duel.GetFirstTarget()
	if rc:IsRelateToEffect(e) and rc:IsFaceup() then
		Duel.ChangePosition(rc,POS_FACEDOWN_DEFENCE)
		if rc:IsFacedown() then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_EVENT+0x1fe0000)
			rc:RegisterEffect(e1)
		end
	end
end
