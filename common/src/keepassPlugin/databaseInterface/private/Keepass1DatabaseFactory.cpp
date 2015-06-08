
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
    return new kpxPrivate::Keepass1DatabaseInterface();
}
