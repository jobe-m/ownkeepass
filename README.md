ownKeepass
==========

What is this?
-------------

ownKeepass is a password safe application for the Sailfish platform. You can use it to store your passwords for webpages, PINs, TANs and any other data that should be kept secret on your Jolla Smartphone. The database where that data is stored is encrypted using a master password. ownKeepass can read and write Keepass database files version 1. The database code is actually taken from [KeepassX project][1]. The code base of KeepassX v0.4.3 is quite stable and well tested by a lot of people. But because its developer is not working any more actively on that code I decided to put it in a new repository and write a QML wrapper around the Keepass database interface class. The QWidget code was thrown away and the UI part is now based on QML.
However please note that the application is not yet ready to be used on Sailfish. The sources are currently work in progress.

Why?
----

I started to work on ownKeepass beginning of 2012 when QML started to get usable from development point of view for the Nokia N9. Writing a QML UI for the stable KeepassX 0.4.3 version was just born out of the idea to take my favourite password safe application to new Qt platforms like the Nokia N9. Although ownKeepass was quite usable for me on my Nokia N9 I never released it for the Nokia N9 due to lack of time and motivation (Nokia's desperate situation) to make the application usable for a wider audience. But later I decided to continue development on the new Sailfish OS platform from the finnish Smartphone start-up company Jolla which is featuring Qt5 and QtQuick2.

Some technical notes
--------------------

If you want to dig deeper into the code here are some hints to help you getting an overview of the code. The interface for the Keepass database code is split into four classes which are exposed as objects to the QML world:

*   KdbDatabase:
    That object enables the QML side to open an existing Keepass database, create a new empty database and close a database.
*   KdbListModel:
    That object is used to get a list of Keepass groups and entries for a dedicated Keepass group or the root group from the Keepass database. It also provides the possibility to search for a specific group and entry in the database.
*   KdbGroup:
    This object provides the posibility to create a new group or change the name for an existing group in the database.
*   KdbEntry:
    With the use of that object the QML code can read all properties from a Keepass entry like webpage, username, password, comment, etc. Through this object it is also possible to create new entries and save them in the Keepass database.

Features (already working)
--------------------------

*   Load and save kdb database file
*

TODO
----

*   Port Keepass backend from Qt4 (N9 version) to Qt5 [Done]
*   Adapt old N9 QML source code to use [Sailfish Silica components][2] and make the application working on the Sailfish emulator.
*   Post some screenshots :D

That's it for now. I will update things here when I have some news to share :)

Marko Koschak

[1] http://www.keepassx.org                                           "KeepassX project homepage"
[2] https://sailfishos.org/sailfish-silica/sailfish-silica-all.html   "QtQuick Components for Sailfish"
