#include <stdio.h>
#include <QtCore/QCoreApplication>
#include <QtCore/QTextStream>

#include "database/Kdb3Database.h"
#include "crypto/yarrow.h"

using namespace std;

KpxConfig *config;
QString  AppDir;
QString HomeDir;
QString DataDir;
//QString PluginLoadError;
//QString DetailViewTemplate;
//bool EventOccurred;
//bool EventOccurredBlock = false;

QPixmap* EntryIcons;
IIconTheme* IconLoader=NULL;

int main(int argc, char *argv[])
{
    qDebug("start");
    QCoreApplication app(argc, argv);

    if (app.arguments().size() != 3) {
        qCritical("Usage: TestConApp <password> <kdb file>");
        return 1;
    }

    QFile dbFile(app.arguments().at(2));
    if (!dbFile.exists()) {
        qCritical("File does not exist.");
        return 1;
    }

    qDebug("init Yarrow");
    initYarrow();
    qDebug("generate session key");
    SecString::generateSessionKey();

    // init config
    config = new KpxConfig("keepassx-config.ini");
    Kdb3Database *db = new Kdb3Database();

    qDebug("set key");
//    bool result = db->setPasswordKey("bmirtbtik");
    bool result = db->setKey(app.arguments().at(1), "");
    qDebug("password set...");

//    db->load("notes.kdb", false);
    db->load(app.arguments().at(2), false);
    qDebug("Db loaded... result: %s", CSTR(db->getError()));

    for (int i = 0; i < db->groups().count(); i++) {
        qDebug("Group %d: %s", i, CSTR(db->groups().at(i)->title()));
    }

    qDebug("Choose group:");
    QTextStream stream(stdin);
    QString line;
    line = stream.readLine();
    for (int i = 0; i < db->entries(db->groups().at(line.toInt())).count(); i++) {
        qDebug("Entry %d: %s", i, CSTR(db->entries(db->groups().at(line.toInt())).at(i)->title()));
    }

    delete db;
    SecString::deleteSessionKey();
    return 0; //app.exec();
}
