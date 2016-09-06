#ifndef GAME_H
#define GAME_H

#include <QObject>
#include <QQmlListProperty>
#include <QString>
#include <QThread>
#include "clientfield.h"
#include "singlemode.h"
#include "signalWaiter.h"

namespace glaze{

struct Config {
    bool use_d3d;
    unsigned short antialias;
    unsigned short serverport;
    unsigned char textfontsize;
    wchar_t lastip[20];
    wchar_t lastport[10];
    wchar_t nickname[20];
    wchar_t gamename[20];
    wchar_t lastdeck[64];
    wchar_t textfont[256];
    wchar_t numfont[256];
    wchar_t roompass[20];
};

class DuelInfo : public QObject {
    Q_OBJECT

public:
	explicit DuelInfo(QObject *parent = 0);

    bool is_started; //TODO: discard its usage
    bool is_replay;
    bool is_replaySkiping;
    bool is_first;
    bool is_tag;
    bool is_singleMode;
    bool is_shuffling;
    bool tag_player[2];
    int lp[2];
    int turn;
    short curMsg;
    wchar_t hostname[20];
    wchar_t clientname[20];
    wchar_t hostname_tag[20];
    wchar_t clientname_tag[20];
//    wchar_t strLP[2][16];
//    wchar_t strTurn[8];
    wchar_t* vic_string;
    unsigned char player_type;
    unsigned char time_player;
    unsigned short time_limit;
    unsigned short time_left[2];

public slots:
    int getLp1() {
        return lp[0];
    }

    int getLp2() {
        return lp[1];
    }

    QString getClientName() {
        return QString::fromWCharArray(clientname);
    }

    int getCurMsg() {
        return curMsg;
    }

    bool isReplay() {
        return is_replay;
    }

    int playerType() {
        return player_type;
    }

    bool isSingleMode() {
        return is_singleMode;
    }

signals:
    void lp1Changed();
    void lp2Changed();
    void clientNameChanged();
};

// struct FadingUnit{}; // not needed

class Game : public QObject
{
    Q_OBJECT

public:
    explicit Game(QObject *parent = 0);
	~Game();

    bool Initialize();

    Q_INVOKABLE void stopSinglePlay(bool is_exiting = false);
    Q_INVOKABLE bool qwMessage() const;
    Q_INVOKABLE void setQwMessage(bool wMess);
    Q_INVOKABLE QString qstMessage();
    Q_INVOKABLE void startSinglePlay(QString name);
    Q_INVOKABLE void mySet();
    Q_INVOKABLE int getShowCardCode();
    Q_INVOKABLE int getShowCard();
    Q_INVOKABLE int getBuffer();
    Q_INVOKABLE void setResponseI(int respI);
    Q_INVOKABLE static void setResponseB(QList<int> respB, unsigned char len);
    Q_INVOKABLE static void sendResponse();

//    void setQstMessage(QString);
    bool qstHintMsg();
    void setQstHintMsg(bool msg);
    QString qHintMsg();
    bool qwQuery();
    void setQwQuery(bool que);
    QString qstQMessage();
    bool qwCardSelect();
    void setQwCardSelect(bool sel);
    QString qstCardSelect();
    bool qwPosSelect();
    void setQwPosSelect(bool pos);
    uint32 qbtnPSAU();
    uint32 qbtnPSAD();
    uint32 qbtnPSDU();
    uint32 qbtnPSDD();
    bool qbtnLeaveGame();
    void setQbtnLeaveGame(bool t);
    QString qstLeaveGame();
    bool qwACMessage();
    void setQwACMessage(bool t);
    QString qstACMessage();
    bool qwANRace();
    void setQwANRace(bool t);
    QList<bool> qchkRace();
    bool qwin();

    int LocalPlayer(int player);
    const wchar_t* LocalName(int local_player);
    void AddChatMsg(wchar_t* msg, int player);

    DuelInfo dInfo;
    ClientField dField;
    SingleMode *sMode;
    QThread *workerThread;
    SignalWaiter actionSignal;
    SignalWaiter singleSignal;
    SignalWaiter invokeMethodSignal;

    QVector<int> buffer;
    bool win;
    QVector<int> showcard;
    QVector<int> showcardcode;
    int showcarddif;
    int showcardp;
    bool always_chain;
    bool ignore_chain;
    int lpplayer;
    int lpccolor;
    wchar_t* lpcstring;
    int lpd;

    std::wstring chatMsg[8];
    int chatTiming[8];
    int chatType[8];
    QVector3D atk_r;
    QVector3D atk_t;
    int is_attacking;
    int attack_sv;

    // command menu (menu showed upon clicling a card)
    bool wCmdMenu;
    bool btnActivate;
    bool btnSummon;
    bool btnSPSummon;
    bool btnMSet;
    bool btnSSet;
    bool btnRepos;
    bool btnAttack;
    bool btnShowList;

    // card select window
    bool wCardSelect;
    QString stCardSelect;
    int btnCardSelect[100];

    //hint text
    bool stHintMsg;
    QString HintMsg;
    bool stTip;

    //message
    bool wMessage;
    QString stMessage;

    //lan
    bool wLanWindow;
    QString ebNickName;
    bool btnLanRefresh;
    bool btnJoinHost;
    bool btnJoinCancel;
    bool btnCreateHost;

    //phase button  //TODO: move completly to qml
    bool wPhase;
    bool btnDP;
    bool btnSP;
    bool btnM1;
    bool btnBP;
    bool btnM2;
    bool btnEP;

    //yes/no
    bool wQuery;
    QString stQMessage;

    //info
    bool chkWaitChain;
    bool chkAutoPos;
    bool chkRandomPos;
    bool chkAutoChain;

    //pos select // select battle position
    // after special summoning a monster it asks for the attle position to put the card in
    bool wPosSelect;
    uint32 btnPSAU;
    uint32 btnPSAD;
    uint32 btnPSDU;
    uint32 btnPSDD;

    //surrender/leave
    bool btnLeaveGame;
    QString stLeaveGame;

    //auto close message
    bool wACMessage;
    QString stACMessage;

    //announce race
    bool wANRace;
    QString stANRace;
    QList<bool> chkRace;

signals:
    void qwMessageChanged();
    void qstHintMsgChanged();
    void qwQueryChanged();
    void qwCardSelectChanged();
    void qwPosSelectChanged();
    void qbtnLeaveGameChanged();
    void qwACMessageChanged();
    void qwANRaceChanged();
    void qwinChanged();
    void qshowCardChanged();
    void qclientAnalyzeChanged();
    void qshowWCardSelectChanged();
};

extern Game* mainGame;

}

#define COMMAND_ACTIVATE	0x0001
#define COMMAND_SUMMON		0x0002
#define COMMAND_SPSUMMON	0x0004
#define COMMAND_MSET		0x0008
#define COMMAND_SSET		0x0010
#define COMMAND_REPOS		0x0020
#define COMMAND_ATTACK		0x0040
#define COMMAND_LIST		0x0080

#endif // GAME_H
