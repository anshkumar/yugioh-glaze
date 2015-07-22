--Gwenhwyfar, Queen of Noble Arms
function c4086.initial_effect(c)
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4086,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(c4086.eqcon)
	e1:SetCost(c4086.cost)
	e1:SetTarget(c4086.eqtg)
	e1:SetOperation(c4086.eqop)
	c:RegisterEffect(e1)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	--destroy sub
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetCondition(c4086.repcon)
	e4:SetTarget(c4086.reptg)
	e4:SetOperation(c4086.repop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)	
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BATTLE_START)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(c4086.descon)
	e5:SetTarget(c4086.destg)
	e5:SetOperation(c4086.desop)
	c:RegisterEffect(e5)
end
function c4086.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,4086)==0 end
	Duel.RegisterFlagEffect(tp,4086,RESET_PHASE+PHASE_END,0,1)
end
function c4086.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():CheckUniqueOnField(tp)
end
function c4086.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107a)
end
function c4086.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c4086.filter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(c4086.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,c4086.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c4086.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:GetControler()~=tp or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	Duel.Equip(tp,c,tc,true)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	e1:SetValue(c4086.eqlimit)
	c:RegisterEffect(e1)
end
function c4086.eqlimit(e,c)
	return c:IsSetCard(0x107a)
end
function c4086.repcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler():GetEquipTarget()
	return c:IsAttribute(ATTRIBUTE_LIGHT)
	and (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c)
end
function c4086.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipTarget():IsReason(REASON_EFFECT)
		and not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED) end
	if Duel.SelectYesNo(tp,aux.Stringid(4086,1)) then
		e:GetHandler():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
function c4086.repop(e,tp,eg,ep,ev,re,r,rp,chk)
	e:GetHandler():SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
function c4086.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler():GetEquipTarget()
	return c:IsAttribute(ATTRIBUTE_DARK)
	and (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c)
end
function c4086.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler():GetEquipTarget()
	local tc=Duel.GetAttacker()
	if tc==c then tc=Duel.GetAttackTarget() end
	if chk==0 then return tc and tc:IsFaceup() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
function c4086.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	local c=e:GetHandler():GetEquipTarget()
	g:AddCard(e:GetHandler())
	local tc=Duel.GetAttacker()
	if tc==c then tc=Duel.GetAttackTarget() end
	g:AddCard(tc)
	if tc:IsRelateToBattle() then Duel.Destroy(g,REASON_EFFECT) end
end


