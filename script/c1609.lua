--CNo.6 先史遺産－カオス・アトランタル
function c1609.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.XyzFilterFunction(c,7),3)
	c:EnableReviveLimit()
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1609,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c1609.eqtg)
	e1:SetOperation(c1609.eqop)
	c:RegisterEffect(e1)
	--life 1
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(550000000,2))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(c1609.discon)
	e2:SetCost(c1609.lifcos)
	e2:SetOperation(c1609.lifop)
	c:RegisterEffect(e2)
end
function c1609.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c1609.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function c1609.eqlimit(e,c)
	return e:GetOwner()==c
end
function c1609.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			Duel.Equip(tp,tc,c,false,true)
			--Add Equip limit
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+0x1fe0000)
			e1:SetValue(c1609.eqlimit)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+0x1fe0000)
			e2:SetValue(1000)
			tc:RegisterEffect(e2)
			Duel.EquipComplete()
			tc:RegisterFlagEffect(1609,RESET_EVENT+0x1fe0000,0,1)
		else Duel.SendtoGrave(tc,REASON_EFFECT) end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c1609.discon(e,tp,eg,ep,ev,re,r,rp)
        return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,9161357)
end
function c1609.filter(c)
	return c:IsSetCard(0x48) and c:IsAbleToGraveAsCost() and c:GetFlagEffect(1609)~=0
end
function c1609.lifcos(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,3,REASON_COST) 
	and e:GetHandler():GetEquipGroup():IsExists(c1609.filter,1,nil) end
	e:GetHandler():RemoveOverlayCard(tp,3,3,REASON_COST)
	local g=e:GetHandler():GetEquipGroup():Filter(c1609.filter,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function c1609.lifop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetLP(1-tp,100)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end