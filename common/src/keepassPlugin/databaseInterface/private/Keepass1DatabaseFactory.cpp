
#include "Keepass1DatabaseFactory.h"
#include "Keepass1DatabaseInterface.h"

Keepass1DatabaseFactory::Keepass1DatabaseFactory(QObject *parent) :
    QObject(parent), AbstractDatabaseFactory()
{}

Keepass1DatabaseFactory::~Keepass1DatabaseFactory()
{}

AbstractDatabaseInterface* Keepass1DatabaseFactory::factoryMethod()
{
    // Yes, this factory has the only meaning to return a specific database object.
    // But doing so the name space of the database implementation is hidden from the DatabaseClient.
    // This is needed to prevent name space collisions from 3rd party code.
    return new kpxPrivate::Keepass1DatabaseInterface();
}
