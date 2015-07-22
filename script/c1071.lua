--ナンバーズ・オーバーレイ・ブースト
function c1071.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c1071.mattg)
	e1:SetOperation(c1071.matop)
	c:RegisterEffect(e1)
end
function c1071.xyzfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) and c:GetOverlayCount()==0
end
function c1071.matfilter(c)
	return c:IsType(TYPE_MONSTER)
end
function c1071.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c1071.xyzfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c1071.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(c1071.matfilter,tp,LOCATION_HAND,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c9105.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c1071.matop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local g=Duel.SelectMatchingCard(tp,c1071.matfilter,tp,LOCATION_HAND,0,2,2,nil)
		if g:GetCount()>0 then
			Duel.Overlay(tc,g)
		end
	end
end
