ownKeepass
==========

[Bug reports go here] [7] - [Translations here] [8]

Status
------

Beta Release 1.0.29 available from [openrepos.net] [1] and warehouse app
*   Added new translations for Chinese, Danish, French, Italian and Russian
*   Added fast unlock feature which allows quick access to a locked database
*   Amount of retries on fast unlock page adjustable in settings from 0 to 5 tries
*   File browser implemented for opening and creating Keepass database, finally ;)
*   Please test both new features. I will do a bit of polishing and bug fixing and wait for some translations to be ready before releasing to Jolla store

Release 1.0.24 available in Jolla store
*   Translation updates and Spanish as new translation

Current limitations/known bugs:
*   Fast unlock code not updated after changing database master password in database settings
*   KeepassX 2 databases (.kdbx) are not yet supported


Roadmap
-------

List of planned features for ownKeepass to happen somewhere the next time. Priority
in descending order.

*   Keepass 2 database support. Planning to reuse database code from [KeepassX 2][3] project.
*   Integrating WebDav support for loading and saving your Keepass database to a server like ownCloud.
*   Activate password expiration feature which can remind you to change a specific password.

I am searching for contributors who want and can work on specific additional features:
*   Delete a Keepass database -> [REQ](https://github.com/jobe-m/ownkeepass/issues/64)
*   Import and export functionality -> [REQ](https://github.com/jobe-m/ownkeepass/issues/44)
*   Change sorting of password groups and entries in database -> [REQ](https://github.com/jobe-m/ownkeepass/issues/82)

The status of my todo list for the next release can be looked up [here] [6].

What is this?
-------------

ownKeepass is a password safe application for the Jolla Smartphone with the purpose to
protect sensible data like passwords for web pages, credit card numbers,
PINs, TANs and other bits of information which should be kept secret. All that information
is saved in a database file which is encrypted and stored locally on your phone. To open
the database you need to know the master password of the database. The used database
format is compatible to Keepass version 1. That means you can use [Keepass classic 1.27+] [2] or [KeepassX 0.4.3] [3] on your desktop
system to decrypt and open that database file, too.

Please note that currently ownKeepass cannot load or save Keepass version 2 databases. This is
planned for a future release of ownKeepass.

Why?
----

I started to work on this project beginning of 2012 when QML started to get usable from development point
of view for the Nokia N9. Writing a QML UI for the stable KeepassX 0.4.3 version was just born out of the
idea to take my favourite Password Safe application to new Qt platforms like the Nokia N9. Although
ownKeepass was quite usable for me on my Nokia N9 I never released it for the Nokia N9 due to lack of
time and motivation (Nokia's Qt strategy disruption) to make the application usable for a wider audience.
Mid of 2013 I decided to continue development on the new Sailfish OS platform from the finnish Smartphone
start-up Jolla. This platform offers Qt5 with QtQuick2 and Wayland which really marks the edge of UI
development. This is so much of technical motivation to me to do some great UI stuff with ownKeepass :)

Some words about Keepass database security
------------------------------------------

The database code in ownKeepass is based on the [KeepassX project] [3] and as such contains a lot of
security related features. It uses proven encryption algorithms like Advanced Encryption Standard
(AES / Rijndael) or Twofish with 128 bits block size and 256 bits key size, SHA-256 as hashing
algorithm and in-memory encryption of all passwords. Furthermore it protects the master
password against Brute-Force and Dictonary Attacks by hashing and encrypting it before
using it to decrypt the Keepass database. This feature is called key transformation rounds and can be
adjusted in database settings. Anyway that all just adds additional security to two points which
you should be aware of:

*   Always use a long enough and difficult to guess master password.
*   Protect your system from spyware which might be specialized to attack ownKeepass.

The second is law #1 of the [10 Immutable Laws of Security] [4]: "If a bad guy can persuade you to run
his program on your computer, it's not your computer anymore".

Sharing Keepass database between your jolla phone and your desktop PC
---------------------------------------------------------------------

The Keepass database file format is perfect to share your password safe between different
systems like phones, tablets, desktop PC and so on. That is because there are a lot of Keepass
implementations available for those platforms. Have a look at the [Keepass download page] [5] to get the classic Keepass 1
version for the desktop PC. There is also a list of alternative Keepass implementations on that page.
I would also like to point you to [KeepassX version 0.4.3] [3] which is also
compatible with Keepass version 1.
You can share your Keepass database file via SD card or via a cloud service like Dropbox.
When using a cloud server I would recommend to use a key file in addition to the master password.
The additional key file will be used by ownKeepass to decrypt the database. Store this key file
only locally on your phone and on your desktop PC. Do not upload it to the cloud service. If an attacker
hacks your cloud service he will be left without the key file. By doing so you make it even
harder for an attacker to crack your Keepass database because the key file content is usually
impossible to guess.

Some technical notes for QML hackers
------------------------------------

If you want to dig deeper into the code here are some hints to help you getting an overview of the code. The interface for
the Keepass database code is split into four classes which are exposed as objects to the QML world:

*   KdbDatabase:
    That object enables the QML side to open an existing Keepass database, create a new empty
    database and close a database.
*   KdbListModel:
    That object is used to get a list of Keepass groups and entries for a dedicated Keepass
    group or the root group from the Keepass database. It also provides the possibility to search
    for a specific group and entry in the database.
*   KdbGroup:
    This object provides the posibility to create a new group or change the name for an existing
    group in the database.
*   KdbEntry:
    With the use of that object the QML code can read all properties from a Keepass entry like
    webpage, username, password, comment, etc. Through this object it is also possible to create
    new entries and save them in the Keepass database.

Features
--------

*   Load and save (automatically in background) kdb database file
*   Create, modify and delete Keepass groups and entries
*   Create new and open existing keepass files from Phone's Home folder, SD Card or Android Storage
*   Database settings adjustable like master password, encryption algorithm and key transformation rounds
*   Search keepass entries in whole database
*   Copy username and password from within cover page and use cover page to peak from other apps to
    look up username and password
*   Clear clipboard after 10 seconds and a lot of more

That's it so far.

11-Mar-2015

Copyright 2014 - 2015 Marko Koschak. Licensed under GPLv2. See LICENSE for more info.

[1]: https://openrepos.net/content/jobe/ownkeepass                     "Beta and testing releases"
[2]: http://www.keepass.info/help/v1/setup.html                        "Official Keepass homepage for version 1"
[3]: http://www.keepassx.org                                           "KeepassX project homepage"
[4]: http://technet.microsoft.com/en-us/library/cc722487.aspx          "10 Immutable Laws of Security"
[5]: http://www.keepass.info/download.html                             "Download classic Keepass"
[6]: https://github.com/jobe-m/ownkeepass/milestones                   "Status of next major ownKeepass releases"
[7]: https://github.com/jobe-m/ownkeepass/issues
[8]: https://www.transifex.com/projects/p/jobe_m-ownKeepass/

Screenshots
-----------

![ownKeepass main mode](http://www.tisno.de/images/stories/myworld/ownkeepass/ownKeepass_MainPage2.jpg)
![ownKeepass main page expert mode](http://www.tisno.de/images/stories/myworld/ownkeepass/ownKeepass_MainPageExpertMode2.jpg)
![ownKeepass query master password](http://www.tisno.de/images/stories/myworld/ownkeepass/ownKeepass_QueryMasterPassword2.jpg)
![ownKeepass group view](http://www.tisno.de/images/stories/myworld/ownkeepass/ownKeepass_GroupView2.jpg)
![ownKeepass search page](http://www.tisno.de/images/stories/myworld/ownkeepass/ownKeepass_SearchPage2.jpg)
![ownKeepass show entry page](http://www.tisno.de/images/stories/myworld/ownkeepass/ownKeepass_ShowEntryPage2.jpg)
![ownKeepass password generator page](http://www.tisno.de/images/stories/myworld/ownkeepass/ownKeepass_PasswordGeneratorPage2.jpg)
![ownKeepass database settings](http://www.tisno.de/images/stories/myworld/ownkeepass/ownKeepass_DatabaseSettings2.jpg)
![ownKeepass cover page](http://www.tisno.de/images/stories/myworld/ownkeepass/ownKeepass_Cover2.jpg)
