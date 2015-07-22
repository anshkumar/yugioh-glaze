--虚構王アンフォームド・ボイド
function c5041.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.XyzFilterFunction(c,4),3)
	c:EnableReviveLimit()
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c5041.condition)
	e1:SetCost(c5041.atkcost)
	e1:SetOperation(c5041.atkop)
	c:RegisterEffect(e1)
end
function c5041.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c5041.filter,tp,0,LOCATION_MZONE,nil)
	return Duel.GetTurnPlayer()==1-tp and Duel.GetCurrentPhase()==PHASE_MAIN1 and g:GetCount()>0
end
function c5041.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c5041.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetAttack()>0
end
function c5041.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c5041.filter,tp,0,LOCATION_MZONE,nil)
	local sc=g:GetFirst()
	local atk=0
	while sc do
		local catk=sc:GetAttack()
		if catk<0 then catk=0 end
		atk=atk+catk
		sc=g:GetNext()
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	e1:SetValue(atk)
	c:RegisterEffect(e1)
end
