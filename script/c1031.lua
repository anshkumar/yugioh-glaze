--暗黒界の鬼神 ケルト
function c1031.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1031,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c1031.spcon)
	e1:SetTarget(c1031.sptg)
	e1:SetOperation(c1031.spop)
	c:RegisterEffect(e1)
end
function c1031.spcon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetPreviousControler())
	return e:GetHandler():GetPreviousLocation()==LOCATION_HAND and bit.band(r,0x4040)==0x4040
end
function c1031.filter(c,e,tp)
	return c:IsRace(RACE_FIEND) and (c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp))
end
function c1031.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c1031.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)>0 
		and rp~=tp and tp==e:GetLabel() and Duel.IsExistingTarget(c1031.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
		and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0)
		and Duel.SelectYesNo(tp,aux.Stringid(1031,1)) then
			Duel.BreakEffect()
			local tc=Duel.SelectMatchingCard(tp,c1031.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
			local s1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			local s2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
			local op=0
			Duel.Hint(HINT_SELECTMSG,tp,0)
			if s1 and s2 then op=Duel.SelectOption(tp,aux.Stringid(1031,2),aux.Stringid(1031,3))
			elseif s1 then op=Duel.SelectOption(tp,aux.Stringid(1031,2))
			elseif s2 then op=Duel.SelectOption(tp,aux.Stringid(1031,3))+1
			else return end
			if op==0 then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			else Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP) end
	end
end
