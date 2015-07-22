#include <QDebug>
#include <QEventLoop>
#include "clientcardmodel.h"
#include "clientfield.h"
#include "clientcard.h"
#include "bufferio.h"
#include "field.h"
#include "game.h"
#include "ocgapi.h"

namespace glaze {


ClientCardModel *ClientField::deck1(){
    return &deck[0];
}

ClientCardModel *ClientField::deck2(){
    return &deck[1];
}
ClientCardModel *ClientField::hand1(){
    return &hand[0];
}
ClientCardModel *ClientField::hand2(){
    return &hand[1];
}
ClientCardModel *ClientField::mzone1(){
    return &mzone[0];
}
ClientCardModel *ClientField::mzone2(){
    return &mzone[1];
}
ClientCardModel *ClientField::szone1(){
    return &szone[0];
}
ClientCardModel *ClientField::szone2(){
    return &szone[1];
}
ClientCardModel *ClientField::grave1(){
    return &grave[0];
}
ClientCardModel *ClientField::grave2(){
    return &grave[1];
}
ClientCardModel *ClientField::remove1(){
    return &remove[0];
}
ClientCardModel *ClientField::remove2(){
    return &remove[1];
}
ClientCardModel *ClientField::extra1(){
    return &extra[0];
}
ClientCardModel *ClientField::extra2(){
    return &extra[1];
}
bool ClientField::qwShowSelectCard()
{
    return wShowSelectCard;
}

bool ClientField::qwShowChainCard()
{
    return wShowChainCard;
}
//QQmlListProperty<ClientCard> ClientField::Overlay_cards(){
////    return QQmlListProperty<ClientCard>(this, Overlay_cards); //TODO: overlay_card return func.
//}

ClientField::ClientField()
{
    hovered_card = 0;
    clicked_card = 0;
    highlighting_card = 0;
    deck_act = false;
    grave_act = false;
    remove_act = false;
    extra_act = false;
    pzone_act = false;
    deck_reversed = false;
    for(int p = 0; p < 2; ++p) {
        for(int i = 0; i < 5; ++i)
            mzone[p].push_back(0);
//            QMetaObject::invokeMethod(&mzone[p],"push_back",Qt::QueuedConnection,Q_ARG(ClientCard*, 0));
        for(int i = 0; i < 8; ++i)
            szone[p].push_back(0);
//            QMetaObject::invokeMethod(&szone[p],"push_back",Qt::QueuedConnection,Q_ARG(ClientCard*, 0));
    }
}

ClientField::~ClientField() {
    for(int p = 0; p < 2; ++p) {
        for(int i = 0; i < 5; ++i)
            mzone[p].clear();
        for(int i = 0; i < 8; ++i)
            szone[p].clear();
    }
}

void ClientField::Clear()
{
    for(int i = 0; i < 2; ++i) {
        for(auto cit = deck[i].begin(); cit != deck[i].end(); ++cit)
            delete *cit;
        deck[i].clear();
//        QMetaObject::invokeMethod(&deck[i], "clear",Qt::QueuedConnection);
        for(auto cit = hand[i].begin(); cit != hand[i].end(); ++cit)
            delete *cit;
        hand[i].clear();
//        QMetaObject::invokeMethod(&hand[i], "clear",Qt::QueuedConnection);
        for(auto cit = mzone[i].begin(); cit != mzone[i].end(); ++cit) {
            if(*cit)
                delete *cit;
            *cit = 0;
        }
        for(auto cit = szone[i].begin(); cit != szone[i].end(); ++cit) {
            if(*cit)
                delete *cit;
            *cit = 0;
        }
        for(auto cit = grave[i].begin(); cit != grave[i].end(); ++cit)
            delete *cit;
        grave[i].clear();
//        QMetaObject::invokeMethod(&grave[i], "clear",Qt::QueuedConnection);
        for(auto cit = remove[i].begin(); cit != remove[i].end(); ++cit)
            delete *cit;
        remove[i].clear();
//        QMetaObject::invokeMethod(&remove[i], "clear",Qt::QueuedConnection);
        for(auto cit = extra[i].begin(); cit != extra[i].end(); ++cit)
            delete *cit;
        extra[i].clear();
//        QMetaObject::invokeMethod(&extra[i], "clear",Qt::QueuedConnection);
    }
    for(auto sit = overlay_cards.begin(); sit != overlay_cards.end(); ++sit)
        delete *sit;
    overlay_cards.clear();
    chains.clear();
    disabled_field = 0;
    deck_act = false;
    grave_act = false;
    remove_act = false;
    extra_act = false;
    pzone_act = false;
    deck_reversed = false;
    emit clearFinished();
}

void ClientField::Initial(int player, int deckc, int extrac)
{
    ClientCard* pcard;
    for(int i = 0; i < deckc; ++i) {
        pcard = new ClientCard;
        QMetaObject::invokeMethod(&deck[player],"push_back", Qt::QueuedConnection, Q_ARG(ClientCard*, pcard));
        pcard->owner = player;
        pcard->controler = player;
        pcard->location = 0x1;
        pcard->sequence = i;
//        GetCardLocation(pcard, &pcard->curPos, &pcard->curRot);
    }
    for(int i = 0; i < extrac; ++i) {
        pcard = new ClientCard;
        QMetaObject::invokeMethod(&extra[player],"push_back", Qt::QueuedConnection, Q_ARG(ClientCard*, pcard));
        pcard->owner = player;
        pcard->controler = player;
        pcard->location = 0x40;
        pcard->sequence = i;
        pcard->position = POS_FACEDOWN_DEFENCE;
//        GetCardLocation(pcard, &pcard->curPos, &pcard->curRot);
    }
}

ClientCard* ClientField::GetCard(int controler, int location, int sequence, int sub_seq)
{
    ClientCardModel* lst = 0;
    bool is_xyz = (location & 0x80) != 0;
    location &= 0x7f;
    switch(location) {
    case LOCATION_DECK:
        lst = &deck[controler];
        break;
    case LOCATION_HAND:
        lst = &hand[controler];
        break;
    case LOCATION_MZONE:
        lst = &mzone[controler];
        break;
    case LOCATION_SZONE:
        lst = &szone[controler];
        break;
    case LOCATION_GRAVE:
        lst = &grave[controler];
        break;
    case LOCATION_REMOVED:
        lst = &remove[controler];
        break;
    case LOCATION_EXTRA:
        lst = &extra[controler];
        break;
    }
    if(!lst)
        return 0;
    if(is_xyz) {
        if(sequence >= (int)lst->size())
            return 0;
        ClientCard* scard = (*lst)[sequence];
        if(scard && (int)scard->overlayed.size() > sub_seq)
            return scard->overlayed[sub_seq];
        else
            return 0;
    } else {
        if(sequence >= (int)lst->size())
            return 0;
        return (*lst)[sequence];
    }
}

ClientCard *ClientField::AddCard(int controler, int location, int sequence, ClientCard* pcard, ClientCard** newcard)
{
    if(!pcard)
        pcard = new ClientCard;
	if(newcard)
		*newcard = pcard;
    pcard->controler = controler;
    pcard->location = location;
    pcard->sequence = sequence;
//    QEventLoop loop;

    switch(location) {
    case LOCATION_DECK: {
//        connect(&deck[controler], SIGNAL(pushBackFinished()), &loop, SLOT(quit()));
        if (sequence != 0 || deck[controler].size() == 0) {
            deck[controler].push_back(pcard);
//            QMetaObject::invokeMethod(&deck[controler],"push_back", Qt::QueuedConnection, Q_ARG(ClientCard*, pcard));
//            loop.exec();
            pcard->sequence = deck[controler].size() - 1;
        } else {
            deck[controler].push_back(0);
//            QMetaObject::invokeMethod(&deck[controler],"push_back", Qt::QueuedConnection, Q_ARG(ClientCard*, 0));
//            loop.exec();
            for(int i = deck[controler].size() - 1; i > 0; --i) {
                deck[controler][i] = deck[controler][i - 1];
                deck[controler][i]->sequence++;
            }
            deck[controler][0] = pcard;
            pcard->sequence = 0;
        }
        pcard->is_reversed = false;
        break;
    }
    case LOCATION_HAND: {
        hand[controler].push_back(pcard);
//        connect(&hand[controler], SIGNAL(pushBackFinished()), &loop, SLOT(quit()));
//        QMetaObject::invokeMethod(&hand[controler],"push_back", Qt::QueuedConnection, Q_ARG(ClientCard*, pcard));
//        loop.exec();
        pcard->sequence = hand[controler].size() - 1;
        break;
    }
    case LOCATION_MZONE: {
        mzone[controler][sequence] = pcard;
        break;
    }
    case LOCATION_SZONE: {
        szone[controler][sequence] = pcard;
        break;
    }
    case LOCATION_GRAVE: {
        grave[controler].push_back(pcard);
//        connect(&grave[controler], SIGNAL(pushBackFinished()), &loop, SLOT(quit()));
//        QMetaObject::invokeMethod(&grave[controler],"push_back", Qt::QueuedConnection, Q_ARG(ClientCard*, pcard));
//        loop.exec();
        pcard->sequence = grave[controler].size() - 1;
        break;
    }
    case LOCATION_REMOVED: {
        remove[controler].push_back(pcard);
//        connect(&remove[controler], SIGNAL(pushBackFinished()), &loop, SLOT(quit()));
//        QMetaObject::invokeMethod(&remove[controler],"push_back", Qt::QueuedConnection, Q_ARG(ClientCard*, pcard));
//        loop.exec();
        pcard->sequence = remove[controler].size() - 1;
        break;
    }
    case LOCATION_EXTRA: {
        extra[controler].push_back(pcard);
//        connect(&extra[controler], SIGNAL(pushBackFinished()), &loop, SLOT(quit()));
//        QMetaObject::invokeMethod(&extra[controler],"push_back", Qt::QueuedConnection, Q_ARG(ClientCard*, pcard));
//        loop.exec();
        pcard->sequence = extra[controler].size() - 1;
        break;
    }
    }
    emit addCardFinished();
    return pcard;
}

ClientCard* ClientField::RemoveCard(int controler, int location, int sequence)
{
    ClientCard* pcard = 0;
    switch (location) {
    case LOCATION_DECK: {
        pcard = deck[controler][sequence];
        for (size_t i = sequence; i < (unsigned int)deck[controler].size() - 1; ++i) {
            deck[controler][i] = deck[controler][i + 1];
            deck[controler][i]->sequence--;
            deck[controler][i]->curPos -= QVector3D(0, 0, 0.01f);
        }
        QMetaObject::invokeMethod(&deck[controler],"erase",Qt::QueuedConnection,Q_ARG(myIter, deck[controler].end() - 1));
        break;
    }
    case LOCATION_HAND: {
        pcard = hand[controler][sequence];
        for (size_t i = sequence; i < (unsigned int)hand[controler].size() - 1; ++i) {
            hand[controler][i] = hand[controler][i + 1];
            hand[controler][i]->sequence--;
        }
        QMetaObject::invokeMethod(&hand[controler],"erase",Qt::QueuedConnection,Q_ARG(myIter, hand[controler].end() - 1));
        break;
    }
    case LOCATION_MZONE: {
        pcard = mzone[controler][sequence];
        mzone[controler][sequence] = 0;
        break;
    }
    case LOCATION_SZONE: {
        pcard = szone[controler][sequence];
        szone[controler][sequence] = 0;
        break;
    }
    case LOCATION_GRAVE: {
        pcard = grave[controler][sequence];
        for (size_t i = sequence; i < (unsigned int)grave[controler].size() - 1; ++i) {
            grave[controler][i] = grave[controler][i + 1];
            grave[controler][i]->sequence--;
            grave[controler][i]->curPos -= QVector3D(0, 0, 0.01f);
        }
        QMetaObject::invokeMethod(&grave[controler],"erase",Qt::QueuedConnection,Q_ARG(myIter, grave[controler].end() - 1));
        break;
    }
    case LOCATION_REMOVED: {
        pcard = remove[controler][sequence];
        for (size_t i = sequence; i < (unsigned int)remove[controler].size() - 1; ++i) {
            remove[controler][i] = remove[controler][i + 1];
            remove[controler][i]->sequence--;
            remove[controler][i]->curPos -= QVector3D(0, 0, 0.01f);
        }
        QMetaObject::invokeMethod(&remove[controler],"erase",Qt::QueuedConnection,Q_ARG(myIter, remove[controler].end() - 1));
        break;
    }
    case LOCATION_EXTRA: {
        pcard = extra[controler][sequence];
        for (size_t i = sequence; i < (unsigned int)extra[controler].size() - 1; ++i) {
            extra[controler][i] = extra[controler][i + 1];
            extra[controler][i]->sequence--;
            extra[controler][i]->curPos -= QVector3D(0, 0, 0.01f);
        }
        QMetaObject::invokeMethod(&extra[controler],"erase",Qt::QueuedConnection,Q_ARG(myIter, extra[controler].end() - 1));
        break;
    }
    }
    pcard->location = 0;
    return pcard;
}

void ClientField::UpdateCard(int controler, int location, int sequence, char *buf)
{
//    char *data = (char*)buf.buffer;
    char *data = buf;
    ClientCard* pcard = GetCard(controler, location, sequence);
    ClientCardModel* lst = 0;
    switch(location)
    {
    case LOCATION_DECK:
        lst = &deck[controler];
        break;
    case LOCATION_HAND:
        lst = &hand[controler];
        break;
    case LOCATION_MZONE:
        lst = &mzone[controler];
        break;
    case LOCATION_SZONE:
        lst = &szone[controler];
        break;
    case LOCATION_GRAVE:
        lst = &grave[controler];
        break;
    case LOCATION_REMOVED:
        lst = &remove[controler];
        break;
    case LOCATION_EXTRA:
        lst = &extra[controler];
        break;
    }
    if(!lst)
        return;
    if(pcard)
        pcard->UpdateInfo(data + 4);
    lst->dataChangedSignal(sequence);
    emit updateCardFinished();
}

void ClientField::UpdateFieldCard(int controler, int location, char *buf)
{
//    char *data = (char*)buf.buffer;
    char *data = buf;
    ClientCardModel* lst = 0;
    QList<ClientCard*>::iterator cit;
    switch(location)
    {
    case LOCATION_DECK:
        lst = &deck[controler];
        break;
    case LOCATION_HAND:
        lst = &hand[controler];
        break;
    case LOCATION_MZONE:
        lst = &mzone[controler];
        break;
    case LOCATION_SZONE:
        lst = &szone[controler];
        break;
    case LOCATION_GRAVE:
        lst = &grave[controler];
        break;
    case LOCATION_REMOVED:
        lst = &remove[controler];
        break;
    case LOCATION_EXTRA:
        lst = &extra[controler];
        break;
    }
    if(!lst)
        return;
    int len;
    for(cit = lst->begin(); cit != lst->end(); ++cit) {
        len = BufferIO::ReadInt32(data);
        if(len > 8) {
            (*cit)->UpdateInfo(data);
        }
        data += len - 4;
    }
    lst->dataChangedSignal();
    emit updateFieldCardFinished();
}

void ClientField::ClearCommandFlag() {
    QList<ClientCard*>::iterator cit;
    for(cit = activatable_cards.begin(); cit != activatable_cards.end(); ++cit)
        (*cit)->cmdFlag = 0;
    for(cit = summonable_cards.begin(); cit != summonable_cards.end(); ++cit)
        (*cit)->cmdFlag = 0;
    for(cit = spsummonable_cards.begin(); cit != spsummonable_cards.end(); ++cit)
        (*cit)->cmdFlag = 0;
    for(cit = msetable_cards.begin(); cit != msetable_cards.end(); ++cit)
        (*cit)->cmdFlag = 0;
    for(cit = ssetable_cards.begin(); cit != ssetable_cards.end(); ++cit)
        (*cit)->cmdFlag = 0;
    for(cit = reposable_cards.begin(); cit != reposable_cards.end(); ++cit)
        (*cit)->cmdFlag = 0;
    for(cit = attackable_cards.begin(); cit != attackable_cards.end(); ++cit)
        (*cit)->cmdFlag = 0;
    deck_act = false;
    extra_act = false;
    grave_act = false;
    remove_act = false;
    pzone_act = false;
}

void ClientField::ClearSelect() {
    QList<ClientCard*>::iterator cit;
    for(cit = selectable_cards.begin(); cit != selectable_cards.end(); ++cit) {
        (*cit)->is_selectable = false;
        (*cit)->is_selected = false;
    }
}

void ClientField::ClearChainSelect() {
    QList<ClientCard*>::iterator cit;
    for(cit = activatable_cards.begin(); cit != activatable_cards.end(); ++cit) {
        (*cit)->cmdFlag = 0;
        (*cit)->is_selectable = false;
        (*cit)->is_selected = false;
    }
    grave_act = false;
    remove_act = false;
}

void ClientField::ShowSelectCard(bool buttonok)
{
    wShowSelectCard = true;
}
void ClientField::ShowChainCard()
{
    wShowChainCard = true;
}
void ClientField::ReplaySwap()
{
    QMetaObject::invokeMethod(&deck[0],"swap",Qt::QueuedConnection,Q_ARG(ClientCardModel&, deck[1]));
    QMetaObject::invokeMethod(&hand[0],"swap",Qt::QueuedConnection,Q_ARG(ClientCardModel&, hand[1]));
    QMetaObject::invokeMethod(&mzone[0],"swap",Qt::QueuedConnection,Q_ARG(ClientCardModel&, mzone[1]));
    QMetaObject::invokeMethod(&szone[0],"swap",Qt::QueuedConnection,Q_ARG(ClientCardModel&, szone[1]));
    QMetaObject::invokeMethod(&grave[0],"swap",Qt::QueuedConnection,Q_ARG(ClientCardModel&, grave[1]));
    QMetaObject::invokeMethod(&remove[0],"swap",Qt::QueuedConnection,Q_ARG(ClientCardModel&, remove[1]));
    QMetaObject::invokeMethod(&extra[0],"swap",Qt::QueuedConnection,Q_ARG(ClientCardModel&, extra[1]));
    for(int p = 0; p < 2; ++p) {
        for(auto cit = deck[p].begin(); cit != deck[p].end(); ++cit) {
            (*cit)->controler = 1 - (*cit)->controler;
//            GetCardLocation(*cit, &(*cit)->curPos, &(*cit)->curRot);
//			(*cit)->mTransform.setTranslation((*cit)->curPos);
//			(*cit)->mTransform.setRotationRadians((*cit)->curRot);
            (*cit)->is_moving = false;
        }
        for(auto cit = hand[p].begin(); cit != hand[p].end(); ++cit) {
            (*cit)->controler = 1 - (*cit)->controler;
//            GetCardLocation(*cit, &(*cit)->curPos, &(*cit)->curRot);
//			(*cit)->mTransform.setTranslation((*cit)->curPos);
//			(*cit)->mTransform.setRotationRadians((*cit)->curRot);
            (*cit)->is_moving = false;
        }
        for(auto cit = mzone[p].begin(); cit != mzone[p].end(); ++cit) {
            if(*cit) {
                (*cit)->controler = 1 - (*cit)->controler;
//                GetCardLocation(*cit, &(*cit)->curPos, &(*cit)->curRot);
//				(*cit)->mTransform.setTranslation((*cit)->curPos);
//				(*cit)->mTransform.setRotationRadians((*cit)->curRot);
                (*cit)->is_moving = false;
            }
        }
        for(auto cit = szone[p].begin(); cit != szone[p].end(); ++cit) {
            if(*cit) {
                (*cit)->controler = 1 - (*cit)->controler;
//                GetCardLocation(*cit, &(*cit)->curPos, &(*cit)->curRot);
//				(*cit)->mTransform.setTranslation((*cit)->curPos);
//				(*cit)->mTransform.setRotationRadians((*cit)->curRot);
                (*cit)->is_moving = false;
            }
        }
        for(auto cit = grave[p].begin(); cit != grave[p].end(); ++cit) {
            (*cit)->controler = 1 - (*cit)->controler;
//            GetCardLocation(*cit, &(*cit)->curPos, &(*cit)->curRot);
//			(*cit)->mTransform.setTranslation((*cit)->curPos);
//			(*cit)->mTransform.setRotationRadians((*cit)->curRot);
            (*cit)->is_moving = false;
        }
        for(auto cit = remove[p].begin(); cit != remove[p].end(); ++cit) {
            (*cit)->controler = 1 - (*cit)->controler;
//            GetCardLocation(*cit, &(*cit)->curPos, &(*cit)->curRot);
//			(*cit)->mTransform.setTranslation((*cit)->curPos);
//			(*cit)->mTransform.setRotationRadians((*cit)->curRot);
            (*cit)->is_moving = false;
        }
        for(auto cit = extra[p].begin(); cit != extra[p].end(); ++cit) {
            (*cit)->controler = 1 - (*cit)->controler;
//            GetCardLocation(*cit, &(*cit)->curPos, &(*cit)->curRot);
//			(*cit)->mTransform.setTranslation((*cit)->curPos);
//			(*cit)->mTransform.setRotationRadians((*cit)->curRot);
            (*cit)->is_moving = false;
        }
    }
    for(auto cit = overlay_cards.begin(); cit != overlay_cards.end(); ++cit) {
        (*cit)->controler = 1 - (*cit)->controler;
//        GetCardLocation(*cit, &(*cit)->curPos, &(*cit)->curRot);
//		(*cit)->mTransform.setTranslation((*cit)->curPos);
//		(*cit)->mTransform.setRotationRadians((*cit)->curRot);
        (*cit)->is_moving = false;
    }
    mainGame->dInfo.isFirst = !mainGame->dInfo.isFirst;
    std::swap(mainGame->dInfo.lp[0], mainGame->dInfo.lp[1]);
//    for(int i = 0; i < 16; ++i)
//        std::swap(mainGame->dInfo.strLP[0][i], mainGame->dInfo.strLP[1][i]);
    for(int i = 0; i < 20; ++i)
        std::swap(mainGame->dInfo.hostname[i], mainGame->dInfo.clientname[i]);
    for(auto chit = chains.begin(); chit != chains.end(); ++chit) {
        chit->controler = 1 - chit->controler;
        GetChainLocation(chit->controler, chit->location, chit->sequence, &chit->chain_pos);
    }
    disabled_field = (disabled_field >> 16) | (disabled_field << 16);
}

//void ClientField::RefreshAllCards()
//{
//    for(int p = 0; p < 2; ++p)
//    {
//        for(auto cit = deck[p].begin(); cit != deck[p].end(); ++cit)
//        {
//            GetCardLocation(*cit, &(*cit)->curPos, &(*cit)->curRot);
//            (*cit)->is_moving = false;
//        }
//        for(auto cit = hand[p].begin(); cit != hand[p].end(); ++cit)
//        {
//            GetCardLocation(*cit, &(*cit)->curPos, &(*cit)->curRot);
//            (*cit)->is_moving = false;
//        }
//        for(auto cit = mzone[p].begin(); cit != mzone[p].end(); ++cit)
//        {
//            if(*cit)
//            {
//                GetCardLocation(*cit, &(*cit)->curPos, &(*cit)->curRot);
//                (*cit)->is_moving = false;
//            }
//        }
//        for(auto cit = szone[p].begin(); cit != szone[p].end(); ++cit)
//        {
//            if(*cit)
//            {
//                GetCardLocation(*cit, &(*cit)->curPos, &(*cit)->curRot);
//                (*cit)->is_moving = false;
//            }
//        }
//        for(auto cit = grave[p].begin(); cit != grave[p].end(); ++cit)
//        {
//            GetCardLocation(*cit, &(*cit)->curPos, &(*cit)->curRot);
//            (*cit)->is_moving = false;
//        }
//        for(auto cit = remove[p].begin(); cit != remove[p].end(); ++cit)
//        {
//            GetCardLocation(*cit, &(*cit)->curPos, &(*cit)->curRot);
//            (*cit)->is_moving = false;
//        }
//        for(auto cit = extra[p].begin(); cit != extra[p].end(); ++cit)
//        {
//            GetCardLocation(*cit, &(*cit)->curPos, &(*cit)->curRot);
//            (*cit)->is_moving = false;
//        }
//    }
//    for(auto cit = overlay_cards.begin(); cit != overlay_cards.end(); ++cit)
//    {
//        GetCardLocation(*cit, &(*cit)->curPos, &(*cit)->curRot);
//        (*cit)->is_moving = false;
//    }
//}

void ClientField::GetChainLocation(int controler, int location, int sequence, QVector3D* t)
{
    t->setX(0);
    t->setY(0);
    t->setZ(0);
    switch((location & 0x7f)) {
    case LOCATION_DECK: {
        if (controler == 0) {
            t->setX(vdeck0.x());
            t->setY(vdeck0.y());
            t->setZ(deck[controler].size() * 0.01f + 0.03f);
        } else {
            t->setX(vdeck1.x());
            t->setY(vdeck1.y());
            t->setZ(deck[controler].size() * 0.01f + 0.03f);
        }
        break;
    }
    case LOCATION_HAND: {
        if (controler == 0) {
            t->setX(2.95f);
            t->setY(3.15f);
            t->setZ(0.03f);
        } else {
            t->setX(2.95f);
            t->setY(-3.15f);
            t->setZ(0.03f);
        }
        break;
    }
    case LOCATION_MZONE: {
        if (controler == 0) {
            t->setX(vmzone0.x() + 1.1f * sequence);
            t->setY(vmzone0.y());
            t->setZ(0.03f);
        } else {
            t->setX(vmzone1.x() - 1.1f * sequence);
            t->setY(vmzone1.y());
            t->setZ(0.03f);
        }
        break;
    }
    case LOCATION_SZONE: {
        if (controler == 0) {
            if (sequence <= 4) {
                t->setX(vszone0.x() + 1.1f * sequence);
                t->setY(vszone0.y());
                t->setZ(0.03f);
            } else if (sequence == 5) {
                t->setX(vsfield0.x());
                t->setY(vsfield0.y());
                t->setZ(0.03f);
            } else if (sequence == 6) {
                t->setX(vsLScale0.x());
                t->setY(vsLScale0.y());
                t->setZ(0.03f);
            } else {
                t->setX(vsRScale0.x());
                t->setY(vsRScale0.y());
                t->setZ(0.03f);
            }
        } else {
            if (sequence <= 4) {
                t->setX(vszone1.x() - 1.1f * sequence);
                t->setY(vszone1.y());
                t->setZ(0.03f);
            } else if (sequence == 5) {
                t->setX(vsfield1.x());
                t->setY(vsfield1.y());
                t->setZ(0.03f);
            } else if (sequence == 6) {
                t->setX(vsLScale1.x());
                t->setY(vsLScale1.y());
                t->setZ(0.03f);
            } else {
                t->setX(vsRScale1.x());
                t->setY(vsRScale1.y());
                t->setZ(0.03f);
            }
        }
        break;
    }
    case LOCATION_GRAVE: {
        if (controler == 0) {
            t->setX(vgrave0.x());
            t->setY(vgrave0.y());
            t->setZ(grave[controler].size() * 0.01f + 0.03f);
        } else {
            t->setX(vgrave1.x());
            t->setY(vgrave1.y());
            t->setZ(grave[controler].size() * 0.01f + 0.03f);
        }
        break;
    }
    case LOCATION_REMOVED: {
        if (controler == 0) {
            t->setX(vremove0.x());
            t->setY(vremove0.y());
            t->setZ(remove[controler].size() * 0.01f + 0.03f);
        } else {
            t->setX(vremove1.x());
            t->setY(vremove1.y());
            t->setZ(remove[controler].size() * 0.01f + 0.03f);
        }
        break;
    }
    case LOCATION_EXTRA: {
        if (controler == 0) {
            t->setX(vextra0.x());
            t->setY(vextra0.y());
            t->setZ(extra[controler].size() * 0.01f + 0.03f);
        } else {
            t->setX(vextra1.x());
            t->setY(vextra1.y());
            t->setZ(extra[controler].size() * 0.01f + 0.03f);
        }
        break;
    }
    }
}

//void ClientField::GetCardLocation(ClientCard* pcard, QVector3D* t, QVector3D* r, bool setTrans) //this function will be removed
//{
//    Q_UNUSED(setTrans);
//    int controler = pcard->controler;
//    int sequence = pcard->sequence;
//    int location = pcard->location;
//    switch (location) {
//        case LOCATION_DECK: {
//        if (controler == 0) {
//            t->setX(vdeck0.x());
//            t->setY(vdeck0.y());
//            t->setZ(0.01f + 0.01f * sequence);
//            if(deck_reversed == pcard->is_reversed) {
//                            r->setX(0.0f);
//                            r->setY(3.1415926f);
//                            r->setZ(0.0f);
//                        } else {
//                            r->setX(0.0f);
//                            r->setY(0.0f);
//                            r->setZ(0.0f);
//        }
//    }
//        else {
//                    t->setX(vdeck1.x());
//                    t->setY(vdeck1.y());
//                    t->setZ(0.01f + 0.01f * sequence);
//                    if(deck_reversed == pcard->is_reversed) {
//                        r->setX(0.0f);
//                        r->setY(3.1415926f);
//                        r->setZ(3.1415926f);
//                    } else {
//                        r->setX(0.0f);
//                        r->setY(0.0f);
//                        r->setZ(3.1415926f);
//                    }
//                }
//                break;
//    }
//    case 0:
//    case LOCATION_HAND: break;  // removed; updates in qml
//    case LOCATION_MZONE: {
//        if (controler == 0) {
//            t->setX(vmzone0.x() + 1.1f * sequence);
//            t->setY(vmzone0.y());
//            t->setZ(0.01f);
//            if (pcard->position & POS_DEFENCE) {
//                r->setX(0.0f);
//                r->setZ(-3.1415926f / 2.0f);
//                if (pcard->position & POS_FACEDOWN)
//                    r->setY(3.1415926f + 0.001f);
//                else r->setY(0.0f);
//            } else {
//                r->setX(0.0f);
//                r->setZ( 0.0f);
//                if (pcard->position & POS_FACEDOWN)
//                    r->setY(3.1415926f);
//                else r->setY(0.0f);
//            }
//        } else {
//            t->setX(vmzone1.x() - 1.1f * sequence);
//            t->setY(vmzone1.y());
//            t->setZ(0.01f);
//            if (pcard->position & POS_DEFENCE) {
//                r->setX(0.0f);
//                r->setZ(3.1415926f / 2.0f);
//                if (pcard->position & POS_FACEDOWN)
//                    r->setY( 3.1415926f + 0.001f);
//                else r->setY( 0.0f);
//            } else {
//                r->setX(0.0f);
//                r->setZ(3.1415926f);
//                if (pcard->position & POS_FACEDOWN)
//                    r->setY(3.1415926f);
//                else r->setY( 0.0f);
//            }
//        }
//        break;
//    }
//    case LOCATION_SZONE: {
//        if (controler == 0) {
//            if (sequence <= 4) {
//                t->setX(vszone0.x() + 1.1f * sequence);
//                t->setY(vszone0.y());
//                t->setZ(0.01f);
//            } else if (sequence == 5) {
//                t->setX(vsfield0.x());
//                t->setY(vsfield0.y());
//                t->setZ(0.01f);
//            } else if (sequence == 6) {
//                t->setX(vsLScale0.x());
//                t->setY(vsLScale0.y());
//                t->setZ(0.01f);
//            } else {
//                t->setX(vsRScale0.x());
//                t->setY(vsRScale0.y());
//                t->setZ(0.01f);
//            }
//            r->setX(0.0f);
//            r->setZ(0.0f);
//            if (pcard->position & POS_FACEDOWN)
//                r->setY(3.1415926f);
//            else r->setY(0.0f);
//        } else {
//            if (sequence <= 4) {
//                t->setX(vszone1.x() - 1.1f * sequence);
//                t->setY(vszone1.y());
//                t->setZ(0.01f);
//            } else if (sequence == 5) {
//                t->setX(vsfield1.x());
//                t->setY(vsfield1.y());
//                t->setZ(0.01f);
//            } else if (sequence == 6) {
//                t->setX(vsLScale1.x());
//                t->setY(vsLScale1.y());
//                t->setZ(0.01f);
//            } else {
//                t->setX(vsRScale1.x());
//                t->setY(vsRScale1.y());
//                t->setZ(0.01f);
//            }
//            r->setX(0.0f);
//            r->setZ( 3.1415926f);
//            if (pcard->position & POS_FACEDOWN)
//                r->setY(3.1415926f);
//            else r->setY(0.0f);
//        }
//        break;
//    }
//    case LOCATION_GRAVE: {
//        if (controler == 0) {
//            t->setX(vgrave0.x());
//            t->setY(vgrave0.y());
//            t->setZ(0.01f + 0.01f * sequence);
//            r->setX(0.0f);
//            r->setY(0.0f);
//            r->setZ(0.0f);
//        } else {
//            t->setX(vgrave1.x());
//            t->setY(vgrave1.y());
//            t->setZ( 0.01f + 0.01f * sequence);
//            r->setX( 0.0f);
//            r->setY(0.0f);
//            r->setZ(3.1415926f);
//        }
//        break;
//    }
//    case LOCATION_REMOVED: {
//        if (controler == 0) {
//            t->setX(vremove0.x());
//            t->setY(vremove0.y());
//            t->setZ(0.01f + 0.01f * sequence);
//            if(pcard->position & POS_FACEUP) {
//                r->setX(0.0f);
//                r->setY(0.0f);
//                r->setZ(0.0f);
//            } else {
//                r->setX(0.0f);
//                r->setY(3.1415926f);
//                r->setZ(0.0f);
//            }
//        } else {
//            t->setX(vremove1.x());
//            t->setY(vremove1.y());
//            t->setZ(0.01f + 0.01f * sequence);
//            if(pcard->position & POS_FACEUP) {
//                r->setX(0.0f);
//                r->setY(0.0f);
//                r->setZ(3.1415926f);
//            } else {
//                r->setX( 0.0f);
//                r->setY(3.1415926f);
//                r->setZ(3.1415926f);
//            }
//        }
//        break;
//    }
//    case LOCATION_EXTRA: {
//        if (controler == 0) {
//            t->setX(vextra0.x());
//            t->setY(vextra0.y());
//            t->setZ(0.01f + 0.01f * sequence);
//            r->setX(0.0f);
//            if(pcard->position & POS_FACEUP)
//                r->setY(0.0f);
//            else r->setY(3.1415926f);
//            r->setZ(0.0f);
//        } else {
//            t->setX(vextra1.x());
//            t->setY(vextra1.y());
//            t->setZ(0.01f * sequence);
//            r->setX(0.0f);
//            if(pcard->position & POS_FACEUP)
//                r->setY(0.0f);
//            else r->setY(3.1415926f);
//            r->setZ(3.1415926f);
//        }
//        break;
//    }
//    case LOCATION_OVERLAY: {
//        if (pcard->overlayTarget->location != 0x4) {
//            return;
//        }
//        int oseq = pcard->overlayTarget->sequence;
//        if (pcard->overlayTarget->controler == 0) {
//            t->setX(vmzone0.x() + 1.1f * oseq - 0.12f + 0.06f * sequence);
//            t->setY(vmzone0.y() + 0.05f);
//            t->setZ(0.005f + pcard->sequence * 0.0001f);
//            r->setX( 0.0f);
//            r->setY(0.0f);
//            r->setZ(0.0f);
//        } else {
//            t->setX(vmzone1.x() - 1.1f * oseq + 0.12f - 0.06f * sequence);
//            t->setY(vmzone1.y() - 0.05f);
//            t->setZ( 0.005f + pcard->sequence * 0.0001f);
//            r->setX(0.0f);
//            r->setY( 0.0f);
//            r->setZ(3.1415926f);
//        }
//        break;
//    }
//}
////    if(setTrans) {
////		pcard->mTransform.setTranslation(*t);
////		pcard->mTransform.setRotationRadians(*r);
////	}
//}

void ClientField::MoveCard(ClientCard * pcard, int frame)
{
    //New definition required here

//    QVector3D trans = pcard->curPos;
//    QVector3D rot = pcard->curRot;
////    GetCardLocation(pcard, &trans, &rot);
//    pcard->dPos = (trans - pcard->curPos) / frame;
//    float diff = rot.x() - pcard->curRot.x();
//    while (diff < 0) diff += 3.1415926f * 2;
//    while (diff > 3.1415926f * 2)
//        diff -= 3.1415926f * 2;
//    if (diff < 3.1415926f)
//        pcard->dRot.setX(diff / frame);
//    else
//        pcard->dRot.setX(-(3.1415926f * 2 - diff) / frame);
//    diff = rot.y() - pcard->curRot.y();
//    while (diff < 0) diff += 3.1415926f * 2;
//    while (diff > 3.1415926f * 2) diff -= 3.1415926f * 2;
//    if (diff < 3.1415926f)
//        pcard->dRot.setY( diff / frame);
//    else
//        pcard->dRot.setY(-(3.1415926f * 2 - diff) / frame);
//    diff = rot.z() - pcard->curRot.z();
//    while (diff < 0) diff += 3.1415926f * 2;
//    while (diff > 3.1415926f * 2) diff -= 3.1415926f * 2;
//    if (diff < 3.1415926f)
//        pcard->dRot.setZ(diff / frame);
//    else
//        pcard->dRot.setZ(-(3.1415926f * 2 - diff) / frame);
//    pcard->is_moving = true;
//    pcard->aniFrame = frame;
}

void ClientField::FadeCard(ClientCard * pcard, int alpha, int frame) {
    pcard->dAlpha = (alpha - pcard->curAlpha) / frame;
//    pcard->qdAlphaChanged();
    pcard->is_fading = true;
    pcard->aniFrame = frame;
//    pcard->qaniFrameChanged();
}

bool ClientField::CheckSelectSum() {
    QSet<ClientCard*> selable;
    QSet<ClientCard*>::iterator sit;
    for(size_t i = 0; i < (unsigned int)selectsum_all.size(); ++i) {
        selectsum_all[i]->is_selectable = false;
        selectsum_all[i]->is_selected = false;
        selable.insert(selectsum_all[i]);
    }
    for(size_t i = 0; i < (unsigned int)selected_cards.size(); ++i) {
        selected_cards[i]->is_selectable = true;
        selected_cards[i]->is_selected = true;
        selable.erase(selable.find(selected_cards[i]));
    }
    selectsum_cards.clear();
    bool ret;
    if (select_mode == 0) {
        ret = check_sel_sum_s(selable, 0, select_sumval);
        selectable_cards.clear();
        for(sit = selectsum_cards.begin(); sit != selectsum_cards.end(); ++sit) {
            (*sit)->is_selectable = true;
//            QMetaObject::invokeMethod(&selectable_cards,"push_back", Qt::QueuedConnection, Q_ARG(QSet<ClientCard*>::iterator, *sit));
            selectable_cards.push_back(*sit);
        }
        return ret;
    } else {
        int op1, op2, mm = -1, ms, m, max = 0, sumc = 0, sums;
        ret = false;
        for (size_t i = 0; i < (unsigned int)selected_cards.size(); ++i) {
            op1 = selected_cards[i]->opParam & 0xffff;
            op2 = selected_cards[i]->opParam >> 16;
            m = (op2 > 0 && op1 > op2) ? op2 : op1;
            max += op2 > op1 ? op2 : op1;
            if (mm == -1 || m < mm)
                mm = m;
            sumc += m;
        }
        if (select_sumval <= sumc)
            return true;
        if (select_sumval <= max)
            ret = true;
        for(sit = selable.begin(); sit != selable.end(); ++sit) {
            op1 = (*sit)->opParam & 0xffff;
            op2 = (*sit)->opParam >> 16;
            m = op1;
            sums = sumc;
            sums += m;
            ms = mm;
            if (ms == -1 || m < ms)
                ms = m;
            if (sums >= select_sumval) {
                if (sums - ms < select_sumval)
                    selectsum_cards.insert(*sit);
            } else {
                QSet<ClientCard*> left(selable);
                left.erase(left.find(*sit));
                if (check_min(left, left.begin(), select_sumval - sums, select_sumval - sums + ms - 1))
                    selectsum_cards.insert(*sit);
            }
            if (op2 == 0)
                continue;
            m = op2;
            sums = sumc;
            sums += m;
            ms = mm;
            if (ms == -1 || m < ms)
                ms = m;
            if (sums >= select_sumval) {
                if (sums - ms < select_sumval)
                    selectsum_cards.insert(*sit);
            } else {
                QSet<ClientCard*> left(selable);
                left.erase(left.find(*sit));
                if (check_min(left, left.begin(), select_sumval - sums, select_sumval - sums + ms - 1))
                    selectsum_cards.insert(*sit);
            }
        }
        selectable_cards.clear();
        for(sit = selectsum_cards.begin(); sit != selectsum_cards.end(); ++sit) {
            (*sit)->is_selectable = true;
//            QMetaObject::invokeMethod(&selectable_cards,"push_back", Qt::QueuedConnection, Q_ARG(QSet<ClientCard*>::iterator, *sit));
            selectable_cards.push_back(*sit);
        }
        return ret;
    }
}

bool ClientField::check_min(QSet<ClientCard*>& left, QSet<ClientCard*>::iterator index, int min, int max) {
    if (index == left.end())
        return false;
    int op1 = (*index)->opParam & 0xffff;
    int op2 = (*index)->opParam >> 16;
    int m = (op2 > 0 && op1 > op2) ? op2 : op1;
    if (m >= min && m <= max)
        return true;
    index++;
    return (min > m && check_min(left, index, min - m, max - m))
            || check_min(left, index, min, max);
}

bool ClientField::check_sel_sum_s(QSet<ClientCard*>& left, int index, int acc) {
    if (index == (int)selected_cards.size()) {
        if (acc == 0)
            return true;
        check_sel_sum_t(left, acc);
        return false;
    }
    int l = selected_cards[index]->opParam;
    int l1 = l & 0xffff;
    int l2 = l >> 16;
    bool res1 = false, res2 = false;
    res1 = check_sel_sum_s(left, index + 1, acc - l1);
    if (l2 > 0)
        res2 = check_sel_sum_s(left, index + 1, acc - l2);
    return res1 || res2;
}

void ClientField::check_sel_sum_t(QSet<ClientCard*>& left, int acc) {
    QSet<ClientCard*>::iterator sit;
    for (sit = left.begin(); sit != left.end(); ++sit) {
        if (selectsum_cards.find(*sit) != selectsum_cards.end())
            continue;
        QSet<ClientCard*> testlist(left);
        testlist.erase(testlist.find(*sit));
        int l = (*sit)->opParam;
        int l1 = l & 0xffff;
        int l2 = l >> 16;
        if (check_sum(testlist, testlist.begin(), acc - l1, selected_cards.size() + 1)
                || (l2 > 0 && check_sum(testlist, testlist.begin(), acc - l2, selected_cards.size() + 1))) {
            selectsum_cards.insert(*sit);
        }
    }
}

bool ClientField::check_sum(QSet<ClientCard*>& testlist, QSet<ClientCard*>::iterator index, int acc, int count) {
    if (acc == 0)
        return count >= select_min && count <= select_max;
    if (acc < 0 || index == testlist.end())
        return false;
    int l = (*index)->opParam;
    int l1 = l & 0xffff;
    int l2 = l >> 16;
    if ((l1 == acc || (l2 > 0 && l2 == acc)) && (count + 1 >= select_min) && (count + 1 <= select_max))
        return true;
    index++;
    return (acc > l1 && check_sum(testlist, index, acc - l1, count + 1))
           || (l2 > 0 && acc > l2 && check_sum(testlist, index, acc - l2, count + 1))
           || check_sum(testlist, index, acc, count);
}

void ClientField::SinglePlayRefresh(int flag) {
    unsigned char queryBuffer[0x1000];
    /*int len = */query_field_card(pduel, 0, LOCATION_MZONE, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(0), LOCATION_MZONE, (char*)queryBuffer);
    /*len = */query_field_card(pduel, 1, LOCATION_MZONE, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(1), LOCATION_MZONE, (char*)queryBuffer);
    /*len = */query_field_card(pduel, 0, LOCATION_SZONE, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(0), LOCATION_SZONE, (char*)queryBuffer);
    /*len = */query_field_card(pduel, 1, LOCATION_SZONE, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(1), LOCATION_SZONE, (char*)queryBuffer);
    /*len = */query_field_card(pduel, 0, LOCATION_HAND, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(0), LOCATION_HAND, (char*)queryBuffer);
    /*len = */query_field_card(pduel, 1, LOCATION_HAND, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(1), LOCATION_HAND, (char*)queryBuffer);
    emit singlePlayRefreshFinished();
}
void ClientField::SinglePlayRefreshHand(int player, int flag) {
    unsigned char queryBuffer[0x1000];
    /*int len = */query_field_card(pduel, player, LOCATION_HAND, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(player), LOCATION_HAND, (char*)queryBuffer);
    emit singlePlayRefreshHandFinished();
}
void ClientField::SinglePlayRefreshGrave(int player, int flag) {
    unsigned char queryBuffer[0x1000];
    /*int len = */query_field_card(pduel, player, LOCATION_GRAVE, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(player), LOCATION_GRAVE, (char*)queryBuffer);
    emit singlePlayRefreshGraveFinished();
}
void ClientField::SinglePlayRefreshDeck(int player, int flag) {
    unsigned char queryBuffer[0x1000];
    /*int len = */query_field_card(pduel, player, LOCATION_DECK, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(player), LOCATION_DECK, (char*)queryBuffer);
    singlePlayRefreshDeckFinished();
}
void ClientField::SinglePlayRefreshExtra(int player, int flag) {
    unsigned char queryBuffer[0x1000];
    /*int len = */query_field_card(pduel, player, LOCATION_EXTRA, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(player), LOCATION_EXTRA, (char*)queryBuffer);
    emit singlePlayRefreshExtraFinished();
}
void ClientField::SinglePlayRefreshSingle(int player, int location, int sequence, int flag) {
    unsigned char queryBuffer[0x1000];
    /*int len = */query_card(pduel, player, location, sequence, flag, queryBuffer, 0);
    mainGame->dField.UpdateCard(mainGame->LocalPlayer(player), location, sequence, (char*)queryBuffer);
    singlePlayRefreshSingleFinished();
}
void ClientField::SinglePlayReload() {
    unsigned char queryBuffer[0x1000];
    unsigned int flag = 0x7fdfff;
    /*int len = */query_field_card(pduel, 0, LOCATION_MZONE, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(0), LOCATION_MZONE, (char*)queryBuffer);
    /*len = */query_field_card(pduel, 1, LOCATION_MZONE, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(1), LOCATION_MZONE, (char*)queryBuffer);
    /*len = */query_field_card(pduel, 0, LOCATION_SZONE, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(0), LOCATION_SZONE, (char*)queryBuffer);
    /*len = */query_field_card(pduel, 1, LOCATION_SZONE, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(1), LOCATION_SZONE, (char*)queryBuffer);
    /*len = */query_field_card(pduel, 0, LOCATION_HAND, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(0), LOCATION_HAND, (char*)queryBuffer);
    /*len = */query_field_card(pduel, 1, LOCATION_HAND, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(1), LOCATION_HAND, (char*)queryBuffer);
    /*len = */query_field_card(pduel, 0, LOCATION_DECK, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(0), LOCATION_DECK, (char*)queryBuffer);
    /*len = */query_field_card(pduel, 1, LOCATION_DECK, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(1), LOCATION_DECK, (char*)queryBuffer);
    /*len = */query_field_card(pduel, 0, LOCATION_EXTRA, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(0), LOCATION_EXTRA, (char*)queryBuffer);
    /*len = */query_field_card(pduel, 1, LOCATION_EXTRA, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(1), LOCATION_EXTRA, (char*)queryBuffer);
    /*len = */query_field_card(pduel, 0, LOCATION_GRAVE, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(0), LOCATION_GRAVE, (char*)queryBuffer);
    /*len = */query_field_card(pduel, 1, LOCATION_GRAVE, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(1), LOCATION_GRAVE, (char*)queryBuffer);
    /*len = */query_field_card(pduel, 0, LOCATION_REMOVED, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(0), LOCATION_REMOVED, (char*)queryBuffer);
    /*len = */query_field_card(pduel, 1, LOCATION_REMOVED, flag, queryBuffer, 0);
    mainGame->dField.UpdateFieldCard(mainGame->LocalPlayer(1), LOCATION_REMOVED, (char*)queryBuffer);
    emit singlePlayReloadFinished();
}

}
