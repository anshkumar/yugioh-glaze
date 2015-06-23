#ifndef SINGLEMODE_H
#define SINGLEMODE_H

#include <QObject>
#include <QString>

namespace glaze {

struct Buffer {
    unsigned char buffer[0x1000];
};

class SingleMode : public QObject
{
    Q_OBJECT
public:
    SingleMode();
    static void SetResponse(unsigned char* resp);
    static bool SinglePlayAnalyze(char* msg, unsigned int len);

    static void SinglePlayRefresh(int flag = 0x781fff);
    static void SinglePlayRefreshHand(int player, int flag = 0x781fff);
    static void SinglePlayRefreshGrave(int player, int flag = 0x181fff);
    static void SinglePlayRefreshDeck(int player, int flag = 0x181fff);
    static void SinglePlayRefreshExtra(int player, int flag = 0x181fff);
    static void SinglePlayRefreshSingle(int player, int location, int sequence, int flag = 0x781fff);
    static void SinglePlayReload();

    static int MessageHandler(long fduel, int type);
    static int enable_log;

    static bool is_closing;
    static bool is_continuing;
    static QString name;
private:
    static long pduel;
    static wchar_t event_string[256];

public slots:
    void singlePlayStart();
signals:
    void finished();
};
}

Q_DECLARE_METATYPE(glaze::Buffer)

#endif // SINGLEMODE_H
