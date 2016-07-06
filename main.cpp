#include <VPApplication>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickView>
#include <QQmlEngine>   // for connect()
#include <QCoreApplication> // for connect()
#include <QtQml>    // for qmlRegisterType<>()
#include "game.h"
#include "clientcard.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    VPApplication vplay;

    QQmlApplicationEngine engine;
    vplay.initialize(&engine);

//    QQuickView view;
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
    engine.rootContext()->setContextProperty("clientField",&glaze::mainGame->dField);
    engine.rootContext()->setContextProperty("game",glaze::mainGame);
    engine.rootContext()->setContextProperty("duelInfo",&glaze::mainGame->dInfo);

    vplay.setMainQmlFileName(QStringLiteral("qml/main.qml"));
    engine.load(QUrl(vplay.mainQmlFileName()));
//    view.setSource(QUrl("qrc:/main.qml"));
//    view.show();
//    view.showFullScreen();
//    QObject::connect(engine, SIGNAL(quit()), QApplication::instance(), SLOT(quit()));
    return app.exec();
}
