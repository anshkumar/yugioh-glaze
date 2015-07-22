--除雪機関車ハッスル・ラッセル
function c3401.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3401,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c3401.spcon)
	e1:SetOperation(c3401.spop)
	c:RegisterEffect(e1)
	--disable spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c3401.sumlimit)
	c:RegisterEffect(e2)
end
function c3401.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
	and Duel.IsExistingMatchingCard(c3401.filter,tp,LOCATION_SZONE,0,1,nil)
end
function c3401.filter(c)
	return c:GetSequence()~=5 and c:IsDestructable()
end
function c3401.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP) then
		local sg=Duel.GetMatchingGroup(c3401.filter,tp,LOCATION_SZONE,0,nil)
		if sg:GetCount()==0 then return end
		Duel.BreakEffect()
		if Duel.Destroy(sg,REASON_EFFECT)>0 then
			Duel.Damage(1-tp,sg:GetCount()*200,REASON_EFFECT)
		end		 
	end
end
function c3401.sumlimit(e,c)
	return not c:IsRace(RACE_MACHINE)
end