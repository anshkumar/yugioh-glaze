#ifndef SINGLEMODE_H
#define SINGLEMODE_H

#include <QObject>
#include <QString>
#include <QEventLoop>

namespace glaze {

//struct Buffer {
//    unsigned char buffer[0x1000];
//};

class SingleMode : public QObject
{
    Q_OBJECT
public:
    SingleMode();
    static void SetResponse(unsigned char* resp);
    static bool SinglePlayAnalyze(char* msg, unsigned int len);

    static int MessageHandler(long fduel, int type);
    static int enable_log;

    static bool is_closing;
    static bool is_continuing;
    static QString name;
protected:
    static long pduel;
    static wchar_t event_string[256];

private:


public slots:
    void singlePlayStart();
signals:
    void finished();
};
}

//Q_DECLARE_METATYPE(glaze::Buffer)

#endif // SINGLEMODE_H
