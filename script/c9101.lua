--SNo.39 希望皇ホープONE
function c9101.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.XyzFilterFunctionF(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),4),3,c9101.ovfilter,aux.Stringid(9101,1))
	c:EnableReviveLimit()
	--attack up
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(9101,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c9101.condition)
	e1:SetCost(c9101.cost)
	e1:SetTarget(c9101.target)
	e1:SetOperation(c9101.operation)
	c:RegisterEffect(e1)
end
function c9101.ovfilter(c)
	return c:IsFaceup() and c:IsCode(84013237)
end
function c9101.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)+3000<=Duel.GetLP(1-tp)
end
function c9101.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLP(tp)>10 and e:GetHandler():CheckRemoveOverlayCard(tp,3,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,3,3,REASON_COST)
	local lp=Duel.GetLP(tp)
	Duel.PayLPCost(tp,lp-10)
end
function c9101.filter(c)
	return bit.band(c:GetSummonType(),SUMMON_TYPE_SPECIAL)==SUMMON_TYPE_SPECIAL and c:IsDestructable()
end
function c9101.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c9101.filter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(c9101.filter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function c9101.operation(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(c9101.filter,tp,0,LOCATION_MZONE,nil)
	local ct=Duel.Destroy(sg,REASON_EFFECT,LOCATION_REMOVED)
	if ct>0 then
		Duel.Damage(1-tp,ct*300,REASON_EFFECT)
	end
end

