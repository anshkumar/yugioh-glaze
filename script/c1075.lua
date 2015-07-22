--ヴァンパイア・シフト
function c1075.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CHAIN_UNIQUE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c1075.cost)
	e1:SetCondition(c1075.condition)
	e1:SetTarget(c1075.target)
	e1:SetOperation(c1075.activate)
	c:RegisterEffect(e1)
end
function c1075.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,1075)==0 end
	Duel.RegisterFlagEffect(tp,1075,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function c1075.check(tp)
	local ret=false
	for i=0,4 do
		local tc=Duel.GetFieldCard(tp,LOCATION_MZONE,i)
		if tc then
			if tc:IsFaceup() and tc:GetRace()~=RACE_ZOMBIE then return false
			else return true end
		else ret=true
		end
	end
	return ret
end
function c1075.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldCard(tp,LOCATION_SZONE,5)==nil and c1075.check(tp)
end
function c1075.filter(c,tp)
	return c:IsCode(1064) and c:GetActivateEffect():IsActivatable(tp)
end
function c1075.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c1075.filter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function c1075.spfilter(c,e,tp)
	return c:IsSetCard(0x8d) and c:GetAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c1075.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstMatchingCard(c1075.filter,tp,LOCATION_DECK,0,nil,tp)
	if tc then
		if Duel.GetFieldCard(tp,LOCATION_SZONE,5)~=nil then
			Duel.Destroy(Duel.GetFieldCard(tp,LOCATION_SZONE,5),REASON_RULE)
			Duel.BreakEffect()
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		elseif Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)~=nil
			and Duel.GetFieldCard(1-tp,LOCATION_SZONE,5):IsFaceup() then
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			Duel.Destroy(Duel.GetFieldCard(1-tp,LOCATION_SZONE,5),REASON_RULE)
		else
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
		Duel.RaiseEvent(tc,EVENT_CHAIN_SOLVED,tc:GetActivateEffect(),0,tp,tp,Duel.GetCurrentChain())
		Duel.BreakEffect()
		--
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,c1075.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc2=g:GetFirst()
		if tc2 then
			Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP_DEFENCE)
		end
	end
end
