--Noble Knight Bedwyr
function c999.initial_effect(c)
	--Normal monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c999.eqcon1)
	e1:SetValue(TYPE_NORMAL+TYPE_MONSTER)
	c:RegisterEffect(e1)
	--tohand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(999,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,999)
	e2:SetCondition(c999.thcon)
	e2:SetTarget(c999.thtg)
	e2:SetOperation(c999.thop)
	c:RegisterEffect(e2)
end
function c999.eqcon1(e)
	local eg=e:GetHandler():GetEquipGroup()
	return not eg or not eg:IsExists(Card.IsSetCard,1,nil,0x207a)
end
function c999.eqcon2(e)
	local eg=e:GetHandler():GetEquipGroup()
	return eg and eg:IsExists(Card.IsSetCard,1,nil,0x207a)
end
function c999.thcon(e,tp,eg,ep,ev,re,r,rp)
	return c13391185.eqcon2(e)
end
function c999.thfilter(c)
	return( c:IsSetCard(0x107a) or c:IsSetCard(0x207a) ) and c:IsAbleToHand()
end
function c999.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c999.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c999.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c999.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c999.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x207a) and c:IsType(TYPE_EQUIP) and c:IsDestructable()
end
function c999.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,c999.desfilter,tp,LOCATION_SZONE,0,1,1,nil)
		Duel.BreakEffect()
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
