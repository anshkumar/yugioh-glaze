--ドラゴン・目覚めの旋律
function c3013.initial_effect(c)
   --Activate
   local e1=Effect.CreateEffect(c)
   e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
   e1:SetType(EFFECT_TYPE_ACTIVATE)
   e1:SetCode(EVENT_FREE_CHAIN)
   e1:SetCost(c3013.cost)
   e1:SetTarget(c3013.target)
   e1:SetOperation(c3013.activate)
   c:RegisterEffect(e1)
end
function c3013.cost(e,tp,eg,ep,ev,re,r,rp,chk)
   if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
   Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
function c3013.filter(c)
   return c:IsRace(RACE_DRAGON) and c:GetAttack()>=3000 and c:GetDefence()<=2500 and c:IsAbleToHand()
end
function c3013.target(e,tp,eg,ep,ev,re,r,rp,chk)
   if chk==0 then return Duel.IsExistingMatchingCard(c3013.filter,tp,LOCATION_DECK,0,1,nil) end
   Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c3013.activate(e,tp,eg,ep,ev,re,r,rp)
   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c3013.filter,tp,LOCATION_DECK,0,1,2,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end     
end