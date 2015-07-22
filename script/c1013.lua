--アーティファクトーフェイルノート
function c1013.initial_effect(c)
	--set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1013,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c1013.spcon)
	e2:SetTarget(c1013.sptg)
	e2:SetOperation(c1013.spop)
	c:RegisterEffect(e2)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1013,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c1013.descon)
	e3:SetTarget(c1013.destg)
	e3:SetOperation(c1013.desop)
	c:RegisterEffect(e3)
end
function c1013.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return 	c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN) 
		and c:IsReason(REASON_DESTROY) and Duel.GetTurnPlayer()~=tp
end
function c1013.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c1013.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then 
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
function c1013.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function c1013.desfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x97) and c:IsSSetable() 
end
function c1013.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	and Duel.IsExistingMatchingCard(c1013.desfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function c1013.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local dg=Duel.SelectMatchingCard(tp,c1013.desfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if dg:GetCount()>0 then
		Duel.SSet(tp,dg:GetFirst())
		Duel.ConfirmCards(1-tp,dg:GetFirst())
	end
end