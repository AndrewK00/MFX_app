﻿#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSharedPointer>
#include <QTranslator>
#include <QQuickStyle>
#include <QtGui/QFontDatabase>

#include "ProjectManager.h"
#include "SettingsManager.h"
#include "AudioTrackRepresentation.h"
#include "WaveformWidget.h"
#include "CursorManager.h"
#include "CueManager.h"
#include "CueSortingModel.h"
#include "DeviceManager.h"
#include "DmxWorker.h"
#include "PatternManager.h"
#include "PatternFilteringModel.h"
#include "TranslationManager.h"
#include "CueContentManager.h"
#include "CueContentSortingModel.h"

int main(int argc, char** argv)
{
    QApplication app(argc, argv);
    app.setOrganizationName("MFX");
    app.setOrganizationDomain("mfx.com");

    const QDir robotoFontDir(":/fonts/Roboto/");
    const auto robotoFontFiles = robotoFontDir.entryList(QStringList{"*.ttf"}, QDir::NoDotAndDotDot | QDir::Files);
    for(const auto & robotoFontFile : robotoFontFiles) {
        QFontDatabase::addApplicationFont(robotoFontDir.path() + QDir::separator() + robotoFontFile);
    }

    SettingsManager settings;
    TranslationManager translationManager(settings);
    ProjectManager project(settings);
    PatternManager patternManager(settings);
    patternManager.initPatterns();
    DeviceManager deviceManager;
    deviceManager.m_patternManager = &patternManager;
    CursorManager cursorManager;
    CueContentManager cueContentManager(deviceManager);
    CueManager cueManager(cueContentManager);
    cueManager.m_deviceManager = &deviceManager;
    cueContentManager.m_cueManager = &cueManager;

    QObject::connect(&cueManager, &CueManager::runPattern, &deviceManager, &DeviceManager::onRunPattern);
    QString comPort = settings.value("comPort").toString();
    if(!comPort.isEmpty()) {
        deviceManager.setComPort(comPort);
    }

    qmlRegisterType<WaveformWidget>("WaveformWidget", 1, 0, "WaveformWidget");

    CueSortingModel::qmlRegister();
    PatternManager::qmlRegister();
    PatternFilteringModel::qmlRegister();
    CueContentManager::qmlRegister();
    CueContentSortingModel::qmlRegister();

    QQmlApplicationEngine engine;

    engine.addImportPath("qrc:/");

    engine.rootContext()->setContextProperty("settingsManager", &settings);
    engine.rootContext()->setContextProperty("translationsManager", &translationManager);
    engine.rootContext()->setContextProperty("project", &project);
    engine.rootContext()->setContextProperty("patternManager", &patternManager);
    engine.rootContext()->setContextProperty("cursorManager", &cursorManager);
    engine.rootContext()->setContextProperty("applicationDirPath", QGuiApplication::applicationDirPath());
    engine.rootContext()->setContextProperty("cueManager", &cueManager);
    engine.rootContext()->setContextProperty("deviceManager", &deviceManager);
    engine.rootContext()->setContextProperty("comPortModel", &deviceManager.m_comPortModel);
    engine.rootContext()->setContextProperty("dmxWorker", DMXWorker::instance());
    engine.rootContext()->setContextProperty("cueContentManager", &cueContentManager);

    engine.load(QUrl(QStringLiteral("qrc:/MFX/UI/ApplicationWindow.qml")));

    return app.exec();
}
