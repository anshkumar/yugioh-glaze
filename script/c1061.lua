--ヴァンパイア帝国
function c1061.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--ad up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE_CALCULATING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c1061.atkup)
	c:RegisterEffect(e2)
	--discard deck
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CHAIN_UNIQUE+EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c1061.descon)
	e3:SetCost(c1061.cost)
	e3:SetTarget(c1061.destg)
	e3:SetOperation(c1061.desop)
	c:RegisterEffect(e3)
end
function c1061.atkup(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	c1061.adup(a,e:GetHandler())
	if d then c1061.adup(d,e:GetHandler()) end
end
function c1061.adup(c,oc)
	if not c:IsRace(RACE_ZOMBIE) then return end
	local e1=Effect.CreateEffect(oc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_PHASE+RESET_DAMAGE_CAL)
	e1:SetValue(500)
	c:RegisterEffect(e1)
end
function c1061.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,1061)==0 end
	Duel.RegisterFlagEffect(tp,1061,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function c1061.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_DECK) and c:GetPreviousControler()==tp
end
function c1061.descon(e,tp,eg,ep,ev,re,r,rp)
	return re and eg:IsExists(c1061.cfilter,1,nil,1-tp)
end
function c1061.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsSetCard(0x8d) and c:IsAbleToGrave()
end
function c1061.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsOnField() and chkc:IsDestructable() end
	if chk==0 then return Duel.IsExistingMatchingCard(c1061.costfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
	and Duel.IsExistingTarget(Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,0,1,0,0)
end
function c1061.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,c1061.costfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g1,POS_FACEUP,REASON_EFFECT)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=Duel.SelectTarget(tp,Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	local tc=g2:GetFirst()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
