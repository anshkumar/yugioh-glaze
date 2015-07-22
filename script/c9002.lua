--極夜の騎士ガイア
function c9002.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9002,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_TOHAND+CATEGORY_TOGRAVE+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c9002.cost1)
	e1:SetTarget(c9002.target1)
	e1:SetOperation(c9002.operation1)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9002,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c9002.cost2)
	e2:SetTarget(c9002.target2)
	e2:SetOperation(c9002.operation2)
	c:RegisterEffect(e2)
end
function c9002.costfilter1(c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
function c9002.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c9002.costfilter1,1,e:GetHandler()) and Duel.GetFlagEffect(tp,9006)==0 end
	local sg=Duel.SelectReleaseGroup(tp,c9002.costfilter1,1,1,e:GetHandler())
	Duel.Release(sg,REASON_COST)
	Duel.RegisterFlagEffect(tp,9006,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function c9002.filter1(c)
	return c:GetLevel()==4 and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
function c9002.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c9002.filter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,1)
end
function c9002.operation1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c9002.filter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()==0 then return end
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	Duel.BreakEffect()
	Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT)
end
function c9002.costfilter2(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
function c9002.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c9002.costfilter2,tp,LOCATION_GRAVE,0,1,nil) and Duel.GetFlagEffect(tp,9007)==0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c9002.costfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	Duel.RegisterFlagEffect(tp,9007,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function c9002.filter2(c)
	return c:IsFaceup()
end
function c9002.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c9002.filter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c9002.filter2,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c9002.filter2,tp,LOCATION_MZONE,0,1,1,nil)
end
function c9002.operation2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,2)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
	end
end
