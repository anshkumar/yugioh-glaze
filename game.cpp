#include <QThread>
#include <QDebug>

#include "game.h"
#include "datamanager.h"

//QTextStream cout(stdout);
//QTextStream cerr(stderr);

namespace glaze{

Game* mainGame;

Game::Game(QObject *parent):
    QObject(parent)
{}

bool Game::Initialize(){
    if(!dataManager.LoadDB("cards.cdb")) {
        qDebug()<<"Card database initialization FAILED";
            return false;
    }
    if(!dataManager.LoadStrings("strings.conf")) {
        qDebug()<<"String file initialization FAILED";
            return false;
    }
    return true;
}

void Game::startSinglePlay(QString name) {
    sMode = new SingleMode;
    workerThread = new QThread;
    sMode->name = name;
    qDebug()<<"SingleMode object craeted at "<<sMode;
    sMode->moveToThread(workerThread);
    connect(workerThread, SIGNAL(started()), sMode, SLOT(singlePlayStart()));
    connect(sMode, SIGNAL(finished()), workerThread, SLOT(quit()));
    connect(sMode, SIGNAL(finished()), sMode, SLOT(deleteLater()));
    connect(workerThread, SIGNAL(finished()), workerThread, SLOT(deleteLater()));
    workerThread->start();
    qDebug()<<"SingleMode Thread created";
}

void Game::stopSinglePlay(bool is_exiting) {
    sMode->is_closing = is_exiting;
    sMode->is_continuing = false;
    actionSignal.set();
    singleSignal.set();
    qDebug()<<"SingleMode stopSinglePlay called";
}

bool Game::qwMessage() const
{
    return wMessage;
}

void Game::mySet() {
    actionSignal.set();
}

void Game::setQwMessage(bool wMess)
{
    if(wMessage != wMess)
    {
        wMessage = wMess;
//        emit qwMessageChanged();
    }
}

QString Game::qstMessage()
{
    return stMessage;
}
//    void setQstMessage(QString);
bool Game::qstHintMsg()
{
    return stHintMsg;
}
void Game::setQstHintMsg(bool msg)
{
    if(stHintMsg != msg)
    {
        stHintMsg = msg;
        emit qstHintMsgChanged();
    }
}
QString Game::qHintMsg()
{
    return HintMsg;
}
bool Game::qwQuery()
{
    return wQuery;
}
void Game::setQwQuery(bool que)
{
    if(wQuery != que)
    {
        wQuery = que;
        emit qwQueryChanged();
    }
}
QString Game::qstQMessage()
{
    return stQMessage;
}
bool Game::qwCardSelect()
{
    return wCardSelect;
}
void Game::setQwCardSelect(bool sel)
{
    if(wCardSelect != sel)
    {
        wCardSelect = sel;
        emit qwCardSelectChanged();
    }
}
QString Game::qstCardSelect()
{
    return stCardSelect;
}
bool Game::qwPosSelect()
{
    return wPosSelect;
}
void Game::setQwPosSelect(bool pos)
{
    if(wPosSelect != pos)
    {
        wPosSelect = pos;
        emit qwPosSelectChanged();
    }
}
uint32 Game::qbtnPSAU()
{
    return btnPSAU;
}
uint32 Game::qbtnPSAD()
{
    return btnPSAD;
}
uint32 Game::qbtnPSDU()
{
    return btnPSDU;
}
uint32 Game::qbtnPSDD()
{
    return btnPSDD;
}
bool Game::qbtnLeaveGame()
{
    return btnLeaveGame;
}
void Game::setQbtnLeaveGame(bool t)
{
    if(btnLeaveGame != t)
    {
        btnLeaveGame = t;
        emit qbtnLeaveGameChanged();
    }
}
QString Game::qstLeaveGame()
{
    return stLeaveGame;
}
bool Game::qwACMessage()
{
    return wACMessage;
}
void Game::setQwACMessage(bool t)
{
    if(wACMessage != t)
    {
        wACMessage = t;
        emit qwACMessageChanged();
    }
}
QString Game::qstACMessage()
{
    return stACMessage;
}
bool Game::qwANRace()
{
    return wANRace;
}
void Game::setQwANRace(bool t)
{
    if(wANRace != t)
    {
        wANRace = t;
        emit qwANRaceChanged();
    }
}
//void Game::append_chk(QQmlListProperty<bool> *list, bool *msg)
//{
//    Game *g = qobject_cast<Game*>(list->object);
//    if(msg)
//        g->chkRace.append(msg);
//}
QList<bool> Game::qchkRace()
{
        return chkRace;
}

bool Game::qwin()
{
    return win;
}

void Game::AddChatMsg(wchar_t* msg, int player) {
    for(int i = 7; i > 0; --i) {
        chatMsg[i] = chatMsg[i - 1];
        chatTiming[i] = chatTiming[i - 1];
        chatType[i] = chatType[i - 1];
    }
    chatMsg[0].clear();
    chatTiming[0] = 1200;
    chatType[0] = player;
    switch(player) {
    case 0: //from host
        chatMsg[0].append(dInfo.hostname);
        chatMsg[0].append(L": ");
        break;
    case 1: //from client
        chatMsg[0].append(dInfo.clientname);
        chatMsg[0].append(L": ");
        break;
    case 2: //host tag
        chatMsg[0].append(dInfo.hostname_tag);
        chatMsg[0].append(L": ");
        break;
    case 3: //client tag
        chatMsg[0].append(dInfo.clientname_tag);
        chatMsg[0].append(L": ");
        break;
    case 7: //local name
        chatMsg[0].append(mainGame->ebNickName.toStdWString());
        chatMsg[0].append(L": ");
        break;
    case 8: //system custom message, no prefix.
        chatMsg[0].append(L"[System]: ");
        break;
    case 9: //error message
        chatMsg[0].append(L"[Script error:] ");
        break;
    default: //from watcher or unknown
        if(player < 11 || player > 19)
            chatMsg[0].append(L"[---]: ");
    }
    chatMsg[0].append(msg);
}

int Game::LocalPlayer(int player) {
    return dInfo.isFirst ? player : 1 - player;
}
const wchar_t* Game::LocalName(int local_player) {
    return local_player == 0 ? dInfo.hostname : dInfo.clientname;
}

}
