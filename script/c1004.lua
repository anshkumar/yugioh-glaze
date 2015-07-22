--防覇龍ヘリオスフィア
function c1004.initial_effect(c)
	--lv change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1004,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c1004.condition)
	e1:SetOperation(c1004.operation)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c1004.atcon)
	c:RegisterEffect(e2)
end
function c1004.atkfilter(c)
	return c:GetLevel()==8 and c:IsRace(RACE_DRAGON)
end
function c1004.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLevel()~=8
	and Duel.IsExistingMatchingCard(c1004.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function c1004.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+RESET_END)
		c:RegisterEffect(e1)
	end
end
function c1004.atcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==1
	and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_HAND)<5
end
