#include "duelclient.h"
#include "clientcard.h"
#include "singlemode.h"
#include "field.h"
#include "duel.h"
#include "game.h"

namespace glaze {

#define myswprintf(buf, fmt, ...) swprintf(buf, 4096, fmt, ##__VA_ARGS__)

//unsigned DuelClient::connect_state = 0;
unsigned char DuelClient::response_buf[64];
unsigned char DuelClient::response_len = 0;
//unsigned int DuelClient::watching = 0;
//unsigned char DuelClient::selftype = 0;
//bool DuelClient::is_host = false;
//event_base* DuelClient::client_base = 0;
//bufferevent* DuelClient::client_bev = 0;
//char DuelClient::duel_client_read[0x2000];
//char DuelClient::duel_client_write[0x2000];
//bool DuelClient::is_closing = false;
int DuelClient::select_hint = 0;
wchar_t DuelClient::event_string[256];
mtrandom DuelClient::rnd;   // class  declared in ocgcore

//bool DuelClient::is_refreshing = false;
int DuelClient::match_kill = 0;
//std::vector<HostPacket> DuelClient::hosts;
//std::set<unsigned int> DuelClient::remotes;
//event* DuelClient::resp_event = 0;

DuelClient::DuelClient(QObject *parent) : QObject(parent)
{

}

int DuelClient::ClientAnalyze(char * msg, unsigned int len)
{
    Q_UNUSED(len);
    char* pbuf = msg;
    wchar_t textBuffer[256];
    mainGame->dInfo.curMsg = BufferIO::ReadUInt8(pbuf);
    mainGame->wCmdMenu = false;
    if(!mainGame->dInfo.isReplay && mainGame->dInfo.curMsg != MSG_WAITING && mainGame->dInfo.curMsg != MSG_CARD_SELECTED) {
        //		mainGame->waitFrame = -1;
        mainGame->stHintMsg = false;
        if(mainGame->wCardSelect == true) {
            mainGame->wCardSelect = false;
            //			mainGame->WaitFrameSignal(11);
        }
    }
    if(mainGame->dInfo.time_player == 1)
        mainGame->dInfo.time_player = 2;
    switch(mainGame->dInfo.curMsg)
    {

    case MSG_RETRY: // In lan mode
    {
        mainGame->stMessage = "Error occurs.";
        mainGame->wMessage = true;

        //        mainGame->actionSignal.Reset();
        //        mainGame->actionSignal.Wait();
        //        mainGame->closeDoneSignal.Reset();
        //        mainGame->closeSignal.Set();
        //        mainGame->closeDoneSignal.Wait();

        mainGame->dInfo.isStarted = false;
        mainGame->btnCreateHost = true;
        mainGame->btnJoinHost = true;
        mainGame->btnJoinCancel = true;
        mainGame->wLanWindow = true;

        //        event_base_loopbreak(client_base);
        //        if(exit_on_return)
        //            mainGame->device->closeDevice();
        return false;
    }

    case MSG_HINT: {
        int type = BufferIO::ReadInt8(pbuf);
        /*int player = */BufferIO::ReadInt8(pbuf);
        int data = BufferIO::ReadInt32(pbuf);
        if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping)
            return true;
        switch (type) {
        case HINT_EVENT: {
            myswprintf(event_string, L"%ls", dataManager.GetDesc(data));
            break;
        }
        case HINT_MESSAGE: {
            mainGame->stMessage = QString::fromWCharArray(dataManager.GetDesc(data));
            mainGame->wMessage = true;

            //			mainGame->actionSignal.Reset();
            //			mainGame->actionSignal.Wait();
            break;
        }
        case HINT_SELECTMSG: {
            select_hint = data;
            break;
        }
        case HINT_OPSELECTED: {
            break;
        }
        case HINT_EFFECT: {
            mainGame->showcardcode = data;
            mainGame->showcarddif = 0;
            mainGame->showcard = 1;
            break;
        }
        case HINT_RACE: {
            break;
        }
        case HINT_ATTRIB: {
            break;
        }
        case HINT_CODE: {
            break;
        }
        case HINT_NUMBER: {
            break;
        }
        case HINT_CARD: {
            mainGame->showcardcode = data;
            mainGame->showcarddif = 0;
            mainGame->showcard = 1;
            break;
        }
        }
        break;
    }

    case MSG_WIN: { //done  //future update required
            int player = BufferIO::ReadInt8(pbuf);
            int type = BufferIO::ReadInt8(pbuf);
            mainGame->showcarddif = 110;
            mainGame->showcardp = 0;
            mainGame->dInfo.vic_string = 0;
            wchar_t vic_buf[256];
            if(player == 2)
                mainGame->showcardcode = 3;
            else if(mainGame->LocalPlayer(player) == 0) {
                mainGame->showcardcode = 1;
                if(match_kill)
                    myswprintf(vic_buf, dataManager.GetVictoryString(0x20), dataManager.GetName(match_kill));
                else if(type < 0x10)
                    myswprintf(vic_buf, L"[%ls] %ls", mainGame->dInfo.clientname, dataManager.GetVictoryString(type));
                else
                    myswprintf(vic_buf, L"%ls", dataManager.GetVictoryString(type));
                mainGame->dInfo.vic_string = vic_buf;
            } else {
                mainGame->showcardcode = 2;
                if(match_kill)
                    myswprintf(vic_buf, dataManager.GetVictoryString(0x20), dataManager.GetName(match_kill));
                else if(type < 0x10)
                    myswprintf(vic_buf, L"[%ls] %ls", mainGame->dInfo.hostname, dataManager.GetVictoryString(type));
                else
                    myswprintf(vic_buf, L"%ls", dataManager.GetVictoryString(type));
                mainGame->dInfo.vic_string = vic_buf;
            }
//            mainGame->vic_string = QString::fromWCharArray(mainGame->dInfo.vic_string);
            mainGame->showcard = 101;
            mainGame->dInfo.vic_string = 0;
            mainGame->showcard = 0;
            //TODO: win signal
            break;
        }

    case MSG_WAITING: {
        mainGame->HintMsg = QString::fromWCharArray(dataManager.GetSysString(1390));
        mainGame->stHintMsg = true;
        return true;
    }

    case MSG_START: {
        mainGame->showcardcode = 11;
        mainGame->showcarddif = 30;
        mainGame->showcardp = 0;
        mainGame->showcard = 101;
        mainGame->showcard = 0;

        int playertype = BufferIO::ReadInt8(pbuf);
        mainGame->dInfo.isFirst =  (playertype & 0xf) ? false : true;
        if(playertype & 0xf0)
            mainGame->dInfo.player_type = 7;
        if(mainGame->dInfo.isTag) {
            if(mainGame->dInfo.isFirst)
                mainGame->dInfo.tag_player[1] = true;
            else
                mainGame->dInfo.tag_player[0] = true;
        }
        mainGame->dInfo.lp[mainGame->LocalPlayer(0)] = BufferIO::ReadInt32(pbuf);
        mainGame->dInfo.lp[mainGame->LocalPlayer(1)] = BufferIO::ReadInt32(pbuf);
//        myswprintf(mainGame->dInfo.strLP[0], L"%d", mainGame->dInfo.lp[0]);
//        myswprintf(mainGame->dInfo.strLP[1], L"%d", mainGame->dInfo.lp[1]);
        int deckc = BufferIO::ReadInt16(pbuf);
        int extrac = BufferIO::ReadInt16(pbuf);
        mainGame->dField.Initial(mainGame->LocalPlayer(0), deckc, extrac);
        deckc = BufferIO::ReadInt16(pbuf);
        extrac = BufferIO::ReadInt16(pbuf);
        mainGame->dField.Initial(mainGame->LocalPlayer(1), deckc, extrac);
        mainGame->dInfo.turn = 0;
        mainGame->dInfo.strTurn[0] = 0;
        mainGame->dInfo.is_shuffling = false;
        return true;
    }

    case MSG_UPDATE_DATA: {
        int player = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
        int location = BufferIO::ReadInt8(pbuf);

        //TODO: update
//        mainGame->dField.UpdateFieldCard(player, location, pbuf);

        return true;
    }

    case MSG_UPDATE_CARD: {
        int player = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
        int loc = BufferIO::ReadInt8(pbuf);
        int seq = BufferIO::ReadInt8(pbuf);

        //TODO: update
//        mainGame->dField.UpdateCard(player, loc, seq, pbuf);

        break;
    }

    case MSG_SELECT_BATTLECMD: {
        /*int selecting_player = */BufferIO::ReadInt8(pbuf);
        int /*code, */desc, count, con, loc, seq/*, diratt*/;
        ClientCard* pcard;
        mainGame->dField.activatable_cards.clear();
        mainGame->dField.activatable_descs.clear();
        count = BufferIO::ReadInt8(pbuf);
        for (int i = 0; i < count; ++i) {
            /*code = */BufferIO::ReadInt32(pbuf);
            con = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            loc =  BufferIO::ReadInt8(pbuf);
            seq =  BufferIO::ReadInt8(pbuf);
            desc =  BufferIO::ReadInt32(pbuf);
            pcard = mainGame->dField.GetCard(con, loc, seq);
            mainGame->dField.activatable_cards.push_back(pcard);
            mainGame->dField.activatable_descs.push_back(desc);
            pcard->cmdFlag |= COMMAND_ACTIVATE;
            if (pcard->location == LOCATION_GRAVE)
                mainGame->dField.grave_act = true;
            if (pcard->location == LOCATION_REMOVED)
                mainGame->dField.remove_act = true;
        }
        mainGame->dField.attackable_cards.clear();
        count = BufferIO::ReadInt8(pbuf);
        for (int i = 0; i < count; ++i) {
            /*code = */BufferIO::ReadInt32(pbuf);
            con = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            loc = BufferIO::ReadInt8(pbuf);
            seq = BufferIO::ReadInt8(pbuf);
            /*diratt = */BufferIO::ReadInt8(pbuf);
            pcard = mainGame->dField.GetCard(con, loc, seq);
            mainGame->dField.attackable_cards.push_back(pcard);
            pcard->cmdFlag |= COMMAND_ATTACK;
        }

        if(BufferIO::ReadInt8(pbuf)) {
            mainGame->btnM2 = true;
//            mainGame->btnM2->setEnabled(true);
//            mainGame->btnM2->setPressed(false);
        }
        if(BufferIO::ReadInt8(pbuf)) {
            mainGame->btnEP = true;
//            mainGame->btnEP->setEnabled(true);
//            mainGame->btnEP->setPressed(false);
        }
        return false;
    }

    case MSG_SELECT_IDLECMD: {
        /*int selecting_player = */BufferIO::ReadInt8(pbuf);
        int code, desc, count, con, loc, seq;
        ClientCard* pcard;
        mainGame->dField.summonable_cards.clear();
        count = BufferIO::ReadInt8(pbuf);
        for (int i = 0; i < count; ++i) {
            code = BufferIO::ReadInt32(pbuf);
            con = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            loc = BufferIO::ReadInt8(pbuf);
            seq = BufferIO::ReadInt8(pbuf);
            pcard = mainGame->dField.GetCard(con, loc, seq);
            mainGame->dField.summonable_cards.push_back(pcard);
            pcard->cmdFlag |= COMMAND_SUMMON;
        }
        mainGame->dField.spsummonable_cards.clear();
        count = BufferIO::ReadInt8(pbuf);
        for (int i = 0; i < count; ++i) {
            code = BufferIO::ReadInt32(pbuf);
            con = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            loc = BufferIO::ReadInt8(pbuf);
            seq = BufferIO::ReadInt8(pbuf);
            pcard = mainGame->dField.GetCard(con, loc, seq);
            mainGame->dField.spsummonable_cards.push_back(pcard);
            pcard->cmdFlag |= COMMAND_SPSUMMON;
            if (pcard->location == LOCATION_DECK) {
                pcard->SetCode(code);
                mainGame->dField.deck_act = true;
            }
            if (pcard->location == LOCATION_GRAVE)
                mainGame->dField.grave_act = true;
            if (pcard->location == LOCATION_REMOVED)
                mainGame->dField.remove_act = true;
            if (pcard->location == LOCATION_EXTRA)
                mainGame->dField.extra_act = true;
            if (pcard->location == LOCATION_SZONE && pcard->sequence == 6)
                mainGame->dField.pzone_act = true;
        }
        mainGame->dField.reposable_cards.clear();
        count = BufferIO::ReadInt8(pbuf);
        for (int i = 0; i < count; ++i) {
            code = BufferIO::ReadInt32(pbuf);
            con = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            loc = BufferIO::ReadInt8(pbuf);
            seq = BufferIO::ReadInt8(pbuf);
            pcard = mainGame->dField.GetCard(con, loc, seq);
            mainGame->dField.reposable_cards.push_back(pcard);
            pcard->cmdFlag |= COMMAND_REPOS;
        }
        mainGame->dField.msetable_cards.clear();
        count = BufferIO::ReadInt8(pbuf);
        for (int i = 0; i < count; ++i) {
            code = BufferIO::ReadInt32(pbuf);
            con = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            loc = BufferIO::ReadInt8(pbuf);
            seq = BufferIO::ReadInt8(pbuf);
            pcard = mainGame->dField.GetCard(con, loc, seq);
            mainGame->dField.msetable_cards.push_back(pcard);
            pcard->cmdFlag |= COMMAND_MSET;
        }
        mainGame->dField.ssetable_cards.clear();
        count = BufferIO::ReadInt8(pbuf);
        for (int i = 0; i < count; ++i) {
            code = BufferIO::ReadInt32(pbuf);
            con = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            loc = BufferIO::ReadInt8(pbuf);
            seq = BufferIO::ReadInt8(pbuf);
            pcard = mainGame->dField.GetCard(con, loc, seq);
            mainGame->dField.ssetable_cards.push_back(pcard);
            pcard->cmdFlag |= COMMAND_SSET;
        }
        mainGame->dField.activatable_cards.clear();
        mainGame->dField.activatable_descs.clear();
        count = BufferIO::ReadInt8(pbuf);
        for (int i = 0; i < count; ++i) {
            code = BufferIO::ReadInt32(pbuf);
            con = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            loc = BufferIO::ReadInt8(pbuf);
            seq = BufferIO::ReadInt8(pbuf);
            desc = BufferIO::ReadInt32(pbuf);
            pcard = mainGame->dField.GetCard(con, loc, seq);
            mainGame->dField.activatable_cards.push_back(pcard);
            mainGame->dField.activatable_descs.push_back(desc);
            pcard->cmdFlag |= COMMAND_ACTIVATE;
            if (pcard->location == LOCATION_GRAVE)
                mainGame->dField.grave_act = true;
            if (pcard->location == LOCATION_REMOVED)
                mainGame->dField.remove_act = true;
        }
        if(BufferIO::ReadInt8(pbuf)) {
            mainGame->btnBP = true;
//			mainGame->btnBP->setEnabled(true);
//			mainGame->btnBP->setPressed(false);
        }
        if(BufferIO::ReadInt8(pbuf)) {
            mainGame->btnEP = true;
//			mainGame->btnEP->setEnabled(true);
//			mainGame->btnEP->setPressed(false);
        }
        return false;
    }
    case MSG_SELECT_EFFECTYN: {
        /*int selecting_player = */BufferIO::ReadInt8(pbuf);
        unsigned int code = (unsigned int)BufferIO::ReadInt32(pbuf);
        int c = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
        int l = BufferIO::ReadInt8(pbuf);
        int s = BufferIO::ReadInt8(pbuf);
        ClientCard* pcard = mainGame->dField.GetCard(c, l, s);
        if (pcard->code != code)
            pcard->SetCode(code);
        BufferIO::ReadInt8(pbuf);
        pcard->is_highlighting = true;
        mainGame->dField.highlighting_card = pcard;
        myswprintf(textBuffer, dataManager.GetSysString(200), dataManager.FormatLocation(l, s), dataManager.GetName(code));

        mainGame->stQMessage = QString::fromWCharArray(textBuffer);
        mainGame->wQuery = true;

        return false;
    }
    case MSG_SELECT_YESNO: {
        /*int selecting_player = */BufferIO::ReadInt8(pbuf);
        int desc = BufferIO::ReadInt32(pbuf);
        mainGame->dField.highlighting_card = 0;

        mainGame->stQMessage = QString::fromWCharArray((wchar_t*)dataManager.GetDesc(desc));
        mainGame->wQuery = true;

        return false;
    }
    case MSG_SELECT_OPTION: {
        return false;
    }
    case MSG_SELECT_CARD: {
        /*int selecting_player = */BufferIO::ReadInt8(pbuf);
        mainGame->dField.select_cancelable = BufferIO::ReadInt8(pbuf);
        mainGame->dField.select_min = BufferIO::ReadInt8(pbuf);
        mainGame->dField.select_max = BufferIO::ReadInt8(pbuf);
        int count = BufferIO::ReadInt8(pbuf);
        mainGame->dField.selectable_cards.clear();
        mainGame->dField.selected_cards.clear();
        int c, l, s, ss;
        unsigned int code;
        bool panelmode = false;
        mainGame->dField.select_ready = false;
        ClientCard* pcard;
        for (int i = 0; i < count; ++i) {
            code = (unsigned int)BufferIO::ReadInt32(pbuf);
            c = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            l = BufferIO::ReadInt8(pbuf);
            s = BufferIO::ReadInt8(pbuf);
            ss = BufferIO::ReadInt8(pbuf);
            if ((l & LOCATION_OVERLAY) > 0)
                pcard = mainGame->dField.GetCard(c, l & 0x7f, s)->overlayed[ss];
            else
                pcard = mainGame->dField.GetCard(c, l, s);
            if (code != 0 && pcard->code != code)
                pcard->SetCode(code);
            pcard->select_seq = i;
            mainGame->dField.selectable_cards.push_back(pcard);
            pcard->is_selectable = true;
            pcard->is_selected = false;
            if (l & 0xf1)
                panelmode = true;
        }
        std::sort(mainGame->dField.selectable_cards.begin(), mainGame->dField.selectable_cards.end(), ClientCard::client_card_sort);
        if(select_hint)
            myswprintf(textBuffer, L"%ls(%d-%d)", dataManager.GetDesc(select_hint),
                       mainGame->dField.select_min, mainGame->dField.select_max);
        else myswprintf(textBuffer, L"%ls(%d-%d)", dataManager.GetSysString(560), mainGame->dField.select_min, mainGame->dField.select_max);
        select_hint = 0;
        if (panelmode) {

            mainGame->wCardSelect = true;
            mainGame->stCardSelect = QString::fromWCharArray(textBuffer);
            mainGame->dField.ShowSelectCard();

        } else {
            mainGame->HintMsg = QString::fromWCharArray(textBuffer);
            mainGame->stHintMsg = true;
        }
        return false;
    }
    case MSG_SELECT_CHAIN: {
        /*int selecting_player = */BufferIO::ReadInt8(pbuf);
        int count = BufferIO::ReadInt8(pbuf);
        /*int specount = */BufferIO::ReadInt8(pbuf);
        int forced = BufferIO::ReadInt8(pbuf);
        /*int hint0 = */BufferIO::ReadInt32(pbuf);
        /*int hint1 = */BufferIO::ReadInt32(pbuf);
        int c, l, s, ss, desc;
        ClientCard* pcard;
        bool panelmode = false;
        mainGame->dField.chain_forced = (forced != 0);
        mainGame->dField.activatable_cards.clear();
        mainGame->dField.activatable_descs.clear();
        for (int i = 0; i < count; ++i) {
            /*code = */BufferIO::ReadInt32(pbuf);
            c = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            l = BufferIO::ReadInt8(pbuf);
            s = BufferIO::ReadInt8(pbuf);
            ss = BufferIO::ReadInt8(pbuf);
            desc = BufferIO::ReadInt32(pbuf);
            pcard = mainGame->dField.GetCard(c, l, s, ss);
            mainGame->dField.activatable_cards.push_back(pcard);
            mainGame->dField.activatable_descs.push_back(desc);
            pcard->is_selectable = true;
            pcard->is_selected = false;
            pcard->cmdFlag |= COMMAND_ACTIVATE;
            if(l == LOCATION_GRAVE)
                mainGame->dField.grave_act = true;
            if(l == LOCATION_REMOVED)
                mainGame->dField.remove_act = true;
            if(l & 0xc1)
                panelmode = true;
        }
//        if(!forced && (mainGame->ignore_chain || ((count == 0 || specount == 0) && !mainGame->always_chain))) {
//            SetResponseI(-1);
//            mainGame->dField.ClearChainSelect();
//            if(mainGame->chkWaitChain == true ) {
//                mainGame->WaitFrameSignal(rnd.real() * 20 + 20);    // replace
//            }
//            DuelClient::SendResponse();
//            return true;
//        }
//        if(mainGame->chkAutoChain->isChecked() && forced) {
//            SetResponseI(0);
//            mainGame->dField.ClearChainSelect();
//            DuelClient::SendResponse();
//            return true;
//        }

        mainGame->HintMsg = QString::fromWCharArray(dataManager.GetSysString(550));
        mainGame->stHintMsg = true;
        if(panelmode) {
            mainGame->dField.list_command = COMMAND_ACTIVATE;
            QMetaObject::invokeMethod(&mainGame->dField.selectable_cards,"copy",Qt::QueuedConnection,Q_ARG(ClientCardModel&, mainGame->dField.activatable_cards));
            std::sort(mainGame->dField.selectable_cards.begin(), mainGame->dField.selectable_cards.end());
            auto eit = std::unique(mainGame->dField.selectable_cards.begin(), mainGame->dField.selectable_cards.end());
            QMetaObject::invokeMethod(&mainGame->dField.selectable_cards,"erase",Qt::QueuedConnection,Q_ARG(myIter, eit), Q_ARG(myIter, mainGame->dField.selectable_cards.end()));
            mainGame->dField.ShowChainCard();
        } else {
            if(!forced) {
                if(count == 0)
                    myswprintf(textBuffer, L"%ls\n%ls", dataManager.GetSysString(201), dataManager.GetSysString(202));
                else
                    myswprintf(textBuffer, L"%ls\n%ls", event_string, dataManager.GetSysString(203));
                mainGame->stQMessage = QString::fromWCharArray((wchar_t*)textBuffer);
                mainGame->wQuery = true;
            }
        }
        return false;
    }
    case MSG_SELECT_PLACE:
    case MSG_SELECT_DISFIELD: {
        /*int selecting_player = */BufferIO::ReadInt8(pbuf);
        mainGame->dField.select_min = BufferIO::ReadInt8(pbuf);
        mainGame->dField.selectable_field = ~BufferIO::ReadInt32(pbuf);
        mainGame->dField.selected_field = 0;
        unsigned char respbuf[64];
        int pzone = 0;
        if (mainGame->dInfo.curMsg == MSG_SELECT_PLACE && mainGame->chkAutoPos == true) {
            int filter;
            if (mainGame->dField.selectable_field & 0x1f) {
                respbuf[0] = mainGame->dInfo.isFirst ? 0 : 1;
                respbuf[1] = 0x4;
                filter = mainGame->dField.selectable_field & 0x1f;
            } else if (mainGame->dField.selectable_field & 0x1f00) {
                respbuf[0] = mainGame->dInfo.isFirst ? 0 : 1;
                respbuf[1] = 0x8;
                filter = (mainGame->dField.selectable_field >> 8) & 0x1f;
            } else if (mainGame->dField.selectable_field & 0xc000) {
                respbuf[0] = mainGame->dInfo.isFirst ? 0 : 1;
                respbuf[1] = 0x8;
                filter = (mainGame->dField.selectable_field >> 14) & 0x3;
                pzone = 1;
            } else if (mainGame->dField.selectable_field & 0x1f0000) {
                respbuf[0] = mainGame->dInfo.isFirst ? 1 : 0;
                respbuf[1] = 0x4;
                filter = (mainGame->dField.selectable_field >> 16) & 0x1f;
            } else if (mainGame->dField.selectable_field & 0x1f000000) {
                respbuf[0] = mainGame->dInfo.isFirst ? 1 : 0;
                respbuf[1] = 0x8;
                filter = (mainGame->dField.selectable_field >> 24) & 0x1f;
            } else {
                respbuf[0] = mainGame->dInfo.isFirst ? 1 : 0;
                respbuf[1] = 0x8;
                filter = (mainGame->dField.selectable_field >> 30) & 0x3;
                pzone = 1;
            }
            if(!pzone) {
                if(mainGame->chkRandomPos == true ) {
                    respbuf[2] = rnd.real() * 5;
                    while(!(filter & (1 << respbuf[2])))
                        respbuf[2] = rnd.real() * 5;
                } else {
                    if (filter & 0x4) respbuf[2] = 2;
                    else if (filter & 0x2) respbuf[2] = 1;
                    else if (filter & 0x8) respbuf[2] = 3;
                    else if (filter & 0x1) respbuf[2] = 0;
                    else if (filter & 0x10) respbuf[2] = 4;
                }
            } else {
                if (filter & 0x1) respbuf[2] = 6;
                else if (filter & 0x2) respbuf[2] = 7;
            }
            mainGame->dField.selectable_field = 0;
            SetResponseB(respbuf, 3);
            DuelClient::SendResponse();
            return true;
        }
        return false;
    }
    case MSG_SELECT_POSITION: { // select battle position
                                // after special summoning a monster it asks for the attle position to put the card in.
        /*int selecting_player = */BufferIO::ReadInt8(pbuf);
        unsigned int code = (unsigned int)BufferIO::ReadInt32(pbuf);
        int positions = BufferIO::ReadInt8(pbuf);
        if (positions == 0x1 || positions == 0x2 || positions == 0x4 || positions == 0x8) {
            SetResponseI(positions);
            return true;
        }
        int count = 0, filter = 0x1;
        while(filter != 0x10) {
            if(positions & filter) count++;
            filter <<= 1;
        }

        if(positions & 0x1) {
            mainGame->btnPSAU = code;
        }
        if(positions & 0x2) {
            mainGame->btnPSAD = 1;
        }
        if(positions & 0x4) {
            mainGame->btnPSDU = code;
        }
        if(positions & 0x8) {
            mainGame->btnPSDD = 1;
        }
        mainGame->wPosSelect = true;
        return false;
    }
    case MSG_SELECT_TRIBUTE: {
        /*int selecting_player = */BufferIO::ReadInt8(pbuf);
        mainGame->dField.select_cancelable = BufferIO::ReadInt8(pbuf) ? true : false;
        mainGame->dField.select_min = BufferIO::ReadInt8(pbuf);
        mainGame->dField.select_max = BufferIO::ReadInt8(pbuf);
        int count = BufferIO::ReadInt8(pbuf);
        mainGame->dField.selectable_cards.clear();
        mainGame->dField.selected_cards.clear();
        int c, l, s, t;
        unsigned int code;
        ClientCard* pcard;
        mainGame->dField.select_ready = false;
        for (int i = 0; i < count; ++i) {
            code = (unsigned int)BufferIO::ReadInt32(pbuf);
            c = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            l = BufferIO::ReadInt8(pbuf);
            s = BufferIO::ReadInt8(pbuf);
            t = BufferIO::ReadInt8(pbuf);
            pcard = mainGame->dField.GetCard(c, l, s);
            if (code && pcard->code != code)
                pcard->SetCode(code);
            mainGame->dField.selectable_cards.push_back(pcard);
            pcard->opParam = t;
            pcard->select_seq = i;
            pcard->is_selectable = true;
        }
        mainGame->HintMsg = QString::fromWCharArray(dataManager.GetSysString(531));
        mainGame->stHintMsg = false;
        return false;
    }
    case MSG_SELECT_COUNTER: {
        /*int selecting_player = */BufferIO::ReadInt8(pbuf);
        mainGame->dField.select_counter_type = BufferIO::ReadInt16(pbuf);
        mainGame->dField.select_counter_count = BufferIO::ReadInt8(pbuf);
        int count = BufferIO::ReadInt8(pbuf);
        mainGame->dField.selectable_cards.clear();
        int c, l, s, t/*, code*/;
        ClientCard* pcard;
        for (int i = 0; i < count; ++i) {
            /*code = */BufferIO::ReadInt32(pbuf);
            c = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            l = BufferIO::ReadInt8(pbuf);
            s = BufferIO::ReadInt8(pbuf);
            t = BufferIO::ReadInt8(pbuf);
            pcard = mainGame->dField.GetCard(c, l, s);
            mainGame->dField.selectable_cards.push_back(pcard);
            pcard->opParam = (t << 16) | t;
            pcard->is_selectable = true;
        }
        myswprintf(textBuffer, dataManager.GetSysString(204), mainGame->dField.select_counter_count, dataManager.GetCounterName(mainGame->dField.select_counter_type));

        mainGame->HintMsg = QString::fromWCharArray(textBuffer);
        mainGame->stHintMsg = true;
        return false;
    }
    case MSG_SELECT_SUM: {
        mainGame->dField.select_mode = BufferIO::ReadInt8(pbuf);
        /*int selecting_player = */BufferIO::ReadInt8(pbuf);
        mainGame->dField.select_sumval = BufferIO::ReadInt32(pbuf);
        mainGame->dField.select_min = BufferIO::ReadInt8(pbuf);
        mainGame->dField.select_max = BufferIO::ReadInt8(pbuf);
        int count = BufferIO::ReadInt8(pbuf);
        mainGame->dField.selectsum_all.clear();
        mainGame->dField.selected_cards.clear();
        mainGame->dField.selectsum_cards.clear();
        int c, l, s;
        unsigned int code;
        bool panelmode = false;
        ClientCard* pcard;
        for (int i = 0; i < count; ++i) {
            code = (unsigned int)BufferIO::ReadInt32(pbuf);
            c = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            l = BufferIO::ReadInt8(pbuf);
            s = BufferIO::ReadInt8(pbuf);
            pcard = mainGame->dField.GetCard(c, l, s);
            if (code != 0 && pcard->code != code)
                pcard->SetCode(code);
            pcard->opParam = BufferIO::ReadInt32(pbuf);
            pcard->select_seq = i;
            mainGame->dField.selectsum_all.push_back(pcard);
            if ((l & 0xe) == 0)
                panelmode = true;
        }
        std::sort(mainGame->dField.selectsum_all.begin(), mainGame->dField.selectsum_all.end(), ClientCard::client_card_sort);
        mainGame->dField.CheckSelectSum();
        if(select_hint)
            myswprintf(textBuffer, L"%ls(%d)", dataManager.GetDesc(select_hint), mainGame->dField.select_sumval);
        else myswprintf(textBuffer, L"%ls(%d)", dataManager.GetSysString(560), mainGame->dField.select_sumval);
        select_hint = 0;
        if (panelmode) {
            mainGame->stCardSelect = QString::fromWCharArray(textBuffer);
            mainGame->wCardSelect = true;
            mainGame->dField.ShowSelectCard();
        } else {
            mainGame->HintMsg = QString::fromWCharArray(textBuffer);
            mainGame->stHintMsg = true;
        }
        return false;
    }
    case MSG_SORT_CARD:
    case MSG_SORT_CHAIN: {
        /*int player = */BufferIO::ReadInt8(pbuf);
        int count = BufferIO::ReadInt8(pbuf);
        mainGame->dField.selectable_cards.clear();
        mainGame->dField.selected_cards.clear();
        mainGame->dField.sort_list.clear();
        int c, l, s;
        unsigned int code;
        ClientCard* pcard;
        for (int i = 0; i < count; ++i) {
            code = (unsigned int)BufferIO::ReadInt32(pbuf);
            c = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            l = BufferIO::ReadInt8(pbuf);
            s = BufferIO::ReadInt8(pbuf);
            pcard = mainGame->dField.GetCard(c, l, s);
            if (code != 0 && pcard->code != code)
                pcard->SetCode(code);
            mainGame->dField.selectable_cards.push_back(pcard);
            mainGame->dField.sort_list.push_back(0);
        }
        if (mainGame->chkAutoChain == true && mainGame->dInfo.curMsg == MSG_SORT_CHAIN) {
            mainGame->dField.sort_list.clear();
            SetResponseI(-1);
            DuelClient::SendResponse();
            return true;
        }
        if(mainGame->dInfo.curMsg == MSG_SORT_CHAIN)
            mainGame->stCardSelect = QString::fromWCharArray(dataManager.GetSysString(206));
        else
            mainGame->stCardSelect = QString::fromWCharArray(dataManager.GetSysString(205));
        mainGame->dField.select_min = 0;
        mainGame->dField.select_max = count;
        mainGame->dField.ShowSelectCard();
        return false;
    }
    case MSG_CONFIRM_DECKTOP: {
        int player = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
        int count = BufferIO::ReadInt8(pbuf);
        int code;
        ClientCard* pcard;
        mainGame->dField.selectable_cards.clear();
        for (int i = 0; i < count; ++i) {
            code = BufferIO::ReadInt32(pbuf);
            pbuf += 3;
            pcard = (mainGame->dField.deck[player].last() + i);
            if (code != 0)
                pcard->SetCode(code);
        }
        if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping)
            return true;
        myswprintf(textBuffer, dataManager.GetSysString(207), count);
//		mainGame->lstLog->addItem(textBuffer);
//		mainGame->logParam.push_back(0);
        for (int i = 0; i < count; ++i) {
            pcard = (mainGame->dField.deck[player].last() + i);

            myswprintf(textBuffer, L"*[%ls]", dataManager.GetName(pcard->code));
//			mainGame->lstLog->addItem(textBuffer);
//			mainGame->logParam.push_back(pcard->code);

            float shift = -0.15f;
            if (player == 1) shift = 0.15f;
            pcard->dPos = QVector3D(shift, 0, 0);
            if(!mainGame->dField.deck_reversed)
                pcard->dRot = QVector3D(0, 3.14159f / 5.0f, 0);
            else pcard->dRot = QVector3D(0, 0, 0);
            pcard->is_moving = true;
            pcard->aniFrame = 5;

            mainGame->dField.MoveCard(pcard, 5);

        }
        return true;
    }
    case MSG_CONFIRM_CARDS: {
        /*int player = */mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
        int count = BufferIO::ReadInt8(pbuf);
        int code, c, l, s;
        ClientCardModel field_confirm;
        ClientCardModel panel_confirm;
        ClientCard* pcard;
        if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping) {
            pbuf += count * 7;
            return true;
        }
        myswprintf(textBuffer, dataManager.GetSysString(208), count);
//		mainGame->lstLog->addItem(textBuffer);
//		mainGame->logParam.push_back(0);
        for (int i = 0; i < count; ++i) {
            code = BufferIO::ReadInt32(pbuf);
            c = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            l = BufferIO::ReadInt8(pbuf);
            s = BufferIO::ReadInt8(pbuf);
            pcard = mainGame->dField.GetCard(c, l, s);
            if (code != 0)
                pcard->SetCode(code);
//            mainGame->gMutex.Lock();
            myswprintf(textBuffer, L"*[%ls]", dataManager.GetName(code));
//			mainGame->lstLog->addItem(textBuffer);
//			mainGame->logParam.push_back(code);

            if (l & 0x41) {
                if(count == 1) {
                    float shift = -0.15f;
                    if (c == 0 && l == 0x40) shift = 0.15f;
                    pcard->dPos = QVector3D(shift, 0, 0);
                    if((l == LOCATION_DECK) && mainGame->dField.deck_reversed)
                        pcard->dRot = QVector3D(0, 0, 0);
                    else pcard->dRot = QVector3D(0, 3.14159f / 5.0f, 0);
                    pcard->is_moving = true;
                    pcard->aniFrame = 5;
//					mainGame->WaitFrameSignal(45);
                    mainGame->dField.MoveCard(pcard, 5);
//					mainGame->WaitFrameSignal(5);
                } else {
                    if(!mainGame->dInfo.isReplay)
                        panel_confirm.push_back(pcard);
                }
            } else {
                if(!mainGame->dInfo.isReplay || (l & LOCATION_ONFIELD))
                    field_confirm.push_back(pcard);
            }
        }
        if (field_confirm.size() > 0) {
//			mainGame->WaitFrameSignal(5);
            for(size_t i = 0; i < (unsigned int)field_confirm.size(); ++i) {
                pcard = field_confirm[i];
                c = pcard->controler;
                l = pcard->location;
                if (l == LOCATION_HAND) {
                    mainGame->dField.MoveCard(pcard, 5);
                } else if (l == LOCATION_MZONE) {
                    if (pcard->position & POS_FACEUP)
                        continue;
                    pcard->dPos = QVector3D(0, 0, 0);
                    if (pcard->position == POS_FACEDOWN_ATTACK)
                        pcard->dRot = QVector3D(0, 3.14159f / 5.0f, 0);
                    else
                        pcard->dRot = QVector3D(3.14159f / 5.0f, 0, 0);
                    pcard->is_moving = true;
                    pcard->aniFrame = 5;
                } else if (l == LOCATION_SZONE) {
                    if (pcard->position & POS_FACEUP)
                        continue;
                    pcard->dPos = QVector3D(0, 0, 0);
                    pcard->dRot = QVector3D(0, 3.14159f / 5.0f, 0);
                    pcard->is_moving = true;
                    pcard->aniFrame = 5;
                }
            }
//            mainGame->WaitFrameSignal(90);
            for(size_t i = 0; i < (unsigned int)field_confirm.size(); ++i) {
                mainGame->dField.MoveCard(field_confirm[i], 5);
            }
//            mainGame->WaitFrameSignal(5);
        }
        if (panel_confirm.size()) {
            std::sort(panel_confirm.begin(), panel_confirm.end(), ClientCard::client_card_sort);

            QMetaObject::invokeMethod(&mainGame->dField.selectable_cards,"copy",Qt::QueuedConnection,Q_ARG(ClientCardModel&, panel_confirm));
            myswprintf(textBuffer, dataManager.GetSysString(208), panel_confirm.size());
            mainGame->stCardSelect = QString::fromWCharArray(textBuffer);
            mainGame->dField.ShowSelectCard(true);

//            mainGame->actionSignal.Reset();
//            mainGame->actionSignal.Wait();
        }
        return true;
    }
    case MSG_SHUFFLE_DECK: {
        int player = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
        if(mainGame->dField.deck[player].size() < 2)
            return true;
        bool rev = mainGame->dField.deck_reversed;
        if(!mainGame->dInfo.isReplay || !mainGame->dInfo.isReplaySkiping) {
            mainGame->dField.deck_reversed = false;
            if(rev) {
                for (size_t i = 0; i < (unsigned int)mainGame->dField.deck[player].size(); ++i)
                    mainGame->dField.MoveCard(mainGame->dField.deck[player][i], 10);
//                mainGame->WaitFrameSignal(10);
            }
        }
        for (size_t i = 0; i < (unsigned int)mainGame->dField.deck[player].size(); ++i) {
            mainGame->dField.deck[player][i]->code = 0;
            mainGame->dField.deck[player][i]->is_reversed = false;
        }
        if(!mainGame->dInfo.isReplay || !mainGame->dInfo.isReplaySkiping) {
            for (int i = 0; i < 5; ++i) {
                for (auto cit = mainGame->dField.deck[player].begin(); cit != mainGame->dField.deck[player].end(); ++cit) {
                    (*cit)->dPos = QVector3D(rand() * 0.4f / RAND_MAX - 0.2f, 0, 0);
                    (*cit)->dRot = QVector3D(0, 0, 0);
                    (*cit)->is_moving = true;
                    (*cit)->aniFrame = 3;
                }
//                mainGame->WaitFrameSignal(3);
                for (auto cit = mainGame->dField.deck[player].begin(); cit != mainGame->dField.deck[player].end(); ++cit)
                    mainGame->dField.MoveCard(*cit, 3);
//                mainGame->WaitFrameSignal(3);
            }
            mainGame->dField.deck_reversed = rev;
            if(rev) {
                for (size_t i = 0; i < (unsigned int)mainGame->dField.deck[player].size(); ++i)
                    mainGame->dField.MoveCard(mainGame->dField.deck[player][i], 10);
            }
        }
        return true;
    }
    case MSG_SHUFFLE_HAND: {
        int player = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
        /*int count = */BufferIO::ReadInt8(pbuf);
        if(!mainGame->dInfo.isReplay || !mainGame->dInfo.isReplaySkiping) {
//			mainGame->WaitFrameSignal(5);
            if(player == 1 && !mainGame->dInfo.isReplay && !mainGame->dInfo.isSingleMode) {
//                bool flip = false;
                for (auto cit = mainGame->dField.hand[player].begin(); cit != mainGame->dField.hand[player].end(); ++cit)
                    if((*cit)->code) {
                        (*cit)->dPos = QVector3D(0, 0, 0);
                        (*cit)->dRot = QVector3D(1.322f / 5, 3.1415926f / 5, 0);
                        (*cit)->is_moving = true;
                        (*cit)->is_hovered = false;
                        (*cit)->aniFrame = 5;
//                        flip = true;
                    }
//                if(flip)
//					mainGame->WaitFrameSignal(5);
            }
            for (auto cit = mainGame->dField.hand[player].begin(); cit != mainGame->dField.hand[player].end(); ++cit) {
                (*cit)->dPos = QVector3D((3.9f - (*cit)->curPos.x()) / 5, 0, 0);
                (*cit)->dRot = QVector3D(0, 0, 0);
                (*cit)->is_moving = true;
                (*cit)->is_hovered = false;
                (*cit)->aniFrame = 5;
            }
//			mainGame->WaitFrameSignal(11);
        }
        for (auto cit = mainGame->dField.hand[player].begin(); cit != mainGame->dField.hand[player].end(); ++cit)
            (*cit)->SetCode(BufferIO::ReadInt32(pbuf));
        if(!mainGame->dInfo.isReplay || !mainGame->dInfo.isReplaySkiping) {
            for (auto cit = mainGame->dField.hand[player].begin(); cit != mainGame->dField.hand[player].end(); ++cit) {
                (*cit)->is_hovered = false;
                mainGame->dField.MoveCard(*cit, 5);
            }
//            mainGame->WaitFrameSignal(5);
        }
        return true;
    }
    case MSG_REFRESH_DECK: {
        /*int player = */mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
        return true;
    }
    case MSG_SWAP_GRAVE_DECK: {
        int player = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
        if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping) {
            QMetaObject::invokeMethod(&mainGame->dField.grave[player],"swap",Qt::QueuedConnection,Q_ARG(ClientCardModel&, mainGame->dField.deck[player]));
            for (auto cit = mainGame->dField.grave[player].begin(); cit != mainGame->dField.grave[player].end(); ++cit)
                (*cit)->location = LOCATION_GRAVE;
            for (auto cit = mainGame->dField.deck[player].begin(); cit != mainGame->dField.deck[player].end(); ) {
                if ((*cit)->type & 0x802040) {
                    (*cit)->location = LOCATION_EXTRA;
                    QMetaObject::invokeMethod(&mainGame->dField.extra[player],"push_back",Qt::QueuedConnection,Q_ARG(ClientCard*, *cit));
                    QMetaObject::invokeMethod(&mainGame->dField.deck[player],"erase",Qt::QueuedConnection,Q_RETURN_ARG(myIter, cit), Q_ARG(myIter, cit));
//                    cit = mainGame->dField.deck[player].erase(cit);
                } else {
                    (*cit)->location = LOCATION_DECK;
                    ++cit;
                }
            }
        } else {

            QMetaObject::invokeMethod(&mainGame->dField.grave[player],"swap",Qt::QueuedConnection,Q_ARG(ClientCardModel&, mainGame->dField.deck[player]));
//            mainGame->dField.grave[player].swap(mainGame->dField.deck[player]);
            for (auto cit = mainGame->dField.grave[player].begin(); cit != mainGame->dField.grave[player].end(); ++cit) {
                (*cit)->location = LOCATION_GRAVE;
                mainGame->dField.MoveCard(*cit, 10);
            }
            for (auto cit = mainGame->dField.deck[player].begin(); cit != mainGame->dField.deck[player].end(); ) {
                ClientCard* pcard = *cit;
                if (pcard->type & 0x802040) {
                    pcard->location = LOCATION_EXTRA;
                    QMetaObject::invokeMethod(&mainGame->dField.extra[player],"push_back",Qt::QueuedConnection,Q_ARG(ClientCard*, pcard));
                    QMetaObject::invokeMethod(&mainGame->dField.deck[player],"erase",Qt::QueuedConnection,Q_RETURN_ARG(myIter, cit), Q_ARG(myIter, cit));
//                    cit = mainGame->dField.deck[player].erase(cit);
                } else {
                    pcard->location = LOCATION_DECK;
                    ++cit;
                }
                mainGame->dField.MoveCard(pcard, 10);
            }

//			mainGame->WaitFrameSignal(11);
        }
        return true;
    }
    case MSG_REVERSE_DECK: {
        mainGame->dField.deck_reversed = !mainGame->dField.deck_reversed;
        if(!mainGame->dInfo.isReplay || !mainGame->dInfo.isReplaySkiping) {
            for(size_t i = 0; i < (unsigned int)mainGame->dField.deck[0].size(); ++i)
                mainGame->dField.MoveCard(mainGame->dField.deck[0][i], 10);
            for(size_t i = 0; i < (unsigned int)mainGame->dField.deck[1].size(); ++i)
                mainGame->dField.MoveCard(mainGame->dField.deck[1][i], 10);
        }
        return true;
    }
    case MSG_DECK_TOP: {
        int player = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
        int seq = BufferIO::ReadInt8(pbuf);
        unsigned int code = (unsigned int)BufferIO::ReadInt32(pbuf);
        ClientCard* pcard = mainGame->dField.GetCard(player, LOCATION_DECK, mainGame->dField.deck[player].size() - 1 - seq);
        pcard->SetCode(code & 0x7fffffff);
        bool rev = (code & 0x80000000) != 0;
        if(pcard->is_reversed != rev) {
            pcard->is_reversed = rev;
            mainGame->dField.MoveCard(pcard, 5);
        }
        return true;
    }
    case MSG_SHUFFLE_SET_CARD: {
        QList<ClientCard*>::iterator cit;
        int count = BufferIO::ReadInt8(pbuf);
        ClientCard* mc[5];
        ClientCard* swp;
        int c, l, s, ps;
        for (int i = 0; i < count; ++i) {
            c = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            l = BufferIO::ReadInt8(pbuf);
            s = BufferIO::ReadInt8(pbuf);
            BufferIO::ReadInt8(pbuf);
            mc[i] = mainGame->dField.mzone[c][s];
            mc[i]->SetCode(0);
            if(!mainGame->dInfo.isReplay || !mainGame->dInfo.isReplaySkiping) {
                mc[i]->dPos = QVector3D((3.95f - mc[i]->curPos.x()) / 10, 0, 0.05f);
                mc[i]->dRot = QVector3D(0, 0, 0);
                mc[i]->is_moving = true;
                mc[i]->aniFrame = 10;
            }
        }
//		if(!mainGame->dInfo.isReplay || !mainGame->dInfo.isReplaySkiping)
//			mainGame->WaitFrameSignal(20);
        for (int i = 0; i < count; ++i) {
            c = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            l = BufferIO::ReadInt8(pbuf);
            s = BufferIO::ReadInt8(pbuf);
            BufferIO::ReadInt8(pbuf);
            ps = mc[i]->sequence;
            if (l > 0) {
                swp = mainGame->dField.mzone[c][s];
                mainGame->dField.mzone[c][ps] = swp;
                mainGame->dField.mzone[c][s] = mc[i];
                mc[i]->sequence = s;
                swp->sequence = ps;
            }
        }
        if(!mainGame->dInfo.isReplay || !mainGame->dInfo.isReplaySkiping) {
            for (int i = 0; i < count; ++i) {
                mainGame->dField.MoveCard(mc[i], 10);
                for (cit = mc[i]->overlayed.begin(); cit != mc[i]->overlayed.end(); ++cit)
                    mainGame->dField.MoveCard(*cit, 10);
            }
//			mainGame->WaitFrameSignal(11);
        }
        return true;
    }
    case MSG_NEW_TURN: {
            int player = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            mainGame->dInfo.turn++;
            if(!mainGame->dInfo.isTag && mainGame->dInfo.turn == 5 && !mainGame->dInfo.isReplay && mainGame->dInfo.player_type < 7) {
                    mainGame->stLeaveGame = QString::fromWCharArray(dataManager.GetSysString(1351));
                    mainGame->btnLeaveGame = true;
            }
            if(mainGame->dInfo.isTag && mainGame->dInfo.turn != 1) {
                    if(player == 0)
                            mainGame->dInfo.tag_player[0] = !mainGame->dInfo.tag_player[0];
                    else
                            mainGame->dInfo.tag_player[1] = !mainGame->dInfo.tag_player[1];
            }
            if(!mainGame->dInfo.isReplay || !mainGame->dInfo.isReplaySkiping) {
                    myswprintf(mainGame->dInfo.strTurn, L"Turn:%d", mainGame->dInfo.turn);
                    mainGame->showcardcode = 10;
                    mainGame->showcarddif = 30;
                    mainGame->showcardp = 0;
                    mainGame->showcard = 101;
//                    mainGame->WaitFrameSignal(40);
                    mainGame->showcard = 0;
            }
            return true;
    }
    case MSG_NEW_PHASE: {
            int phase = (unsigned char)BufferIO::ReadInt8(pbuf);
            mainGame->btnDP = false;
            mainGame->btnSP = false;
            mainGame->btnM1 = false;
            mainGame->btnBP = false;
            mainGame->btnM2 = false;
            mainGame->btnEP = false;
            mainGame->showcarddif = 30;
            mainGame->showcardp = 0;
            switch (phase) {
            case PHASE_DRAW:
                    mainGame->btnDP = true;
                    mainGame->showcardcode = 4;
                    break;
            case PHASE_STANDBY:
                    mainGame->btnSP = true;
                    mainGame->showcardcode = 5;
                    break;
            case PHASE_MAIN1:
                    mainGame->btnM1 = true;
                    mainGame->showcardcode = 6;
                    break;
            case PHASE_BATTLE:
                    mainGame->btnBP = false;
//                    mainGame->btnBP->setPressed(true);
//                    mainGame->btnBP->setEnabled(false);
                    mainGame->showcardcode = 7;
                    break;
            case PHASE_MAIN2:
                    mainGame->btnM2 = false;
//                    mainGame->btnM2->setPressed(true);
//                    mainGame->btnM2->setEnabled(false);
                    mainGame->showcardcode = 8;
                    break;
            case PHASE_END:
                    mainGame->btnEP = false;
//                    mainGame->btnEP->setPressed(true);
//                    mainGame->btnEP->setEnabled(false);
                    mainGame->showcardcode = 9;
                    break;
            }
            if(!mainGame->dInfo.isReplay || !mainGame->dInfo.isReplaySkiping) {
                    mainGame->showcard = 101;
//                    mainGame->WaitFrameSignal(40);
                    mainGame->showcard = 0;
            }
            return true;
    }
    case MSG_MOVE: {
            unsigned int code = (unsigned int)BufferIO::ReadInt32(pbuf);
            int pc = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));   // player - controller
            int pl = BufferIO::ReadUInt8(pbuf); // player - location
            int ps = BufferIO::ReadInt8(pbuf);  // player - sequence
            int pp = BufferIO::ReadInt8(pbuf);
            int cc = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            int cl = BufferIO::ReadUInt8(pbuf);
            int cs = BufferIO::ReadInt8(pbuf);
            int cp = BufferIO::ReadInt8(pbuf);
            /*int reason = */BufferIO::ReadInt32(pbuf);
            if (pl == 0) {
                    ClientCard* pcard = new ClientCard();
                    pcard->position = cp;
                    pcard->SetCode(code);
                    if(!mainGame->dInfo.isReplay || !mainGame->dInfo.isReplaySkiping) {

                            mainGame->dField.AddCard(pcard, cc, cl, cs);

//                            mainGame->dField.GetCardLocation(pcard, &pcard->curPos, &pcard->curRot);
//                            pcard->mTransform.setTranslation(pcard->curPos);
//                            pcard->mTransform.setRotationRadians(pcard->curRot);
                            pcard->curAlpha = 5;
                            mainGame->dField.FadeCard(pcard, 255, 20);
//                            mainGame->WaitFrameSignal(20);
                    } else
                            mainGame->dField.AddCard(pcard, cc, cl, cs);
            } else if (cl == 0) {
                    ClientCard* pcard = mainGame->dField.GetCard(pc, pl, ps);
                    if (code != 0 && pcard->code != code)
                            pcard->SetCode(code);
                    pcard->ClearTarget();
                    for(auto eqit = pcard->equipped.begin(); eqit != pcard->equipped.end(); ++eqit)
                            (*eqit)->equipTarget = 0;
                    if(!mainGame->dInfo.isReplay || !mainGame->dInfo.isReplaySkiping) {
                            mainGame->dField.FadeCard(pcard, 5, 20);
//                            mainGame->WaitFrameSignal(20);

                            mainGame->dField.RemoveCard(pc, pl, ps);

                            if(pcard == mainGame->dField.hovered_card)
                                    mainGame->dField.hovered_card = 0;
                    } else
                            mainGame->dField.RemoveCard(pc, pl, ps);
                    delete pcard;
            } else {
                    if (!(pl & 0x80) && !(cl & 0x80)) {
                            ClientCard* pcard = mainGame->dField.GetCard(pc, pl, ps);
                            if (pcard->code != code && (code != 0 || cl == 0x40))
                                    pcard->SetCode(code);
                            pcard->cHint = 0;
                            pcard->chValue = 0;
                            if((pl & LOCATION_ONFIELD) && (cl != pl))
                                    pcard->counters.clear();
                            if(cl != pl) {
                                    pcard->ClearTarget();
                                    if(pcard->equipTarget) {
                                            pcard->equipTarget->is_showequip = false;
                                            pcard->equipTarget->equipped.erase(pcard->equipTarget->equipped.find(pcard));
                                            pcard->equipTarget = 0;
                                    }
                            }
                            pcard->is_showequip = false;
                            pcard->is_showtarget = false;
                            if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping) {
                                    mainGame->dField.RemoveCard(pc, pl, ps);
                                    pcard->position = cp;
                                    mainGame->dField.AddCard(pcard, cc, cl, cs);
                            } else {

                                    mainGame->dField.RemoveCard(pc, pl, ps);
                                    pcard->position = cp;
                                    mainGame->dField.AddCard(pcard, cc, cl, cs);

                                    if (pl == cl && pc == cc && (cl & 0x71)) {
                                            pcard->dPos = QVector3D(-0.3f, 0, 0);
                                            pcard->dRot = QVector3D(0, 0, 0);
                                            if (pc == 1)
                                                pcard->dPos.setX(0.3f);
                                            pcard->is_moving = true;
                                            pcard->aniFrame = 5;
//                                            mainGame->WaitFrameSignal(5);
                                            mainGame->dField.MoveCard(pcard, 5);
//                                            mainGame->WaitFrameSignal(5);
                                    } else {
                                            if (cl == 0x4 && pcard->overlayed.size() > 0) {

                                                    for (size_t i = 0; i < (unsigned int)pcard->overlayed.size(); ++i)
                                                            mainGame->dField.MoveCard(pcard->overlayed[i], 10);

//                                                    mainGame->WaitFrameSignal(10);
                                            }
                                            if (cl == 0x2) {

                                                    for (size_t i = 0; i < (unsigned int)mainGame->dField.hand[cc].size(); ++i)
                                                            mainGame->dField.MoveCard(mainGame->dField.hand[cc][i], 10);

                                            } else {

                                                    mainGame->dField.MoveCard(pcard, 10);
                                                    if (pl == 0x2)
                                                            for (size_t i = 0; i < (unsigned int)mainGame->dField.hand[pc].size(); ++i)
                                                                    mainGame->dField.MoveCard(mainGame->dField.hand[pc][i], 10);

                                            }
//                                            mainGame->WaitFrameSignal(5);
                                    }
                            }
                    } else if (!(pl & 0x80)) {
                            ClientCard* pcard = mainGame->dField.GetCard(pc, pl, ps);
                            if (code != 0 && pcard->code != code)
                                    pcard->SetCode(code);
                            pcard->counters.clear();
                            pcard->ClearTarget();
                            ClientCard* olcard = mainGame->dField.GetCard(cc, cl & 0x7f, cs);
                            if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping) {
                                    mainGame->dField.RemoveCard(pc, pl, ps);
                                    olcard->overlayed.push_back(pcard);
                                    mainGame->dField.overlay_cards.insert(pcard);
                                    pcard->overlayTarget = olcard;
                                    pcard->location = 0x80;
                                    pcard->sequence = olcard->overlayed.size() - 1;
                            } else {

                                    mainGame->dField.RemoveCard(pc, pl, ps);
                                    olcard->overlayed.push_back(pcard);
                                    mainGame->dField.overlay_cards.insert(pcard);

                                    pcard->overlayTarget = olcard;
                                    pcard->location = 0x80;
                                    pcard->sequence = olcard->overlayed.size() - 1;
                                    if (olcard->location == 0x4) {

                                            mainGame->dField.MoveCard(pcard, 10);
                                            if (pl == 0x2)
                                                    for (size_t i = 0; i < (unsigned int)mainGame->dField.hand[pc].size(); ++i)
                                                            mainGame->dField.MoveCard(mainGame->dField.hand[pc][i], 10);

//                                            mainGame->WaitFrameSignal(5);
                                    }
                            }
                    } else if (!(cl & 0x80)) {
                            ClientCard* olcard = mainGame->dField.GetCard(pc, pl & 0x7f, ps);
                            ClientCard* pcard = olcard->overlayed[pp];
                            if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping) {
                                    olcard->overlayed.erase(olcard->overlayed.begin() + pcard->sequence);
                                    pcard->overlayTarget = 0;
                                    pcard->position = cp;
                                    mainGame->dField.AddCard(pcard, cc, cl, cs);
                                    mainGame->dField.overlay_cards.erase(mainGame->dField.overlay_cards.find(pcard));
                                    for (size_t i = 0; i < (unsigned int)olcard->overlayed.size(); ++i)
                                            olcard->overlayed[i]->sequence = i;
                            } else {

                                    olcard->overlayed.erase(olcard->overlayed.begin() + pcard->sequence);
                                    pcard->overlayTarget = 0;
                                    pcard->position = cp;
                                    mainGame->dField.AddCard(pcard, cc, cl, cs);
                                    mainGame->dField.overlay_cards.erase(mainGame->dField.overlay_cards.find(pcard));
                                    for (size_t i = 0; i < (unsigned int)olcard->overlayed.size(); ++i) {
                                            olcard->overlayed[i]->sequence = i;
                                            mainGame->dField.MoveCard(olcard->overlayed[i], 2);
                                    }

//                                    mainGame->WaitFrameSignal(5);

                                    mainGame->dField.MoveCard(pcard, 10);

//                                    mainGame->WaitFrameSignal(5);
                            }
                    } else {
                            ClientCard* olcard1 = mainGame->dField.GetCard(pc, pl & 0x7f, ps);
                            ClientCard* pcard = olcard1->overlayed[pp];
                            ClientCard* olcard2 = mainGame->dField.GetCard(cc, cl & 0x7f, cs);
                            if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping) {
                                    olcard1->overlayed.erase(olcard1->overlayed.begin() + pcard->sequence);
                                    olcard2->overlayed.push_back(pcard);
                                    pcard->sequence = olcard2->overlayed.size() - 1;
                                    pcard->location = 0x80;
                                    pcard->overlayTarget = olcard2;
                                    for (size_t i = 0; i < (unsigned int)olcard1->overlayed.size(); ++i) {
                                            olcard1->overlayed[i]->sequence = i;
                                    }
                            } else {

                                    olcard1->overlayed.erase(olcard1->overlayed.begin() + pcard->sequence);
                                    olcard2->overlayed.push_back(pcard);
                                    pcard->sequence = olcard2->overlayed.size() - 1;
                                    pcard->location = 0x80;
                                    pcard->overlayTarget = olcard2;
                                    for (size_t i = 0; i < (unsigned int)olcard1->overlayed.size(); ++i) {
                                            olcard1->overlayed[i]->sequence = i;
                                            mainGame->dField.MoveCard(olcard1->overlayed[i], 2);
                                    }
                                    mainGame->dField.MoveCard(pcard, 10);

//                                    mainGame->WaitFrameSignal(5);
                            }
                    }
            }
            return true;
    }
    case MSG_POS_CHANGE: {
            unsigned int code = (unsigned int)BufferIO::ReadInt32(pbuf);
            int cc = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            int cl = BufferIO::ReadInt8(pbuf);
            int cs = BufferIO::ReadInt8(pbuf);
            int pp = BufferIO::ReadInt8(pbuf);
            int cp = BufferIO::ReadInt8(pbuf);
            ClientCard* pcard = mainGame->dField.GetCard(cc, cl, cs);
            if((pp & POS_FACEUP) && (cp & POS_FACEDOWN)) {
                    pcard->counters.clear();
                    pcard->ClearTarget();
            }
            if (code != 0 && pcard->code != code)
                    pcard->SetCode(code);
            pcard->position = cp;
            if(!mainGame->dInfo.isReplay || !mainGame->dInfo.isReplaySkiping) {
                    myswprintf(event_string, dataManager.GetSysString(1600));
                    mainGame->dField.MoveCard(pcard, 10);
//                    mainGame->WaitFrameSignal(11);
            }
            return true;
    }
    case MSG_SET: {
            /*int code = */BufferIO::ReadInt32(pbuf);
            /*int cc = mainGame->LocalPlayer*/(BufferIO::ReadInt8(pbuf));
            /*int cl = */BufferIO::ReadInt8(pbuf);
            /*int cs = */BufferIO::ReadInt8(pbuf);
            /*int cp = */BufferIO::ReadInt8(pbuf);
            myswprintf(event_string, dataManager.GetSysString(1601));
            return true;
    }
    case MSG_SWAP: {
            /*int code1 = */BufferIO::ReadInt32(pbuf);
            int c1 = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            int l1 = BufferIO::ReadInt8(pbuf);
            int s1 = BufferIO::ReadInt8(pbuf);
            /*int p1 = */BufferIO::ReadInt8(pbuf);
            /*int code2 = */BufferIO::ReadInt32(pbuf);
            int c2 = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            int l2 = BufferIO::ReadInt8(pbuf);
            int s2 = BufferIO::ReadInt8(pbuf);
            /*int p2 = */BufferIO::ReadInt8(pbuf);
            myswprintf(event_string, dataManager.GetSysString(1602));
            ClientCard* pc1 = mainGame->dField.GetCard(c1, l1, s1);
            ClientCard* pc2 = mainGame->dField.GetCard(c2, l2, s2);
            if(!mainGame->dInfo.isReplay || !mainGame->dInfo.isReplaySkiping) {

                    mainGame->dField.RemoveCard(c1, l1, s1);
                    mainGame->dField.RemoveCard(c2, l2, s2);
                    mainGame->dField.AddCard(pc1, c2, l2, s2);
                    mainGame->dField.AddCard(pc2, c1, l1, s1);
                    mainGame->dField.MoveCard(pc1, 10);
                    mainGame->dField.MoveCard(pc2, 10);
                    for (size_t i = 0; i < (unsigned int)pc1->overlayed.size(); ++i)
                            mainGame->dField.MoveCard(pc1->overlayed[i], 10);
                    for (size_t i = 0; i < (unsigned int)pc2->overlayed.size(); ++i)
                            mainGame->dField.MoveCard(pc2->overlayed[i], 10);

//                    mainGame->WaitFrameSignal(11);
            } else {
                    mainGame->dField.RemoveCard(c1, l1, s1);
                    mainGame->dField.RemoveCard(c2, l2, s2);
                    mainGame->dField.AddCard(pc1, c2, l2, s2);
                    mainGame->dField.AddCard(pc2, c1, l1, s1);
            }
            return true;
    }
    case MSG_FIELD_DISABLED: {
            int disabled = BufferIO::ReadInt32(pbuf);
            if (!mainGame->dInfo.isFirst)
                    disabled = (disabled >> 16) | (disabled << 16);
            mainGame->dField.disabled_field = disabled;
            return true;
    }
    case MSG_SUMMONING: {
            unsigned int code = (unsigned int)BufferIO::ReadInt32(pbuf);
            /*int cc = */mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            /*int cl = */BufferIO::ReadInt8(pbuf);
            /*int cs = */BufferIO::ReadInt8(pbuf);
            /*int cp = */BufferIO::ReadInt8(pbuf);
            if(!mainGame->dInfo.isReplay || !mainGame->dInfo.isReplaySkiping) {
                    myswprintf(event_string, dataManager.GetSysString(1603), dataManager.GetName(code));
                    mainGame->showcardcode = code;
                    mainGame->showcarddif = 0;
                    mainGame->showcardp = 0;
                    mainGame->showcard = 7;
//                    mainGame->WaitFrameSignal(30);
                    mainGame->showcard = 0;
//                    mainGame->WaitFrameSignal(11);
            }
            return true;
    }
    case MSG_SUMMONED: {
            myswprintf(event_string, dataManager.GetSysString(1604));
            return true;
    }
    case MSG_SPSUMMONING: {
            unsigned int code = (unsigned int)BufferIO::ReadInt32(pbuf);
            /*int cc = */mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            /*int cl = */BufferIO::ReadInt8(pbuf);
            /*int cs = */BufferIO::ReadInt8(pbuf);
            /*int cp = */BufferIO::ReadInt8(pbuf);
            if(!mainGame->dInfo.isReplay || !mainGame->dInfo.isReplaySkiping) {
                    myswprintf(event_string, dataManager.GetSysString(1605), dataManager.GetName(code));
                    mainGame->showcardcode = code;
                    mainGame->showcarddif = 1;
                    mainGame->showcard = 5;
//                    mainGame->WaitFrameSignal(30);
                    mainGame->showcard = 0;
//                    mainGame->WaitFrameSignal(11);
            }
            return true;
    }
    case MSG_SPSUMMONED: {
            myswprintf(event_string, dataManager.GetSysString(1606));
            return true;
    }
    case MSG_FLIPSUMMONING: {
            unsigned int code = (unsigned int)BufferIO::ReadInt32(pbuf);
            int cc = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            int cl = BufferIO::ReadInt8(pbuf);
            int cs = BufferIO::ReadInt8(pbuf);
            int cp = BufferIO::ReadInt8(pbuf);
            ClientCard* pcard = mainGame->dField.GetCard(cc, cl, cs);
            pcard->SetCode(code);
            pcard->position = cp;
            if(!mainGame->dInfo.isReplay || !mainGame->dInfo.isReplaySkiping) {
                    myswprintf(event_string, dataManager.GetSysString(1607), dataManager.GetName(code));
                    mainGame->dField.MoveCard(pcard, 10);
//                    mainGame->WaitFrameSignal(11);
                    mainGame->showcardcode = code;
                    mainGame->showcarddif = 0;
                    mainGame->showcardp = 0;
                    mainGame->showcard = 7;
//                    mainGame->WaitFrameSignal(30);
                    mainGame->showcard = 0;
//                    mainGame->WaitFrameSignal(11);
            }
            return true;
    }
    case MSG_FLIPSUMMONED: {
            myswprintf(event_string, dataManager.GetSysString(1608));
            return true;
    }
    case MSG_CHAINING: {
            unsigned int code = (unsigned int)BufferIO::ReadInt32(pbuf);
            int pcc = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            int pcl = BufferIO::ReadInt8(pbuf);
            int pcs = BufferIO::ReadInt8(pbuf);
            int subs = BufferIO::ReadInt8(pbuf);
            int cc = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            int cl = BufferIO::ReadInt8(pbuf);
            int cs = BufferIO::ReadInt8(pbuf);
            int desc = BufferIO::ReadInt32(pbuf);
            /*int ct = */BufferIO::ReadInt8(pbuf);
            if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping)
                    return true;
            ClientCard* pcard = mainGame->dField.GetCard(pcc, pcl, pcs, subs);
            if(pcard->code != code) {
                    pcard->code = code;
                    mainGame->dField.MoveCard(pcard, 10);
            }
            mainGame->showcardcode = code;
            mainGame->showcarddif = 0;
            mainGame->showcard = 1;
            pcard->is_highlighting = true;
//            mainGame->WaitFrameSignal(30);
            pcard->is_highlighting = false;
            mainGame->dField.current_chain.chain_card = pcard;
            mainGame->dField.current_chain.code = code;
            mainGame->dField.current_chain.desc = desc;
            mainGame->dField.current_chain.controler = cc;
            mainGame->dField.current_chain.location = cl;
            mainGame->dField.current_chain.sequence = cs;
            mainGame->dField.GetChainLocation(cc, cl, cs, &mainGame->dField.current_chain.chain_pos);
            mainGame->dField.current_chain.solved = false;
            int chc = 0;
            for(size_t i = 0; i < (unsigned int)mainGame->dField.chains.size(); ++i) {
                    if (cl == 0x10 || cl == 0x20) {
                            if (mainGame->dField.chains[i].controler == cc && mainGame->dField.chains[i].location == cl)
                                    chc++;
                    } else {
                            if (mainGame->dField.chains[i].controler == cc && mainGame->dField.chains[i].location == cl && mainGame->dField.chains[i].sequence == cs)
                                    chc++;
                    }
            }
            if(cl == LOCATION_HAND)
                    mainGame->dField.current_chain.chain_pos.setX(mainGame->dField.current_chain.chain_pos.x() + 0.35f);
            else
                    mainGame->dField.current_chain.chain_pos.setY(mainGame->dField.current_chain.chain_pos.y() + chc * 0.25f);
            return true;
    }
    case MSG_CHAINED: {
            /*int ct = */BufferIO::ReadInt8(pbuf);
            if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping)
                    return true;
            myswprintf(event_string, dataManager.GetSysString(1609), dataManager.GetName(mainGame->dField.current_chain.code));

            mainGame->dField.chains.push_back(mainGame->dField.current_chain);

//            if (ct > 1)
//                    mainGame->WaitFrameSignal(20);
            mainGame->dField.last_chain = true;
            return true;
    }
    case MSG_CHAIN_SOLVING: {
            int ct = BufferIO::ReadInt8(pbuf);
            if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping)
                    return true;
            if (mainGame->dField.chains.size() > 1) {
//                    if (mainGame->dField.last_chain)
//                            mainGame->WaitFrameSignal(11);
                    for(int i = 0; i < 5; ++i) {
                            mainGame->dField.chains[ct - 1].solved = false;
//                            mainGame->WaitFrameSignal(3);
                            mainGame->dField.chains[ct - 1].solved = true;
//                            mainGame->WaitFrameSignal(3);
                    }
            }
            mainGame->dField.last_chain = false;
            return true;
    }
    case MSG_CHAIN_SOLVED: {
            /*int ct = */BufferIO::ReadInt8(pbuf);
            return true;
    }
    case MSG_CHAIN_END: {
            mainGame->dField.chains.clear();
            return true;
    }
    case MSG_CHAIN_NEGATED:
    case MSG_CHAIN_DISABLED: {
            int ct = BufferIO::ReadInt8(pbuf);
            if(!mainGame->dInfo.isReplay || !mainGame->dInfo.isReplaySkiping) {
                    mainGame->showcardcode = mainGame->dField.chains[ct - 1].code;
                    mainGame->showcarddif = 0;
                    mainGame->showcard = 3;
//                    mainGame->WaitFrameSignal(30);
                    mainGame->showcard = 0;
            }
            return true;
    }
    case MSG_CARD_SELECTED: {
            return true;
    }
    case MSG_RANDOM_SELECTED: {
            /*int player = */BufferIO::ReadInt8(pbuf);
            int count = BufferIO::ReadInt8(pbuf);
            if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping) {
                    pbuf += count * 4;
                    return true;
            }
            ClientCard* pcards[10];
            for (int i = 0; i < count; ++i) {
                    int c = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
                    int l = BufferIO::ReadInt8(pbuf);
                    int s = BufferIO::ReadInt8(pbuf);
                    int ss = BufferIO::ReadInt8(pbuf);
                    if ((l & 0x80) > 0)
                            pcards[i] = mainGame->dField.GetCard(c, l & 0x7f, s)->overlayed[ss];
                    else
                            pcards[i] = mainGame->dField.GetCard(c, l, s);
                    pcards[i]->is_highlighting = true;
            }
//            mainGame->WaitFrameSignal(30);
            for(int i = 0; i < count; ++i)
                    pcards[i]->is_highlighting = false;
            return true;
    }
    case MSG_BECOME_TARGET: {
            int count = BufferIO::ReadInt8(pbuf);
            if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping) {
                    pbuf += count * 4;
                    return true;
            }
            ClientCard* pcard;
            for (int i = 0; i < count; ++i) {
                    int c = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
                    int l = BufferIO::ReadInt8(pbuf);
                    int s = BufferIO::ReadInt8(pbuf);
                    /*int ss = */BufferIO::ReadInt8(pbuf);
                    pcard = mainGame->dField.GetCard(c, l, s);
                    pcard->is_highlighting = true;
                    if(pcard->location & LOCATION_ONFIELD) {
                            for (int j = 0; j < 3; ++j) {
                                    mainGame->dField.FadeCard(pcard, 5, 5);
//                                    mainGame->WaitFrameSignal(5);
                                    mainGame->dField.FadeCard(pcard, 255, 5);
//                                    mainGame->WaitFrameSignal(5);
                            }
                    } /*else
                            mainGame->WaitFrameSignal(30);*/
                    myswprintf(textBuffer, dataManager.GetSysString(1610), dataManager.GetName(pcard->code), dataManager.FormatLocation(l, s), s);
//                    mainGame->lstLog->addItem(textBuffer);
//                    mainGame->logParam.push_back(pcard->code);
                    pcard->is_highlighting = false;
            }
            return true;
    }
    case MSG_DRAW: {
            int player = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            int count = BufferIO::ReadInt8(pbuf);
            ClientCard* pcard;
            for (int i = 0; i < count; ++i) {
                    unsigned int code = (unsigned int)BufferIO::ReadInt32(pbuf);
                    pcard = mainGame->dField.GetCard(player, LOCATION_DECK, mainGame->dField.deck[player].size() - 1 - i);
                    if(!mainGame->dField.deck_reversed || code)
                            pcard->SetCode(code & 0x7fffffff);
            }
            if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping) {
                    for (int i = 0; i < count; ++i) {
                            pcard = mainGame->dField.GetCard(player, LOCATION_DECK, mainGame->dField.deck[player].size() - 1);
                            QMetaObject::invokeMethod(&mainGame->dField.deck[player],"erase",Qt::QueuedConnection, Q_ARG(myIter, mainGame->dField.deck[player].end() - 1));
//                            mainGame->dField.deck[player].erase(mainGame->dField.deck[player].end() - 1);
                            mainGame->dField.AddCard(pcard, player, LOCATION_HAND, 0);
                    }
            } else {
                    for (int i = 0; i < count; ++i) {

                            pcard = mainGame->dField.GetCard(player, LOCATION_DECK, mainGame->dField.deck[player].size() - 1);
                            QMetaObject::invokeMethod(&mainGame->dField.deck[player],"erase",Qt::QueuedConnection, Q_ARG(myIter, mainGame->dField.deck[player].end() - 1));
                            mainGame->dField.AddCard(pcard, player, LOCATION_HAND, 0);
                            for(size_t i = 0; i < (unsigned int)mainGame->dField.hand[player].size(); ++i)
                                    mainGame->dField.MoveCard(mainGame->dField.hand[player][i], 10);

//                            mainGame->WaitFrameSignal(5);
                    }
            }
            if (player == 0)
                    myswprintf(event_string, dataManager.GetSysString(1611), count);
            else myswprintf(event_string, dataManager.GetSysString(1612), count);
            return true;
    }
    case MSG_DAMAGE: {
            int player = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            int val = BufferIO::ReadInt32(pbuf);
            int final = mainGame->dInfo.lp[player] - val;
            if (final < 0)
                    final = 0;
            if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping) {
                    mainGame->dInfo.lp[player] = final;
//                    myswprintf(mainGame->dInfo.strLP[player], L"%d", mainGame->dInfo.lp[player]);
                    return true;
            }
            mainGame->lpd = (mainGame->dInfo.lp[player] - final) / 10;
            if (player == 0)
                    myswprintf(event_string, dataManager.GetSysString(1613), val);
            else
                    myswprintf(event_string, dataManager.GetSysString(1614), val);
            mainGame->lpccolor = 0xffff0000;
            mainGame->lpplayer = player;
            myswprintf(textBuffer, L"-%d", val);
            mainGame->lpcstring = textBuffer;
//            mainGame->WaitFrameSignal(30);
//            mainGame->lpframe = 10;
//            mainGame->WaitFrameSignal(11);
            mainGame->lpcstring = 0;
            mainGame->dInfo.lp[player] = final;

//            myswprintf(mainGame->dInfo.strLP[player], L"%d", mainGame->dInfo.lp[player]);

            return true;
    }
    case MSG_RECOVER: {
            int player = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            int val = BufferIO::ReadInt32(pbuf);
            int final = mainGame->dInfo.lp[player] + val;
            if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping) {
                    mainGame->dInfo.lp[player] = final;
//                    myswprintf(mainGame->dInfo.strLP[player], L"%d", mainGame->dInfo.lp[player]);
                    return true;
            }
            mainGame->lpd = (mainGame->dInfo.lp[player] - final) / 10;
            if (player == 0)
                    myswprintf(event_string, dataManager.GetSysString(1615), val);
            else
                    myswprintf(event_string, dataManager.GetSysString(1616), val);
            mainGame->lpccolor = 0xff00ff00;
            mainGame->lpplayer = player;
            myswprintf(textBuffer, L"+%d", val);
            mainGame->lpcstring = textBuffer;
//            mainGame->WaitFrameSignal(30);
//            mainGame->lpframe = 10;
//            mainGame->WaitFrameSignal(11);
            mainGame->lpcstring = 0;
            mainGame->dInfo.lp[player] = final;

//            myswprintf(mainGame->dInfo.strLP[player], L"%d", mainGame->dInfo.lp[player]);

            return true;
    }
    case MSG_EQUIP: {
            int c1 = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            int l1 = BufferIO::ReadInt8(pbuf);
            int s1 = BufferIO::ReadInt8(pbuf);
            BufferIO::ReadInt8(pbuf);
            int c2 = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            int l2 = BufferIO::ReadInt8(pbuf);
            int s2 = BufferIO::ReadInt8(pbuf);
            BufferIO::ReadInt8(pbuf);
            ClientCard* pc1 = mainGame->dField.GetCard(c1, l1, s1);
            ClientCard* pc2 = mainGame->dField.GetCard(c2, l2, s2);
            if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping) {
                    pc1->equipTarget = pc2;
                    pc2->equipped.insert(pc1);
            } else {

                    pc1->equipTarget = pc2;
                    pc2->equipped.insert(pc1);
                    if (mainGame->dField.hovered_card == pc1)
                            pc2->is_showequip = true;
                    else if (mainGame->dField.hovered_card == pc2)
                            pc1->is_showequip = true;

            }
            return true;
    }
    case MSG_LPUPDATE: {
            int player = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            int val = BufferIO::ReadInt32(pbuf);
            if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping) {
                    mainGame->dInfo.lp[player] = val;
//                    myswprintf(mainGame->dInfo.strLP[player], L"%d", mainGame->dInfo.lp[player]);
                    return true;
            }
            mainGame->lpd = (mainGame->dInfo.lp[player] - val) / 10;
            mainGame->lpplayer = player;
//            mainGame->lpframe = 10;
//            mainGame->WaitFrameSignal(11);
            mainGame->dInfo.lp[player] = val;

//            myswprintf(mainGame->dInfo.strLP[player], L"%d", mainGame->dInfo.lp[player]);

            return true;
    }
    case MSG_UNEQUIP: {
            int c1 = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            int l1 = BufferIO::ReadInt8(pbuf);
            int s1 = BufferIO::ReadInt8(pbuf);
            BufferIO::ReadInt8(pbuf);
            ClientCard* pc = mainGame->dField.GetCard(c1, l1, s1);
            if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping) {
                    pc->equipTarget->equipped.erase(pc->equipTarget->equipped.find(pc));
                    pc->equipTarget = 0;
            } else {

                    if (mainGame->dField.hovered_card == pc)
                            pc->equipTarget->is_showequip = false;
                    else if (mainGame->dField.hovered_card == pc->equipTarget)
                            pc->is_showequip = false;
                    pc->equipTarget->equipped.erase(pc->equipTarget->equipped.find(pc));
                    pc->equipTarget = 0;

            }
            return true;
    }
    case MSG_CARD_TARGET: {
            int c1 = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            int l1 = BufferIO::ReadInt8(pbuf);
            int s1 = BufferIO::ReadInt8(pbuf);
            BufferIO::ReadInt8(pbuf);
            int c2 = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            int l2 = BufferIO::ReadInt8(pbuf);
            int s2 = BufferIO::ReadInt8(pbuf);
            BufferIO::ReadInt8(pbuf);
            ClientCard* pc1 = mainGame->dField.GetCard(c1, l1, s1);
            ClientCard* pc2 = mainGame->dField.GetCard(c2, l2, s2);
            if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping) {
                    pc1->cardTarget.insert(pc2);
                    pc2->ownerTarget.insert(pc1);
            } else {

                    pc1->cardTarget.insert(pc2);
                    pc2->ownerTarget.insert(pc1);
                    if (mainGame->dField.hovered_card == pc1)
                            pc2->is_showtarget = true;
                    else if (mainGame->dField.hovered_card == pc2)
                            pc1->is_showtarget = true;

            }
            break;
    }
    case MSG_CANCEL_TARGET: {
            int c1 = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            int l1 = BufferIO::ReadInt8(pbuf);
            int s1 = BufferIO::ReadInt8(pbuf);
            BufferIO::ReadInt8(pbuf);
            int c2 = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            int l2 = BufferIO::ReadInt8(pbuf);
            int s2 = BufferIO::ReadInt8(pbuf);
            BufferIO::ReadInt8(pbuf);
            ClientCard* pc1 = mainGame->dField.GetCard(c1, l1, s1);
            ClientCard* pc2 = mainGame->dField.GetCard(c2, l2, s2);
            if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping) {
                    pc1->cardTarget.erase(pc1->cardTarget.find(pc2));
                    pc2->ownerTarget.erase(pc2->ownerTarget.find(pc1));
            } else {

                    pc1->cardTarget.erase(pc1->cardTarget.find(pc2));
                    pc2->ownerTarget.erase(pc2->ownerTarget.find(pc1));
                    if (mainGame->dField.hovered_card == pc1)
                            pc2->is_showtarget = false;
                    else if (mainGame->dField.hovered_card == pc2)
                            pc1->is_showtarget = false;

            }
            break;
    }
    case MSG_PAY_LPCOST: {
            int player = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            int cost = BufferIO::ReadInt32(pbuf);
            int final = mainGame->dInfo.lp[player] - cost;
            if (final < 0)
                    final = 0;
            if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping) {
                    mainGame->dInfo.lp[player] = final;
//                    myswprintf(mainGame->dInfo.strLP[player], L"%d", mainGame->dInfo.lp[player]);
                    return true;
            }
            mainGame->lpd = (mainGame->dInfo.lp[player] - final) / 10;
            mainGame->lpccolor = 0xff0000ff;
            mainGame->lpplayer = player;
            myswprintf(textBuffer, L"-%d", cost);
            mainGame->lpcstring = textBuffer;
//            mainGame->WaitFrameSignal(30);
//            mainGame->lpframe = 10;
//            mainGame->WaitFrameSignal(11);
            mainGame->lpcstring = 0;
            mainGame->dInfo.lp[player] = final;

//            myswprintf(mainGame->dInfo.strLP[player], L"%d", mainGame->dInfo.lp[player]);

            return true;
    }
    case MSG_ADD_COUNTER: {
            int type = BufferIO::ReadInt16(pbuf);
            int c = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
            int l = BufferIO::ReadInt8(pbuf);
            int s = BufferIO::ReadInt8(pbuf);
            int count = BufferIO::ReadInt8(pbuf);
            ClientCard* pc = mainGame->dField.GetCard(c, l, s);
            if (pc->counters.count(type))
                    pc->counters[type] += count;
            else pc->counters[type] = count;
            if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping)
                    return true;
            myswprintf(textBuffer, dataManager.GetSysString(1617), dataManager.GetName(pc->code), count, dataManager.GetCounterName(type));
            pc->is_highlighting = true;

            mainGame->stACMessage = QString::fromWCharArray(textBuffer);
            mainGame->wACMessage = true;

//            mainGame->WaitFrameSignal(40);
            pc->is_highlighting = false;
            return true;
    }
    case MSG_REMOVE_COUNTER: {
        int type = BufferIO::ReadInt16(pbuf);
        int c = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
        int l = BufferIO::ReadInt8(pbuf);
        int s = BufferIO::ReadInt8(pbuf);
        int count = BufferIO::ReadInt8(pbuf);
        ClientCard* pc = mainGame->dField.GetCard(c, l, s);
        pc->counters[type] -= count;
        if (pc->counters[type] <= 0)
            pc->counters.erase(pc->counters.find(type));
        if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping)
            return true;
        myswprintf(textBuffer, dataManager.GetSysString(1618), dataManager.GetName(pc->code), count, dataManager.GetCounterName(type));
        pc->is_highlighting = true;

        mainGame->stACMessage = QString::fromWCharArray(textBuffer);
        mainGame->wACMessage = true;

//		mainGame->WaitFrameSignal(40);
        pc->is_highlighting = false;
        return true;
    }
    case MSG_ATTACK: {
        int ca = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
        int la = BufferIO::ReadInt8(pbuf);
        int sa = BufferIO::ReadInt8(pbuf);
        BufferIO::ReadInt8(pbuf);
        mainGame->dField.attacker = mainGame->dField.GetCard(ca, la, sa);
        int cd = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
        int ld = BufferIO::ReadInt8(pbuf);
        int sd = BufferIO::ReadInt8(pbuf);
        BufferIO::ReadInt8(pbuf);
        if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping)
            return true;
//        float sy(0.0);
        if (ld != 0) {
            mainGame->dField.attack_target = mainGame->dField.GetCard(cd, ld, sd);
            myswprintf(event_string, dataManager.GetSysString(1619), dataManager.GetName(mainGame->dField.attacker->code),
                       dataManager.GetName(mainGame->dField.attack_target->code));
            float xa = mainGame->dField.attacker->curPos.x();
            float ya = mainGame->dField.attacker->curPos.y();
            float xd = mainGame->dField.attack_target->curPos.x();
            float yd = mainGame->dField.attack_target->curPos.y();
//            sy = (float)sqrt((xa - xd) * (xa - xd) + (ya - yd) * (ya - yd)) / 2;
            mainGame->atk_t = QVector3D((xa + xd) / 2, (ya + yd) / 2, 0);
            if (ca == 0)
                mainGame->atk_r = QVector3D(0, 0, -atan((xd - xa) / (yd - ya)));
            else
                mainGame->atk_r = QVector3D(0, 0, 3.1415926 - atan((xd - xa) / (yd - ya)));
        } else {
            myswprintf(event_string, dataManager.GetSysString(1620), dataManager.GetName(mainGame->dField.attacker->code));
            float xa = mainGame->dField.attacker->curPos.x();
            float ya = mainGame->dField.attacker->curPos.y();
            float xd = 3.95f;
            float yd = 3.5f;
            if (ca == 0)
                yd = -3.5f;
//            sy = (float)sqrt((xa - xd) * (xa - xd) + (ya - yd) * (ya - yd)) / 2;
            mainGame->atk_t = QVector3D((xa + xd) / 2, (ya + yd) / 2, 0);
            if (ca == 0)
                mainGame->atk_r = QVector3D(0, 0, -atan((xd - xa) / (yd - ya)));
            else
                mainGame->atk_r = QVector3D(0, 0, 3.1415926 - atan((xd - xa) / (yd - ya)));
        }
//        matManager.GenArrow(sy);  // generate arrow here
        mainGame->attack_sv = 0;
        mainGame->is_attacking = true;
//		mainGame->WaitFrameSignal(40);
        mainGame->is_attacking = false;
        return true;
    }
    case MSG_BATTLE: {
        int ca = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
        int la = BufferIO::ReadInt8(pbuf);
        int sa = BufferIO::ReadInt8(pbuf);
        BufferIO::ReadInt8(pbuf);
        int aatk = BufferIO::ReadInt32(pbuf);
        int adef = BufferIO::ReadInt32(pbuf);
        /*int da = */BufferIO::ReadInt8(pbuf);
        int cd = mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
        int ld = BufferIO::ReadInt8(pbuf);
        int sd = BufferIO::ReadInt8(pbuf);
        BufferIO::ReadInt8(pbuf);
        int datk = BufferIO::ReadInt32(pbuf);
        int ddef = BufferIO::ReadInt32(pbuf);
        /*int dd = */BufferIO::ReadInt8(pbuf);
        if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping)
            return true;

        ClientCard* pcard = mainGame->dField.GetCard(ca, la, sa);
        if(aatk != pcard->attack) {
            pcard->attack = aatk;
//            myswprintf(pcard->atkstring, L"%d", aatk);
        }
        if(adef != pcard->defence) {
            pcard->defence = adef;
//            myswprintf(pcard->defstring, L"%d", adef);
        }
        if(ld) {
            pcard = mainGame->dField.GetCard(cd, ld, sd);
            if(datk != pcard->attack) {
                pcard->attack = datk;
//                myswprintf(pcard->atkstring, L"%d", datk);
            }
            if(ddef != pcard->defence) {
                pcard->defence = ddef;
//                myswprintf(pcard->defstring, L"%d", ddef);
            }
        }

        return true;
    }
    case MSG_ATTACK_DISABLED: {
        myswprintf(event_string, dataManager.GetSysString(1621), dataManager.GetName(mainGame->dField.attacker->code));
        return true;
    }
    case MSG_DAMAGE_STEP_START: {
        return true;
    }
    case MSG_DAMAGE_STEP_END: {
        return true;
    }
    case MSG_MISSED_EFFECT: {
        BufferIO::ReadInt32(pbuf);
        unsigned int code = (unsigned int)BufferIO::ReadInt32(pbuf);
        myswprintf(textBuffer, dataManager.GetSysString(1622), dataManager.GetName(code));
//		mainGame->lstLog->addItem(textBuffer);
//		mainGame->logParam.push_back(code);
        return true;
    }
    case MSG_TOSS_COIN: {
        /*int player = */mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
        int count = BufferIO::ReadInt8(pbuf);
        wchar_t* pwbuf = textBuffer;
        BufferIO::CopyWStrRef(dataManager.GetSysString(1623), pwbuf, 256);
        for (int i = 0; i < count; ++i) {
            int res = BufferIO::ReadInt8(pbuf);
            *pwbuf++ = L'[';
            BufferIO::CopyWStrRef(dataManager.GetSysString(res ? 60 : 61), pwbuf, 256);
            *pwbuf++ = L']';
        }
        *pwbuf = 0;
        if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping)
            return true;

//		mainGame->lstLog->addItem(textBuffer);
//		mainGame->logParam.push_back(0);
        mainGame->stACMessage = QString::fromWCharArray(textBuffer);
        mainGame->wACMessage = true;

//		mainGame->WaitFrameSignal(40);
        return true;
    }
    case MSG_TOSS_DICE: {
        /*int player = */mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
        int count = BufferIO::ReadInt8(pbuf);
        wchar_t* pwbuf = textBuffer;
        BufferIO::CopyWStrRef(dataManager.GetSysString(1624), pwbuf, 256);
        for (int i = 0; i < count; ++i) {
            int res = BufferIO::ReadInt8(pbuf);
            *pwbuf++ = L'[';
            *pwbuf++ = L'0' + res;
            *pwbuf++ = L']';
        }
        *pwbuf = 0;
        if(mainGame->dInfo.isReplay && mainGame->dInfo.isReplaySkiping)
            return true;

//		mainGame->lstLog->addItem(textBuffer);
//		mainGame->logParam.push_back(0);
        mainGame->stACMessage = QString::fromWCharArray(textBuffer);
        mainGame->wACMessage = true;

//		mainGame->WaitFrameSignal(40);
        return true;
    }
    case MSG_ANNOUNCE_RACE: {
        /*int player = */mainGame->LocalPlayer(BufferIO::ReadInt8(pbuf));
        mainGame->dField.announce_count = BufferIO::ReadInt8(pbuf);
        /*int available = */BufferIO::ReadInt32(pbuf);
        for(int i = 0, filter = 0x1; i < 24; ++i, filter <<= 1) {
            mainGame->chkRace[i] = false;
//            if(filter & available)
//                mainGame->chkRace[i]->setVisible(true);
//            else mainGame->chkRace[i]->setVisible(false);
        }
        if(select_hint)
            myswprintf(textBuffer, L"%ls", dataManager.GetDesc(select_hint));
        else myswprintf(textBuffer, dataManager.GetSysString(563));
        select_hint = 0;

        mainGame->stANRace = QString::fromWCharArray(textBuffer);
        mainGame->wANRace = true;

        return false;
    }
    }
    return 0;
}

void DuelClient::SetResponseI(int respI) {
    *((int*)response_buf) = respI;
    response_len = 4;
}
void DuelClient::SetResponseB(unsigned char * respB, unsigned char len) {
    memcpy(response_buf, respB, len);
    response_len = len;
}
void DuelClient::SendResponse() {
    switch(mainGame->dInfo.curMsg) {
    case MSG_SELECT_BATTLECMD: {
        mainGame->dField.ClearCommandFlag();
        mainGame->btnM2 = false;
        mainGame->btnEP = false;
        break;
    }
    case MSG_SELECT_IDLECMD: {
        mainGame->dField.ClearCommandFlag();
        mainGame->btnBP = false;
        mainGame->btnEP = false;
        break;
    }
    case MSG_SELECT_CARD: {
        mainGame->dField.ClearSelect();
        break;
    }
    case MSG_SELECT_CHAIN: {
        mainGame->dField.ClearChainSelect();
        break;
    }
    case MSG_SELECT_TRIBUTE: {
        mainGame->dField.ClearSelect();
        break;
    }
    case MSG_SELECT_COUNTER: {
        mainGame->dField.ClearSelect();
        break;
    }
    case MSG_SELECT_SUM: {
        for(size_t i = 0; i < (unsigned int)mainGame->dField.selectsum_all.size(); ++i) {
            mainGame->dField.selectsum_all[i]->is_selectable = false;
            mainGame->dField.selectsum_all[i]->is_selected = false;
        }
        break;
    }
    }
    if(mainGame->dInfo.isSingleMode) {
        SingleMode::SetResponse(response_buf);
//        mainGame->singleSignal.Set();
    } else {
        mainGame->dInfo.time_player = 2;
//        SendBufferToServer(CTOS_RESPONSE, response_buf, response_len);
    }
}

DuelClient::~DuelClient()
{

}

}

