--Heroic Challenger - Clasp Sword
function c4011.initial_effect(c)
	--tohand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CHAIN_UNIQUE)
	e1:SetCondition(c4011.retcon)
	e1:SetCost(c4011.cost)
	e1:SetTarget(c4011.rettg)
	e1:SetOperation(c4011.retop)
	c:RegisterEffect(e1)
end
function c4011.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,4011)==0 end
	Duel.RegisterFlagEffect(tp,4011,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function c4011.retcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsSetCard(0x6f)
end
function c4011.schfilter(c)
	return c:IsSetCard(0x6f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c4011.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c4011.schfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c4011.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c4011.schfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
