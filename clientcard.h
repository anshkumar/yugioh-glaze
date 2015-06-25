// Complete
#ifndef CLIENTCARD_H
#define CLIENTCARD_H

#include <QObject>
#include <QVector3D>
#include <QVector>
#include <QSet>
#include <QMap>
#include <vector>
#include <set>
#include <map>
#include <unordered_map>

namespace glaze {

typedef unsigned int u32;
typedef signed int s32;
typedef unsigned char u8;

struct CardData {
    unsigned int code;
    unsigned int alias;
    unsigned long long setcode;
    unsigned int type;
    unsigned int level;
    unsigned int attribute;
    unsigned int race;
    int attack;
    int defence;
    unsigned int lscale;
    unsigned int rscale;
};

struct CardDataC {
    unsigned int code;
    unsigned int alias;
    unsigned long long setcode;
    unsigned int type;
    unsigned int level;
    unsigned int attribute;
    unsigned int race;
    int attack;
    int defence;
    unsigned int lscale;
    unsigned int rscale;
    unsigned int ot;
    unsigned int category;
};

struct CardString {
    wchar_t* name;
    wchar_t* text;
    wchar_t* desc[16];
};

typedef std::unordered_map<unsigned int, CardDataC>::iterator code_pointer;

class ClientCard : public QObject
{
    Q_OBJECT
public:
    QVector3D curPos;
    QVector3D curRot;
    QVector3D dPos;
    QVector3D dRot;

    u32 curAlpha;
    u32 dAlpha;
    u32 aniFrame;
    bool is_moving;
    bool is_fading;
    bool is_hovered;
    bool is_selectable;
    bool is_selected;
    bool is_showequip;
    bool is_showtarget;
    bool is_highlighting;
    bool is_reversed;
    u32 code;
    u32 alias;
    u32 type;
    u32 level;
    u32 rank;
    u32 attribute;
    u32 race;
    s32 attack;
    s32 defence;
    s32 base_attack;
    s32 base_defence;
    u32 lscale;
    u32 rscale;
    u32 reason;
    u32 select_seq;
    u8 owner;
    u8 controler;
    u8 location;
    u8 sequence;
    u8 position;
    u8 is_disabled;
    u8 is_public;
    u8 cHint;
    u32 chValue;
    u32 opParam;
    u32 symbol;
    u32 cmdFlag;
    ClientCard* overlayTarget;
    QList<ClientCard*> overlayed;
    ClientCard* equipTarget;
    QSet<ClientCard*> equipped;
    QSet<ClientCard*> cardTarget;
    QSet<ClientCard*> ownerTarget;
    QMap<int, int> counters;
    QMap<int, int> desc_hints;

    // These strings are not required
//    wchar_t atkstring[16];    //attack string
//    wchar_t defstring[16];    //defence string
//    wchar_t lvstring[16];     //level string
//    wchar_t lscstring[16];    //lscale string
//    wchar_t rscstring[16];    //rscale string

    explicit ClientCard(QObject *parent = 0);
    void SetCode(int code);
    void ClearTarget();
    static bool client_card_sort(ClientCard* c1, ClientCard* c2);
    static bool deck_sort_lv(code_pointer l1, code_pointer l2);    
    void UpdateInfo(char* buf);

};
}

Q_DECLARE_METATYPE(glaze::ClientCard*)
#endif // CLIENTCARD_H
