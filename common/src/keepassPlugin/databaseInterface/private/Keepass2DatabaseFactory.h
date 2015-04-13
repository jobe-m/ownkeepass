#ifndef KEEPASS2DATABASEFACTORY_H
#define KEEPASS2DATABASEFACTORY_H

#include <QObject>
#include "AbstractDatabaseFactory.h"

class Keepass2DatabaseFactory : public QObject, public AbstractDatabaseFactory
{
    Q_OBJECT
    Q_INTERFACES(AbstractDatabaseFactory)

public:
    explicit Keepass2DatabaseFactory(QObject *parent = 0);
    virtual ~Keepass2DatabaseFactory();

    // factory method will be implemented in the subclass for each database type
    AbstractDatabaseInterface* factoryMethod();

signals:

public slots:

};

#endif // KEEPASS2DATABASEFACTORY_H
