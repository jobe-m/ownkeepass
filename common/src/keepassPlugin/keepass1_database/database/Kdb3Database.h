/***************************************************************************
 *   Copyright (C) 2005-2007 by Tarek Saidi                                *
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

#ifndef _STD_DATABASE_H_
#define _STD_DATABASE_H_

#include <QThread>
#include <QMap>
#include "database/Database.h"
#include "config/keepassx.h"

#define DB_HEADER_SIZE	124
#define PWM_DBSIG_1		0x9AA2D903
#define PWM_DBSIG_2 	0xB54BFB65
#define PWM_DBVER_DW	0x00030002
#define PWM_FLAG_SHA2			1
#define PWM_FLAG_RIJNDAEL		2
#define PWM_FLAG_ARCFOUR		4
#define PWM_FLAG_TWOFISH		8
#define PWM_STD_KEYENCROUNDS 	6000

void memcpyFromLEnd32(quint32* dst,const char* src);
void memcpyFromLEnd16(quint16* dst,const char* src);
void memcpyToLEnd32(char* src,const quint32* dst);
void memcpyToLEnd16(char* src,const quint16* dst);

//! Implementation of the standard KeePassX database.
class Kdb3Database:public ICustomIcons,public IDatabase, public IKdbSettings{
Q_OBJECT
public:
	class StdGroup;
	class StdEntry;
	class EntryHandle:public IEntryHandle{

		friend class Kdb3Database;
		public:
			EntryHandle(Kdb3Database* db);
			virtual void setImage(const quint32& ImageID);
			virtual void setTitle(const QString& Title);
			virtual void setUrl(const QString& URL);
			virtual void setUsername(const QString& Username);
			virtual void setPassword(const SecString& Password);
			virtual void setComment(const QString& Comment);
			virtual void setBinaryDesc(const QString& BinaryDesc);
			virtual void setCreation(const KpxDateTime& Creation);
			virtual void setLastMod(const KpxDateTime& LastMod);
			virtual void setLastAccess(const KpxDateTime& LastAccess);
			virtual void setExpire(const KpxDateTime& Expire);
			virtual void setBinary(const QByteArray& BinaryData);
			virtual KpxUuid uuid()const;
			virtual IGroupHandle* group()const;
			virtual quint32 image()const;
			virtual int visualIndex() const;
			virtual void setVisualIndex(int i);
			virtual void setVisualIndexDirectly(int i);
			virtual QString title()const;
			virtual QString url()const;
			virtual QString username()const;
			virtual SecString password()const;
			virtual QString comment()const;
			virtual QString binaryDesc()const;
			virtual KpxDateTime creation()const;
			virtual KpxDateTime lastMod()const;
			virtual KpxDateTime lastAccess()const;
			virtual KpxDateTime expire()const;
			virtual QByteArray binary()const;
			virtual quint32 binarySize()const;
			virtual QString friendlySize()const;
			virtual bool isValid() const;
			virtual CEntry data()const;
		private:
			void invalidate(){valid=false;}
			bool valid;
			//KpxUuid Uuid; ???
			Kdb3Database* pDB;
			StdEntry* Entry;
	};

	class GroupHandle:public IGroupHandle{
		friend class Kdb3Database;
		GroupHandle(Kdb3Database* db);
		public:
			virtual void setTitle(const QString& Title);
			virtual void setImage(const quint32& ImageId);
            virtual QString title()const;
			virtual quint32 image();
			virtual bool isValid();
			virtual IGroupHandle* parent();
			virtual QList<IGroupHandle*> children();
			virtual int index();
			//virtual void setIndex(int index);
			virtual int level();
			virtual bool expanded();
			virtual void setExpanded(bool IsExpanded);
		private:
			void invalidate(){valid=false;}
			bool valid;
			StdGroup* Group;
			Kdb3Database* pDB;
	};

	friend class EntryHandle;
	friend class GroupHandle;

	class StdEntry:public CEntry{
		public:
				StdEntry();
				quint16 Index;
				EntryHandle* Handle;
				StdGroup* Group;
	};

	class StdGroup:public CGroup{
		public:
			StdGroup();
			StdGroup(const CGroup&);
			quint16 Index;
			StdGroup* Parent;
			GroupHandle* Handle;
			QList<StdGroup*> Children;
			QList<StdEntry*> Entries;
	};

	Kdb3Database();
	virtual ~Kdb3Database(){};
	virtual bool load(QString identifier, bool readOnly);
	virtual bool save();
	virtual bool saveFileTransactional(char* buffer, int size);
	virtual bool close();
	virtual void create();
	virtual int numEntries();
	virtual int numGroups();
	virtual QString getError();
	virtual bool isKeyError();
	virtual void cleanUpHandles();
	virtual QPixmap& icon(int index);
 	virtual int numIcons();
	virtual void addIcon(const QPixmap& icon);
	virtual void removeIcon(int index);
	virtual void replaceIcon(int index,const QPixmap& icon);
	virtual int builtinIcons(){return BUILTIN_ICONS;};
	virtual QList<IEntryHandle*> search(IGroupHandle* Group,const QString& SearchString, bool CaseSensitve, bool RegExp,bool Recursive,bool* Fields);
	virtual QFile* file(){return File;}
	virtual bool changeFile(const QString& filename);
	virtual void setCryptAlgorithm(CryptAlgorithm algo){Algorithm=algo;}
	virtual CryptAlgorithm cryptAlgorithm(){return Algorithm;}
	virtual unsigned int keyTransfRounds(){return KeyTransfRounds;}
	virtual void setKeyTransfRounds(unsigned int rounds){KeyTransfRounds=rounds;}
	virtual bool setKey(const QString& password, const QString& keyfile);
	virtual bool setPasswordKey(const QString& password);
	virtual bool setFileKey(const QString& filename);
	virtual bool setCompositeKey(const QString& password,const QString& filename);

	virtual QList<IEntryHandle*> entries();
	virtual QList<IEntryHandle*> entries(IGroupHandle* Group);
	virtual QList<IEntryHandle*> entriesSortedStd(IGroupHandle* Group);
	virtual QList<IEntryHandle*> expiredEntries();

	virtual IEntryHandle* cloneEntry(const IEntryHandle* entry);
	virtual void deleteEntry(IEntryHandle* entry);
	virtual void deleteEntries(QList<IEntryHandle*> entries);
	virtual IEntryHandle* newEntry(IGroupHandle* group);
	virtual IEntryHandle* addEntry(const CEntry* NewEntry, IGroupHandle* group);
	virtual void moveEntry(IEntryHandle* entry, IGroupHandle* group);
	virtual void deleteLastEntry();


	virtual QList<IGroupHandle*> groups();
	virtual QList<IGroupHandle*> sortedGroups();
	virtual void deleteGroup(IGroupHandle* group);
	virtual void moveGroup(IGroupHandle* Group,IGroupHandle* NewParent,int Position);
	virtual IGroupHandle* addGroup(const CGroup* Group,IGroupHandle* Parent);
	virtual IGroupHandle* backupGroup(bool create=false);
	virtual bool isParent(IGroupHandle* parent, IGroupHandle* child);
	
	virtual void generateMasterKey();
	//virtual IDatabase* groupToNewDb(IGroupHandle* group);
	
	inline bool hasPasswordEncodingChanged() { return passwordEncodingChanged; };

private:
	bool loadReal(QString filename, bool readOnly, bool differentEncoding);
	QDateTime dateFromPackedStruct5(const unsigned char* pBytes);
	void dateToPackedStruct5(const QDateTime& datetime, unsigned char* dst);
	bool isMetaStream(StdEntry& Entry);
	bool parseMetaStream(const StdEntry& Entry);
	void parseCustomIconsMetaStream(const QByteArray& data);
	void parseCustomIconsMetaStreamV3(const QByteArray& data);
	void parseGroupTreeStateMetaStream(const QByteArray& data);
	void createCustomIconsMetaStream(StdEntry* e);
	void createGroupTreeStateMetaStream(StdEntry* e);
	bool readEntryField(StdEntry* entry, quint16 FieldType, quint32 FieldSize, quint8 *pData);
	bool readGroupField(StdGroup* group,QList<quint32>& Levels,quint16 FieldType, quint8 *pData);
	bool createGroupTree(QList<quint32>& Levels);
	void createHandles();
	void invalidateHandle(StdEntry* entry);
	bool convHexToBinaryKey(char* HexKey, char* dst);
	quint32 getNewGroupId();
	void serializeEntries(QList<StdEntry>& EntryList,char* buffer,unsigned int& pos);
	void serializeGroups(char* buffer,unsigned int& pos);
	void appendChildrenToGroupList(QList<StdGroup*>& list,StdGroup& group);
    void appendChildrenToGroupList(QList<IGroupHandle*>& list,StdGroup& group);
    void appendChildrenToGroupListSorted(QList<IGroupHandle*>& list, IGroupHandle *group);
    bool searchStringContains(const QString& search, const QString& string,bool Cs, bool RegExp);
	void getEntriesRecursive(IGroupHandle* Group, QList<IEntryHandle*>& EntryList);
	void rebuildIndices(QList<StdGroup*>& list);
	void restoreGroupTreeState();
	//void copyTree(Kdb3Database* db, GroupHandle* orgGroup, IGroupHandle* parent);
	static bool EntryHandleLessThan(const IEntryHandle* This,const IEntryHandle* Other);
	static bool EntryHandleLessThanStd(const IEntryHandle* This,const IEntryHandle* Other);
    static bool GroupHandleLessThanStd(const IGroupHandle* This,const IGroupHandle* Other);
    static bool StdEntryLessThan(const Kdb3Database::StdEntry& This,const Kdb3Database::StdEntry& Other);

	StdEntry* getEntry(const KpxUuid& uuid);
	StdEntry* getEntry(EntryHandle* handle);
	int getEntryListIndex(EntryHandle* handle);
	EntryHandle* getHandle(StdEntry* entry);

	StdGroup* getGroup(quint32 Id);
	void deleteGroup(StdGroup* group);

	QList<EntryHandle> EntryHandles;
	QList<GroupHandle> GroupHandles;
	QList<StdEntry> Entries;
	QList<StdGroup> Groups;
	StdGroup RootGroup;
	QList<QPixmap>CustomIcons;
	QFile* File;
	bool openedReadOnly;
	QString error;
	bool KeyError;
	bool PotentialEncodingIssueLatin1;
	bool PotentialEncodingIssueUTF8;
	QList<StdEntry> UnknownMetaStreams;
	QMap<quint32,bool> TreeStateMetaStream;
	unsigned int KeyTransfRounds;
	CryptAlgorithm Algorithm;
	SecData RawMasterKey;
	SecData RawMasterKey_CP1252;
	SecData RawMasterKey_Latin1;
	SecData RawMasterKey_UTF8;
	SecData MasterKey;
	quint8 TransfRandomSeed[32];
	bool hasV4IconMetaStream;
	bool passwordEncodingChanged;
};

class KeyTransform : public QThread{
	Q_OBJECT
	
	public:
		static void transform(quint8* src, quint8* dst, quint8* KeySeed, int rounds);
	
	private:
		KeyTransform(quint8* pSrc, quint8* pDst, quint8* pKeySeed, int pRounds);
		quint8* src;
		quint8* dst;
		quint8* KeySeed;
		int rounds;
	
	protected:
		void run();
};

class KeyTransformBenchmark : public QThread{
	Q_OBJECT
	
	public:
		static int benchmark(int pMSecs);
	
	private:
		KeyTransformBenchmark(int pMSecs);
		int msecs;
		int rounds;
	
	protected:
		void run();
};

#endif
