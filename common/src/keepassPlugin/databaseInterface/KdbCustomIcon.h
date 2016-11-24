#ifndef KDBCUSTOMICON_H
#define KDBCUSTOMICON_H

#include <QQuickImageProvider>
#include <QImage>

class KdbCustomIcon : public QQuickImageProvider
{
public:
    KdbCustomIcon()
        : QQuickImageProvider(QQuickImageProvider::Image)
    {}

    QImage requestImage(const QString &uuid, QSize *size, const QSize &requestedSize);
};

#endif // KDBCUSTOMICON_H
