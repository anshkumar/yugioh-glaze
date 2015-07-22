--森羅の仙樹 レギア
function c1020.initial_effect(c)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c1020.target)
	e1:SetOperation(c1020.operation)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c1020.condtion)
	e2:SetTarget(c1020.tg)
	e2:SetOperation(c1020.activate)
	c:RegisterEffect(e2)
end
function c1020.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
end
function c1020.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	Duel.ConfirmDecktop(tp,1)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsRace(RACE_PLANT) then	
		Duel.DisableShuffleCheck()
		Duel.SendtoGrave(tc,REASON_EFFECT)
		Duel.Draw(tp,1,REASON_EFFECT)		
	else
		Duel.DisableShuffleCheck()
		Duel.MoveSequence(tc,1)
	end
end
function c1020.condtion(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local code=re:GetHandler():GetCode()
	return c:GetPreviousLocation()==LOCATION_DECK and c:IsReason(REASON_EFFECT)
		and (code==63942761 or code==58577036 or code==18631392 or code==79106360 or code==32362575 or code==43040603 or code==22796548 or code==1020 or code==1015 or code==1052)
end
function c1020.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
end
function c1020.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.SortDecktop(tp,tp,3)
end
