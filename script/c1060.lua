--アーティファクト・ムーブメント
function c1060.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c1060.target)
	e1:SetOperation(c1060.activate)
	c:RegisterEffect(e1)
	--Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c1060.descon)
	e2:SetOperation(c1060.desop)
	c:RegisterEffect(e2)
end
function c1060.filter(c)
	return c:IsDestructable() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c1060.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c1060.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c1060.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
		and Duel.IsExistingTarget(c1060.desfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,c1060.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c1060.desfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x97)
end
function c1060.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local dgc=Duel.GetMatchingGroup(c1060.desfilter,tp,LOCATION_DECK,0,nil)
	if dgc:GetCount()==0 or Duel.GetLocationCount(tp,LOCATION_SZONE)<0 or not tc:IsRelateToEffect(e) then return end
	if Duel.Destroy(tc,REASON_EFFECT)==0 then return end
	if dgc:GetCount()>0 then
		local dgcd=dgc:Filter(Card.IsSSetable,nil)
		if dgcd:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local dt=dgcd:Select(tp,1,1,nil)
			Duel.SSet(tp,dt:GetFirst())
			Duel.ConfirmCards(1-tp,dt:GetFirst())
		end
	else
		local dgt=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
		Duel.ConfirmCards(1-tp,dgt)
		Duel.ShuffleDeck(tp)
	end
end
function c1060.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp~=tp and c:IsReason(REASON_DESTROY) and c:GetPreviousControler()==tp
end
function c1060.desop(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	if (Duel.GetTurnPlayer()==1-tp 
	and (phase==PHASE_DRAW or phase==PHASE_STANDBY or phase==PHASE_MAIN1))
	 or Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	else
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c1060.skipcon)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	end
	Duel.RegisterEffect(e1,tp)
end
function c1060.skipcon(e)
	return Duel.GetTurnCount()~=e:GetLabel()
end
