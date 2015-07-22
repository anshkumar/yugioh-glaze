--ＲＵＭ－七皇の剣
function c1058.initial_effect(c)
	--recover
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1058,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DRAW)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1)
	e1:SetCondition(c1058.reccon)
	e1:SetOperation(c1058.recop)
	c:RegisterEffect(e1)
	--Activate
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetTarget(c1058.target)
	e2:SetOperation(c1058.activate)
	c:RegisterEffect(e2)
end
function c1058.reccon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and r==REASON_RULE and eg:GetFirst()==e:GetHandler()
end
function c1058.recop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp,aux.Stringid(1058,1)) then
		Duel.ConfirmCards(1-tp,e:GetHandler())
		Duel.Hint(HINT_MESSAGE,1-tp,aux.Stringid(1058,2))
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PUBLIC)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		e:GetHandler():RegisterEffect(e1)
		Duel.RegisterFlagEffect(tp,1059,RESET_PHASE+PHASE_END,0,1)
	end
end
function c1058.filter1(c,e,tp)
	local code=c:GetCode()
	return ((c:GetLocation()==LOCATION_EXTRA or c:GetLocation()==LOCATION_GRAVE) and c:IsCanBeSpecialSummoned(e,0,tp,true,false))
	 and Duel.IsExistingMatchingCard(c1058.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,code)
end
function c1058.filter2(c,e,tp,code1)
	local code2=0
	if code1==48739166 then code2=12744567 end
	if code1==49678559 then code2=1044 end
	if code1==1042 then code2=1043 end
	if code1==2061963 then code2=49456901 end
	if code1==59627393 then code2=85121942 end
	if code1==63746411 then code2=55888045 end
	if code1==88177324 then code2=1041 end
	if code2==0 then return false end
	return c:IsCode(code2) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function c1058.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,1058)==0 and Duel.GetFlagEffect(tp,1059)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	 and Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity() and Duel.IsExistingTarget(c1058.filter1,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.RegisterFlagEffect(tp,1058,0,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c1058.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,c1058.filter1,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c1058.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetCode())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			Duel.Overlay(sc,mg)
		end
		Duel.Overlay(sc,Group.FromCards(tc))
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
