#ifndef CLIENTCARDMODEL_H
#define CLIENTCARDMODEL_H

#include <QAbstractListModel>
#include "clientcard.h"

namespace glaze {

typedef QList<ClientCard*>::iterator myIter;

class ClientCardModel : public QAbstractListModel
{
    Q_OBJECT
public:
    ClientCardModel(QObject* parent = 0);

    enum CardRoles {
        CodeRole = Qt::UserRole + 1,
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
        LocationRole,
        PositionRole,
        IsDisabledRole,
        CmdFlagRole
    };

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    QList<ClientCard*>::iterator begin();
    QList<ClientCard*>::iterator end();
    int size() const;
    ClientCard* &last();
    ClientCard* &operator[](int i);
    ~ClientCardModel();

    Q_INVOKABLE void dataChangedSignal();
    Q_INVOKABLE void dataChangedSignal(int sequence);
    Q_INVOKABLE void push_back(ClientCard* card);
    Q_INVOKABLE void clear();
    QList<glaze::ClientCard*>::iterator erase(const myIter);
    QList<glaze::ClientCard*>::iterator erase(const myIter begin, const myIter end);
    void swap(ClientCardModel&);
    void copy(const ClientCardModel &model);

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    QList<ClientCard*> m_list;
};
}

Q_DECLARE_METATYPE(glaze::ClientCardModel*)

#endif // CLIENTCARDMODEL_H
