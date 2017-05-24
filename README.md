# ownKeepass

[Bug reports go here] - [Translations here]

## Status

Release 1.2.2 is available on [openrepos.net]
* Password entries in Keepass 2 databases can be created, edited and deleted
* Password groups in Keepass 2 databases can be created, edited and deleted
* Additional attributes of password entries in Keepass 2 databases can be added, changed and deleted
* Added possibility to copy into clipboard every item of a password entry by long-press on it
* Open URL in web browser by just one click on the URL text
* Reworked password entry editing page for Keepass 2 support
* Fixed scaling of icons on password generator page with higher resolution displays
* Updated and reordered text sections on about page
* Added new translations for Polish and Serbian (Not yet fully done, please help on transifex to finish them)
* Updated all other translations from transifex
* Bugfix: Specifying the wrong Keepass version on opening a database does not give a proper error notification; the display just kept showing the loading databasee message
* Bugfix: It was not possible to delete more than one keepass entry or group in a row
* Bugfix: When deleting the last password item from a group the placeholder text was not shown again


Bugfix release 1.1.15 is available in Jolla store
* Fixed mapping of settings value for time to clear clipboard: In release 1.1.14 the time for clearing clipboard silently changed to 5 seconds if it was before set to "disabled"

Release 1.1.14
* Added individual icons for password entries and groups
* Time to clear clipboard can be adjusted between 5 seconds and 10 minutes
* Parent group of password entries is shown in search list view
* Copy-Paste cover action now skips empty username or password entries
* Implemented alphabetical sorting of Keepass 2 database entries
* Added new translation for Galician language
* Updated all other translations from Transifex

## Roadmap

List of planned features for ownKeepass to happen somewhere the next time. Priority
in descending order.

*   Finishing write support for Keepass 2 databases
*   Integrating WebDav and Dropbox support for loading and saving your Keepass database to a server like ownCloud.


## What is this?

ownKeepass is a password safe application for the Jolla Smartphone with the purpose to
protect sensible data like passwords for web pages, credit card numbers,
PINs, TANs and other bits of information which should be kept secret. All that information
is saved in a database file which is encrypted and stored locally on your phone. To open
the database you need to know the master password of the database. ownKeepass can use Keepass
version 1 and 2 databases. That means you can use [Keepass] or [KeepassX] on your desktop
system to decrypt and open that database file, too.

## Why?

I started to work on this project beginning of 2012 when QML started to get usable from development point
of view for the Nokia N9. Writing a QML UI for the stable KeepassX 0.4.3 version was just born out of the
idea to take my favourite Password Safe application to new Qt platforms like the Nokia N9. Although
ownKeepass was quite usable for me on my Nokia N9 I never released it for the Nokia N9 due to lack of
time and motivation (Nokia's Qt strategy disruption) to make the application usable for a wider audience.
Mid of 2013 I decided to continue development on the new Sailfish OS platform from the finnish Smartphone
start-up Jolla. This platform offers Qt5 with QtQuick2 and Wayland which really marks the edge of UI
development. This is so much of technical motivation to me to do some great UI stuff with ownKeepass :)

## Some words about Keepass database security

The database code in ownKeepass is based on the [KeepassX] project and as such contains a lot of
security related features. It uses proven encryption algorithms like Advanced Encryption Standard
(AES / Rijndael) or Twofish with 128 bits block size and 256 bits key size, SHA-256 as hashing
algorithm and in-memory encryption of all passwords. Furthermore it protects the master
password against Brute-Force and Dictonary Attacks by hashing and encrypting it before
using it to decrypt the Keepass database. This feature is called key transformation rounds and can be
adjusted in database settings. Anyway that all just adds additional security to two points which
you should be aware of:

*   Always use a long enough and difficult to guess master password.
*   Protect your system from spyware which might be specialized to attack ownKeepass.

The second is law #1 of the [10 Immutable Laws of Security]: "If a bad guy can persuade you to run
his program on your computer, it's not your computer anymore".

## Sharing Keepass database between your jolla phone and your desktop PC

The Keepass database file format is perfect to share your password safe between different
systems like phones, tablets, desktop PC and so on. That is because there are a lot of Keepass
implementations available for those platforms. Have a look at the [Keepass download page] to get the classic Keepass 1 or
the new Keepass version 2 for the desktop PC. There is also a list of alternative Keepass implementations on that page.
I would also like to point you to [KeepassX] which is also compatible with Keepass version 1 and 2 databases.
You can share your Keepass database file via SD card or via a cloud service like Dropbox.
When using a cloud server I would recommend to use a key file in addition to the master password.
The additional key file will be used by ownKeepass to decrypt the database. Store this key file
only locally on your phone and on your desktop PC. Do not upload it to the cloud service. If an attacker
hacks your cloud service he will be left without the key file. By doing so you make it even
harder for an attacker to crack your Keepass database because the key file content is usually
impossible to guess.

Optionally you could use [Syncthing] to sync the password safe between different devices. Syncthing is available for
all platforms including Sailfish OS. For Sailfish OS it is available in openrepos as the [core] and a [GUI].
Syncthing does not require a sync over the internet but it can sync locally between devices.

Copyright 2014 - 2017 Marko Koschak. Licensed under GPLv2. See LICENSE for more info.

[openrepos.net]: https://openrepos.net/content/jobe/ownkeepass                             "Beta and testing releases"
[Keepass]: http://www.keepass.info/help/v1/setup.html                                      "Official Keepass homepage for version 1"
[KeepassX]: http://www.keepassx.org                                                        "KeepassX project homepage"
[10 Immutable Laws of Security]: http://technet.microsoft.com/en-us/library/cc722487.aspx  "10 Immutable Laws of Security"
[Keepass download page]: http://www.keepass.info/download.html                             "Download classic Keepass"
[Bug reports go here]: https://github.com/jobe-m/ownkeepass/issues
[Translations here]: https://www.transifex.com/projects/p/jobe_m-ownKeepass/
[Syncthing]: https://syncthing.net/                                                        "Syncthing homepage"
[core]: https://openrepos.net/content/fooxl/syncthing-inotify-bin                          "Syncthing core for SFOS"
[GUI]: https://openrepos.net/content/fooxl/syncthing-sf                                    "Syncthing GUI for SFOS"
