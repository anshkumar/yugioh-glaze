#include "clientcardmodel.h"
#include "datamanager.h"
#include "card.h"
#include "game.h"
#include <QThread>
#include <QDebug>

namespace glaze {

ClientCardModel::ClientCardModel(QObject *parent)
    : QAbstractListModel(parent)
{
    qRegisterMetaType<myIter>("myIter");
}

int ClientCardModel::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent);
    return m_list.count();
}

QVariant ClientCardModel::data(const QModelIndex &index, int role) const {
    if (index.row() < 0 || index.row() >= m_list.count())
            return QVariant();
    const ClientCard *clientCard = m_list[index.row()];
    CardData cd;
    ClientCardModel* lst = 0;
    wchar_t formatBuffer[256];
    const wchar_t* showingtext;
    if(!clientCard)
        return 0;
    if(!dataManager.GetData(clientCard->code, &cd))
            memset(&cd, 0, sizeof(CardData));

    switch(clientCard->location) {
    case LOCATION_DECK:
        lst = &mainGame->dField.deck[clientCard->controler];
        break;
    case LOCATION_HAND:
        lst = &mainGame->dField.hand[clientCard->controler];
        break;
    case LOCATION_MZONE:
        lst = &mainGame->dField.mzone[clientCard->controler];
        break;
    case LOCATION_SZONE:
        lst = &mainGame->dField.szone[clientCard->controler];
        break;
    case LOCATION_GRAVE:
        lst = &mainGame->dField.grave[clientCard->controler];
        break;
    case LOCATION_REMOVED:
        lst = &mainGame->dField.remove[clientCard->controler];
        break;
    case LOCATION_EXTRA:
        lst = &mainGame->dField.extra[clientCard->controler];
        break;
    }

    switch (role) {
    case CodeRole:
        return clientCard->code;
        break;
    case AliasRole:
        return cd.alias;
        break;
    case BaseTypeRole:
        return cd.type;
        break;
    case BaseLevelRole:
        return cd.level;
        break;
    case BaseRankRole:
        return clientCard->rank;    //might need an update
        break;
    case BaseAttributeRole:
        return cd.attribute;
        break;
    case BaseRaceRole:
        return cd.race;
        break;
    case BaseAttackRole:
        return cd.attack;
        break;
    case BaseDefenceRole:
        return cd.defence;
        break;
    case BaseLscaleRole:
        return cd.lscale;
        break;
    case BaseRscaleRole:
        return cd.rscale;
        break;
    case NameRole:
        if(cd.alias != 0 && (cd.alias - clientCard->code < 10 || clientCard->code - cd.alias < 10))
            myswprintf(formatBuffer, L"%ls", dataManager.GetName(cd.alias));
        else
            myswprintf(formatBuffer, L"%ls", dataManager.GetName(clientCard->code));
        return QString::fromWCharArray(formatBuffer);
        break;
    case FormatTypeRole:
        myswprintf(formatBuffer, L"[%ls]", dataManager.FormatType(cd.type));
        return QString::fromWCharArray(formatBuffer);
        break;
    case TextRole:
        showingtext = dataManager.GetText(clientCard->code);
        return QString::fromWCharArray(showingtext);
        break;
    case TypeRole:
        return clientCard->type;
        break;
    case LevelRole:
        return clientCard->level;
        break;
    case RankRole:
        return clientCard->rank;
        break;
    case AttributeRole:
        return clientCard->attribute;
        break;
    case RaceRole:
        return clientCard->race;
        break;
    case AttackRole:
        return clientCard->attack;
        break;
    case DefenceRole:
        return clientCard->defence;
        break;
    case LscaleRole:
        return clientCard->lscale;
        break;
    case RscaleRole:
        return clientCard->rscale;
        break;
    case LocationRole:
        return clientCard->location;
        break;
    case PositionRole:
        return clientCard->position;
        break;
    case IsDisabledRole:
        return clientCard->is_disabled;
        break;
    case CmdFlagRole:
        return clientCard->cmdFlag;
        break;
    case EquipTargetController:
        return clientCard->equipTarget->controler;
        break;
    case EquipTargetLocation:
        return clientCard->equipTarget->location;
        break;
    case EquipTargetSequence:
        return clientCard->equipTarget->sequence;
        break;
    default:
        break;
    }
    return QVariant();
}

void ClientCardModel::dataChangedSignal() {
    QModelIndex top = createIndex(0, 0);
    QModelIndex bottom = createIndex(m_list.count() - 1, 0);
    emit dataChanged(top, bottom);
}

void ClientCardModel::dataChangedSignal(int sequence) {
    QModelIndex index = createIndex(sequence, 0);
    emit dataChanged(index, index);
}

QHash<int, QByteArray> ClientCardModel::roleNames() const{
    QHash<int, QByteArray> roles;
    roles[CodeRole] = "code";
    roles[AliasRole] = "alias";
    roles[BaseTypeRole] = "baseType";
    roles[BaseLevelRole] = "baseLevel";
    roles[BaseRankRole] = "baseRank";
    roles[BaseAttributeRole] = "baseAttribute";
    roles[BaseRaceRole] = "baseRace";
    roles[BaseAttackRole] = "baseAttack";
    roles[BaseDefenceRole] = "baseDefence";
    roles[BaseLscaleRole] = "baseLscale";
    roles[BaseRscaleRole] = "baseRscale";
    roles[NameRole] = "name";
    roles[FormatTypeRole] = "formatType";
    roles[TextRole] = "showingText";
    roles[TypeRole] = "type";
    roles[LevelRole] = "level";
    roles[RankRole] = "rank";
    roles[AttributeRole] = "attribute";
    roles[RaceRole] = "race";
    roles[AttackRole] = "attack";
    roles[DefenceRole] = "defence";
    roles[LscaleRole] = "lscale";
    roles[RscaleRole] = "rscale";
    roles[LocationRole] = "location";
    roles[PositionRole] = "position";
    roles[IsDisabledRole] = "isDisabled";
    roles[CmdFlagRole] = "cmdFlag";
    roles[EquipTargetController] = "equipTargetController";
    roles[EquipTargetLocation] = "equipTargetLocation";
    roles[EquipTargetSequence] = "equipTargetSequence";
    return roles;
}

QList<ClientCard*>::iterator ClientCardModel::begin() {
    if(m_list.size() >= 1)
        return m_list.begin();
    return 0;
}

QList<ClientCard*>::iterator ClientCardModel::end() {
    if(m_list.size() >= 1)
        return m_list.end();
    return 0;
}

void ClientCardModel::clear() {
    beginResetModel();
    m_list.clear();
    endResetModel();
}

void ClientCardModel::push_back(ClientCard *card) {
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_list << card;
    endInsertRows();
}

int ClientCardModel::size() const {
    return m_list.size();
}

QList<ClientCard*>::iterator ClientCardModel::erase(const myIter iter) {
    beginRemoveRows(QModelIndex(), iter - m_list.begin(), iter - m_list.begin());
    auto rtn = m_list.erase(iter);
    endRemoveRows();
    return rtn;
}

QList<ClientCard*>::iterator ClientCardModel::erase(const myIter begin,const myIter end) {
    beginRemoveRows(QModelIndex(), begin - m_list.begin(), end - m_list.begin());
    auto rtn = m_list.erase(begin, end);
    endRemoveRows();
    return rtn;
}

ClientCard* &ClientCardModel::last() {
    return m_list.last();
}

void ClientCardModel::swap(ClientCardModel &other) {
    beginResetModel();
    other.beginResetModel();
    m_list.swap(other.m_list);
    endResetModel();
    other.endResetModel();
}

ClientCard* &ClientCardModel::operator [](int i) {
    return m_list[i];
}

void ClientCardModel::copy(const ClientCardModel &model) {
    beginResetModel();
    m_list = model.m_list;
    endResetModel();
}

ClientCardModel::~ClientCardModel()
{

}

}
