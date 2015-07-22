
function c3010.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c3010.cost)
	e1:SetOperation(c3010.activate)
	c:RegisterEffect(e1)
end
function c3010.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,3010)==0 end
	Duel.PayLPCost(tp,Duel.GetLP(tp)/2)
	Duel.RegisterFlagEffect(tp,3010,RESET_PHASE+PHASE_END,0,1)
end
function c3010.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(3010,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHAIN_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c3010.chain_target)
	e1:SetOperation(c3010.chain_operation)
	e1:SetValue(aux.TRUE)
	Duel.RegisterEffect(e1,tp)
end
function c3010.filter(c,e)
	return c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
function c3010.chain_target(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(c3010.filter,eg,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0,nil,tp)
end
function c3010.chain_operation(e,te,tp,tc,mat,sumtype)
	if not sumtype then sumtype=SUMMON_TYPE_FUSION end
	tc:SetMaterial(mat)
	Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.BreakEffect()
	Duel.SpecialSummon(tc,sumtype,tp,tp,false,false,POS_FACEUP)
	tc:RegisterFlagEffect(3010,RESET_EVENT+0x1fc0000+RESET_PHASE+RESET_END,0,1)
end