﻿#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSharedPointer>
#include <QTranslator>

#include "ProjectManager.h"
#include "SettingsManager.h"
//#include "ProjectManager2.h"
#include "ActionsManager.h"
#include "AudioTrackRepresentation.h"
#include "WaveformWidget.h"
#include "CursorManager.h"

int main(int argc, char** argv)
{
    QApplication app(argc, argv);
    app.setOrganizationName("MFX");
    app.setOrganizationDomain("mfx.com");

    SettingsManager settings;
    ProjectManager project(settings);
    ActionsManager actionsManager(settings);
    actionsManager.loadActions();
    CursorManager cursorManager;

    QTranslator translator;
    translator.load("qrc:/translations/russian.qm");
    qApp->installTranslator(&translator);

    qmlRegisterType<WaveformWidget>("WaveformWidget", 1, 0, "WaveformWidget");

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("settingsManager", &settings);
    engine.rootContext()->setContextProperty("project", &project);
    engine.rootContext()->setContextProperty("actionsManager", &actionsManager);
    engine.rootContext()->setContextProperty("cursorManager", &cursorManager);
    engine.rootContext()->setContextProperty("applicationDirPath", QGuiApplication::applicationDirPath());
    engine.load(QUrl(QStringLiteral("qrc:/MFX/main.qml")));
    return app.exec();
}
