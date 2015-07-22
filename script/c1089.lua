--Noble Knight Drystan
function c1089.initial_effect(c)
	--at limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetTarget(c1089.limit)
	e1:SetCondition(c1089.condition)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--cannot be target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c1089.limit)
	e2:SetCondition(c1089.condition)
	e2:SetValue(c1089.tg)
	c:RegisterEffect(e2)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1089,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_EQUIP)
	e3:SetCost(c1089.descost)
	e3:SetTarget(c1089.destg)
	e3:SetOperation(c1089.desop)
	c:RegisterEffect(e3)
end
function c1089.limit(e,c)
	return c~=e:GetHandler() and c:IsAttackBelow(1800) and c:IsFaceup()
end
function c1089.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107a)
end
function c1089.condition(e)
	return Duel.IsExistingMatchingCard(c1089.filter,0,LOCATION_MZONE,0,1,e:GetHandler())
end
function c1089.tg(e,re,rp)
	return rp~=e:GetHandlerPlayer()
end
function c1089.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,1089)==0 end
	Duel.RegisterFlagEffect(tp,1089,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function c1089.desfilter1(c,ec)
	return c:GetEquipTarget()==ec and c:IsSetCard(0x207a)
end
function c1089.desfilter2(c)
	return c:IsFaceup() and c:IsDestructable()
end
function c1089.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return eg:IsExists(c1089.desfilter1,1,nil,e:GetHandler()) end
	if chkc then return chkc:IsOnField() and c1089.desfilter2(chkc) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,c1089.desfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function c1089.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
