--森羅の賢樹 シャーマン
function c1021.initial_effect(c)
		--spsummon
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(1021,0))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		e1:SetCode(EVENT_TO_GRAVE)
		e1:SetRange(LOCATION_HAND)
		e1:SetCondition(c1021.spcon)
		e1:SetTarget(c1021.sptg)
		e1:SetOperation(c1021.spop)
		c:RegisterEffect(e1)
        --deck check
        local e2=Effect.CreateEffect(c)
        e2:SetDescription(aux.Stringid(1021,1))
        e2:SetType(EFFECT_TYPE_IGNITION)
        e2:SetRange(LOCATION_MZONE)
        e2:SetCountLimit(1)
        e2:SetTarget(c1021.target)
        e2:SetOperation(c1021.operation)
        c:RegisterEffect(e2)
        --sort decktop
        local e3=Effect.CreateEffect(c)
		e3:SetCategory(CATEGORY_TOHAND)
        e3:SetDescription(aux.Stringid(1021,2))
        e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
        e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_CHAIN_UNIQUE)
		e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e3:SetCode(EVENT_TO_GRAVE)
        e3:SetCondition(c1021.sdcon)
		e3:SetTarget(c1021.sdtg)
        e3:SetOperation(c1021.sdop)
        c:RegisterEffect(e3)
end
function c1021.cfilter(c,tp)
	return c:GetPreviousControler()==tp	and c:IsSetCard(0x90) and c:IsType(TYPE_MONSTER)
end
function c1021.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c1021.cfilter,1,nil,tp)
end
function c1021.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c1021.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c1021.target(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
end
function c1021.operation(e,tp,eg,ep,ev,re,r,rp)
        if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
        Duel.ConfirmDecktop(tp,1)
        local g=Duel.GetDecktopGroup(tp,1)
        local tc=g:GetFirst()
        if tc:IsRace(RACE_PLANT) then
                Duel.DisableShuffleCheck()
                Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
                Duel.Draw(tp,1,REASON_EFFECT)
        else
                Duel.MoveSequence(tc,1)
        end
end
function c1021.sdcon(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        return c:IsPreviousLocation(LOCATION_DECK) and
                (c:IsReason(REASON_REVEAL) or c:IsPreviousPosition(POS_FACEUP) or Duel.IsPlayerAffectedByEffect(tp,EFFECT_REVERSE_DECK))
end
function c1021.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x90) and c:IsAbleToHand()
end
function c1021.sdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c1021.filter(chkc) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c1021.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
function c1021.sdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
