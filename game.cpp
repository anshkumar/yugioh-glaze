#include <QThread>
#include <QDebug>
#include <time.h>
#include "game.h"
#include "datamanager.h"

#include <dirent.h>
#include <iostream>
//QTextStream cout(stdout);
//QTextStream cerr(stderr);

namespace glaze{

Game* mainGame = 0;

DuelInfo::DuelInfo(QObject *parent):
    QObject(parent)
{
    isStarted = false;
    isReplay = false;
    isReplaySkiping = false;
    isFirst = false;
    isTag = false;
    isSingleMode = false;
    is_shuffling = false;
    tag_player[0] = false;
    tag_player[1] = false;
    lp[0] = 0;
    lp[1] = 0;
    turn = 0;
    curMsg = 0;
    hostname[0] = 0;
	clientname[0] = 0;
	hostname_tag[0] = 0;
	clientname_tag[0] = 0;
//	strTurn[0] = 0;
    vic_string = 0;
    player_type  = 0;
    time_player = 0;
    time_limit = 0;
    time_left[0] = 0;
    time_left[1] = 0;
}

Game::Game(QObject *parent):
    QObject(parent)
{
    sMode = 0;
    workerThread = 0;
}

Game::~Game() {
    sMode = 0;
    workerThread = 0;
    mainGame = 0;
}

bool Game::Initialize(){
    srand(time(0));
//    memset(&dInfo, 0, sizeof(DuelInfo));	//DO NOT uncomment
    if(!dataManager.LoadDB("cards.cdb")) {
        qDebug()<<"Card database initialization FAILED";
            return false;
    }
    if(!dataManager.LoadStrings("strings.conf")) {
        qDebug()<<"String file initialization FAILED";
            return false;
    }
    DIR * dir;
    struct dirent * dirp;
    const char *foldername = "./expansions/";
    if((dir = opendir(foldername)) != NULL) {
        while((dirp = readdir(dir)) != NULL) {
            size_t len = strlen(dirp->d_name);
            if(len < 5 || strcasecmp(dirp->d_name + len - 4, ".cdb") != 0)
                continue;
                    char *filepath = (char *)malloc(sizeof(char)*(len + strlen(foldername)));
                    strncpy(filepath, foldername, strlen(foldername)+1);
                    strncat(filepath, dirp->d_name, len);
                    std::cout << "Found file " << filepath << std::endl;
                    if (!dataManager.LoadDB(filepath))
                        std::cout << "Error loading file" << std::endl;
                    free(filepath);
        }
        closedir(dir);
    }
    return true;
}

void Game::startSinglePlay(QString name) {
    sMode = new SingleMode;
    workerThread = new QThread;
    sMode->name = name;
    singleSignal.setNoWait(false);
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
    singleSignal.setNoWait(true);
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
