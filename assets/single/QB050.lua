
Debug.SetAIName("アリアリクイクイ")
Debug.ReloadFieldBegin(DUEL_ATTACK_FIRST_TURN+DUEL_SIMPLE_AI)

Debug.SetPlayerInfo(0,100,0,0)
Debug.SetPlayerInfo(1,3900,0,0)

Debug.AddCard(15595052,0,0,LOCATION_DECK,0,POS_FACEDOWN)
Debug.AddCard(10032958,0,0,LOCATION_DECK,0,POS_FACEDOWN)
Debug.AddCard(40640057,1,1,LOCATION_DECK,0,POS_FACEDOWN)

Debug.AddCard(13250922,0,0,LOCATION_HAND,0,POS_FACEDOWN)

Debug.AddCard(15595052,0,0,LOCATION_MZONE,1,POS_FACEUP_ATTACK)
Debug.AddCard(10032958,0,0,LOCATION_MZONE,2,POS_FACEUP_ATTACK)
Debug.AddCard(77252217,0,0,LOCATION_MZONE,3,POS_FACEUP_ATTACK)
Debug.AddCard(23205979,1,1,LOCATION_MZONE,2,POS_FACEUP_DEFENCE)

Debug.AddCard(34460239,0,0,LOCATION_SZONE,1,POS_FACEDOWN)
Debug.AddCard(07076131,0,0,LOCATION_SZONE,2,POS_FACEDOWN)
Debug.AddCard(42829885,0,0,LOCATION_SZONE,3,POS_FACEDOWN)
Debug.AddCard(44095762,1,1,LOCATION_SZONE,2,POS_FACEDOWN)

Debug.ReloadFieldEnd()
Debug.ShowHint("１回合內取得勝利")
aux.BeginPuzzle()