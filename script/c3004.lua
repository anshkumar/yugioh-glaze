--エクシーズ・シフト 
function c3004.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c3004.cost)
	e1:SetTarget(c3004.target)
	e1:SetOperation(c3004.operation)
	c:RegisterEffect(e1)
end
function c3004.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,3004)==0 end
	Duel.RegisterFlagEffect(tp,3004,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function c3004.filter1(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
function c3004.filter2(c,e)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
function c3004.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,70095154)
	 and (Duel.IsExistingMatchingCard(c3004.filter1,tp,LOCATION_DECK,0,1,nil)
	 or Duel.IsExistingMatchingCard(c3004.filter2,tp,LOCATION_GRAVE,0,1,nil,e)) end
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,70095154)
	local sel=0
	local ac=0
	if Duel.IsExistingMatchingCard(c3004.filter1,tp,LOCATION_DECK,0,1,nil) then sel=sel+1 end
	if Duel.IsExistingMatchingCard(c3004.filter2,tp,LOCATION_GRAVE,0,1,nil,e) then sel=sel+2 end
	if sel==1 then
		ac=Duel.SelectOption(tp,aux.Stringid(3004,0))
	elseif sel==2 then
		ac=Duel.SelectOption(tp,aux.Stringid(3004,1))+1
	elseif ct>2 then
		ac=Duel.SelectOption(tp,aux.Stringid(3004,0),aux.Stringid(3004,1),aux.Stringid(3004,2))
	else
		ac=Duel.SelectOption(tp,aux.Stringid(3004,0),aux.Stringid(3004,1))
	end
	e:SetLabel(ac)
	if ac>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g1=Duel.SelectTarget(tp,c3004.filter2,tp,LOCATION_GRAVE,0,1,1,nil,e)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,1,0,0)
	end
	if ac==0 or ac==2 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function c3004.operation(e,tp,eg,ep,ev,re,r,rp)
	local ac=e:GetLabel()
	if ac==0 or ac==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,c3004.filter1,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if ac==1 or ac==2 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
		end
	end
end