
#ifndef KEEPASS1DATABASEFACTORY_H
#define KEEPASS1DATABASEFACTORY_H

#include <QObject>
#include "AbstractDatabaseFactory.h"

class Keepass1DatabaseFactory : public QObject, public AbstractDatabaseFactory
{
    Q_OBJECT
    Q_INTERFACES(AbstractDatabaseFactory)

public:
    explicit Keepass1DatabaseFactory(QObject *parent = 0);
    virtual ~Keepass1DatabaseFactory();

    // factory method will be implemented in the subclass for each database type
    AbstractDatabaseInterface* factoryMethod();

signals:

public slots:

};

#endif // KEEPASS1DATABASEFACTORY_H
