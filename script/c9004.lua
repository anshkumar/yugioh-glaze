--混沌の種
function c9004.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c9004.cost)
	e1:SetCondition(c9004.spcon)
	e1:SetTarget(c9004.target)
	e1:SetOperation(c9004.activate)
	c:RegisterEffect(e1)
end
function c9004.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,9004)==0 end
	Duel.RegisterFlagEffect(tp,9004,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function c9004.filter1(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function c9004.filter2(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
function c9004.spcon(e,c)
	return Duel.IsExistingMatchingCard(c9004.filter1,0,LOCATION_MZONE,0,1,nil)
	and Duel.IsExistingMatchingCard(c9004.filter2,0,LOCATION_MZONE,0,1,nil)
end
function c9004.filter(c)
	return c:IsFaceup() and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK)) and c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
function c9004.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c9004.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c9004.filter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c9004.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c9004.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
