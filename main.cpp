#include <QGuiApplication>
#include <QQuickView>
#include <QQmlEngine>   // for connect()
#include <QCoreApplication> // for connect()
#include <QtQml>    // for qmlRegisterType<>()
#include "game.h"
#include "clientcard.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickView view;
    qDebug()<<"From main thread: "<<QThread::currentThreadId();
    qRegisterMetaType<glaze::ClientCard*>("ClientCard*");
	qRegisterMetaType<glaze::ClientCard**>("ClientCard**");
    qRegisterMetaType<glaze::ClientCardModel*>("ClientCardModel*");
//    qRegisterMetaType<glaze::Buffer>("Buffer");
    glaze::Game _game;
    glaze::mainGame = &_game;
    if(!glaze::mainGame->Initialize())
        return 0;

    // context property should come before you set qml source
    view.rootContext()->setContextProperty("clientField",&glaze::mainGame->dField);
    view.rootContext()->setContextProperty("game",glaze::mainGame);
    view.rootContext()->setContextProperty("duelInfo",&glaze::mainGame->dInfo);

    view.setSource(QUrl("qrc:/main.qml"));
    view.show();
    //view.showFullScreen();
    QObject::connect(view.engine(), SIGNAL(quit()), QGuiApplication::instance(), SLOT(quit()));
    return app.exec();
}
