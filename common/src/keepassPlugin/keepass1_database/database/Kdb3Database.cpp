/***************************************************************************
 *   Copyright (C) 2005-2008 by Tarek Saidi                                *
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

#include <QDebug>

#include <QBuffer>
#include <algorithm>

#include "Kdb3Database.h"
#include "config/KpxConfig.h"
#include "config/keepassx.h"
#include "crypto/twoclass.h"
#include "utils/tools.h"
#include "crypto/yarrow.h"
#include "crypto/sha256.h"
#include "crypto/aescpp.h"

#define UNEXP_ERROR error=QString("Unexpected error in: %1, Line:%2").arg(__FILE__).arg(__LINE__);

const QDateTime Date_Never(QDate(2999,12,28),QTime(23,59,59));


bool Kdb3Database::EntryHandleLessThan(const IEntryHandle* This,const IEntryHandle* Other){
	if(!This->isValid() && Other->isValid())return true;
	if(This->isValid() && !Other->isValid())return false;
	if(!This->isValid() && !Other->isValid())return false;
	return This->visualIndex()<Other->visualIndex();
}

bool Kdb3Database::EntryHandleLessThanStd(const IEntryHandle* This,const IEntryHandle* Other){
    int comp = This->title().toLower().compare(Other->title().toLower());
	if (comp < 0) return true;
	else if (comp > 0) return false;
	
    comp = This->username().toLower().compare(Other->username().toLower());
	if (comp < 0) return true;
	else if (comp > 0) return false;
	
    return true;
}

bool Kdb3Database::GroupHandleLessThanStd(const IGroupHandle* This,const IGroupHandle* Other){
    int comp = This->title().toLower().compare(Other->title().toLower());
    if (comp > 0) return false;
    else return true;
}

bool Kdb3Database::StdEntryLessThan(const Kdb3Database::StdEntry& This,const Kdb3Database::StdEntry& Other){
	return This.Index<Other.Index;
}


Kdb3Database::Kdb3Database() : File(NULL), RawMasterKey(32), RawMasterKey_CP1252(32),
	RawMasterKey_Latin1(32), RawMasterKey_UTF8(32), MasterKey(32){
}

QString Kdb3Database::getError(){
	return error;
}

void Kdb3Database::addIcon(const QPixmap& icon){
	CustomIcons << icon;
	emit iconsModified();
}

QPixmap& Kdb3Database::icon(int i){
	if(i>=builtinIcons()+CustomIcons.size())
		return EntryIcons[0];
	if(i<builtinIcons())
		return EntryIcons[i];
	return CustomIcons[i-builtinIcons()];
}

void Kdb3Database::removeIcon(int id){
	id-=builtinIcons();
	if(id < 0 ) return;
	if(id >= CustomIcons.size()) return;
	CustomIcons.removeAt(id); // .isNull()==true
	for(int i=0;i<Entries.size();i++){
		if(Entries[i].Image == id+builtinIcons())
			Entries[i].Image=0;
		if(Entries[i].Image>id+builtinIcons())
			Entries[i].Image--;
	}
	for(int i=0;i<Groups.size();i++){
		if(Groups[i].Image == id+builtinIcons())
			Groups[i].Image=0;
		if(Groups[i].Image>id+builtinIcons())
			Groups[i].Image--;
	}
	emit iconsModified();
}

void Kdb3Database::replaceIcon(int id,const QPixmap& icon){
	if(id<builtinIcons())return;
		CustomIcons[id-builtinIcons()]=icon;
	emit iconsModified();
}

int Kdb3Database::numIcons(){
	return builtinIcons()+CustomIcons.size();
}

bool Kdb3Database::parseMetaStream(const StdEntry& entry){

//	qDebug("Found Metastream: %s", CSTR(entry.Comment));

	if(entry.Comment=="KPX_GROUP_TREE_STATE"){
		parseGroupTreeStateMetaStream(entry.Binary);
		return true;
	}
	else if(entry.Comment=="KPX_CUSTOM_ICONS_4"){
		parseCustomIconsMetaStream(entry.Binary);
		return true;
	}
	else if(entry.Comment=="KPX_CUSTOM_ICONS_3"){
		if (!hasV4IconMetaStream)
			parseCustomIconsMetaStreamV3(entry.Binary);
		return true;
	}
	else if(entry.Comment=="KPX_CUSTOM_ICONS_2"){
		qDebug("Removed old CuIcMeSt v2");
		return true;
	}
	else if(entry.Comment=="KPX_CUSTOM_ICONS"){
		qDebug("Removed old CuIcMeSt v1");
		return true;
	}

	return false; //unknown MetaStream
}

bool Kdb3Database::isMetaStream(StdEntry& p){
	if(p.Binary.isNull()) return false;
	if(p.Comment == "") return false;
	if(p.BinaryDesc != "bin-stream") return false;
	if(p.Title != "Meta-Info") return false;
	if(p.Username != "SYSTEM") return false;
	if(p.Url != "$") return false;
	if(p.Image != 0) return false;
	return true;
}

void Kdb3Database::parseCustomIconsMetaStream(const QByteArray& dta){
	//Rev 4 (KeePassX 0.3.2)
	quint32 NumIcons,NumEntries,NumGroups,offset;
	memcpyFromLEnd32(&NumIcons,dta.data());
	memcpyFromLEnd32(&NumEntries,dta.data()+4);
	memcpyFromLEnd32(&NumGroups,dta.data()+8);
	offset=12;
	CustomIcons.clear();
	for(int i=0;i<NumIcons;i++){
		CustomIcons << QPixmap();
		quint32 Size;
		memcpyFromLEnd32(&Size,dta.data()+offset);
		if(offset+Size > dta.size()){
			CustomIcons.clear();
			qWarning("Discarded metastream KPX_CUSTOM_ICONS_4 because of a parsing error.");
			return;
		}
		offset+=4;
		if(!CustomIcons.back().loadFromData((const unsigned char*)dta.data()+offset,Size,"PNG")){
			CustomIcons.clear();
			qWarning("Discarded metastream KPX_CUSTOM_ICONS_4 because of a parsing error.");
			return;
		}
		offset+=Size;
		if(offset > dta.size()){
			CustomIcons.clear();
			qWarning("Discarded metastream KPX_CUSTOM_ICONS_4 because of a parsing error.");
			return;
		}
	}
	for(int i=0;i<NumEntries;i++){
		quint32 Icon;
		KpxUuid EntryUuid;
		EntryUuid.fromRaw(dta.data()+offset);
		offset+=16;
		memcpyFromLEnd32(&Icon,dta.data()+offset);
		offset+=4;
		StdEntry* entry=getEntry(EntryUuid);
		if(entry)
			entry->Image=Icon+BUILTIN_ICONS;
	}
	for(int i=0;i<NumGroups;i++){
		quint32 GroupId,Icon;
		memcpyFromLEnd32(&GroupId,dta.data()+offset);
		offset+=4;
		memcpyFromLEnd32(&Icon,dta.data()+offset);
		offset+=4;
		StdGroup* Group=getGroup(GroupId);
		if(Group)
			Group->Image=Icon+BUILTIN_ICONS;
	}
	return;
}

void Kdb3Database::parseCustomIconsMetaStreamV3(const QByteArray& dta){
	//Rev 3
	quint32 NumIcons,NumEntries,NumGroups,offset;
	memcpyFromLEnd32(&NumIcons,dta.data());
	memcpyFromLEnd32(&NumEntries,dta.data()+4);
	memcpyFromLEnd32(&NumGroups,dta.data()+8);
	offset=12;
	CustomIcons.clear();
	for(int i=0;i<NumIcons;i++){
		CustomIcons << QPixmap();
		quint32 Size;
		memcpyFromLEnd32(&Size,dta.data()+offset);
		if(offset+Size > dta.size()){
			CustomIcons.clear();
			qWarning("Discarded metastream KPX_CUSTOM_ICONS_3 because of a parsing error.");
			return;
		}
		offset+=4;
		if(!CustomIcons.back().loadFromData((const unsigned char*)dta.data()+offset,Size,"PNG")){
			CustomIcons.clear();
			qWarning("Discarded metastream KPX_CUSTOM_ICONS_3 because of a parsing error.");
			return;
		}
		offset+=Size;
		if(offset > dta.size()){
			CustomIcons.clear();
			qWarning("Discarded metastream KPX_CUSTOM_ICONS_3 because of a parsing error.");
			return;
		}
	}
	for(int i=0;i<NumEntries;i++){
		quint32 Icon;
		KpxUuid EntryUuid;
		EntryUuid.fromRaw(dta.data()+offset);
		offset+=16;
		memcpyFromLEnd32(&Icon,dta.data()+offset);
		offset+=4;
		StdEntry* entry=getEntry(EntryUuid);
		if(entry){
			if (Icon>=65)
				entry->Image=Icon+4; // Since v0.3.2 the BUILTIN_ICONS number has increased by 4
			else
				entry->Image=Icon;
		}
	}
	for(int i=0;i<NumGroups;i++){
		quint32 GroupId,Icon;
		memcpyFromLEnd32(&GroupId,dta.data()+offset);
		offset+=4;
		memcpyFromLEnd32(&Icon,dta.data()+offset);
		offset+=4;
		StdGroup* Group=getGroup(GroupId);
		if(Group){
			if (Group->Image>=65)
				Group->Image=Icon+4; // Since v0.3.2 the BUILTIN_ICONS number has increased by 4
			else
				Group->Image=Icon;
		}
	}
	return;
}

void Kdb3Database::parseGroupTreeStateMetaStream(const QByteArray& dta){
	if(dta.size()<4){
		qWarning("Discarded metastream KPX_GROUP_TREE_STATE because of a parsing error.");
		return;
	}
	quint32 Num;
	memcpyFromLEnd32(&Num,dta.data());
	if(Num*5!=dta.size()-4){
		qWarning("Discarded metastream KPX_GROUP_TREE_STATE because of a parsing error.");
		return;
	}
	TreeStateMetaStream.clear();
	for(int i=0;i<Num;i++){
		quint32 GroupID;
		quint8 IsExpanded;
		memcpyFromLEnd32(&GroupID,dta.data()+4+5*i);
		memcpy(&IsExpanded,dta.data()+8+5*i,1);
		TreeStateMetaStream.insert(GroupID,(bool)IsExpanded);
	}
	return;
}

void Kdb3Database::createGroupTreeStateMetaStream(StdEntry* e){
	e->BinaryDesc="bin-stream";
	e->Title="Meta-Info";
	e->Username="SYSTEM";
	e->Comment="KPX_GROUP_TREE_STATE";
	e->Url="$";
	e->Image=0;
	if(Groups.size())e->GroupId=Groups[0].Id;
	QByteArray bin;
	quint32 Num=Groups.size();
	bin.resize(Num*5+4);
	memcpyToLEnd32(bin.data(),&Num);
	for(int i=0;i<Num;i++){
		memcpyToLEnd32(bin.data()+4+5*i,&Groups[i].Id);
		if(Groups[i].IsExpanded)
			bin.data()[8+5*i]=1;
		else
			bin.data()[8+5*i]=0;
	}
	e->Binary=bin;
}

Kdb3Database::StdEntry* Kdb3Database::getEntry(const KpxUuid& uuid){
	for(int i=0; i<Entries.size();i++)
		if(Entries[i].Uuid==uuid)return &Entries[i];
	return NULL;
}

Kdb3Database::StdGroup* Kdb3Database::getGroup(quint32 Id){
	for(int i=0; i<Groups.size();i++)
		if(Groups[i].Id==Id)return &Groups[i];
	return NULL;
}


//! Extracts one entry from raw decrypted data.
bool Kdb3Database::readEntryField(StdEntry* entry, quint16 FieldType, quint32 FieldSize, quint8 *pData){
switch(FieldType)
	{
	case 0x0000:
		// Ignore field
		break;
	case 0x0001:
		entry->Uuid=KpxUuid(pData);
		break;
	case 0x0002:
		memcpyFromLEnd32(&entry->GroupId, (char*)pData);
		break;
	case 0x0003:
		memcpyFromLEnd32(&entry->Image, (char*)pData);
		break;
	case 0x0004:
		entry->Title=QString::fromUtf8((char*)pData);
		break;
	case 0x0005:
		entry->Url=QString::fromUtf8((char*)pData);
		break;
	case 0x0006:
		entry->Username=QString::fromUtf8((char*)pData);
		break;
	case 0x0007:{
		QString s=QString::fromUtf8((char*)pData);
		entry->Password.setString(s,true);
		break;}
	case 0x0008:
		entry->Comment=QString::fromUtf8((char*)pData);
		break;
	case 0x0009:
		entry->Creation=dateFromPackedStruct5(pData);
		break;
	case 0x000A:
		entry->LastMod=dateFromPackedStruct5(pData);
		break;
	case 0x000B:
		entry->LastAccess=dateFromPackedStruct5(pData);
		break;
	case 0x000C:
		entry->Expire=dateFromPackedStruct5(pData);
		break;
	case 0x000D:
		entry->BinaryDesc=QString::fromUtf8((char*)pData);
		break;
	case 0x000E:
		if(FieldSize != 0)
			entry->Binary=QByteArray((char*)pData,FieldSize);
		else
			entry->Binary=QByteArray();
		break;
	case 0xFFFF:
		break;
	default:
		return false;
	}
	return true;
}

//! Extracts one group from raw decrypted data.
bool Kdb3Database::readGroupField(StdGroup* group,QList<quint32>& Levels,quint16 FieldType, quint8 *pData)
{
	switch(FieldType)
	{
	case 0x0000:
		// Ignore field
		break;
	case 0x0001:
		memcpyFromLEnd32(&group->Id, (char*)pData);
		break;
	case 0x0002:
		group->Title=QString::fromUtf8((char*)pData);
		break;
	case 0x0003: //not longer used by KeePassX but part of the KDB format
		break;
	case 0x0004: //not longer used by KeePassX but part of the KDB format
		break;
	case 0x0005: //not longer used by KeePassX but part of the KDB format
		break;
	case 0x0006: //not longer used by KeePassX but part of the KDB format
		break;
	case 0x0007:
		memcpyFromLEnd32(&group->Image, (char*)pData);
		break;
	case 0x0008:
		quint16 Level;
		memcpyFromLEnd16(&Level, (char*)pData);
		Levels.append(Level);
		break;
	case 0x0009:
		 //not used by KeePassX but part of the KDB format
		 //memcpyFromLEnd32(&Flags, (char*)pData);
		break;
	case 0xFFFF:
		break;
	default:
		return false; // Field unsupported
	}

	return true; // Field supported
}

bool Kdb3Database::createGroupTree(QList<quint32>& Levels){
	if(Levels[0]!=0) return false;
	//find the parent for every group
	for(int i=0;i<Groups.size();i++){
		if(Levels[i]==0){
			Groups[i].Parent=&RootGroup;
			Groups[i].Index=RootGroup.Children.size();
			RootGroup.Children.append(&Groups[i]);
			continue;
		}
		int j;
		//the first item with a lower level is the parent
		for(j=i-1;j>=0;j--){
			if(Levels[j]<Levels[i]){
				if(Levels[i]-Levels[j]!=1)return false;
				break;
			}
			if(j==0)return false; //No parent found
		}
		Groups[i].Parent=&Groups[j];
		Groups[i].Index=Groups[j].Children.size();
		Groups[i].Parent->Children.append(&Groups[i]);
	}

	QList<int> EntryIndexCounter;
	for(int i=0;i<Groups.size();i++)EntryIndexCounter << 0;

	for(int e=0;e<Entries.size();e++){
		int groupIndex = -1;
		for(int g=0;g<Groups.size();g++){
			if(Entries[e].GroupId==Groups[g].Id){
				groupIndex = g;
				break;
			}
		}
		
		if (groupIndex == -1) {
			qWarning("Orphaned entry found, assigning to first group");
			for(int g=0;g<Groups.size();g++){
				if(Groups[g].Id == RootGroup.Children[0]->Id){
					groupIndex = g;
					break;
				}
			}
		}
		
		Groups[groupIndex].Entries.append(&Entries[e]);
		Entries[e].Group=&Groups[groupIndex];
		Entries[e].Index=EntryIndexCounter[groupIndex];
		EntryIndexCounter[groupIndex]++;
	}

	return true;
}

void Kdb3Database::createHandles(){
	for(int i=0;i<Groups.size();i++){
		GroupHandles.append(GroupHandle(this));
		Groups[i].Handle=&GroupHandles.back();
		GroupHandles.back().Group=&Groups[i];
	}
	for(int i=0;i<Entries.size();i++){
		EntryHandles.append(EntryHandle(this));
		Entries[i].Handle=&EntryHandles.back();
		EntryHandles.back().Entry=&Entries[i];
	}
}

void Kdb3Database::restoreGroupTreeState(){
// TODO (Marko Koschak) check if this function is used somewhere
    switch (config->groupTreeState()){
		case KpxConfig::RestoreLast:
			for(int i=0;i<Groups.size();i++){
				if(TreeStateMetaStream.contains(Groups[i].Id))
					Groups[i].IsExpanded=TreeStateMetaStream.value(Groups[i].Id);
			}
			break;

		case KpxConfig::ExpandAll:
			for(int i=0;i<Groups.size();i++)
				Groups[i].IsExpanded=true;
			break;
		
		case KpxConfig::DoNothing:
			break;
	}
}

bool Kdb3Database::load(QString identifier, bool readOnly){
	return loadReal(identifier, readOnly, false);
}

#define LOAD_RETURN_CLEANUP \
	delete File; \
	File = NULL; \
	delete[] buffer; \
	return false;

bool Kdb3Database::loadReal(QString filename, bool readOnly, bool differentEncoding) {
	File = new QFile(filename);
	if (readOnly) {
		if(!File->open(QIODevice::ReadOnly)){
			error=tr("Could not open file.");
			delete File;
			File = NULL;
			return false;
		}
	}
	else {
		if(!File->open(QIODevice::ReadWrite)){
			if(!File->open(QIODevice::ReadOnly)){
				error=tr("Could not open file.");
				delete File;
				File = NULL;
				return false;
			}
			else{
				readOnly = true;
			}
		}
	}
	
	openedReadOnly = readOnly;
	
	unsigned long total_size,crypto_size;
	quint32 Signature1,Signature2,Version,NumGroups,NumEntries,Flags;
	quint8 FinalRandomSeed[16];
	quint8 ContentsHash[32];
	quint8 EncryptionIV[16];
	
	total_size=File->size();
	char* buffer = new char[total_size];
	File->read(buffer,total_size);
	
	if(total_size < DB_HEADER_SIZE){
		error=tr("Unexpected file size (DB_TOTAL_SIZE < DB_HEADER_SIZE)");
		LOAD_RETURN_CLEANUP
	}
	
	memcpyFromLEnd32(&Signature1,buffer);
	memcpyFromLEnd32(&Signature2,buffer+4);
	memcpyFromLEnd32(&Flags,buffer+8);
	memcpyFromLEnd32(&Version,buffer+12);
	memcpy(FinalRandomSeed,buffer+16,16);
	memcpy(EncryptionIV,buffer+32,16);
	memcpyFromLEnd32(&NumGroups,buffer+48);
	memcpyFromLEnd32(&NumEntries,buffer+52);
	memcpy(ContentsHash,buffer+56,32);
	memcpy(TransfRandomSeed,buffer+88,32);
	memcpyFromLEnd32(&KeyTransfRounds,buffer+120);
	
	if((Signature1!=PWM_DBSIG_1) || (Signature2!=PWM_DBSIG_2)){
		error=tr("Wrong Signature");
		LOAD_RETURN_CLEANUP
	}
	
	if((Version & 0xFFFFFF00) != (PWM_DBVER_DW & 0xFFFFFF00)){
		error=tr("Unsupported File Version.");
		LOAD_RETURN_CLEANUP
	}
	
	if (Flags & PWM_FLAG_RIJNDAEL)
		Algorithm = Rijndael_Cipher;
	else if (Flags & PWM_FLAG_TWOFISH)
		Algorithm = Twofish_Cipher;
	else{
		error=tr("Unknown Encryption Algorithm.");
		LOAD_RETURN_CLEANUP
	}
	
	RawMasterKey.unlock();
	MasterKey.unlock();
	KeyTransform::transform(*RawMasterKey,*MasterKey,TransfRandomSeed,KeyTransfRounds);
	
	quint8 FinalKey[32];
	
	SHA256 sha;
	sha.update(FinalRandomSeed,16);
	sha.update(*MasterKey,32);
	sha.finish(FinalKey);
	
	RawMasterKey.lock();
	MasterKey.lock();
	
	if(Algorithm == Rijndael_Cipher){
		AESdecrypt aes;
		aes.key256(FinalKey);
		aes.cbc_decrypt((unsigned char*)buffer+DB_HEADER_SIZE,(unsigned char*)buffer+DB_HEADER_SIZE,total_size-DB_HEADER_SIZE,(unsigned char*)EncryptionIV);
		crypto_size=total_size-((quint8*)buffer)[total_size-1]-DB_HEADER_SIZE;
	}
	else if(Algorithm == Twofish_Cipher){
		CTwofish twofish;
		if (twofish.init(FinalKey, 32, EncryptionIV) != true){
			error=tr("Unable to initialize the twofish algorithm.");
			LOAD_RETURN_CLEANUP
		}
		crypto_size = (unsigned long)twofish.padDecrypt((quint8 *)buffer + DB_HEADER_SIZE,
		total_size - DB_HEADER_SIZE, (quint8 *)buffer + DB_HEADER_SIZE);
	}
	else{
		error=tr("Unknown encryption algorithm.");
		LOAD_RETURN_CLEANUP
	}
	
	if ((crypto_size > 2147483446) || (!crypto_size && NumGroups)){
        error=tr("Decryption failed. The password is wrong or the file is damaged.");
		KeyError=true;
		LOAD_RETURN_CLEANUP
	}
	SHA256::hashBuffer(buffer+DB_HEADER_SIZE,FinalKey,crypto_size);
	
	if(memcmp(ContentsHash, FinalKey, 32) != 0){
		if(PotentialEncodingIssueLatin1){
			delete[] buffer;
			delete File;
			File = NULL;
			
			RawMasterKey.copyData(RawMasterKey_Latin1);
			PotentialEncodingIssueLatin1 = false;
			qDebug("Decryption failed. Retrying with Latin-1.");
			return loadReal(filename, readOnly, true); // second try
		}
		if(PotentialEncodingIssueUTF8){
			delete[] buffer;
			delete File;
			File = NULL;
			
			RawMasterKey.copyData(RawMasterKey_UTF8);
			PotentialEncodingIssueUTF8 = false;
			qDebug("Decryption failed. Retrying with UTF-8.");
			return loadReal(filename, readOnly, true); // second/third try
		}
        error=tr("Hash test failed. The password is wrong or the key file is damaged.");
		KeyError=true;
		LOAD_RETURN_CLEANUP
	}
	
	unsigned long pos = DB_HEADER_SIZE;
	quint16 FieldType;
	quint32 FieldSize;
	char* pField;
	bool bRet;
	StdGroup group;
	QList<quint32> Levels;
	RootGroup.Title="$ROOT$";
	RootGroup.Parent=NULL;
	RootGroup.Handle=NULL;
	
	for(unsigned long CurGroup = 0; CurGroup < NumGroups; )
	{
		pField = buffer+pos;
	
		memcpyFromLEnd16(&FieldType, pField);
		pField += 2; pos += 2;
		if (pos >= total_size){
			error=tr("Unexpected error: Offset is out of range.").append(" [G1]");
			LOAD_RETURN_CLEANUP
		}
	
		memcpyFromLEnd32(&FieldSize, pField);
		pField += 4; pos += 4;
		if (pos >= (total_size + FieldSize)){
			error=tr("Unexpected error: Offset is out of range.").append(" [G2]");
			LOAD_RETURN_CLEANUP
		}
	
		bRet = readGroupField(&group,Levels, FieldType, (quint8 *)pField);
		if ((FieldType == 0xFFFF) && (bRet == true)){
			Groups << group;
			CurGroup++; // Now and ONLY now the counter gets increased
		}
		pField += FieldSize;
		pos += FieldSize;
		if (pos >= total_size){
			error=tr("Unexpected error: Offset is out of range.").append(" [G1]");
			LOAD_RETURN_CLEANUP
		}
	}
	
	StdEntry entry;
	
	for (unsigned long CurEntry = 0; CurEntry < NumEntries;)
	{
		pField = buffer+pos;
	
		memcpyFromLEnd16(&FieldType, pField);
		pField += 2; pos += 2;
		if(pos >= total_size){
			error=tr("Unexpected error: Offset is out of range.").append(" [E1]");
			LOAD_RETURN_CLEANUP
		}
	
		memcpyFromLEnd32(&FieldSize, pField);
		pField += 4; pos += 4;
		if (pos >= (total_size + FieldSize)){
			error=tr("Unexpected error: Offset is out of range.").append(" [E2]");
			LOAD_RETURN_CLEANUP
		}
	
		bRet = readEntryField(&entry,FieldType,FieldSize,(quint8*)pField);
	
		if((FieldType == 0xFFFF) && (bRet == true)){
			Entries << entry;
			if(!entry.GroupId)
				qDebug("NULL: %i, '%s'", (int)CurEntry, (char*)entry.Title.toUtf8().data());
			CurEntry++;
		}
	
		pField += FieldSize;
		pos += FieldSize;
		if (pos >= total_size){
			error=tr("Unexpected error: Offset is out of range.").append(" [E3]");
			LOAD_RETURN_CLEANUP
		}
	}
	
	if(!createGroupTree(Levels)){
		error=tr("Invalid group tree.");
		LOAD_RETURN_CLEANUP
	}
	
	delete [] buffer;
	
	hasV4IconMetaStream = false;
	for(int i=0;i<Entries.size();i++){
		if(isMetaStream(Entries[i]) && Entries[i].Comment=="KPX_CUSTOM_ICONS_4"){
			hasV4IconMetaStream = true;
			break;
		}
	}
	
	//Remove the metastreams from the entry list
	for(int i=0;i<Entries.size();i++){
		if(isMetaStream(Entries[i])){
			if(!parseMetaStream(Entries[i]))
				UnknownMetaStreams << Entries[i];
			Entries.removeAt(i);
			i--;
		}
	}
	
	int* EntryIndices=new int[Groups.size()];
	for(int i=0;i<Groups.size();i++)EntryIndices[i]=0;
	
	for(int g=0;g<Groups.size();g++){
		for(int e=0;e<Entries.size();e++){
			if(Entries[e].GroupId==Groups[g].Id){
				Entries[e].Index=EntryIndices[g];
				EntryIndices[g]++;
			}
		}
	}
	delete [] EntryIndices;
	createHandles();
	restoreGroupTreeState();
	
	passwordEncodingChanged = differentEncoding;
	if (differentEncoding) {
		RawMasterKey.copyData(RawMasterKey_CP1252);
		generateMasterKey();
	}
	
	return true;
}

QDateTime Kdb3Database::dateFromPackedStruct5(const unsigned char* pBytes){
	quint32 dw1, dw2, dw3, dw4, dw5;
	dw1 = (quint32)pBytes[0]; dw2 = (quint32)pBytes[1]; dw3 = (quint32)pBytes[2];
	dw4 = (quint32)pBytes[3]; dw5 = (quint32)pBytes[4];
	int y = (dw1 << 6) | (dw2 >> 2);
	int mon = ((dw2 & 0x00000003) << 2) | (dw3 >> 6);
	int d = (dw3 >> 1) & 0x0000001F;
	int h = ((dw3 & 0x00000001) << 4) | (dw4 >> 4);
	int min = ((dw4 & 0x0000000F) << 2) | (dw5 >> 6);
	int s = dw5 & 0x0000003F;
	return QDateTime(QDate(y,mon,d),QTime(h,min,s));
}


void Kdb3Database::dateToPackedStruct5(const QDateTime& d,unsigned char* pBytes){
	pBytes[0] = (quint8)(((quint32)d.date().year() >> 6) & 0x0000003F);
	pBytes[1] = (quint8)((((quint32)d.date().year() & 0x0000003F) << 2) | (((quint32)d.date().month() >> 2) & 0x00000003));
	pBytes[2] = (quint8)((((quint32)d.date().month() & 0x00000003) << 6) | (((quint32)d.date().day() & 0x0000001F) << 1) | (((quint32)d.time().hour() >> 4) & 0x00000001));
	pBytes[3] = (quint8)((((quint32)d.time().hour() & 0x0000000F) << 4) | (((quint32)d.time().minute() >> 2) & 0x0000000F));
	pBytes[4] = (quint8)((((quint32)d.time().minute() & 0x00000003) << 6) | ((quint32)d.time().second() & 0x0000003F));
}


int Kdb3Database::numGroups(){
	return Groups.size();
}

int Kdb3Database::numEntries(){
	return Entries.size();
}

void Kdb3Database::deleteGroup(StdGroup* group){

	while(group->Children.size())
		deleteGroup(group->Children.front());

	QList<IEntryHandle*> GroupEntries;
	GroupEntries=entries(group->Handle);
	deleteEntries(GroupEntries);

	Q_ASSERT(group==group->Parent->Children[group->Index]);
	group->Parent->Children.removeAt(group->Index);
	for(int i=group->Index;i<group->Parent->Children.size();i++){
		group->Parent->Children[i]->Index--;
	}
	group->Handle->invalidate();

	for(int i=0;i<Groups.size();i++){
		if(&Groups[i]==group){
			Groups.removeAt(i);
			break;
		}
	}

}


void Kdb3Database::deleteGroup(IGroupHandle* group){
	deleteGroup(((GroupHandle*)group)->Group);
}

/*
void Kdb3Database::GroupHandle::setIndex(int index){
	quint32 ParentId=((GroupHandle*)parent())->Id;
	int Pos=pDB->getGroupListIndex(this);
	int NewPos=0;
	// Move the group to the new position in the list
	if(ParentId)
		NewPos=pDB->getGroupListIndex((GroupHandle*)parent());
	if(!index){
		if(ParentId)
			pDB->Groups.move(Pos,NewPos+1);
		else
			pDB->Groups.move(Pos,NewPos);
	}
	else{
		for(NewPos;NewPos<pDB->Groups.size();NewPos++){
			if(pDB->Groups[NewPos].ParentId==ParentId && pDB->Groups[NewPos].Index+1==index)
				break;
		}
		//skip the children of the found sibling
		for(NewPos;NewPos<Groups.size();NewPos++){
			if(Groups[NewPos]
			pDB->Groups.move(Pos,NewPos);
		}

	}
	// adjust the indices
	int NewIndex=0;
	for(int i=0;i<pDB->Groups.size();i++){
		if(pDB->Groups[i].ParentId==ParentId){
			pDB->Groups[i].Index=NewIndex;
			NewIndex++;
		}
	}
}
*/

bool Kdb3Database::convHexToBinaryKey(char* HexKey, char* dst){
    QString hex=QString::fromLatin1(HexKey,64);
	for(int i=0; i<64; i+=2){
		bool err;
		quint8 bin;
		bin=hex.mid(i,2).toUInt(&err,16);
		if(!err)return false;
		memcpy(dst+(i/2),&bin,1);
	}
	return true;
}

bool Kdb3Database::setKey(const QString& password,const QString& keyfile){
	if(!password.isEmpty() && !keyfile.isEmpty())
		return setCompositeKey(password,keyfile);
	if(!password.isEmpty())
		return setPasswordKey(password);
	if(!keyfile.isEmpty())
		return setFileKey(keyfile);
	Q_ASSERT(false);
	return false;
}

bool Kdb3Database::setPasswordKey(const QString& Password){
	Q_ASSERT(Password.size());
	QTextCodec* codec=QTextCodec::codecForName("Windows-1252");
	QByteArray Password_CP1252 = codec->fromUnicode(Password);
	RawMasterKey_CP1252.unlock();
	SHA256::hashBuffer(Password_CP1252.data(),*RawMasterKey_CP1252,Password_CP1252.size());
	RawMasterKey_CP1252.lock();
	RawMasterKey.copyData(RawMasterKey_CP1252);
	
	QByteArray Password_Latin1 = Password.toLatin1();
	QByteArray Password_UTF8 = Password.toUtf8();
	PotentialEncodingIssueLatin1 = false;
	PotentialEncodingIssueUTF8 = false;
	
	if (Password_Latin1 != Password_CP1252){
		// KeePassX used Latin-1 encoding for passwords until version 0.3.1
		// but KeePass/Win32 uses Windows Codepage 1252.
		// To stay compatible with databases created with KeePassX <= 0.3.1
		// the loading function gives both encodings a try.
		PotentialEncodingIssueLatin1 = true;
		RawMasterKey_Latin1.unlock();
		SHA256::hashBuffer(Password_Latin1.data(),*RawMasterKey_Latin1,Password_Latin1.size());
		RawMasterKey_Latin1.lock();
	}
	
	if (Password_UTF8 != Password_CP1252){
		// KeePassX used UTF-8 encoding for passwords until version 0.2.2
		// but KeePass/Win32 uses Windows Codepage 1252.
		// To stay compatible with databases created with KeePassX <= 0.2.2
		// the loading function gives both encodings a try.
		PotentialEncodingIssueUTF8 = true;
		RawMasterKey_UTF8.unlock();
		SHA256::hashBuffer(Password_UTF8.data(),*RawMasterKey_UTF8,Password_UTF8.size());
		RawMasterKey_UTF8.lock();
	}
	
	return true;
}

bool Kdb3Database::setFileKey(const QString& filename){
	QFile file(filename);
	if(!file.open(QIODevice::ReadOnly|QIODevice::Unbuffered)){
		error=decodeFileError(file.error());
		return false;
	}
	qint64 FileSize=file.size();
	if(FileSize == 0){
		error=tr("Key file is empty.");
		return false;
	}
	RawMasterKey.unlock();
	if(FileSize == 32){
		if(file.read((char*)(*RawMasterKey),32) != 32){
			error=decodeFileError(file.error());
			RawMasterKey.lock();
			return false;
		}
		RawMasterKey.lock();
		return true;
	}
	if(FileSize == 64){
		char hex[64];
		if(file.read(hex,64) != 64){
			error=decodeFileError(file.error());
			RawMasterKey.lock();
			return false;
		}
		if (convHexToBinaryKey(hex,(char*)(*RawMasterKey))){
			RawMasterKey.lock();
			return true;
		}
	}
	SHA256 sha;
	unsigned char* buffer[2048];
	unsigned long read;
	do {
		read = file.read((char*)buffer,2048);
		if (read != 0)
			sha.update(buffer,read);
	} while (read == 2048);
	sha.finish(*RawMasterKey);
	RawMasterKey.lock();
	return true;
}

bool Kdb3Database::setCompositeKey(const QString& Password,const QString& filename){
	SHA256 sha;
	
	setPasswordKey(Password);
	RawMasterKey.unlock();
	sha.update(*RawMasterKey,32);
	RawMasterKey.lock();
	
	if(!setFileKey(filename))return false;
	RawMasterKey.unlock();
	sha.update(*RawMasterKey,32);
	sha.finish(*RawMasterKey);
	RawMasterKey.lock();
	
	return true;
}

QList<IEntryHandle*> Kdb3Database::entries(){
	QList<IEntryHandle*> handles;
	for(int i=0; i<EntryHandles.size(); i++){
		if(EntryHandles[i].isValid())handles.append(&EntryHandles[i]);
	}
	return handles;
}

QList<IEntryHandle*> Kdb3Database::expiredEntries(){
	QList<IEntryHandle*> handles;
	for(int i=0; i<EntryHandles.size(); i++){
		if(EntryHandles[i].isValid() &&
		  (EntryHandles[i].expire()<=QDateTime::currentDateTime()) &&
		  (EntryHandles[i].expire()!=Date_Never))
			handles.append(&EntryHandles[i]);
	}
	return handles;
}

QList<IEntryHandle*> Kdb3Database::entries(IGroupHandle* Group){
	QList<IEntryHandle*> handles;
	for(int i=0; i<EntryHandles.size(); i++){
		if(EntryHandles[i].isValid() && (EntryHandles[i].group()==Group))
			handles.append(&EntryHandles[i]);
	}
	qSort(handles.begin(),handles.end(),EntryHandleLessThan);

	return handles;
}

QList<IEntryHandle*> Kdb3Database::entriesSortedStd(IGroupHandle* Group){
	QList<IEntryHandle*> handles;
	for(int i=0; i<EntryHandles.size(); i++){
		if(EntryHandles[i].isValid() && (EntryHandles[i].group()==Group))
			handles.append(&EntryHandles[i]);
	}
	qSort(handles.begin(),handles.end(),EntryHandleLessThanStd);

	return handles;
}

void Kdb3Database::deleteEntry(IEntryHandle* entry){
	if(!entry)return;
	int j;
	for(j=0;j<Entries.size();j++){
		if(&Entries[j]==((EntryHandle*)entry)->Entry)
			break;
	}
	Entries[j].Handle->invalidate();
	Entries.removeAt(j);
}

void Kdb3Database::moveEntry(IEntryHandle* entry, IGroupHandle* group){
	((EntryHandle*)entry)->Entry->GroupId=((GroupHandle*)group)->Group->Id;
	((EntryHandle*)entry)->Entry->Group=((GroupHandle*)group)->Group;
}


void Kdb3Database::deleteEntries(QList<IEntryHandle*> entries){
	if(!entries.size())return;
	StdGroup* Group=((EntryHandle*)entries[0])->Entry->Group;
	for(int i=0;i<entries.size();i++){
		int j;
		for(j=0;j<Entries.size();j++){
			if(&Entries[j]==((EntryHandle*)entries[i])->Entry)
				break;
		}
		Group->Children.removeAt(Entries[j].Index);
		Entries[j].Handle->invalidate();
		Entries.removeAt(j);
	}

	for(int i=0;i<Group->Children.size();i++){
		Group->Children[i]->Index=i;
	}
};

QList<IGroupHandle*> Kdb3Database::groups(){
	QList<IGroupHandle*> handles;
	for(int i=0; i<GroupHandles.size(); i++){
		if(GroupHandles[i].isValid())handles.append(&GroupHandles[i]);
	}
	return handles;
}

quint32 Kdb3Database::getNewGroupId(){
	quint32 id;
	bool used;
	do{
		used=false;
		randomize(&id,4);
		if(!id)continue; //group IDs must not be 0
		for(int j=0;j<Groups.size();j++){
			if(Groups[j].Id==id){
				used=true;
				break;
			}
		}
	} while(used);
	return id;
}

IGroupHandle* Kdb3Database::addGroup(const CGroup* group,IGroupHandle* ParentHandle){
	GroupHandles.append(GroupHandle(this));
	Groups.append(*group);
	Groups.back().Id=getNewGroupId();
	Groups.back().Handle=&GroupHandles.back();
	GroupHandles.back().Group=&Groups.back();
	if(ParentHandle){
		Groups.back().Parent=((GroupHandle*)ParentHandle)->Group;
		Groups.back().Index=Groups.back().Parent->Children.size();
		Groups.back().Parent->Children.append(&Groups.back());
	}
	else{
		// Insert to root group. Try to keep Backup group at the end.
		Groups.back().Parent=&RootGroup;
		Groups.back().Index=RootGroup.Children.size();
		int position = RootGroup.Children.size();
		if (group->Title!="Backup" && !RootGroup.Children.isEmpty() && RootGroup.Children.last()->Title=="Backup"){
			RootGroup.Children.last()->Index = Groups.back().Index;
			Groups.back().Index--;
			position--;
		}
		RootGroup.Children.insert(position, &Groups.back());
	}
	return &GroupHandles.back();
}

IGroupHandle* Kdb3Database::backupGroup(bool create){
	IGroupHandle* group = NULL;
	QList<IGroupHandle*> allGroups = groups();
	for (int i=0; i<allGroups.size(); i++){
		if (allGroups[i]->parent()==NULL && allGroups[i]->title()=="Backup"){
			group = allGroups[i];
			break;
		}
	}
	
	if (group==NULL && create){
		CGroup newGroup;
		newGroup.Title = "Backup";
		newGroup.Image = 4;
		group = addGroup(&newGroup, NULL);
	}
	
	return group;
}

Kdb3Database::StdEntry::StdEntry(){
	Handle = NULL;
	Group = NULL;
}

Kdb3Database::StdGroup::StdGroup(){
	Index=0;
	Id=0;
	Parent=NULL;
	Handle=NULL;
}

Kdb3Database::StdGroup::StdGroup(const CGroup& other){
	Index=0;
	Id=other.Id;
	Image=other.Image;
	Title=other.Title;
	Parent=NULL;
	Handle=NULL;
}

void Kdb3Database::EntryHandle::setTitle(const QString& Title){Entry->Title=Title; }
void Kdb3Database::EntryHandle::setUsername(const QString& Username){Entry->Username=Username;}
void Kdb3Database::EntryHandle::setUrl(const QString& Url){Entry->Url=Url;}
void Kdb3Database::EntryHandle::setPassword(const SecString& Password){Entry->Password=Password;}
void Kdb3Database::EntryHandle::setExpire(const KpxDateTime& s){Entry->Expire=s;}
void Kdb3Database::EntryHandle::setCreation(const KpxDateTime& s){Entry->Creation=s;}
void Kdb3Database::EntryHandle::setLastAccess(const KpxDateTime& s){Entry->LastAccess=s;}
void Kdb3Database::EntryHandle::setLastMod(const KpxDateTime& s){Entry->LastMod=s;}
void Kdb3Database::EntryHandle::setBinaryDesc(const QString& s){Entry->BinaryDesc=s;}
void Kdb3Database::EntryHandle::setComment(const QString& s){Entry->Comment=s;}
void Kdb3Database::EntryHandle::setBinary(const QByteArray& s){Entry->Binary=s;}
void Kdb3Database::EntryHandle::setImage(const quint32& s){Entry->Image=s;}
KpxUuid	Kdb3Database::EntryHandle::uuid()const{return Entry->Uuid;}
IGroupHandle* Kdb3Database::EntryHandle::group()const{return Entry->Group->Handle;}
quint32	Kdb3Database::EntryHandle::image()const{return Entry->Image;}
QString	Kdb3Database::EntryHandle::title()const{return Entry->Title;}
QString	Kdb3Database::EntryHandle::url()const{return Entry->Url;}
QString	Kdb3Database::EntryHandle::username()const{return Entry->Username;}
SecString Kdb3Database::EntryHandle::password()const{return Entry->Password;}
QString	Kdb3Database::EntryHandle::comment()const{return Entry->Comment;}
QString	Kdb3Database::EntryHandle::binaryDesc()const{return Entry->BinaryDesc;}
KpxDateTime	Kdb3Database::EntryHandle::creation()const{return Entry->Creation;}
KpxDateTime	Kdb3Database::EntryHandle::lastMod()const{return Entry->LastMod;}
KpxDateTime	Kdb3Database::EntryHandle::lastAccess()const{return Entry->LastAccess;}
KpxDateTime	Kdb3Database::EntryHandle::expire()const{return Entry->Expire;}
QByteArray Kdb3Database::EntryHandle::binary()const{return Entry->Binary;}
quint32 Kdb3Database::EntryHandle::binarySize()const{return Entry->Binary.size();}

QString Kdb3Database::EntryHandle::friendlySize()const
{
    quint32 binsize = binarySize();
    QString unit;
    uint    faktor;
    int     prec;

    if (binsize < 1024)
    {
        unit = tr("Bytes");
        faktor = 1;
        prec = 0;
    }
    else
    {
        if (binsize < 1048576)
        {
            unit = tr("KiB");
            faktor = 1024;
        }
        else
            if (binsize < 1073741824)
            {
                unit = tr("MiB");
                faktor = 1048576;
            }
            else
            {
                unit = tr("GiB");
                faktor = 1073741824;
            }
        prec = 1;
    }
    return (QString::number((float)binsize / (float)faktor, 'f', prec) + " " + unit);
}

int Kdb3Database::EntryHandle::visualIndex()const{return Entry->Index;}
void Kdb3Database::EntryHandle::setVisualIndexDirectly(int i){Entry->Index=i;}
bool Kdb3Database::EntryHandle::isValid()const{return valid;}

CEntry Kdb3Database::EntryHandle::data()const{
	return *this->Entry;
}

void Kdb3Database::EntryHandle::setVisualIndex(int index){
	QList<IEntryHandle*>Entries=pDB->entries(Entry->Group->Handle);
	Entries.move(visualIndex(),index);
	for(int i=0;i<Entries.size();i++){
		dynamic_cast<Kdb3Database::EntryHandle*>(Entries[i])->Entry->Index=index;
	}
}

Kdb3Database::EntryHandle::EntryHandle(Kdb3Database* db){
	pDB=db;
	valid=true;
	Entry=NULL;
}


bool Kdb3Database::GroupHandle::isValid(){return valid;}
QString Kdb3Database::GroupHandle::title()const{return Group->Title;}
quint32	Kdb3Database::GroupHandle::image(){return Group->Image;}
int Kdb3Database::GroupHandle::index(){return Group->Index;}
void Kdb3Database::GroupHandle::setTitle(const QString& Title){Group->Title=Title;}
void Kdb3Database::GroupHandle::setExpanded(bool IsExpanded){Group->IsExpanded=IsExpanded;}
bool Kdb3Database::GroupHandle::expanded(){return Group->IsExpanded;}
void Kdb3Database::GroupHandle::setImage(const quint32& New){Group->Image=New;}


Kdb3Database::GroupHandle::GroupHandle(Kdb3Database* db){
	pDB=db;
	valid=true;
	Group=NULL;
}

IGroupHandle* Kdb3Database::GroupHandle::parent(){
	return (IGroupHandle*)Group->Parent->Handle;
}

int Kdb3Database::GroupHandle::level(){
	int i=0;
	StdGroup* group=Group;
	while(group->Parent){
		group=group->Parent;
		i++;
	}
	i--;
	return i;
}


QList<IGroupHandle*> Kdb3Database::GroupHandle::children(){
	QList<IGroupHandle*> children;
	for(int i=0; i < Group->Children.size(); i++){
		children.append(Group->Children[i]->Handle);
	}
	return children;
}


void memcpyFromLEnd32(quint32* dst,const char* src){
	if (QSysInfo::ByteOrder==QSysInfo::BigEndian){
		memcpy(((char*)dst)+3,src+0,1);
		memcpy(((char*)dst)+2,src+1,1);
		memcpy(((char*)dst)+1,src+2,1);
		memcpy(((char*)dst)+0,src+3,1);
	}
	else{
		memcpy(dst,src,4);
	}
}

void memcpyFromLEnd16(quint16* dst,const char* src){
	if (QSysInfo::ByteOrder==QSysInfo::BigEndian){
		memcpy(((char*)dst)+1,src+0,1);
		memcpy(((char*)dst)+0,src+1,1);
	}
	else{
		memcpy(dst,src,2);
	}
}

void memcpyToLEnd32(char* dst,const quint32* src){
	if (QSysInfo::ByteOrder==QSysInfo::BigEndian){
		memcpy(dst+0,((char*)src)+3,1);
		memcpy(dst+1,((char*)src)+2,1);
		memcpy(dst+2,((char*)src)+1,1);
		memcpy(dst+3,((char*)src)+0,1);
	}
	else{
		memcpy(dst,src,4);
	}
}

void memcpyToLEnd16(char* dst,const quint16* src){
	if (QSysInfo::ByteOrder==QSysInfo::BigEndian){
		memcpy(dst+0,((char*)src)+1,1);
		memcpy(dst+1,((char*)src)+0,1);
	}
	else{
		memcpy(dst,src,2);
	}
}

bool Kdb3Database::save(){
	if(!Groups.size()){
		error=tr("The database must contain at least one group.");
		return false;
	}
	
	if (!File->isOpen()) {
		if(!File->open(QIODevice::ReadWrite)){
			error=tr("Could not open file.");
			return false;
		}
	}
	
	if(!(File->openMode() & QIODevice::WriteOnly)){
		error = tr("The database has been opened read-only.");
		return false;
	}

// TODO (Marko Koschak) we need only these functions from backup - others might be deleted
	//Delete old backup entries
	if (config->backup() && config->backupDelete() && config->backupDeleteAfter()>0 && backupGroup()){
		QDateTime time = QDateTime::currentDateTime().addDays(-config->backupDeleteAfter());
		QList<IEntryHandle*> backupEntries = entries(backupGroup());
		for (int i=0; i<backupEntries.size(); i++){
			if (backupEntries[i]->lastMod()<time)
				deleteEntry(backupEntries[i]);
		}
	}
	
	quint32 NumGroups,NumEntries,Signature1,Signature2,Flags,Version;
	quint8 FinalRandomSeed[16];
	quint8 ContentsHash[32];
	quint8 EncryptionIV[16];

	unsigned int FileSize;

	QList<StdEntry> MetaStreams;
	MetaStreams << StdEntry();
	createCustomIconsMetaStream(&MetaStreams.back());
	MetaStreams << StdEntry();
	createGroupTreeStateMetaStream(&MetaStreams.back());

	FileSize=DB_HEADER_SIZE;
	// Get the size of all groups (94 Byte + length of the name string)
	for(int i = 0; i < Groups.size(); i++){
		FileSize += 94 + Groups[i].Title.toUtf8().length()+1;
	}
	// Get the size of all entries
	for(int i = 0; i < Entries.size(); i++){
		FileSize
			+= 134
			+Entries[i].Title.toUtf8().length()+1
			+Entries[i].Username.toUtf8().length()+1
			+Entries[i].Url.toUtf8().length()+1
			+Entries[i].Password.length()+1
			+Entries[i].Comment.toUtf8().length()+1
			+Entries[i].BinaryDesc.toUtf8().length()+1
			+Entries[i].Binary.length();
	}

	for(int i=0; i < UnknownMetaStreams.size(); i++){
		FileSize
			+=165
			+UnknownMetaStreams[i].Comment.toUtf8().length()+1
			+UnknownMetaStreams[i].Binary.length();
	}

	for(int i=0; i < MetaStreams.size(); i++){
		FileSize
				+=165
				+MetaStreams[i].Comment.toUtf8().length()+1
				+MetaStreams[i].Binary.length();
	}


	// Round up filesize to 16-byte boundary for Rijndael/Twofish
	FileSize = (FileSize + 16) - (FileSize % 16);
	char* buffer=new char[FileSize+16];

	Signature1 = PWM_DBSIG_1;
	Signature2 = PWM_DBSIG_2;
	Flags = PWM_FLAG_SHA2;
	if(Algorithm == Rijndael_Cipher) Flags |= PWM_FLAG_RIJNDAEL;
	else if(Algorithm == Twofish_Cipher) Flags |= PWM_FLAG_TWOFISH;
	Version = PWM_DBVER_DW;
	NumGroups = Groups.size();
	NumEntries = Entries.size()+UnknownMetaStreams.size()+MetaStreams.size();

	QList<StdEntry> saveEntries = Entries;
	qSort(saveEntries.begin(),saveEntries.end(),StdEntryLessThan);

	randomize(FinalRandomSeed,16);
	randomize(EncryptionIV,16);

	unsigned int pos=DB_HEADER_SIZE; // Skip the header, it will be written later

	serializeGroups(buffer,pos);
	serializeEntries(saveEntries,buffer,pos);
	serializeEntries(UnknownMetaStreams,buffer,pos);
	serializeEntries(MetaStreams,buffer,pos);
	SHA256::hashBuffer(buffer+DB_HEADER_SIZE,ContentsHash,pos-DB_HEADER_SIZE);
	memcpyToLEnd32(buffer,&Signature1);
	memcpyToLEnd32(buffer+4,&Signature2);
	memcpyToLEnd32(buffer+8,&Flags);
	memcpyToLEnd32(buffer+12,&Version);
	memcpy(buffer+16,FinalRandomSeed,16);
	memcpy(buffer+32,EncryptionIV,16);
	memcpyToLEnd32(buffer+48,&NumGroups);
	memcpyToLEnd32(buffer+52,&NumEntries);
	memcpy(buffer+56,ContentsHash,32);
	memcpy(buffer+88,TransfRandomSeed,32);
	memcpyToLEnd32(buffer+120,&KeyTransfRounds);
	quint8 FinalKey[32];

	SHA256 sha;
	sha.update(FinalRandomSeed,16);
	MasterKey.unlock();
	sha.update(*MasterKey,32);
	MasterKey.lock();
	sha.finish(FinalKey);

	unsigned long EncryptedPartSize;

	if(Algorithm == Rijndael_Cipher){
		EncryptedPartSize=((pos-DB_HEADER_SIZE)/16+1)*16;
		quint8 PadLen=EncryptedPartSize-(pos-DB_HEADER_SIZE);
		for(int i=0;i<PadLen;i++)
			((quint8*)buffer)[DB_HEADER_SIZE+EncryptedPartSize-1-i]=PadLen;
		AESencrypt aes;
		aes.key256(FinalKey);
		aes.cbc_encrypt((unsigned char*)buffer+DB_HEADER_SIZE,(unsigned char*)buffer+DB_HEADER_SIZE,EncryptedPartSize,(unsigned char*)EncryptionIV);
	}
	else{ // Algorithm == Twofish_Cipher
		CTwofish twofish;
		if(twofish.init(FinalKey, 32, EncryptionIV) == false){
			UNEXP_ERROR
			delete [] buffer;
			return false;
		}
		EncryptedPartSize = (unsigned long)twofish.padEncrypt((quint8*)buffer+DB_HEADER_SIZE,
			pos - DB_HEADER_SIZE,(quint8*)buffer+DB_HEADER_SIZE);
	}
	if((EncryptedPartSize > (0xFFFFFFE - 202)) || (!EncryptedPartSize && Groups.size())){
		UNEXP_ERROR
		delete [] buffer;
		return false;
	}
	
	int size = EncryptedPartSize+DB_HEADER_SIZE;
	
	if (!saveFileTransactional(buffer, size)) {
		error=decodeFileError(File->error());
		delete [] buffer;
		return false;
	}

	delete [] buffer;
	//if(SearchGroupID!=-1)Groups.push_back(SearchGroup);
	return true;
}

bool Kdb3Database::saveFileTransactional(char* buffer, int size) {
	QString orgFilename = File->fileName();
	QFile* tmpFile = new QFile(orgFilename + ".tmp");
	if (!tmpFile->open(QIODevice::WriteOnly|QIODevice::Truncate)) {
		tmpFile->remove();
		delete tmpFile;
		return false;
	}
	if (tmpFile->write(buffer,size) != size) {
		tmpFile->remove();
		delete tmpFile;
		return false;
	}
	if (!syncFile(tmpFile))
		qWarning("Unable to flush file to disk");
	tmpFile->close();
	if (!File->remove()) {
		delete tmpFile;
		return false;
	}
	delete File;
	File = NULL;
	if (!tmpFile->rename(orgFilename)) {
		delete tmpFile;
		File = new QFile(orgFilename);
		return false;
	}
	File = tmpFile;
	if (!tmpFile->open(QIODevice::ReadWrite)) {
		delete tmpFile;
		return false;
	}
	
	return true;
}

void Kdb3Database::createCustomIconsMetaStream(StdEntry* e){
	/* Rev 3 */
	e->BinaryDesc="bin-stream";
	e->Title="Meta-Info";
	e->Username="SYSTEM";
	e->Comment="KPX_CUSTOM_ICONS_4";
	e->Url="$";
	if(Groups.size())e->GroupId=Groups[0].Id;
	int Size=12;
	quint32 NumEntries=0;
	for(quint32 i=0;i<Entries.size();i++){
		if (Entries[i].Image>=BUILTIN_ICONS)
			NumEntries++;
	}
	quint32 NumGroups=0;
	for(quint32 i=0;i<Groups.size();i++){
		if (Groups[i].Image>=BUILTIN_ICONS)
			NumGroups++;
	}
	Size+=8*NumGroups+20*NumEntries;
	Size+=CustomIcons.size()*1000; // 1KB
	e->Binary.reserve(Size);
	e->Binary.resize(12);
	quint32 NumIcons=CustomIcons.size();

	memcpyToLEnd32(e->Binary.data(),&NumIcons);
	memcpyToLEnd32(e->Binary.data()+4,&NumEntries);
	memcpyToLEnd32(e->Binary.data()+8,&NumGroups);
	for(int i=0;i<CustomIcons.size();i++){
		quint32 ImgSize;
		char ImgSizeBin[4];
		QByteArray png;
		png.reserve(1000);
		QBuffer buffer(&png);
		CustomIcons[i].save(&buffer,"PNG",0);
		ImgSize=png.size();
		memcpyToLEnd32(ImgSizeBin,&ImgSize);
		e->Binary.append(QByteArray::fromRawData(ImgSizeBin,4));
		e->Binary.append(png);
	}
	
	for(quint32 i=0;i<Entries.size();i++){
		if (Entries[i].Image>=BUILTIN_ICONS){
			char Bin[20];
			Entries[i].Uuid.toRaw(Bin);
			quint32 id=Entries[i].Image-BUILTIN_ICONS;
			memcpyToLEnd32(Bin+16,&id);
			e->Binary.append(QByteArray::fromRawData(Bin,20));
		}
	}
	for(quint32 i=0;i<Groups.size();i++){
		if (Groups[i].Image>=BUILTIN_ICONS){
			char Bin[8];
			memcpyToLEnd32(Bin,&Groups[i].Id);
			quint32 id=Groups[i].Image-BUILTIN_ICONS;
			memcpyToLEnd32(Bin+4,&id);
			e->Binary.append(QByteArray::fromRawData(Bin,8));
		}
	}
}


QList<IGroupHandle*> Kdb3Database::sortedGroups(){
    QList<IGroupHandle*> sortedGroups;
    // first sort the list of all children from the root group
    QList<IGroupHandle*> sortedChildren;
    for(int i=0;i<RootGroup.Children.size();i++){
        sortedChildren << RootGroup.Children[i]->Handle;
    }
    qDebug() << "befor sort: " << sortedChildren;
    qSort(sortedChildren.begin(),sortedChildren.end(),GroupHandleLessThanStd);
    qDebug() << "after sort: " << sortedChildren;
    // now go through the list of sorted children
    for(int i=0;i<sortedChildren.size();i++){
        sortedGroups << sortedChildren[i];
        appendChildrenToGroupListSorted(sortedGroups,sortedChildren[i]);
    }
    return sortedGroups;
}


void Kdb3Database::appendChildrenToGroupListSorted(QList<IGroupHandle*>& list,IGroupHandle* group){
    // first sort the list of all children
    QList<IGroupHandle*> sortedChildren;
    for(int i=0;i<group->children().size();i++){
        sortedChildren << group->children()[i];
    }
    qSort(sortedChildren.begin(),sortedChildren.end(),GroupHandleLessThanStd);
    // now go through the list of sorted children
    for(int i=0;i<sortedChildren.size();i++){
        list << sortedChildren[i];
        appendChildrenToGroupListSorted(list,sortedChildren[i]);
    }
}


void Kdb3Database::appendChildrenToGroupList(QList<IGroupHandle*>& list,StdGroup& group){
    for(int i=0;i<group.Children.size();i++){
        list << group.Children[i]->Handle;
        appendChildrenToGroupList(list,*group.Children[i]);
    }
}


void Kdb3Database::appendChildrenToGroupList(QList<StdGroup*>& list,StdGroup& group){
	for(int i=0;i<group.Children.size();i++){
		list << group.Children[i];
		appendChildrenToGroupList(list,*group.Children[i]);
	}
}


void Kdb3Database::serializeGroups(char* buffer,unsigned int& pos){
	quint16 FieldType;
	quint32 FieldSize;
	quint32 Flags=0; //unused
	QList<StdGroup*>SortedGroups;
	appendChildrenToGroupList(SortedGroups,RootGroup);

	for(int i=0; i < SortedGroups.size(); i++){
		unsigned char Date[5];
		dateToPackedStruct5(Date_Never,Date);
		quint16 Level=0;
		StdGroup* group=SortedGroups[i];
		while(group->Parent){
			Level++;
			group=group->Parent;
		}
		Level--;

		FieldType = 0x0001; FieldSize = 4;
		memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		memcpyToLEnd32(buffer+pos, &SortedGroups[i]->Id); pos += 4;

		FieldType = 0x0002; FieldSize = SortedGroups[i]->Title.toUtf8().length() + 1;
		memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		memcpy(buffer+pos, SortedGroups[i]->Title.toUtf8(),FieldSize); pos += FieldSize;

		FieldType = 0x0003; FieldSize = 5; //Creation
		memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		memcpy(buffer+pos, Date,5); pos+=5;

		FieldType = 0x0004; FieldSize = 5; //LastMod
		memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		memcpy(buffer+pos, Date,5); pos+=5;

		FieldType = 0x0005; FieldSize = 5; //LastAccess
		memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		memcpy(buffer+pos, Date,5); pos+=5;

		FieldType = 0x0006; FieldSize = 5; //Expire
		memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		memcpy(buffer+pos, Date,5); pos+=5;

		FieldType = 0x0007; FieldSize = 4;
		memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		memcpyToLEnd32(buffer+pos, &SortedGroups[i]->Image); pos += 4;

		FieldType = 0x0008; FieldSize = 2;
		memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		memcpyToLEnd16(buffer+pos, &Level); pos += 2;

		FieldType = 0x0009; FieldSize = 4;
		memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		memcpyToLEnd32(buffer+pos, &Flags); pos += 4;

		FieldType = 0xFFFF; FieldSize = 0;
		memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
	}

}


void Kdb3Database::serializeEntries(QList<StdEntry>& EntryList,char* buffer,unsigned int& pos){
	 quint16 FieldType;
	 quint32 FieldSize;
	 for(int i = 0; i < EntryList.size(); i++){
		 FieldType = 0x0001; FieldSize = 16;
		 memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		 memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		 EntryList[i].Uuid.toRaw(buffer+pos);		pos += 16;

		 FieldType = 0x0002; FieldSize = 4;
		 memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		 memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		 memcpyToLEnd32(buffer+pos, &EntryList[i].GroupId); pos += 4;

		 FieldType = 0x0003; FieldSize = 4;
		 memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		 memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		 memcpyToLEnd32(buffer+pos,&EntryList[i].Image); pos += 4;


		 FieldType = 0x0004;
		 FieldSize = EntryList[i].Title.toUtf8().length() + 1; // Add terminating NULL character space
		 memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		 memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		 memcpy(buffer+pos, EntryList[i].Title.toUtf8(),FieldSize);  pos += FieldSize;

		 FieldType = 0x0005;
		 FieldSize = EntryList[i].Url.toUtf8().length() + 1; // Add terminating NULL character space
		 memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		 memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		 memcpy(buffer+pos, EntryList[i].Url.toUtf8(),FieldSize);  pos += FieldSize;

		 FieldType = 0x0006;
		 FieldSize = EntryList[i].Username.toUtf8().length() + 1; // Add terminating NULL character space
		 memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		 memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		 memcpy(buffer+pos, EntryList[i].Username.toUtf8(),FieldSize);  pos += FieldSize;

		 FieldType = 0x0007;
		 FieldSize = EntryList[i].Password.length() + 1; // Add terminating NULL character space
		 memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		 memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		 EntryList[i].Password.unlock();
		 memcpy(buffer+pos, EntryList[i].Password.string().toUtf8(),FieldSize);  pos += FieldSize;
		 EntryList[i].Password.lock();

		 FieldType = 0x0008;
		 FieldSize = EntryList[i].Comment.toUtf8().length() + 1; // Add terminating NULL character space
		 memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		 memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		 memcpy(buffer+pos, EntryList[i].Comment.toUtf8(),FieldSize);  pos += FieldSize;

		 FieldType = 0x0009; FieldSize = 5;
		 memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		 memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		 dateToPackedStruct5(EntryList[i].Creation,(unsigned char*)buffer+pos); pos+=5;


		 FieldType = 0x000A; FieldSize = 5;
		 memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		 memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		 dateToPackedStruct5(EntryList[i].LastMod,(unsigned char*)buffer+pos); pos+=5;

		 FieldType = 0x000B; FieldSize = 5;
		 memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		 memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		 dateToPackedStruct5(EntryList[i].LastAccess,(unsigned char*)buffer+pos); pos+=5;

		 FieldType = 0x000C; FieldSize = 5;
		 memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		 memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		 dateToPackedStruct5(EntryList[i].Expire,(unsigned char*)buffer+pos); pos+=5;

		 FieldType = 0x000D;
		 FieldSize = EntryList[i].BinaryDesc.toUtf8().length() + 1; // Add terminating NULL character space
		 memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		 memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		 memcpy(buffer+pos, EntryList[i].BinaryDesc.toUtf8(),FieldSize);  pos += FieldSize;

		 FieldType = 0x000E; FieldSize = EntryList[i].Binary.length();
		 memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		 memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
		 if((!EntryList[i].Binary.isNull()) && (FieldSize != 0))
			 memcpy(buffer+pos, EntryList[i].Binary.data(), FieldSize);
		 pos += FieldSize;

		 FieldType = 0xFFFF; FieldSize = 0;
		 memcpyToLEnd16(buffer+pos, &FieldType); pos += 2;
		 memcpyToLEnd32(buffer+pos, &FieldSize); pos += 4;
	 }
 }

bool Kdb3Database::close(){
	if (File!=NULL)
		delete File;
	return true;
}

void Kdb3Database::create(){
	File=NULL;
	RootGroup.Title="$ROOT$";
	RootGroup.Parent=NULL;
	RootGroup.Handle=NULL;
	Algorithm=Rijndael_Cipher;
	KeyTransfRounds=50000;
	KeyError=false;
}

bool Kdb3Database::isKeyError(){
	if(KeyError){
		KeyError=false;
		return true;
	}
	else
		return false;
}

IEntryHandle* Kdb3Database::cloneEntry(const IEntryHandle* entry){
	StdEntry dolly;
	dolly=*((EntryHandle*)entry)->Entry;
	dolly.Uuid.generate();
	Entries.append(dolly);
	EntryHandles.append(EntryHandle(this));
	EntryHandles.back().Entry=&Entries.back();
	Entries.back().Handle=&EntryHandles.back();
	return &EntryHandles.back();
}

IEntryHandle* Kdb3Database::newEntry(IGroupHandle* group){
	StdEntry Entry;
	Entry.Uuid.generate();
	Entry.Group=((GroupHandle*)group)->Group;
	Entry.GroupId=Entry.Group->Id;
	Entries.append(Entry);
	EntryHandles.append(EntryHandle(this));
	EntryHandles.back().Entry=&Entries.back();
	Entries.back().Handle=&EntryHandles.back();
	return &EntryHandles.back();
}

IEntryHandle* Kdb3Database::addEntry(const CEntry* NewEntry, IGroupHandle* Group){
	StdEntry Entry(*((StdEntry*)NewEntry));
	Entry.Uuid.generate();
	Entry.Group=((GroupHandle*)Group)->Group;
	Entry.GroupId=Entry.Group->Id;
	Entries.append(Entry);
	EntryHandles.append(EntryHandle(this));
	EntryHandles.back().Entry=&Entries.back();
	Entries.back().Handle=&EntryHandles.back();
	return &EntryHandles.back();
}

void Kdb3Database::deleteLastEntry(){
	Entries.removeAt(Entries.size()-1);
	EntryHandles.back().invalidate();
}

bool Kdb3Database::isParent(IGroupHandle* parent, IGroupHandle* child){
	StdGroup* group=((GroupHandle*)child)->Group;
	while(group->Parent!=&RootGroup){
		if(group->Parent==((GroupHandle*)parent)->Group)return true;
		group=group->Parent;
	}
	return false;
}



void Kdb3Database::cleanUpHandles(){}

bool Kdb3Database::searchStringContains(const QString& search, const QString& string,bool Cs, bool RegExp){
	if(RegExp){
		QRegExp exp(search,Cs ? Qt::CaseSensitive : Qt::CaseInsensitive);
		if(string.contains(exp)==0)return false;}
		else
			if(string.contains(search,Cs ? Qt::CaseSensitive : Qt::CaseInsensitive)==0)return false;

		return true;
}

void Kdb3Database::getEntriesRecursive(IGroupHandle* Group, QList<IEntryHandle*>& EntryList){
	EntryList<<entries(Group);
	for(int i=0;i<((GroupHandle*)Group)->Group->Children.size();	i++){
		getEntriesRecursive(((GroupHandle*)Group)->Group->Children[i]->Handle,EntryList);
	}
}

QList<IEntryHandle*> Kdb3Database::search(IGroupHandle* Group,const QString& search, bool CaseSensitive, bool RegExp, bool Recursive,bool* Fields){
	bool fields[6]={true,true,true,false,true,true};
	if(!Fields)
		Fields=fields;
	QList<IEntryHandle*> SearchEntries;
	if(search==QString())return Group ? entries(Group) : entries();
	if(Group){
		if(Recursive)
			getEntriesRecursive(Group,SearchEntries);
		else
			SearchEntries=entries(Group);
	}
	else
		SearchEntries=entries();
	
	IGroupHandle* bGroup = backupGroup();
	
	QList<IEntryHandle*> ResultEntries;
	for(int i=0; i<SearchEntries.size(); i++){
		IGroupHandle* entryGroup = SearchEntries[i]->group();
		while (entryGroup->parent())
			entryGroup = entryGroup->parent();
		if (entryGroup == bGroup)
			continue;
		
		bool match=false;
		if(Fields[0])match=match||searchStringContains(search,SearchEntries[i]->title(),CaseSensitive,RegExp);
		if(Fields[1])match=match||searchStringContains(search,SearchEntries[i]->username(),CaseSensitive,RegExp);
		if(Fields[2])match=match||searchStringContains(search,SearchEntries[i]->url(),CaseSensitive,RegExp);
		SecString Password=SearchEntries[i]->password();
		Password.unlock();
		if(Fields[3])match=match||searchStringContains(search,Password.string(),CaseSensitive,RegExp);
		Password.lock();
		if(Fields[4])match=match||searchStringContains(search,SearchEntries[i]->comment(),CaseSensitive,RegExp);
		if(Fields[5])match=match||searchStringContains(search,SearchEntries[i]->binaryDesc(),CaseSensitive,RegExp);
		if(match)
			ResultEntries << SearchEntries[i];
	}

	return ResultEntries;
}

void Kdb3Database::rebuildIndices(QList<StdGroup*>& list){
	for(int i=0;i<list.size();i++){
		list[i]->Index=i;
	}
}


void Kdb3Database::moveGroup(IGroupHandle* groupHandle,IGroupHandle* NewParent,int Pos){
	StdGroup* Parent;
	StdGroup* Group=((GroupHandle*)groupHandle)->Group;
	if(NewParent)
		Parent=((GroupHandle*)NewParent)->Group;
	else
		Parent=&RootGroup;
	Group->Parent->Children.removeAt(Group->Index);
	rebuildIndices(Group->Parent->Children);
	Group->Parent=Parent;
	if(Pos==-1){
		Parent->Children.append(Group);
	}
	else
	{
		Q_ASSERT(Parent->Children.size()>=Pos);
		Parent->Children.insert(Pos,Group);
	}
	rebuildIndices(Parent->Children);
}

bool Kdb3Database::changeFile(const QString& filename){
	QFile* tmpFile = new QFile(filename);
	if(!tmpFile->open(QIODevice::ReadWrite)){
		error = decodeFileError(File->error());
		delete tmpFile;
		return false;
	}
	
	if (File)
		delete File;
	
	File = tmpFile;

	return true;
}

void Kdb3Database::generateMasterKey(){
	randomize(TransfRandomSeed,32);
	RawMasterKey.unlock();
	MasterKey.unlock();
	KeyTransform::transform(*RawMasterKey,*MasterKey,TransfRandomSeed,KeyTransfRounds);
	RawMasterKey.lock();
	MasterKey.lock();
}

/*void Kdb3Database::copyTree(Kdb3Database* db, GroupHandle* orgGroup, IGroupHandle* parent) {
	IGroupHandle* newParent = db->addGroup(orgGroup->Group, parent);
	
	QList<IEntryHandle*> entryList = entries(orgGroup);
	for (int i=0; i<entryList.size(); i++) {
		EntryHandle* entry = static_cast<EntryHandle*>(entryList[i]);
		db->addEntry(entry->Entry, newParent);
	}
	
	QList<IGroupHandle*> children = orgGroup->children();
	for (int i=0; i<children.size(); i++) {
		GroupHandle* child = static_cast<GroupHandle*>(children[i]);
		copyTree(db, child, newParent);
	}
}

IDatabase* Kdb3Database::groupToNewDb(IGroupHandle* group){
	Kdb3Database* db = new Kdb3Database();
	db->create();
	copyTree(db, static_cast<GroupHandle*>(group), NULL);
	
	db->changeFile("/ramtmp/test.kdb");
	if (!db->save())
		qWarning("%s", CSTR(db->error));
	
	return db;
}*/


void KeyTransform::transform(quint8* src, quint8* dst, quint8* KeySeed, int rounds){
	KeyTransform* ktLeft = new KeyTransform(&src[0], &dst[0], KeySeed, rounds);
	KeyTransform* ktRight = new KeyTransform(&src[16], &dst[16], KeySeed, rounds);
	ktLeft->start();
	ktRight->start();
	ktLeft->wait();
	ktRight->wait();
	SHA256::hashBuffer(dst,dst,32);
	delete ktLeft;
	delete ktRight;
}

KeyTransform::KeyTransform(quint8* pSrc, quint8* pDst, quint8* pKeySeed, int pRounds){
	src = pSrc;
	dst = pDst;
	KeySeed = pKeySeed;
	rounds = pRounds;
}

void KeyTransform::run(){
	AESencrypt aes;
	aes.key256(KeySeed);
	memcpy(dst,src,16);
	for (int i=0; i<rounds; i++){
		aes.ecb_encrypt(dst,dst,16);
	}
}


int KeyTransformBenchmark::benchmark(int pMSecs){
	KeyTransformBenchmark* ktbLeft = new KeyTransformBenchmark(pMSecs);
	KeyTransformBenchmark* ktbRight = new KeyTransformBenchmark(pMSecs);
	ktbLeft->start();
	ktbRight->start();
	ktbLeft->wait();
	ktbRight->wait();
	int num = std::min(ktbLeft->rounds, ktbRight->rounds);
	delete ktbLeft;
	delete ktbRight;
	
	return num;
}

KeyTransformBenchmark::KeyTransformBenchmark(int pMSecs){
	msecs = pMSecs;
	rounds = 0;
}

void KeyTransformBenchmark::run(){
	quint8 KeySeed[32];
	memset(KeySeed, 0x4B, 32);
	quint8 dst[16];
	memset(dst, 0x7E, 16);
	
	QTime t;
	t.start();
	
	AESencrypt aes;
	aes.key256(KeySeed);
	
	do {
		for (int i=0; i<64; i++){
			aes.ecb_encrypt(dst,dst,16);
		}
		rounds += 64;
	} while (t.elapsed() < msecs);
}
