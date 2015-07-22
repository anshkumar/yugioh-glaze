function c998.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCondition(c998.con)
  e1:SetCountLimit(1,998)
	e1:SetTarget(c998.target)
	e1:SetOperation(c998.operation)
	c:RegisterEffect(e1)
end
function c998.con(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
function c998.filter(c,e,tp)
	return c:IsSetCard(0x107A) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) 
  and Duel.IsExistingMatchingCard(c998.eqfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c)
end
function c998.eqfilter(c,e,tp,ec)
	return c:IsType(TYPE_SPELL+TYPE_EQUIP) and c:IsSetCard(0x207a) 
  and c:IsCanBeEffectTarget(e) and c:CheckUniqueOnField(tp) and c:CheckEquipTarget(ec)
end
function c998.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) 
	and Duel.IsExistingMatchingCard(c998.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
  if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=1 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		return Duel.IsExistingMatchingCard(c998.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
  local g=Duel.GetMatchingGroup(c998.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g1=Duel.SelectTarget(tp,c998.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
  local g2=Duel.SelectTarget(tp,c998.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp,g1:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,0,LOCATION_GRAVE)
  Duel.SetOperationInfo(0,CATEGORY_EQUIP,g2,1,0,LOCATION_GRAVE)
end
function c998.operation(e,tp,eg,ep,ev,re,r,rp)
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_EQUIP)
  local sg1=g1:Filter(Card.IsRelateToEffect,nil,e)
  local sg2=g2:Filter(Card.IsRelateToEffect,nil,e)
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
  if sg1:GetCount()>0 and sg2:GetCount()>0 and Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)~=0 then
    Duel.Equip(tp,sg2:GetFirst(),sg1:GetFirst(),true)
  end
end
