#include <QDebug>
#include "game.h"
#include "singlemode.h"
#include "mtrandom.h"
#include "ocgapi.h"
#include "datamanager.h"
#include "bufferio.h"
#include "field.h"
#include "duelclient.h"

namespace glaze {

long SingleMode::pduel = 0;
bool SingleMode::is_closing = false;
bool SingleMode::is_continuing = false;
wchar_t SingleMode::event_string[256];
int SingleMode::enable_log = 0;
QString SingleMode::name = "";

SingleMode::SingleMode()
{
}

void SingleMode::SetResponse(unsigned char* resp) {
    if(!pduel)
        return;
    set_responseb(pduel, resp);
}

void SingleMode::singlePlayStart()
{
    qDebug()<<"SingleMode run called from?: "<<QThread::currentThreadId();
    QString fname("./single/"+name+".lua");
    char fname2[256];
    strcpy(fname2, fname.toStdString().c_str());
    size_t slen = fname.length();
    qDebug()<<"SingleMode game name after conversion is "<<fname<<" and length is "<<slen;
    qDebug()<<"script name is "<<fname2;
    mtrandom rnd;
    time_t seed = time(0);
    rnd.reset(seed);
    set_card_reader((card_reader)DataManager::CardReader);
    pduel = create_duel(rnd.rand());    
    set_player_info(pduel, 0, 8000, 5, 1);
    set_player_info(pduel, 1, 8000, 5, 1);
    qDebug()<<"card info set. Duel created in ocgcore";
    mainGame->dInfo.lp[0] = 8000;
    mainGame->dInfo.lp[1] = 8000;
//    myswprintf(mainGame->dInfo.strLP[0], L"%d", mainGame->dInfo.lp[0]);
//    myswprintf(mainGame->dInfo.strLP[1], L"%d", mainGame->dInfo.lp[1]);
    mainGame->dInfo.clientname[0] = 0;
    mainGame->dInfo.turn = 0;
    mainGame->dInfo.strTurn[0] = 0;
    qDebug()<<"Duel info set";

    if(!preload_script(pduel, fname2, slen)) {  //loading the lua script for puzzle in ocgcore
        end_duel(pduel);
        qDebug()<<"SingleMode script load ERROR";
        return ;
    }
    qDebug()<<"SingleMode game script loaded successfully";
    //Initialze the field to start the game
    mainGame->dInfo.isFirst = true;
    mainGame->dInfo.isStarted = true;
    mainGame->dInfo.isSingleMode = true;
    mainGame->dField.hovered_card = 0;
    mainGame->dField.clicked_card = 0;
    mainGame->dField.Clear();

    start_duel(pduel, 0);
    char engineBuffer[0x1000];  //size = 4096
    is_closing = false;
    is_continuing = true;
    int len = 0;

    while (is_continuing) {
        int result = process(pduel);    //function from ocgcore
        len = result & 0xffff;
        /* int flag = result >> 16; */
        if (len > 0) {
            get_message(pduel, (byte*)engineBuffer);    //function from ocgcore which return array containing commands of current duel process
            is_continuing = SinglePlayAnalyze(engineBuffer, len);   // the commands from above function are processed here
        }
    }
    mainGame->dField.Clear();
    qDebug()<<"SingleMode game ended";
    end_duel(pduel);
    if(is_closing) {
        //Game ended; do the necessary resetting
        mainGame->dInfo.isStarted = false;
        mainGame->dInfo.isSingleMode = false;
    }
    emit finished();
}

bool SingleMode::SinglePlayAnalyze(char* msg, unsigned int len)
{
    char* offset, *pbuf = msg;
    int player, count;
    while (pbuf - msg < (int)len) {
        if(is_closing || !is_continuing)
            return false;
        offset = pbuf;
        mainGame->dInfo.curMsg = BufferIO::ReadUInt8(pbuf);
        switch (mainGame->dInfo.curMsg) {
        case MSG_RETRY: {
            qDebug()<<"current duel message is "<<mainGame->dInfo.curMsg<<" MSG_RETRY";
            mainGame->wMessage = true;
            mainGame->stMessage = "Error occured.";
            emit mainGame->qwMessageChanged();
            mainGame->actionSignal.reset();
            mainGame->actionSignal.wait();
            return false;
        }
        case MSG_HINT: {
            /*int type = */BufferIO::ReadInt8(pbuf);
            int player = BufferIO::ReadInt8(pbuf);
            /*int data = */BufferIO::ReadInt32(pbuf);
            if(player == 0)
                DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_WIN: {
            pbuf += 2;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            return false;
        }
        case MSG_SELECT_BATTLECMD: {
            player = BufferIO::ReadInt8(pbuf);
            count = BufferIO::ReadInt8(pbuf);
            pbuf += count * 11;
            count = BufferIO::ReadInt8(pbuf);
            pbuf += count * 8 + 2;
            SinglePlayRefresh();
            if(!DuelClient::ClientAnalyze(offset, pbuf - offset)) {
//				mainGame->singleSignal.Reset();
//				mainGame->singleSignal.Wait();
            }
            break;
        }
        case MSG_SELECT_IDLECMD: {
            player = BufferIO::ReadInt8(pbuf);
            count = BufferIO::ReadInt8(pbuf);
            pbuf += count * 7;
            count = BufferIO::ReadInt8(pbuf);
            pbuf += count * 7;
            count = BufferIO::ReadInt8(pbuf);
            pbuf += count * 7;
            count = BufferIO::ReadInt8(pbuf);
            pbuf += count * 7;
            count = BufferIO::ReadInt8(pbuf);
            pbuf += count * 7;
            count = BufferIO::ReadInt8(pbuf);
            pbuf += count * 11 + 2;
            SinglePlayRefresh();
            if(!DuelClient::ClientAnalyze(offset, pbuf - offset)) {
//				mainGame->singleSignal.Reset();
//				mainGame->singleSignal.Wait();
            }
            break;
        }
        case MSG_SELECT_EFFECTYN: {
            player = BufferIO::ReadInt8(pbuf);
            pbuf += 8;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            if(!DuelClient::ClientAnalyze(offset, pbuf - offset)) {
//				mainGame->singleSignal.Reset();
//				mainGame->singleSignal.Wait();
            }
            break;
        }
        case MSG_SELECT_YESNO: {
            player = BufferIO::ReadInt8(pbuf);
            pbuf += 4;
            if(!DuelClient::ClientAnalyze(offset, pbuf - offset)) {
//				mainGame->singleSignal.Reset();
//				mainGame->singleSignal.Wait();
            }
            break;
        }
        case MSG_SELECT_OPTION: {
            player = BufferIO::ReadInt8(pbuf);
            count = BufferIO::ReadInt8(pbuf);
            pbuf += count * 4;
            if(!DuelClient::ClientAnalyze(offset, pbuf - offset)) {
//				mainGame->singleSignal.Reset();
//				mainGame->singleSignal.Wait();
            }
            break;
        }
        case MSG_SELECT_CARD:
        case MSG_SELECT_TRIBUTE: {
            player = BufferIO::ReadInt8(pbuf);
            pbuf += 3;
            count = BufferIO::ReadInt8(pbuf);
            pbuf += count * 8;
            if(!DuelClient::ClientAnalyze(offset, pbuf - offset)) {
//				mainGame->singleSignal.Reset();
//				mainGame->singleSignal.Wait();
            }
            break;
        }
        case MSG_SELECT_CHAIN: {
            player = BufferIO::ReadInt8(pbuf);
            count = BufferIO::ReadInt8(pbuf);
            pbuf += 10 + count * 12;
            if(!DuelClient::ClientAnalyze(offset, pbuf - offset)) {
//				mainGame->singleSignal.Reset();
//				mainGame->singleSignal.Wait();
            }
            break;
        }
        case MSG_SELECT_PLACE:
        case MSG_SELECT_DISFIELD: {
            player = BufferIO::ReadInt8(pbuf);
            pbuf += 5;
            if(!DuelClient::ClientAnalyze(offset, pbuf - offset)) {
//				mainGame->singleSignal.Reset();
//				mainGame->singleSignal.Wait();
            }
            break;
        }
        case MSG_SELECT_POSITION: {
            player = BufferIO::ReadInt8(pbuf);
            pbuf += 5;
            if(!DuelClient::ClientAnalyze(offset, pbuf - offset)) {
//				mainGame->singleSignal.Reset();
//				mainGame->singleSignal.Wait();
            }
            break;
        }
        case MSG_SELECT_COUNTER: {
            player = BufferIO::ReadInt8(pbuf);
            pbuf += 3;
            count = BufferIO::ReadInt8(pbuf);
            pbuf += count * 8;
            if(!DuelClient::ClientAnalyze(offset, pbuf - offset)) {
//				mainGame->singleSignal.Reset();
//				mainGame->singleSignal.Wait();
            }
            break;
        }
        case MSG_SELECT_SUM: {
            pbuf++;
            player = BufferIO::ReadInt8(pbuf);
            pbuf += 6;
            count = BufferIO::ReadInt8(pbuf);
            pbuf += count * 11;
            if(!DuelClient::ClientAnalyze(offset, pbuf - offset)) {
//				mainGame->singleSignal.Reset();
//				mainGame->singleSignal.Wait();
            }
            break;
        }
        case MSG_SORT_CARD:
        case MSG_SORT_CHAIN: {
            player = BufferIO::ReadInt8(pbuf);
            count = BufferIO::ReadInt8(pbuf);
            pbuf += count * 7;
            if(!DuelClient::ClientAnalyze(offset, pbuf - offset)) {
//				mainGame->singleSignal.Reset();
//				mainGame->singleSignal.Wait();
            }
            break;
        }
        case MSG_CONFIRM_DECKTOP: {
            player = BufferIO::ReadInt8(pbuf);
            count = BufferIO::ReadInt8(pbuf);
            pbuf += count * 7;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_CONFIRM_CARDS: {
            player = BufferIO::ReadInt8(pbuf);
            count = BufferIO::ReadInt8(pbuf);
            pbuf += count * 7;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_SHUFFLE_DECK: {
            player = BufferIO::ReadInt8(pbuf);
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            SinglePlayRefreshDeck(player);
            break;
        }
        case MSG_SHUFFLE_HAND: {
            /*int oplayer = */BufferIO::ReadInt8(pbuf);
            int count = BufferIO::ReadInt8(pbuf);
            pbuf += count * 4;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_REFRESH_DECK: {
            pbuf++;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_SWAP_GRAVE_DECK: {
            player = BufferIO::ReadInt8(pbuf);
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            SinglePlayRefreshGrave(player);
            break;
        }
        case MSG_REVERSE_DECK: {
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_DECK_TOP: {
            pbuf += 6;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_SHUFFLE_SET_CARD: {
            count = BufferIO::ReadInt8(pbuf);
            pbuf += count * 8;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_NEW_TURN: {
            player = BufferIO::ReadInt8(pbuf);
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_NEW_PHASE: {
            pbuf++;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            SinglePlayRefresh();
            break;
        }
        case MSG_MOVE: {
            int pc = pbuf[4];
            int pl = pbuf[5];
            /*int ps = pbuf[6];*/
            /*int pp = pbuf[7];*/
            int cc = pbuf[8];
            int cl = pbuf[9];
            int cs = pbuf[10];
            /*int cp = pbuf[11];*/
            pbuf += 16;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            if(cl && !(cl & 0x80) && (pl != cl || pc != cc))
                SinglePlayRefreshSingle(cc, cl, cs);
            break;
        }
        case MSG_POS_CHANGE: {
            pbuf += 9;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_SET: {
            pbuf += 8;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_SWAP: {
            pbuf += 16;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_FIELD_DISABLED: {
            pbuf += 4;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_SUMMONING: {
            pbuf += 8;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_SUMMONED: {
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            SinglePlayRefresh();
            break;
        }
        case MSG_SPSUMMONING: {
            pbuf += 8;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_SPSUMMONED: {
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            SinglePlayRefresh();
            break;
        }
        case MSG_FLIPSUMMONING: {
            pbuf += 8;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_FLIPSUMMONED: {
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            SinglePlayRefresh();
            break;
        }
        case MSG_CHAINING: {
            pbuf += 16;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_CHAINED: {
            pbuf++;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            SinglePlayRefresh();
            break;
        }
        case MSG_CHAIN_SOLVING: {
            pbuf++;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_CHAIN_SOLVED: {
            pbuf++;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            SinglePlayRefresh();
            break;
        }
        case MSG_CHAIN_END: {
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            SinglePlayRefresh();
            SinglePlayRefreshDeck(0);
            SinglePlayRefreshDeck(1);
            break;
        }
        case MSG_CHAIN_NEGATED: {
            pbuf++;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_CHAIN_DISABLED: {
            pbuf++;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_CARD_SELECTED:
        case MSG_RANDOM_SELECTED: {
            player = BufferIO::ReadInt8(pbuf);
            count = BufferIO::ReadInt8(pbuf);
            pbuf += count * 4;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_BECOME_TARGET: {
            count = BufferIO::ReadInt8(pbuf);
            pbuf += count * 4;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_DRAW: {
            player = BufferIO::ReadInt8(pbuf);
            count = BufferIO::ReadInt8(pbuf);
            pbuf += count * 4;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_DAMAGE: {
            pbuf += 5;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_RECOVER: {
            pbuf += 5;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_EQUIP: {
            pbuf += 8;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_LPUPDATE: {
            pbuf += 5;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_UNEQUIP: {
            pbuf += 4;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_CARD_TARGET: {
            pbuf += 8;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_CANCEL_TARGET: {
            pbuf += 8;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_PAY_LPCOST: {
            pbuf += 5;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_ADD_COUNTER: {
            pbuf += 6;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_REMOVE_COUNTER: {
            pbuf += 6;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_ATTACK: {
            pbuf += 8;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_BATTLE: {
            pbuf += 26;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_ATTACK_DISABLED: {
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_DAMAGE_STEP_START: {
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            SinglePlayRefresh();
            break;
        }
        case MSG_DAMAGE_STEP_END: {
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            SinglePlayRefresh();
            break;
        }
        case MSG_MISSED_EFFECT: {
            pbuf += 8;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_TOSS_COIN: {
            player = BufferIO::ReadInt8(pbuf);
            count = BufferIO::ReadInt8(pbuf);
            pbuf += count;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_TOSS_DICE: {
            player = BufferIO::ReadInt8(pbuf);
            count = BufferIO::ReadInt8(pbuf);
            pbuf += count;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_ANNOUNCE_RACE: {
            player = BufferIO::ReadInt8(pbuf);
            pbuf += 5;
            if(!DuelClient::ClientAnalyze(offset, pbuf - offset)) {
//				mainGame->singleSignal.Reset();
//				mainGame->singleSignal.Wait();
            }
            break;
        }
        case MSG_ANNOUNCE_ATTRIB: {
            player = BufferIO::ReadInt8(pbuf);
            pbuf += 5;
            if(!DuelClient::ClientAnalyze(offset, pbuf - offset)) {
//				mainGame->singleSignal.Reset();
//				mainGame->singleSignal.Wait();
            }
            break;
        }
        case MSG_ANNOUNCE_CARD: {
            player = BufferIO::ReadInt8(pbuf);
            if(!DuelClient::ClientAnalyze(offset, pbuf - offset)) {
//				mainGame->singleSignal.Reset();
//				mainGame->singleSignal.Wait();
            }
            break;
        }
        case MSG_ANNOUNCE_NUMBER: {
            player = BufferIO::ReadInt8(pbuf);
            count = BufferIO::ReadInt8(pbuf);
            pbuf += 4 * count;
            if(!DuelClient::ClientAnalyze(offset, pbuf - offset)) {
//				mainGame->singleSignal.Reset();
//				mainGame->singleSignal.Wait();
            }
            break;
        }
        case MSG_CARD_HINT: {
            pbuf += 9;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            break;
        }
        case MSG_TAG_SWAP: {
            player = pbuf[0];
            pbuf += pbuf[3] * 4 + 8;
            DuelClient::ClientAnalyze(offset, pbuf - offset);
            SinglePlayRefreshDeck(player);
            SinglePlayRefreshExtra(player);
            break;
        }
        case MSG_MATCH_KILL: {
            pbuf += 4;
            break;
        }
        case MSG_RELOAD_FIELD: {
            mainGame->dField.Clear();
            int val = 0;
            for(int p = 0; p < 2; ++p) {
                mainGame->dInfo.lp[p] = BufferIO::ReadInt32(pbuf);
                qDebug()<<"Life point of player "<<p+1<<" set to "<<mainGame->dInfo.lp[p];
                for(int seq = 0; seq < 5; ++seq) {
                    val = BufferIO::ReadInt8(pbuf);
                    if(val) {
                        ClientCard* ccard = new ClientCard;
                        mainGame->dField.AddCard(ccard, p, LOCATION_MZONE, seq);
                        ccard->position = BufferIO::ReadInt8(pbuf);
                        val = BufferIO::ReadInt8(pbuf);
                        if(val) {
                            for(int xyz = 0; xyz < val; ++xyz) {
                                ClientCard* xcard = new ClientCard;
                                ccard->overlayed.push_back(xcard);
                                mainGame->dField.overlay_cards.insert(xcard);
                                xcard->overlayTarget = ccard;
                                xcard->location = 0x80;
                                xcard->sequence = ccard->overlayed.size() - 1;
                            }
                        }
                    }
                }
                for(int seq = 0; seq < 8; ++seq) {
                    val = BufferIO::ReadInt8(pbuf);
                    if(val) {
                        ClientCard* ccard = new ClientCard;
                        mainGame->dField.AddCard(ccard, p, LOCATION_SZONE, seq);
                        ccard->position = BufferIO::ReadInt8(pbuf);
                    }
                }
                val = BufferIO::ReadInt8(pbuf);
                for(int seq = 0; seq < val; ++seq) {
                    ClientCard* ccard = new ClientCard;
                    mainGame->dField.AddCard(ccard, p, LOCATION_DECK, seq);
                }
                val = BufferIO::ReadInt8(pbuf);
                for(int seq = 0; seq < val; ++seq) {
                    ClientCard* ccard = new ClientCard;
                    mainGame->dField.AddCard(ccard, p, LOCATION_HAND, seq);                    
                }
                val = BufferIO::ReadInt8(pbuf);
                for(int seq = 0; seq < val; ++seq) {
                    ClientCard* ccard = new ClientCard;
                    mainGame->dField.AddCard(ccard, p, LOCATION_GRAVE, seq);   
                }
                val = BufferIO::ReadInt8(pbuf);
                for(int seq = 0; seq < val; ++seq) {
                    ClientCard* ccard = new ClientCard;
                    mainGame->dField.AddCard(ccard, p, LOCATION_REMOVED, seq);     
                }
                val = BufferIO::ReadInt8(pbuf);
                for(int seq = 0; seq < val; ++seq) {
                    ClientCard* ccard = new ClientCard;
                    mainGame->dField.AddCard(ccard, p, LOCATION_EXTRA, seq);      
                }
            }
            BufferIO::ReadInt8(pbuf); //chain count, always 0
            SinglePlayReload();
//            mainGame->dField.RefreshAllCards(); // updates the position and rotation
            emit mainGame->dInfo.qstrLP1Changed();
            emit mainGame->dInfo.qstrLP2Changed();
            break;
        }
        case MSG_AI_NAME: {
            char namebuf[128];
            wchar_t wname[128];
            int len = BufferIO::ReadInt16(pbuf);
            char* begin = pbuf;
            pbuf += len + 1;
            memcpy(namebuf, begin, len + 1);
            BufferIO::DecodeUTF8(namebuf, wname);
            BufferIO::CopyWStr(wname, mainGame->dInfo.clientname, 20);
            break;
        }
        case MSG_SHOW_HINT: {
            char msgbuf[1024];
            wchar_t msg[1024];
            int len = BufferIO::ReadInt16(pbuf);
            char* begin = pbuf;
            pbuf += len + 1;
            memcpy(msgbuf, begin, len + 1);
            BufferIO::DecodeUTF8(msgbuf, msg);
            mainGame->stMessage = QString::fromWCharArray(msg);
            mainGame->wMessage = true ;
            emit mainGame->qwMessageChanged();
            mainGame->actionSignal.reset();
            mainGame->actionSignal.wait();
            break;
        }
        }
    }
    return is_continuing;
}

void SingleMode::SinglePlayRefresh(int flag) {
    Buffer queryBuffer;
    query_field_card(pduel, 0, LOCATION_MZONE, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(0)),
                              Q_ARG(int, LOCATION_MZONE),
                              Q_ARG(Buffer, queryBuffer));
    query_field_card(pduel, 1, LOCATION_MZONE, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(1)),
                              Q_ARG(int, LOCATION_MZONE),
                              Q_ARG(Buffer, queryBuffer));
    query_field_card(pduel, 0, LOCATION_SZONE, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(0)),
                              Q_ARG(int, LOCATION_SZONE),
                              Q_ARG(Buffer, queryBuffer));
    query_field_card(pduel, 1, LOCATION_SZONE, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(1)),
                              Q_ARG(int, LOCATION_SZONE),
                              Q_ARG(Buffer, queryBuffer));
    query_field_card(pduel, 0, LOCATION_HAND, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(0)),
                              Q_ARG(int, LOCATION_HAND),
                              Q_ARG(Buffer, queryBuffer));
    query_field_card(pduel, 1, LOCATION_HAND, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(1)),
                              Q_ARG(int, LOCATION_HAND),
                              Q_ARG(Buffer, queryBuffer));
}

void SingleMode::SinglePlayRefreshHand(int player, int flag) {
    Buffer queryBuffer;
    query_field_card(pduel, player, LOCATION_HAND, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(player)),
                              Q_ARG(int, LOCATION_HAND),
                              Q_ARG(Buffer, queryBuffer));
}

void SingleMode::SinglePlayRefreshGrave(int player, int flag) {
    Buffer queryBuffer;
    query_field_card(pduel, player, LOCATION_GRAVE, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(player)),
                              Q_ARG(int, LOCATION_GRAVE),
                              Q_ARG(Buffer, queryBuffer));
}
void SingleMode::SinglePlayRefreshDeck(int player, int flag) {
    Buffer queryBuffer;
    query_field_card(pduel, player, LOCATION_DECK, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(player)),
                              Q_ARG(int, LOCATION_DECK),
                              Q_ARG(Buffer, queryBuffer));
}

void SingleMode::SinglePlayRefreshExtra(int player, int flag) {
    Buffer queryBuffer;
    query_field_card(pduel, player, LOCATION_EXTRA, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(player)),
                              Q_ARG(int, LOCATION_EXTRA),
                              Q_ARG(Buffer, queryBuffer));
}

void SingleMode::SinglePlayRefreshSingle(int player, int location, int sequence, int flag) {
    Buffer queryBuffer;
    query_card(pduel, player, location, sequence, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(player)),
                              Q_ARG(int, location),
                              Q_ARG(int, sequence),
                              Q_ARG(Buffer, queryBuffer));
}

void SingleMode::SinglePlayReload()
{
    Buffer queryBuffer;
    unsigned int flag = 0x7fdfff;
    query_field_card(pduel, 0, LOCATION_MZONE, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(0)),
                              Q_ARG(int, LOCATION_MZONE),
                              Q_ARG(Buffer, queryBuffer));
    query_field_card(pduel, 1, LOCATION_MZONE, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(1)),
                              Q_ARG(int, LOCATION_MZONE),
                              Q_ARG(Buffer, queryBuffer));
    query_field_card(pduel, 0, LOCATION_SZONE, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(0)),
                              Q_ARG(int, LOCATION_SZONE),
                              Q_ARG(Buffer, queryBuffer));
    query_field_card(pduel, 1, LOCATION_SZONE, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(1)),
                              Q_ARG(int, LOCATION_SZONE),
                              Q_ARG(Buffer, queryBuffer));
    query_field_card(pduel, 0, LOCATION_HAND, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(0)),
                              Q_ARG(int, LOCATION_HAND),
                              Q_ARG(Buffer, queryBuffer));
    query_field_card(pduel, 1, LOCATION_HAND, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(1)),
                              Q_ARG(int, LOCATION_HAND),
                              Q_ARG(Buffer, queryBuffer));
    query_field_card(pduel, 0, LOCATION_DECK, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(0)),
                              Q_ARG(int, LOCATION_DECK),
                              Q_ARG(Buffer, queryBuffer));
    query_field_card(pduel, 1, LOCATION_DECK, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(1)),
                              Q_ARG(int, LOCATION_DECK),
                              Q_ARG(Buffer, queryBuffer));
    query_field_card(pduel, 0, LOCATION_EXTRA, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(0)),
                              Q_ARG(int, LOCATION_EXTRA),
                              Q_ARG(Buffer, queryBuffer));
    query_field_card(pduel, 1, LOCATION_EXTRA, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(1)),
                              Q_ARG(int, LOCATION_EXTRA),
                              Q_ARG(Buffer, queryBuffer));
    query_field_card(pduel, 0, LOCATION_GRAVE, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(0)),
                              Q_ARG(int, LOCATION_GRAVE),
                              Q_ARG(Buffer, queryBuffer));
    query_field_card(pduel, 1, LOCATION_GRAVE, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(1)),
                              Q_ARG(int, LOCATION_GRAVE),
                              Q_ARG(Buffer, queryBuffer));
    query_field_card(pduel, 0, LOCATION_REMOVED, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(0)),
                              Q_ARG(int, LOCATION_REMOVED),
                              Q_ARG(Buffer, queryBuffer));
    query_field_card(pduel, 1, LOCATION_REMOVED, flag, queryBuffer.buffer, 0);
    QMetaObject::invokeMethod(&mainGame->dField,"UpdateFieldCard",Qt::QueuedConnection,
                              Q_ARG(int, mainGame->LocalPlayer(1)),
                              Q_ARG(int, LOCATION_REMOVED),
                              Q_ARG(Buffer, queryBuffer));
}

int SingleMode::MessageHandler(long fduel, int type) {
    Q_UNUSED(fduel);
    Q_UNUSED(type);
    return 0;
}

}
