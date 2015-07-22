--古代の機械箱
function c1032.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1032,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCondition(c1032.spcon)
	e1:SetCost(c1032.spcost)
	e1:SetTarget(c1032.sptg)
	e1:SetOperation(c1032.spop)
	c:RegisterEffect(e1)
end
function c1032.cfilter(c,e)
	return (c:IsPreviousLocation(LOCATION_DECK) or c:IsPreviousLocation(LOCATION_GRAVE))
		and c==e:GetHandler() and not c:IsReason(REASON_DRAW)
end
function c1032.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c1032.cfilter,1,nil,e)
end
function c1032.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,1032)==0 end
	Duel.RegisterFlagEffect(tp,1032,RESET_PHASE+PHASE_END,0,1)
end
function c1032.filter(c)
        return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) 
		 and (c:GetAttack()==500 or c:GetDefence()==500) and c:IsAbleToHand()
end
function c1032.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c1032.filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c1032.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c1032.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
       Duel.SendtoHand(g,nil,REASON_EFFECT)
       Duel.ConfirmCards(1-tp,g)
	end
end
