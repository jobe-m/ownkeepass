
#include "Keepass2DatabaseFactory.h"
#include "Keepass2DatabaseInterface.h"

Keepass2DatabaseFactory::Keepass2DatabaseFactory(QObject *parent) :
    QObject(parent), AbstractDatabaseFactory()
{

}

Keepass2DatabaseFactory::~Keepass2DatabaseFactory()
{

}

AbstractDatabaseInterface* Keepass2DatabaseFactory::factoryMethod()
{
    // Yes, this factory has the only meaning to return a specific database object.
    // But doing so the name space of the database implementation is hidden from the database client.
    // This is needed to prevent name space collisions from 3rd party code.
    return new kpxPrivate::Keepass2DatabaseInterface();
}
