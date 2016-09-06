#ifndef CLIENTCARDMODEL_H
#define CLIENTCARDMODEL_H

#include <QAbstractListModel>
#include <QSet>
#include "clientcard.h"

namespace glaze {

typedef QList<ClientCard*>::iterator myIter;

class ClientCardModel : public QAbstractListModel
{
    Q_OBJECT
public:
    ClientCardModel(QObject* parent = 0);

    enum CardRoles {
        CodeRole = Qt::UserRole + 1,    /*Qt::UserRole = 0x0100*/
        AliasRole,
        BaseTypeRole,
        BaseLevelRole,
        BaseRankRole,
        BaseAttributeRole,
        BaseRaceRole,
        BaseAttackRole,
        BaseDefenceRole,
        BaseLscaleRole,
        BaseRscaleRole,
        NameRole,
        FormatTypeRole,
        TextRole,
        TypeRole,
        LevelRole,
        RankRole,
        AttributeRole,
        RaceRole,
        AttackRole,
        DefenceRole,
        LscaleRole,
        RscaleRole,
        ControlerRole,
        LocationRole,
        PositionRole,
        IsDisabledRole,
        CmdFlagRole,
        OverlayedSizeRole,
        EquipTargetController,
        EquipTargetLocation,
        EquipTargetSequence,
        IsSelectableRole,
        IsSelectedRole,
        SelectSeqRole,
        OpParamRole,
        cardRole
    };

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    Qt::ItemFlags flags(const QModelIndex &index) const;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole);
    QList<ClientCard*>::iterator begin();
    QList<ClientCard*>::iterator end();
    QList<ClientCard*>::const_iterator find(ClientCard *value);
//    void insert(ClientCard *card);
    ClientCard* &last();
    ClientCard* &operator[](int i);

    QList<glaze::ClientCard*>::iterator erase(const myIter);
    QList<glaze::ClientCard*>::iterator erase(const myIter begin, const myIter end);
    void swap(ClientCardModel&);
    void copy(const ClientCardModel &model);
    void dataChangedSignal();
    void dataChangedSignal(int sequence,const QVector<int> &roles = QVector<int> ());

public slots:
    ClientCard* at(int i);
    int size() const;   // to access from QML javascript
    QVariant getData(int index, int role);  // to access from QML javascript
    void push_back(ClientCard* card);
    void clear();

signals:
    //    void pushBackFinished();

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<ClientCard*> m_list;
};
}
Q_DECLARE_METATYPE(glaze::ClientCardModel*)

#endif // CLIENTCARDMODEL_H
