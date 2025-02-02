#ifndef COMPORTMODEL_H
#define COMPORTMODEL_H

#include <QStringList>
#include <QStringListModel>

class ComPortModel : public QStringListModel
{
    Q_OBJECT
public:
    explicit ComPortModel(QObject *parent = nullptr);
    Q_INVOKABLE void reload();
    Q_INVOKABLE int getModelIndexByPortName(QString portName);
signals:
    void dataReady();
};

#endif // COMPORTMODEL_H
