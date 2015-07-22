--オノマト連攜
function c1067.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c1067.cost)
	e1:SetTarget(c1067.target)
	e1:SetOperation(c1067.activate)
	c:RegisterEffect(e1)
end
function c1067.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,1067)==0 and
	Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
	Duel.RegisterFlagEffect(tp,1067,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function c1067.filter(c)
	return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0x54) or c:IsSetCard(0x59) or c:IsSetCard(0x82) or c:IsSetCard(0x92))  and c:IsAbleToHand()
end
function c1067.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c1067.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c1067.refilter(c,cd,cod)
	return c==cd and c:IsSetCard(cod)
end
function c1067.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c1067.filter,tp,LOCATION_DECK,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1=g:Select(tp,1,1,nil)
	local sc=0
	local cod=nil
	while sc<4 do
		if(sc==0)then cod=0x54 end
		if(sc==1)then cod=0x59 end
		if(sc==2)then cod=0x82 end
		if(sc==3)then cod=0x92 end
		if	g:IsExists(c1067.refilter,1,nil,g1:GetFirst(),cod) then
			g:Remove(Card.IsSetCard,nil,cod)
		end
		sc=sc+1
	end
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(1067,0)) then
		local g2=g:Select(tp,1,1,nil)
		g1:Merge(g2)
	end
	Duel.SendtoHand(g1,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g1)
end
