--パラドックス·フュージョン
function c1091.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c1091.target1)
	e1:SetOperation(c1091.activate1)
	c:RegisterEffect(e1)
end
function c1091.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x88) and c:IsType(TYPE_XYZ) and c:IsAbleToRemove()
	and Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
function c1091.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(c1091.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local gt=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local g=Duel.SelectTarget(tp,c1091.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,gt,gt:GetCount(),0,0)
end
function c1091.activate1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		tc:RegisterFlagEffect(1091,RESET_EVENT+0x1fe0000,0,0)
		local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if g:GetCount()==0 then return end
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,1)
		e1:SetCondition(c1091.indcon)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
		Duel.RegisterEffect(e2,tp)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		Duel.RegisterEffect(e3,tp)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_CHANGE_DAMAGE)
		e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e4:SetTargetRange(1,1)
		e4:SetValue(0)
		e4:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		Duel.RegisterEffect(e4,tp)
		local e6=Effect.CreateEffect(c)
		e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e6:SetCode(EVENT_PHASE+PHASE_END)
		e6:SetCountLimit(1)
		if Duel.GetTurnPlayer()==tp then
			e6:SetLabel(Duel.GetTurnCount()-1)
		else
			e6:SetLabel(Duel.GetTurnCount())
		end
		e6:SetLabelObject(tc)
		e6:SetCondition(c1091.spcon)
		e6:SetCost(c1091.spcost)
		e6:SetTarget(c1091.sptg)
		e6:SetOperation(c1091.spop)
		e6:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		Duel.RegisterEffect(e6,tp)
	end
end
function c1091.indcon(e)
	return Duel.GetFlagEffect(tp,1091)==0
end
function c1091.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local act=e:GetLabel()
	return tc and Duel.GetTurnCount()==act+3 and Duel.GetTurnPlayer()==tp
end
function c1091.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,1091)==0 end
	Duel.RegisterFlagEffect(tp,1091,RESET_PHASE+PHASE_END,0,1)
end
function c1091.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	if chk==0 then return tc:GetFlagEffect(1091)~=0 end
	--tc:CreateEffectRelation(e)
	--Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
function c1091.matfilter(c)
	return c:IsSetCard(0x88) and c:IsType(TYPE_MONSTER) 
end
function c1091.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	--local tc=Duel.GetFirstTarget()
	--if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		local gt=Duel.GetMatchingGroup(c1091.matfilter,tp,LOCATION_GRAVE,0,nil)
		if gt:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local mg=gt:Select(tp,1,1,nil)
			Duel.Overlay(tc,mg)
		end
	end
end