TEMPLATE = app

CONFIG += c++11 debug

QT += qml quick widgets core

SOURCES += main.cpp \
    singlemode.cpp \
    datamanager.cpp \
    clientcard.cpp \
    clientfield.cpp \
    game.cpp \
    duelclient.cpp \
    clientcardmodel.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

OTHER_FILES +=

HEADERS += \
    singlemode.h \
    datamanager.h \
    clientcard.h \
    bufferio.h \
    clientfield.h \
    game.h \
    duelclient.h \
    ocgcore/card.h \
    ocgcore/common.h \
    ocgcore/duel.h \
    ocgcore/effect.h \
    ocgcore/effectset.h \
    ocgcore/field.h \
    ocgcore/group.h \
    ocgcore/interpreter.h \
    ocgcore/mtrandom.h \
    ocgcore/ocgapi.h \
    ocgcore/scriptlib.h \
    signalWaiter.h \
    clientcardmodel.h


win32:CONFIG(release, debug|release): LIBS += -L$$PWD/release/ -locgcore
else:win32:CONFIG(debug, debug|release): LIBS += -L$$PWD/debug/ -locgcore
else:unix: LIBS += -L$$PWD/ -locgcore

INCLUDEPATH += $$PWD/ocgcore
DEPENDPATH += $$PWD/ocgcore

win32-g++:CONFIG(release, debug|release): PRE_TARGETDEPS += $$PWD/release/libocgcore.a
else:win32-g++:CONFIG(debug, debug|release): PRE_TARGETDEPS += $$PWD/debug/libocgcore.a
else:win32:!win32-g++:CONFIG(release, debug|release): PRE_TARGETDEPS += $$PWD/release/ocgcore.lib
else:win32:!win32-g++:CONFIG(debug, debug|release): PRE_TARGETDEPS += $$PWD/debug/ocgcore.lib
else:unix: PRE_TARGETDEPS += $$PWD/libocgcore.a

unix|win32: LIBS += -lsqlite3

unix|win32: LIBS += -llua

#needed in Ubuntu 14.04
unix|win32: LIBS += -ldl
