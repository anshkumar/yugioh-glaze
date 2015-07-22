--明と宵の逆転
function c9005.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CHAIN_UNIQUE)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c9005.cost2)
	e1:SetTarget(c9005.target2)
	e1:SetOperation(c9005.activate)
	c:RegisterEffect(e1)
	--instant
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CHAIN_UNIQUE)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCost(c9005.cost)
	e2:SetTarget(c9005.target)
	e2:SetOperation(c9005.activate)
	c:RegisterEffect(e2)
end
function c9005.afilter1(c,e,tp)
	local lv=c:GetLevel()
	return Duel.IsExistingMatchingCard(c9005.afilter2,tp,LOCATION_DECK,0,1,nil,lv)
	and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function c9005.afilter2(c,lv)
	return c:GetLevel()==lv
	and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_DARK)
end
function c9005.bfilter1(c,e,tp)
	local lv=c:GetLevel()
	return Duel.IsExistingMatchingCard(c9005.bfilter2,tp,LOCATION_DECK,0,1,nil,lv)
	and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_DARK)
end
function c9005.bfilter2(c,lv)
	return c:GetLevel()==lv
	and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function c9005.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,9005)==0 end
	Duel.RegisterFlagEffect(tp,9005,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function c9005.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c9005.afilter1,tp,LOCATION_HAND,0,1,nil) or Duel.IsExistingMatchingCard(c9005.bfilter1,tp,LOCATION_HAND,0,1,nil) end
	if Duel.IsExistingMatchingCard(c9005.afilter1,tp,LOCATION_HAND,0,1,nil)
	and Duel.IsExistingMatchingCard(c9005.bfilter1,tp,LOCATION_HAND,0,1,nil) then
		op=Duel.SelectOption(tp,aux.Stringid(9005,1),aux.Stringid(9005,2))+1
	elseif Duel.IsExistingMatchingCard(c9005.afilter1,tp,LOCATION_HAND,0,1,nil) then
		op=Duel.SelectOption(tp,aux.Stringid(9005,1))+1
	elseif Duel.IsExistingMatchingCard(c9005.bfilter1,tp,LOCATION_HAND,0,1,nil) then
		op=Duel.SelectOption(tp,aux.Stringid(9005,2))+2
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	e:SetLabel(op)
end
function c9005.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local g=Duel.SelectMatchingCard(tp,c9005.afilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()==0 then return end
		local tc=g:GetFirst()
		Duel.SendtoGrave(tc,POS_FACEUP,REASON_EFFECT)
		Duel.BreakEffect()
		--
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local ag=Duel.SelectMatchingCard(tp,c9005.afilter2,tp,LOCATION_DECK,0,1,1,nil,tc:GetLevel())
		Duel.SendtoHand(ag,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,ag)
	elseif e:GetLabel()==2 then
		local g=Duel.SelectMatchingCard(tp,c9005.bfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()==0 then return end
		local tc=g:GetFirst()
		Duel.SendtoGrave(tc,POS_FACEUP,REASON_EFFECT)
		Duel.BreakEffect()
		--
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local ag=Duel.SelectMatchingCard(tp,c9005.bfilter2,tp,LOCATION_DECK,0,1,1,nil,tc:GetLevel())
		Duel.SendtoHand(ag,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,ag)
	end
end
function c9005.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(0)
	if Duel.GetFlagEffect(tp,9005)==0
	and (Duel.IsExistingMatchingCard(c9005.afilter1,tp,LOCATION_HAND,0,1,nil)
	or Duel.IsExistingMatchingCard(c9005.bfilter1,tp,LOCATION_HAND,0,1,nil)) then
		if Duel.SelectYesNo(tp,aux.Stringid(9005,0)) then
			Duel.RegisterFlagEffect(tp,9005,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
			e:SetLabel(1)
		end
	end
end
function c9005.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:GetLabel()~=1 then return end
	if Duel.IsExistingMatchingCard(c9005.afilter1,tp,LOCATION_HAND,0,1,nil)
	and Duel.IsExistingMatchingCard(c9005.bfilter1,tp,LOCATION_HAND,0,1,nil) then
		op=Duel.SelectOption(tp,aux.Stringid(9005,1),aux.Stringid(9005,2))+1
	elseif Duel.IsExistingMatchingCard(c9005.afilter1,tp,LOCATION_HAND,0,1,nil) then
		op=Duel.SelectOption(tp,aux.Stringid(9005,1))+1
	elseif Duel.IsExistingMatchingCard(c9005.bfilter1,tp,LOCATION_HAND,0,1,nil) then
		op=Duel.SelectOption(tp,aux.Stringid(9005,2))+2
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	e:SetLabel(op)
end
