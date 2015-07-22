--トラブル・ダイバー
function c1408.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c1408.spcon)
	e1:SetOperation(c1408.spop)
	c:RegisterEffect(e1)
	--xyzlimit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(c1408.xyzlimit)
	c:RegisterEffect(e2)
end
function c1408.cfilter(c)
	local lv=c:GetLevel()
	return c:IsFacedown() or c:IsFaceup() and not (lv==4)
end
function c1408.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetFlagEffect(tp,1408)==0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		and not Duel.IsExistingMatchingCard(c1408.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c1408.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.RegisterFlagEffect(tp,1408,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function c1408.xyzlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_WARRIOR)
end
