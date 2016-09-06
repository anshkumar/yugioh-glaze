#include "clientcardmodel.h"
#include "datamanager.h"
#include "card.h"
#include "game.h"
#include <QThread>
#include <QDebug>
#include <QtAlgorithms>

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
    const wchar_t* showingtext;
    if(!clientCard)
        return 0;
    if(!dataManager.GetData(clientCard->code, &cd))
        memset(&cd, 0, sizeof(CardData));

    QString formatBuffer;
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
            formatBuffer = QString::fromWCharArray(dataManager.GetName(cd.alias));
        else
            formatBuffer = QString::fromWCharArray(dataManager.GetName(clientCard->code));
        return formatBuffer;
        break;
    case FormatTypeRole:
        formatBuffer = QString::fromWCharArray(dataManager.FormatType(cd.type));
        formatBuffer = "[" + formatBuffer + "]";
        return formatBuffer;
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
    case ControlerRole:
        return clientCard->controler;
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
    case OverlayedSizeRole:
        return clientCard->overlayed.size();
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
    case IsSelectableRole:
        return clientCard->is_selectable;
        break;
    case IsSelectedRole:
        return clientCard->is_selected;
        break;
    case SelectSeqRole:
        return clientCard->select_seq;
        break;
    case OpParamRole:
        return clientCard->opParam;
        break;
    case cardRole:
        return clientCard;
        break;
    default:
        break;
    }
    return QVariant();
}

Qt::ItemFlags ClientCardModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::ItemIsEnabled;

    return QAbstractItemModel::flags(index) | Qt::ItemIsEditable;
}

bool ClientCardModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (index.isValid()) {
        ClientCard *clientCard = m_list[index.row()];
        if(!clientCard)
            return 0;
        switch (role) {
        case IsSelectableRole:
            clientCard->is_selectable = value.toBool();
//            qDebug()<<"ClientCard->is_selectable set to = "<<value.toBool();
            emit dataChangedSignal(index.row(), QVector<int>(1,role));
            break;
        case IsSelectedRole:
            clientCard->is_selected = value.toBool();
//            qDebug()<<"ClientCard->is_selected set to = "<<value.toBool();
            emit dataChangedSignal(index.row(), QVector<int>(1,role));
            break;
        case OpParamRole:
            clientCard->opParam = value.toUInt();
//            qDebug()<<"ClientCard->opParam set to = "<<value.toUInt();
            emit dataChangedSignal(index.row(), QVector<int>(1,role));
            break;
        default:
            break;
        }
        return true;
    }
    return false;
}


void ClientCardModel::dataChangedSignal() {
    QModelIndex top = createIndex(0, 0);
    QModelIndex bottom = createIndex(m_list.count() - 1, 0);
    emit dataChanged(top, bottom);
}

void ClientCardModel::dataChangedSignal(int sequence, const QVector<int> &roles) {
    QModelIndex index = createIndex(sequence, 0);
    emit dataChanged(index, index, roles);
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
    roles[ControlerRole] = "controler";
    roles[LocationRole] = "location";
    roles[PositionRole] = "position";
    roles[IsDisabledRole] = "isDisabled";
    roles[CmdFlagRole] = "cmdFlag";
    roles[OverlayedSizeRole] = "overlayedSize";
    roles[EquipTargetController] = "equipTargetController";
    roles[EquipTargetLocation] = "equipTargetLocation";
    roles[EquipTargetSequence] = "equipTargetSequence";
    roles[IsSelectableRole] = "isSelectable";
    roles[IsSelectedRole] = "isSelected";
    roles[SelectSeqRole] = "selectSeq";
    roles[OpParamRole] = "opParam";
    roles[cardRole] = "card";
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

QList<ClientCard*>::const_iterator ClientCardModel::find(ClientCard *value) {
    return qFind(m_list,value);
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
    //    emit pushBackFinished();
}

int ClientCardModel::size() const {
    return m_list.size();
}

QVariant ClientCardModel::getData(int index, int role) {
    if (index < 0 || index >= m_list.count())
        return QVariant();
    const ClientCard *clientCard = m_list[index];
    if(!clientCard)
        return 0;
    switch (role) {
    case CodeRole:
        return clientCard->code;
        break;
    case IsSelectableRole:
        return clientCard->is_selectable;
        break;
    case IsSelectedRole:
        return clientCard->is_selected;
        break;
    case SelectSeqRole:
        return clientCard->select_seq;
        break;
    case OpParamRole:
        return clientCard->opParam;
        break;
    default:
        break;
    }
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

ClientCard* ClientCardModel::at(int i) {
    return m_list[i];
}

void ClientCardModel::copy(const ClientCardModel &model) {
    beginResetModel();
    m_list = model.m_list;
    endResetModel();
}

}
