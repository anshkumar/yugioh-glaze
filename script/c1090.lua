--武神決戦
function c1090.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c1090.target)
	e1:SetOperation(c1090.activate)
	c:RegisterEffect(e1)
end
function c1090.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x88)
end
function c1090.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1090.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c1090.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c1090.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function c1090.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		tc:RegisterFlagEffect(1090,RESET_EVENT+0x1620000+RESET_PHASE+PHASE_END,0,1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(aux.Stringid(1090,0))
		e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e2:SetCode(EVENT_BATTLE_DESTROYING)
		e2:SetLabelObject(tc)
		e2:SetCondition(c1090.shcon)
		e2:SetTarget(c1090.shtg)
		e2:SetOperation(c1090.shop)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
end
function c1090.shcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local d=Duel.GetAttackTarget()
	if d==tc then d=Duel.GetAttacker() end
	return eg:IsContains(tc) and tc:GetFlagEffect(1090)~=0
	 and d:GetAttack()>tc:GetBaseAttack()
end
function c1090.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	local d=Duel.GetAttackTarget()
	if d==tc then d=Duel.GetAttacker() end
	if chk==0 then return d:IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,d,1,0,0)
end
function c1090.shfilter(c,code)
	return c:IsCode(code) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function c1090.shop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local d=Duel.GetAttackTarget()
	if d==tc then d=Duel.GetAttacker() end
	if Duel.Remove(d,POS_FACEUP,REASON_EFFECT)==0 then return end
	Duel.BreakEffect()
	local dgc=Duel.GetMatchingGroup(c1090.shfilter,tp,0,0x13+LOCATION_EXTRA,nil,d:GetCode())
	if dgc:GetCount()>0 then
		Duel.Remove(dgc,POS_FACEUP,REASON_EFFECT)
	else
		local dgt=Duel.GetFieldGroup(tp,0,0x13+LOCATION_EXTRA)
		Duel.ConfirmCards(tp,dgt)
		Duel.ShuffleDeck(1-tp)
		Duel.ShuffleHand(1-tp)
	end
end
