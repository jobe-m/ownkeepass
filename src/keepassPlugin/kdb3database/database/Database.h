/***************************************************************************
 *   Copyright (C) 2005-2006 by Tarek Saidi                                *
 *   tarek.saidi@arcor.de                                                  *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; version 2 of the License.               *

 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#ifndef _DATABASE_H_
#define _DATABASE_H_

#include <QDateTime>
#include <QPixmap>
#include <QFile>
#include "utils/SecString.h"

extern const QDateTime Date_Never;

enum CryptAlgorithm{
	Rijndael_Cipher=0,
	Twofish_Cipher=1
};

//! Universally Unique Identifier Class.
/*!
Provides generation, serialization, deserialization and comparison of UUIDs.
*/
class KpxUuid{
public:
	KpxUuid();
	KpxUuid(const void* src);
	void generate();
	QString toString() const;
	const unsigned char* data()const
		{return (const unsigned char*) Data.data();}
	void toRaw(void* dst)const;
	void fromRaw(const void* src);
	bool operator==(const KpxUuid&) const;
	bool operator!=(const KpxUuid&) const;
private:
	QByteArray Data;
};

//! Advanced DateTime Class.
/*!
This class advances the standard Qt class 'QDateTime' with KeePassX specific methods for string conversion.
*/
class KpxDateTime:public QDateTime{
	public:
		KpxDateTime(){};
		KpxDateTime ( const QDate & date ):QDateTime(date){};
		KpxDateTime ( const QDate & date, const QTime & time, Qt::TimeSpec spec = Qt::LocalTime):QDateTime(date,time,spec){};
		KpxDateTime ( const QDateTime & other ):QDateTime(other){};
		//! Returns a string representation of the DateTime object in the given format or "Never" if the DateTime value is 28.12.2999 23:59:59.
		virtual QString toString(Qt::DateFormat format = Qt::TextDate ) const;
		//! Returns a string representation of the date part of the DateTime object in the given format or "Never" if the DateTime value is 28.12.2999 23:59:59.
		QString dateToString(Qt::DateFormat format = Qt::TextDate)const;
		static KpxDateTime fromString(const QString& string,Qt::DateFormat format = Qt::TextDate);
		bool operator<(const QDateTime& other);
};

//! Entry Data Structure
/*! This class holds the data of a normal database entry. It is used by some interface functions to process predefined entries and can be used for internal data handling.*/
class CEntry{
public:
	CEntry();
	KpxUuid Uuid;
	quint32 GroupId;
	quint32 Image;
	QString Title;
	QString Url;
	QString Username;
	SecString Password;
	QString Comment;
	QString BinaryDesc;
	KpxDateTime Creation;
	KpxDateTime LastMod;
	KpxDateTime LastAccess;
	KpxDateTime Expire;
	QByteArray Binary;
	bool operator==(const CEntry& other) const;
};

//! Group Data Structure
/*! This class holds the data of a normal database group. It is used by some interface functions to process predefined groups and can be used for internal data handling.*/
class CGroup{
public:
	CGroup();
	quint32 Id;
	quint32 Image;
	QString Title;
	bool operator==(const CGroup& other) const;
	bool IsExpanded;
};


class IGroupHandle;
class IEntryHandle;
//! Handle class interface for accessing entries
/*!
The IEntryHandle interface provides access to Entry data structures without using direct references. Every entry handle class must implement this interface necessarily.
*/
class IEntryHandle{
public:
	virtual void setImage(const quint32& ImageID)=0;
	virtual void setTitle(const QString& Title)=0;
	virtual void setUrl(const QString& URL)=0;
    virtual void setUsername(const QString& Username)=0;
	virtual void setPassword(const SecString& Password)=0;
	virtual void setComment(const QString& Comment)=0;
	virtual void setBinaryDesc(const QString& BinaryDesc)=0;
	virtual void setCreation(const KpxDateTime& Creation)=0;
	virtual void setLastMod(const KpxDateTime& LastMod)=0;
	virtual void setLastAccess(const KpxDateTime& LastAccess)=0;
	virtual void setExpire(const KpxDateTime& Expire)=0;
	virtual void setBinary(const QByteArray& BinaryData)=0;

	virtual KpxUuid uuid()const=0;
	virtual IGroupHandle* group()const=0;
	virtual quint32 image()const=0;
	virtual QString title()const=0;
	virtual QString url()const=0;
	virtual QString username()const=0;
	virtual SecString password()const=0;
	virtual QString comment()const=0;
	virtual QString binaryDesc()const=0;
	virtual KpxDateTime creation()const=0;
	virtual KpxDateTime lastMod()const=0;
	virtual KpxDateTime lastAccess()const=0;
	virtual KpxDateTime expire()const=0;
	virtual QByteArray binary()const=0;
	virtual quint32 binarySize()const=0;
	virtual QString friendlySize()const=0;

	//! \return the index of the entry amongst the entries of its group. The index of the first entry is 0.
	virtual int visualIndex()const=0;

	/*! Sets the visual index of an entry. The indices of all other entries in the same group get automaticly readjusted by this function.
		\param index The new visual index.
	*/
	virtual void setVisualIndex(int index)=0;

	/*! Sets the visual index of an entry. The indices of all other entries in the same group need to be adjusted manually!
		This function is optimal to avoid readjustion overhead when sorting items.
		\param index The new visual index.
	*/
	virtual void setVisualIndexDirectly(int index)=0;

	/*! Tests the validity of the handle.
		\return TRUE if the handle is valid and FALSE if the handle is invalid e.g. because the associated entry was deleted.*/
	virtual bool isValid()const=0;

	virtual CEntry data()const=0;
};

//! Custom Icon Interface
/*!
This class provides an interface for the management of custom icons. The implementation is optional and not necessarily needed.
 */
class ICustomIcons:public QObject{
	Q_OBJECT
	public:
		/*! Adds a new custom icon to the database.
		\param icon The pixmap which contains the new icon. This function makes a copy of the given pixmap.
		 */
		virtual void addIcon(const QPixmap& icon)=0;

		/*! Removes an icon.
		\param index The index of the icon which should be removed. Built-in icons cannot be removed so make sure that index is not the index of an Built-in icon before calling this function.
		 */
		virtual void removeIcon(int index)=0;

		/*! Replaces one icon with another one.
		\param index The index of the icon which should be replaced. Built-in icons cannot be replaced so make sure that index is not the index of an Built-in icon before calling this function.
		\param icon The pixmap which contains the new icon.
		 */
		virtual void replaceIcon(int index,const QPixmap& icon)=0;
	signals:
		/*! This signal is emitted when an icon was modified.
		That means it is emitted after every call off addIcon(), removeIcon() and replaceIcon().
		 */
		void iconsModified();

};


//! Handle class interface for accessing groups
/*!
The IGroupHandle interface provides access to CGroup data structures without using direct references. Every entry handle class must implement this interface necessarily.
*/
class IGroupHandle{
public:
	virtual void setTitle(const QString& Title)=0;
	virtual void setImage(const quint32& ImageID)=0;

	virtual QString title()=0;
	virtual quint32 image()=0;

	//! \return a pointer to the handle of the parent group or NULL if the group has no parent.
	virtual IGroupHandle* parent()=0;

	//! \return a List of pointers to the handles of all children of the group and an empty list if the group has no children. The list is sorted.
	virtual QList<IGroupHandle*> children()=0;

	//! \return the index of the group amongst the children of its parent. The index of the first child is 0.
	virtual int index()=0;

	/*! Sets the index of a group amongst the children of its parent.
		This function can be used to sort the groups of the database in a specific order.
		\param index The new index of the group. The indices of the other groups which are affected by this operation will be automatically adjusted.*/
	//virtual void setIndex(int index)=0;

	/*! Tests the validity of the handle.
		\return TRUE if the handle is valid and FALSE if the handle is invalid e.g. because the associated group was deleted.*/
	virtual bool isValid()=0;

	/*! \return the level of the group in the group tree. This level is tantamount to the number of parents that the group has. */
	virtual int level()=0;

	virtual bool expanded()=0;
	virtual void setExpanded(bool)=0;

};

//! Common Database Interface.
/*!
This is the common base interface for databases. Every database class must implement this interface necessarily.
*/
class IDatabase{
public:
	virtual ~IDatabase(){};
	
	virtual bool setKey(const QString& password,const QString& keyfile)=0;
	virtual bool isKeyError()=0;
	virtual void generateMasterKey()=0;

	//! Loads a database.
   	/*! It is not allowed to call this function if a database is already loaded.
		\param  identifier Normally this is the filename of the database but it can also be an IP address or something else if the database is not file based.
		\return TRUE if loading was successfull, otherwise FALSE.
	*/
	virtual bool load(QString identifier, bool readOnly)=0;

	//! Saves the current database.
   	/*! It is not allowed to call this function if no database is loaded.
		\return TRUE if saving was successfull, otherwise FALSE.
	*/
	virtual bool save()=0;

	//! Closes the current database.
   	/*! After a call of this function the database object can be used to load another database.
		It is not allowed to call this function if no database is loaded.
		Please note: The database will be closed without saving it in before.
	 *  \return TRUE if closing was successfull, otherwise FALSE.
	*/
	virtual bool close()=0;

	//! Creates a new database.
   	/*! It is not allowed to call this function if a database is already loaded.
		\return TRUE if saving was successfull, otherwise FALSE.
	*/
	virtual void create()=0;


	virtual bool changeFile(const QString& filename)=0;

	virtual QFile* file()=0;

	//! \return a list with the pointers to the handles of all entries of the database. The list contains only valid handles. The list is not sorted.
	virtual QList<IEntryHandle*> entries()=0;

	//! \param Group The group which contains the wanted entries.
	//! \return a list of pointers to the handles of all entries which belong to the given group. The list contains only valid handles and is sorted in an ascending order regarding to the entry indices.
	virtual QList<IEntryHandle*> entries(IGroupHandle* Group)=0;

	//! \param Group The group which contains the wanted entries.
	//! \return a list of pointers to the handles of all entries which belong to the given group. The list contains only valid handles and is sorted in an ascending order (title, username).
	virtual QList<IEntryHandle*> entriesSortedStd(IGroupHandle* Group)=0;

	//! \return a list with the pointers to the handles of all expired entries of the database. The list contains only valid handles. The list is not sorted.
	virtual QList<IEntryHandle*> expiredEntries()=0;

	//! \return a list with the pointers to the handles of all entries of the database. The list contains only valid handles and is not sorted.
	virtual QList<IGroupHandle*> groups()=0;

	/*!
		This function might be slower than groups() - denpending on the implementation.
		\return a list with the pointers to the handles of all entries of the database. The list ist sorted and contains only valid handles.*/
	virtual QList<IGroupHandle*> sortedGroups()=0;

	/*! \return handle of the backup group or NULL if it doesn't exist
		\param create Create the backup group if it doesn't exist
	 */
	virtual IGroupHandle* backupGroup(bool create=false)=0;

	/*! \return the last error message or an empty QString() object if no error occured.*/
	virtual QString getError()=0;

	/*! Creates a clone of a given entry.
		All attributes besides the UUID are copied, even the creation date.
		\param entry The handle of the entry which should be cloned.
		\return a pointer to the handle of the cloned entry.
	*/
	virtual IEntryHandle* cloneEntry(const IEntryHandle* entry)=0;

	/*! Deletes a given entry.
		\param entry The handle of the entry which should be deleted.
	*/
	virtual void deleteEntry(IEntryHandle* entry)=0;


	/*! Deletes the last added entry.
		This function should only be called immediately after an addEntry() call, otherwise the behavior is undefined. Immediately means that there are no other add/move/delete operations between the two function calls.*/
	virtual void deleteLastEntry()=0;


	/*! Deletes multiple given entries.
		Calling this function can be faster then calling deleteEntry(..) several times - depending on the implementation.
		Important: All entries must belong to the same group!
		\param entries A pointer list of handles of the entries which sould be deleted. The list can be empty therefore no prior testing is necessary.*/
	virtual void deleteEntries(QList<IEntryHandle*> entries)=0;


	/*! Creates a new blank entry.
		\param Group The group to which the entry should be added.
		\return the handle of the new entry.
	*/
 	virtual IEntryHandle* newEntry(IGroupHandle* Group)=0;

	/*! Adds a Entry object to the database.
		\param Group The group to which the entry should be added.
		\param NewEntry The new entry. It is important that the new entry object has a valid UUID!
		\return a pointer to the handle of the added entry.
	*/
	virtual IEntryHandle* addEntry(const CEntry* NewEntry, IGroupHandle* Group)=0;

	/*! Moves an entry to another group.
		\param entry The entry which should be moved.
		\param group The new group of the entry.*/
	virtual void moveEntry(IEntryHandle* entry, IGroupHandle* group)=0;


	/*! Removes a group from the database.
		Deletes the group, all it's entries and child groups and their entries as well.
		\param group The group which should be deleted.*/
	virtual void deleteGroup(IGroupHandle* group)=0;

	/*! Adds a group to the database.
		\param Group A pointer to a CGroup object. Id and ParentId of the object are ignored.
		\param Parent A pointer to the handle of parent of the group. Can be NULL if the group is a top-level group.
		\return a pointer to the handle of the added group.*/
	virtual IGroupHandle* addGroup(const CGroup* Group,IGroupHandle* Parent)=0;

	/*! Moves a group.
		\param Group The group which should be moved.
		\param NewParent The new parent of the group.
		\param Position The position of the group amongst it's new siblings. If Position is 0 the group will be prepended if it is -1 the group will be appended.*/
	virtual void moveGroup(IGroupHandle* Group,IGroupHandle* NewParent,int Position)=0;

	/*! Checks two given groups if one is the parent of the other.
		\param Child The child group.
		\param Parent The parent group.
		\return TRUE if Parent is the parent of child, otherwise FALSE.*/
	virtual bool isParent(IGroupHandle* parent, IGroupHandle* child)=0;

	/*! \param index Index of the requested icon.
		\return a reference to the pixmap of the requested icon.
	*/
	virtual QPixmap& icon(int index)=0;
	//! \return the number of icons provided by the database. This number can vary at runtime if the database supports custom icons.
 	virtual int numIcons()=0;

	/*! Deletes all old invalid handles of the database.
		Make sure that there are no pointers to those handles which are still in use before calling this function.*/
	virtual void cleanUpHandles()=0;

	/*! \return the number of groups in the database.*/
	virtual int numGroups()=0;

	/*! \return the number of entires in the database.*/
	virtual int numEntries()=0;

	/*! \return the number of built-in icons of the database. Each database must contain at least one built-in icon. */
	virtual int builtinIcons()=0;

	/*! Searches in the database for a string or regular expression.
		\param Group The group where the search should be performed in. If Group is NULL the search will be performed in the whole database.
		\param SearchString The searched string or a regular expression.
		\param CaseSensitvie If this parameter is true the search will be case sensitive.
		\param RegExp The SearchString parameter will be handled as regular expression if this parameter is true.
		\param Recursive Defines whether the search should include subgroups of Group or not. This parameter has no effect if Group is NULL.
		\param Fields A pointer to a six element bool array. It defines which fields are included into the search. The order is: title, username, url, password, comment, attachment description. The pointer can also be NULL, than the default pattern is used instead.
		\return the search results as a list of pointers to the entry handles.*/
	virtual QList<IEntryHandle*> search(IGroupHandle* Group,const QString& SearchString, bool CaseSensitve, bool RegExp,bool Recursive,bool* Fields)=0;
	
	//virtual IDatabase* groupToNewDb(IGroupHandle* group)=0;
};

class IKdbSettings{
	public:
		virtual void setCryptAlgorithm(CryptAlgorithm algo)=0;
		virtual CryptAlgorithm cryptAlgorithm()=0;
		virtual unsigned int keyTransfRounds()=0;
		virtual void setKeyTransfRounds(unsigned int rounds)=0;
};

#endif
