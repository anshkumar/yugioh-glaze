
Debug.SetAIName("明日への旅立ち")
Debug.ReloadFieldBegin(DUEL_ATTACK_FIRST_TURN+DUEL_SIMPLE_AI)

Debug.SetPlayerInfo(0,1000,0,0)
Debug.SetPlayerInfo(1,8000,0,0)

Debug.AddCard(40640057,1,1,LOCATION_HAND,0,POS_FACEDOWN)

Debug.AddCard(31887905,0,0,LOCATION_DECK,0,POS_FACEDOWN)
Debug.AddCard(68881649,0,0,LOCATION_DECK,0,POS_FACEDOWN)
Debug.AddCard(04376658,0,0,LOCATION_DECK,0,POS_FACEDOWN)
Debug.AddCard(31764353,0,0,LOCATION_DECK,0,POS_FACEDOWN)

Debug.AddCard(00759393,0,0,LOCATION_MZONE,1,POS_FACEDOWN_DEFENCE)
Debug.AddCard(37970940,0,0,LOCATION_MZONE,2,POS_FACEDOWN_DEFENCE)
Debug.AddCard(74364659,0,0,LOCATION_MZONE,3,POS_FACEDOWN_DEFENCE)
Debug.AddCard(37744402,0,0,LOCATION_MZONE,4,POS_FACEDOWN_DEFENCE)
Debug.AddCard(75356564,1,1,LOCATION_MZONE,0,POS_FACEUP_DEFENCE)
Debug.AddCard(53776525,1,1,LOCATION_MZONE,1,POS_FACEUP_DEFENCE)
Debug.AddCard(75889523,1,1,LOCATION_MZONE,2,POS_FACEUP_DEFENCE)
Debug.AddCard(88753985,1,1,LOCATION_MZONE,3,POS_FACEUP_DEFENCE)
Debug.AddCard(31305911,1,1,LOCATION_MZONE,4,POS_FACEUP_ATTACK)

Debug.AddCard(42945701,0,0,LOCATION_SZONE,1,POS_FACEDOWN)
Debug.AddCard(70156997,0,0,LOCATION_SZONE,2,POS_FACEDOWN)
Debug.AddCard(06540606,0,0,LOCATION_SZONE,3,POS_FACEDOWN)
Debug.AddCard(79333300,0,0,LOCATION_SZONE,4,POS_FACEDOWN)

Debug.ReloadFieldEnd()
Debug.ShowHint("１回合內取得勝利")
aux.BeginPuzzle()