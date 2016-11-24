
#include "KdbCustomIcon.h"
#include "private/DatabaseClient.h"
#include "private/AbstractDatabaseInterface.h"

KdbCustomIcon::requestImage(const QString &uuid, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(requestedSize);

    QImage customIcon = kpxPrivate::DatabaseClient::getInstance()->getInterface()->getCustomIcon(uuid);
    if (size) {
        *size = QSize(customIcon.width(), customIcon.height());
    }
    return customIcon;
}
