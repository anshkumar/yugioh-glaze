--Ｎｏ．１０１　Ｓ・Ｈ・Ａｒｋ　Ｋｎｉｇｈｔ
function c1047.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.XyzFilterFunction(c,4),2)
	c:EnableReviveLimit()
	--disable attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1047,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c1047.cost)
	e1:SetTarget(c1047.target)
	e1:SetOperation(c1047.operation)
	c:RegisterEffect(e1)
	--destroy replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c1047.reptg)
	c:RegisterEffect(e3)
end
function c1047.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
function c1047.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and bit.band(c:GetSummonType(),SUMMON_TYPE_SPECIAL)==SUMMON_TYPE_SPECIAL
end
function c1047.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c1047.filter(chkc) end
	if chk==0 then return Duel.GetFlagEffect(tp,1047)==0 and Duel.IsExistingTarget(c1047.filter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.SelectTarget(tp,c1047.filter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.RegisterFlagEffect(tp,1047,RESET_PHASE+PHASE_END,0,1)
end
function c1047.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsType(TYPE_TOKEN) then Duel.Destroy(tc,REASON_RULE) return end
	if tc:IsRelateToEffect(e) and tc:IsFaceup()	and c:IsRelateToEffect(e)
	 and c:IsFaceup() and not tc:IsImmuneToEffect(e) then
		local g=nil
		if tc:IsType(TYPE_XYZ) and tc:GetOverlayCount()>0 then 
			g=tc:GetOverlayGroup()
		end
		Duel.Overlay(c,Group.FromCards(tc))	
		if g~=nil then 
			Duel.SendtoGrave(g,REASON_RULE)
		end	
	end
end
function c1047.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	if Duel.SelectYesNo(tp,aux.Stringid(1047,1)) then
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	else return false end
end