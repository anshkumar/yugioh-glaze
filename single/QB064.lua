
Debug.SetAIName("頂上決戦！")
Debug.ReloadFieldBegin(DUEL_ATTACK_FIRST_TURN+DUEL_SIMPLE_AI)

Debug.SetPlayerInfo(0,100,0,0)
Debug.SetPlayerInfo(1,4500,0,0)

Debug.AddCard(70095154,0,0,LOCATION_DECK,0,POS_FACEDOWN)
Debug.AddCard(04162088,0,0,LOCATION_DECK,0,POS_FACEDOWN)

Debug.AddCard(37630732,0,0,LOCATION_HAND,0,POS_FACEDOWN)
Debug.AddCard(26439287,0,0,LOCATION_HAND,0,POS_FACEDOWN)
Debug.AddCard(70095154,0,0,LOCATION_HAND,0,POS_FACEDOWN)

Debug.AddCard(04162088,0,0,LOCATION_MZONE,2,POS_FACEUP_ATTACK)
Debug.AddCard(53347303,1,1,LOCATION_MZONE,1,POS_FACEUP_ATTACK)
local m12 = Debug.AddCard(62873545,1,1,LOCATION_MZONE,2,POS_FACEUP_ATTACK)

Debug.AddCard(66607691,0,0,LOCATION_SZONE,1,POS_FACEDOWN)
Debug.AddCard(12247206,0,0,LOCATION_SZONE,2,POS_FACEDOWN)
Debug.AddCard(97077563,0,0,LOCATION_SZONE,3,POS_FACEDOWN)
local s12 = Debug.AddCard(07625614,1,1,LOCATION_SZONE,2,POS_FACEUP)

Debug.AddCard(23995346,1,1,LOCATION_GRAVE,0,POS_FACEDOWN)
Debug.AddCard(23995346,1,1,LOCATION_GRAVE,0,POS_FACEDOWN)
Debug.AddCard(99267150,1,1,LOCATION_GRAVE,0,POS_FACEDOWN)
Debug.AddCard(11091375,1,1,LOCATION_GRAVE,0,POS_FACEDOWN)
Debug.AddCard(11091375,1,1,LOCATION_GRAVE,0,POS_FACEDOWN)
Debug.AddCard(89631139,1,1,LOCATION_GRAVE,0,POS_FACEDOWN)
Debug.AddCard(89631139,1,1,LOCATION_GRAVE,0,POS_FACEDOWN)
Debug.AddCard(89631139,1,1,LOCATION_GRAVE,0,POS_FACEDOWN)

Debug.AddCard(74157028,0,0,LOCATION_EXTRA,0,POS_FACEDOWN)
Debug.AddCard(01546123,0,0,LOCATION_EXTRA,0,POS_FACEDOWN)

Debug.PreEquip(s12,m12)

Debug.ReloadFieldEnd()
Debug.ShowHint("１回合內取得勝利")
aux.BeginPuzzle()