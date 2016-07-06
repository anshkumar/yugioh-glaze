CONFIG += v-play c++11

qmlFolder.source = qml
DEPLOYMENTFOLDERS += qmlFolder # comment for publishing

assetsFolder.source = assets
DEPLOYMENTFOLDERS += assetsFolder

# Add more folders to ship with the application here

RESOURCES += #    resources.qrc # uncomment for publishing

# NOTE: for PUBLISHING, perform the following steps:
# 1. comment the DEPLOYMENTFOLDERS += qmlFolder line above, to avoid shipping your qml files with the application (instead they get compiled to the app binary)
# 2. uncomment the resources.qrc file inclusion and add any qml subfolders to the .qrc file; this compiles your qml files and js files to the app binary and protects your source code
# 3. change the setMainQmlFile() call in main.cpp to the one starting with "qrc:/" - this loads the qml files from the resources
# for more details see the "Deployment Guides" in the V-Play Documentation

# during development, use the qmlFolder deployment because you then get shorter compilation times (the qml files do not need to be compiled to the binary but are just copied)
# also, for quickest deployment on Desktop disable the "Shadow Build" option in Projects/Builds - you can then select "Run Without Deployment" from the Build menu in Qt Creator if you only changed QML files; this speeds up application start, because your app is not copied & re-compiled but just re-interpreted


SOURCES += main.cpp \
    singlemode.cpp \
    datamanager.cpp \
    clientcard.cpp \
    clientfield.cpp \
    game.cpp \
    duelclient.cpp \
    clientcardmodel.cpp

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

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

unix: LIBS += -lsqlite3

unix: LIBS += -llua5.2

#needed in unix
unix: LIBS += -ldl

win32:CONFIG(release, debug|release): LIBS += -L$$PWD/sqlite3/ -lsqlite3
else:win32:CONFIG(debug, debug|release): LIBS += -L$$PWD/sqlite3/ -lsqlite3d
else:macx: LIBS += -L$$PWD/sqlite3/ -lsqlite3

INCLUDEPATH += $$PWD/sqlite3
DEPENDPATH += $$PWD/sqlite3

win32:CONFIG(release, debug|release): LIBS += -L$$PWD/lua/lib/ -llua
else:win32:CONFIG(debug, debug|release): LIBS += -L$$PWD/lua/lib/ -lluad
else:macx: LIBS += -L$$PWD/lua/lib/ -llua

INCLUDEPATH += $$PWD/lua
DEPENDPATH += $$PWD/lua

android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    OTHER_FILES += android/AndroidManifest.xml
}

ios {
    QMAKE_INFO_PLIST = ios/Project-Info.plist
    OTHER_FILES += $$QMAKE_INFO_PLIST
}

# set application icons for win and macx
win32 {
    RC_FILE += win/app_icon.rc
}
macx {
    ICON = macx/app_icon.icns
}
