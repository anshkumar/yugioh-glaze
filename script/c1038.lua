--騎士デイ・グレファー
function c1038.initial_effect(c)
	aux.EnableDualAttribute(c)
	--to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1038,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCondition(c1038.thcon)
	e1:SetTarget(c1038.thtg)
	e1:SetOperation(c1038.thop)
	c:RegisterEffect(e1)
end
function c1038.cfilter(c)
	return c:IsType(TYPE_EQUIP)
end
function c1038.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp 
		and aux.IsDualState(e) and Duel.IsExistingMatchingCard(c1038.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function c1038.tgfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
function c1038.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetFlagEffect(tp,1038)==0 end
	if chkc then return chkc:GetLocation()==LOCATION_GRAVE and chkc:GetControler()==tp and c1038.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c1038.tgfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c1038.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.RegisterFlagEffect(tp,1038,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function c1038.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
