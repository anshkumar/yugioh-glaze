--月華竜 ブラック・ローズ
function c1701.initial_effect(c)
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c1701.thtg)
	e1:SetOperation(c1701.thop)
	c:RegisterEffect(e1)
end
function c1701.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and bit.band(c:GetSummonType(),SUMMON_TYPE_SPECIAL)~=0
end
function c1701.thfilter2(c,e,tp)
	return c:IsFaceup() and ((c:IsControler(1-tp) and c:GetLevel()>=5) or c==e:GetHandler())
end
function c1701.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,1701)==0 and eg:IsExists(c1701.thfilter2,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,c1701.thfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.RegisterFlagEffect(tp,1701,RESET_PHASE+PHASE_END,0,1)
end
function c1701.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
