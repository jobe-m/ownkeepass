#ifndef ABSTRACTDATABASEFACTORY_H
#define ABSTRACTDATABASEFACTORY_H

#include "AbstractDatabaseInterface.h"

// This abstract class is used to specify a factory method which creates a database instance.
// Due to separating the name spaces of each database implementation (Keepass 1 and Keepass 2)
// the actual instance of the specific database object is done in the contrete
// implementation of the different database factories.

// Interface for accessing a database
class AbstractDatabaseFactory
{
public:
    virtual ~AbstractDatabaseFactory(){}

    // factory method will be implemented in the subclass for each database type
    virtual AbstractDatabaseInterface* factoryMethod() = 0;
};

Q_DECLARE_INTERFACE(AbstractDatabaseFactory, "harbour.ownkeepass.AbstractDatabaseFactory")

#endif // ABSTRACTDATABASEFACTORY_H
