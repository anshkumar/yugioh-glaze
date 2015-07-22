--青き眼の乙女
function c2505.initial_effect(c)
	--pos change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2505,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCost(c2505.cost)
	e1:SetOperation(c2505.posop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2505,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c2505.tgcon)
	e2:SetCost(c2505.cost)
	e2:SetOperation(c2505.tgop)
	c:RegisterEffect(e2)
end
function c2505.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,2505)==0 end
	Duel.RegisterFlagEffect(tp,2505,RESET_PHASE+PHASE_END,0,1)
end
function c2505.filter(c,e,tp)
	return c:IsCode(89631139) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c2505.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		Duel.NegateAttack()
		if Duel.ChangePosition(c,POS_FACEUP_DEFENCE,0,POS_FACEUP_ATTACK,0)
			and Duel.SelectYesNo(tp,aux.Stringid(2505,1)) then
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
				and Duel.IsExistingTarget(c2505.filter,tp,0x13,0,1,nil,e,tp) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local g=Duel.SelectMatchingCard(tp,c2505.filter,tp,0x13,0,1,1,nil,e,tp)
				if g:GetCount()>0 then
					Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end
function c2505.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg:IsContains(c) and Duel.IsExistingTarget(c2505.filter,tp,0x13,0,1,nil,e,tp)
end
function c2505.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingTarget(c2505.filter,tp,0x13,0,1,nil,e,tp) then
			local g=Duel.SelectMatchingCard(tp,c2505.filter,tp,0x13,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
