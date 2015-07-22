#ifndef CLIENTFIELD_H
#define CLIENTFIELD_H

#include "clientcardmodel.h"
#include <QObject>
#include <QList>
#include <QSet>
#include <QVector3D>
#include <QVector2D>
#include <QQmlListProperty>
#include "card.h"
#include "singlemode.h"

namespace glaze{

class ClientCard;

struct ChainInfo{
    QVector3D chain_pos;
    ClientCard* chain_card;
    int code;
    int desc;
    int controler;
    int location;
    int sequence;
    bool solved;
};

class ClientField : public SingleMode
{
    Q_OBJECT
    Q_PROPERTY(ClientCardModel* deck1 READ deck1 CONSTANT)
    Q_PROPERTY(ClientCardModel* deck2 READ deck2 CONSTANT)
    Q_PROPERTY(ClientCardModel* hand1 READ hand1 CONSTANT)
    Q_PROPERTY(ClientCardModel* hand2 READ hand2 CONSTANT)
    Q_PROPERTY(ClientCardModel* mzone1 READ mzone1 CONSTANT)
    Q_PROPERTY(ClientCardModel* mzone2 READ mzone2 CONSTANT)
    Q_PROPERTY(ClientCardModel* szone1 READ szone1 CONSTANT)
    Q_PROPERTY(ClientCardModel* szone2 READ szone2 CONSTANT)
    Q_PROPERTY(ClientCardModel* grave1 READ grave1 CONSTANT)
    Q_PROPERTY(ClientCardModel* grave2 READ grave2 CONSTANT)
    Q_PROPERTY(ClientCardModel* remove1 READ remove1 CONSTANT)
    Q_PROPERTY(ClientCardModel* remove2 READ remove2 CONSTANT)
    Q_PROPERTY(ClientCardModel* extra1 READ extra1 CONSTANT)
    Q_PROPERTY(ClientCardModel* extra2 READ extra2 CONSTANT)

public:
    ClientField();
    ~ClientField();

    ClientCardModel *deck1();
    ClientCardModel *deck2();
    ClientCardModel *hand1();
    ClientCardModel *hand2();
    ClientCardModel *mzone1();
    ClientCardModel *mzone2();
    ClientCardModel *szone1();
    ClientCardModel *szone2();
    ClientCardModel *grave1();
    ClientCardModel *grave2();
    ClientCardModel *remove1();
    ClientCardModel *remove2();
    ClientCardModel *extra1();
    ClientCardModel *extra2();
    ClientCardModel *Overlay_cards();

    bool qwShowSelectCard();
    bool qwShowChainCard();

    ClientCardModel deck[2];
    ClientCardModel hand[2];
    ClientCardModel mzone[2];
    ClientCardModel szone[2];
    ClientCardModel grave[2];
    ClientCardModel remove[2];
    ClientCardModel extra[2];
    QSet<ClientCard*> overlay_cards;
    ClientCardModel summonable_cards;
    ClientCardModel spsummonable_cards;
    ClientCardModel msetable_cards;
    ClientCardModel ssetable_cards;
    ClientCardModel reposable_cards;
    ClientCardModel activatable_cards;
    ClientCardModel attackable_cards;
    QList<int> activatable_descs;
    QList<int> select_options;
    QList<ChainInfo> chains;

    size_t selected_option;
    ClientCard* attacker;
    ClientCard* attack_target;
    int disabled_field;
    int selectable_field;
    int selected_field;
    int select_min;
    int select_max;
    int select_sumval;
    int select_cancelable;
    int select_mode;
    bool select_ready;
    int announce_count;
    int select_counter_count;
    int select_counter_type;
    ClientCardModel selectable_cards;
    ClientCardModel selected_cards;
    QSet<ClientCard*> selectsum_cards;
    ClientCardModel selectsum_all;
    QList<int> sort_list;
    bool grave_act;
    bool remove_act;
    bool deck_act;
    bool extra_act;
    bool pzone_act;
    bool chain_forced;
    ChainInfo current_chain;
    bool last_chain;
    bool deck_reversed;

    //card select window
    bool wShowSelectCard;

    //chain select window
    bool wShowChainCard;

    void Initial(int player, int deckc, int extrac);
    ClientCard* GetCard(int controler, int location, int sequence, int sub_seq = 0);
    ClientCard* RemoveCard(int controler, int location, int sequence);

    void ClearCommandFlag();
    void ClearSelect();
    void ClearChainSelect();
    void ShowSelectCard(bool buttonok = false);
    void ShowChainCard();
    void ReplaySwap();
//    void RefreshAllCards();

    void GetChainLocation(int controler, int location, int sequence, QVector3D* t);
//    void GetCardLocation(ClientCard* pcard, QVector3D* t, QVector3D* r, bool setTrans = false);
    void MoveCard(ClientCard* pcard, int frame);
    void FadeCard(ClientCard* pcard, int alpha, int frame);
    bool CheckSelectSum();
    bool check_min(QSet<ClientCard*>& left, QSet<ClientCard*>::iterator index, int min, int max);
    bool check_sel_sum_s(QSet<ClientCard*>& left, int index, int acc);
    void check_sel_sum_t(QSet<ClientCard*>& left, int acc);
    bool check_sum(QSet<ClientCard*>& testlist, QSet<ClientCard*>::iterator index, int acc, int count);

    QList<int> ancard;
    int hovered_controler;
    int hovered_location;
    size_t hovered_sequence;
    int command_controler;
    int command_location;
    size_t command_sequence;
    ClientCard* hovered_card;
    ClientCard* clicked_card;
    ClientCard* command_card;
    ClientCard* highlighting_card;
    int list_command;
    wchar_t formatBuffer[2048];

    QVector3D vdeck0;
    QVector3D vgrave0;
    QVector3D vextra0;
    QVector3D vremove0;
    QVector3D vmzone0;
    QVector3D vszone0;
    QVector3D vsfield0;
    QVector3D vsLScale0;
    QVector3D vsRScale0;
    QVector3D vdeck1;
    QVector3D vgrave1;
    QVector3D vextra1;
    QVector3D vremove1;
    QVector3D vmzone1;
    QVector3D vszone1;
    QVector3D vsfield1;
    QVector3D vsLScale1;
    QVector3D vsRScale1;

public slots:
    void Clear();
    ClientCard* AddCard(int controler, int location, int sequence, ClientCard* pcard = 0, ClientCard** newcard = 0);
    void UpdateCard(int controler, int location, int sequence, char* buf);
    void UpdateFieldCard(int controler, int location, char* buf);
    void SinglePlayRefresh(int flag = 0x781fff);
    void SinglePlayRefreshHand(int player, int flag = 0x781fff);
    void SinglePlayRefreshGrave(int player, int flag = 0x181fff);
    void SinglePlayRefreshDeck(int player, int flag = 0x181fff);
    void SinglePlayRefreshExtra(int player, int flag = 0x181fff);
    void SinglePlayRefreshSingle(int player, int location, int sequence, int flag = 0x781fff);
    void SinglePlayReload();

signals:
    void clearFinished();
    void addCardFinished();
    void updateFieldCardFinished();
    void updateCardFinished();
    void singlePlayRefreshFinished();
    void singlePlayRefreshHandFinished();
    void singlePlayRefreshGraveFinished();
    void singlePlayRefreshDeckFinished();
    void singlePlayRefreshExtraFinished();
    void singlePlayRefreshSingleFinished();
    void singlePlayReloadFinished();

//    virtual bool OnEvent(const irr::SEvent& event);
//	void GetHoverField(int x, int y);
//	void ShowMenu(int flag, int x, int y);


//    void qwShowSelectCardChanged();
//    void qwShowChainCardChanged();

};
}

#endif // CLIENTFIELD_H
