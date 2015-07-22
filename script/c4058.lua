--ナンバーズ・ウォール
function c4058.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_DRAW_PHASE)
	e1:SetCondition(c4058.regcon)
	c:RegisterEffect(e1)
	--indestructable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetTarget(c4058.infilter)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(c4058.indes)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetTarget(c4058.infilter)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetValue(1)
	Duel.RegisterEffect(e3,tp)
	--Destroy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c4058.descon)
	e4:SetOperation(c4058.desop)
	c:RegisterEffect(e4)
end
function c4058.regfilter(c)
	return not c:IsSetCard(0x48)
end
function c4058.regcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(c4058.regfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c4058.infilter(e,c)
	return c:IsSetCard(0x48) and c:IsType(TYPE_MONSTER)
end
function c4058.indes(e,c)
	return not c:IsSetCard(0x48)
end
function c4058.desfilter(c,tp)
	return c:GetPreviousControler()==tp and c:IsReason(REASON_DESTROY) and c:IsSetCard(0x48)
end
function c4058.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c4058.desfilter,1,nil,tp)
end
function c4058.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
