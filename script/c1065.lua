--コアキメイルの金剛核
function c1065.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c1065.target)
	e1:SetOperation(c1065.activate)
	c:RegisterEffect(e1)
        --
        local e2=Effect.CreateEffect(c)
        e2:SetDescription(aux.Stringid(1065,0))
        e2:SetCategory(CATEGORY_DISABLE)
        e2:SetType(EFFECT_TYPE_IGNITION)
        e2:SetRange(LOCATION_GRAVE)
        e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetCondition(c1065.datcon)
        e2:SetCost(c1065.cost)
        e2:SetOperation(c1065.activate2)
        c:RegisterEffect(e2)
end
function c1065.cost(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
        Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c1065.datcon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
	and Duel.GetTurnPlayer()==tp
end
function c1065.activate2(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetTarget(c1065.tg)
	e1:SetCountLimit(999)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_DRAW)
	e1:SetValue(1)
	Duel.RegisterEffect(e1,tp)
end
function c1065.tg(e,c)
	return c:IsSetCard(0x1d) and not c:IsImmuneToEffect(e)
end
function c1065.filter(c)
	return c:IsSetCard(0x1d) and c:IsAbleToHand() and not c:IsCode(1065) 
end
function c1065.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c1065.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c1065.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c1065.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
