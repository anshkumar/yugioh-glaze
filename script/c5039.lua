--フォトン・アレキサンドラ・クィーン
function c5039.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,c5039.xyzfilter,2)
	c:EnableReviveLimit()	
	--damage
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c5039.cost)
	e1:SetTarget(c5039.target)
	e1:SetOperation(c5039.activate)
	c:RegisterEffect(e1)
end
function c5039.xyzfilter(c)
	return c:IsSetCard(0x6a) and c:GetLevel()==4
end
function c5039.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c5039.thfilter(c)
	return c:IsAbleToHand()
end
function c5039.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c5039.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function c5039.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(c5039.thfilter,tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(c5039.thfilter,tp,0,LOCATION_MZONE,nil)
	local thc1=0
	local thc2=0
	local sc1=g1:GetFirst()
	while sc1 do
		Duel.SendtoHand(sc1,nil,REASON_EFFECT)
		if sc1:GetLocation()==LOCATION_HAND and sc1:GetControler()==tp then thc1=thc1+1 end
		if sc1:GetLocation()==LOCATION_HAND and sc1:GetControler()==1-tp then thc2=thc2+1 end
		sc1=g1:GetNext()
	end
	local sc2=g2:GetFirst()
	while sc2 do
		Duel.SendtoHand(sc2,nil,REASON_EFFECT)
		if sc2:GetLocation()==LOCATION_HAND and sc2:GetControler()==tp then thc1=thc1+1 end
		if sc2:GetLocation()==LOCATION_HAND and sc2:GetControler()==1-tp then thc2=thc2+1 end
		sc2=g2:GetNext()
	end
	Duel.BreakEffect()
	Duel.Damage(tp,thc1*300,REASON_EFFECT)
	Duel.Damage(1-tp,thc2*300,REASON_EFFECT)
end
