/***************************************************************************
 *   Copyright (C) 2005-2007 by Tarek Saidi                                *
 *   tarek.saidi@arcor.de                                                  *
 *                                                                         *
 *   Copyright (C) 2007 by Constantin "Dinosaur" Makshin                   *
 *   dinosaur-rus@users.sourceforge.net                                    *
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

#ifndef _KPXCONFIG_H_
#define _KPXCONFIG_H_

#include <QBitArray>
#include <QColor>
#include <QSettings>

#include "utils/tools1.h"
//#include "lib/AutoType.h"

//#if defined(Q_WS_MAC)
//#	define DEFAULT_MOUNT_DIR "/Volumes/"
//#elif defined(Q_WS_X11)
#	define DEFAULT_MOUNT_DIR "/media/"
//#elif defined(Q_WS_WIN)
//#	define DEFAULT_MOUNT_DIR "/"
//#else
//#	define DEFAULT_MOUNT_DIR QString()
//#endif

class KpxConfig{
public:
	friend class KpxBookmarks;
	
	enum IntegrPluginType{NoIntegr,KDE,Gnome};
	enum GrpTreeState{DoNothing,RestoreLast,ExpandAll};

	KpxConfig(const QString& filePath);

	bool alternatingRowColors(){return settings.value("Options/AlternatingRowColors",true).toBool();}
	QColor bannerColor1(){return stringToColor(settings.value("Options/BannerColor1","0,85,127").toString());}
	QColor bannerColor2(){return stringToColor(settings.value("Options/BannerColor2","0,117,175").toString());}
	QColor bannerTextColor(){return stringToColor(settings.value("Options/BannerTextColor","222,222,222").toString());}
	int clipboardTimeOut(){return settings.value("Options/ClipboardTimeOut",20).toInt();}
	QBitArray columns(){return stringToBitArray(settings.value("UI/Columns","11111000000").toString(),11);}
	QList<int> columnOrder(){return stringToIntArray(settings.value("UI/ColumnOrder","1,2,3,4,5,6,7,8,9,10,11").toString(),11);}
	QList<int> columnSizes(){return stringToIntArray(settings.value("UI/ColumnSizes","15,10,10,10,10,10,10,10,10,10,10").toString(),11);}
	int columnSort(){return settings.value("UI/ColumnSort",0).toInt();}
	Qt::SortOrder columnSortOrder(){return static_cast<Qt::SortOrder>(settings.value("UI/ColumnSortOrder",Qt::AscendingOrder).toInt());}
	QBitArray searchColumns(){return stringToBitArray(settings.value("UI/SearchColumns","11110000001").toString(),11);}
	QList<int> searchColumnOrder(){return stringToIntArray(settings.value("UI/SearchColumnOrder","2,3,4,5,6,7,8,9,10,11,1").toString(),11);}
	QList<int> searchColumnSizes(){return stringToIntArray(settings.value("UI/SearchColumnSizes","15,10,10,10,10,10,10,10,10,10,10").toString(),11);}
	int searchColumnSort(){return settings.value("UI/SearchColumnSort",0).toInt();}
	Qt::SortOrder searchColumnSortOrder(){return static_cast<Qt::SortOrder>(settings.value("UI/SearchColumnSortOrder",Qt::AscendingOrder).toInt());}
	QStringList fileDlgHistory(unsigned index){return settings.value(QString("FileDlgHistory/ENTRY%1").arg(index)).toStringList();}
	GrpTreeState groupTreeState(){return stringToGrpTreeState(settings.value("Options/GroupTreeState").toString());}
	bool hidePasswords(){return settings.value("UI/HidePasswords",true).toBool();}
	bool hideUsernames(){return settings.value("UI/HideUsernames",true).toBool();}
	QByteArray hSplitterPos(){return settings.value("UI/HSplitterPos").toByteArray();}
	bool alwaysOnTop(){return settings.value("UI/AlwaysOnTop",false).toBool();}
	IntegrPluginType integrPlugin(){return stringToIntegrPluginType(settings.value("Options/IntegrPlugin").toString());}
	QString lastFile(){return settings.value("Options/LastFile").toString();}
	QString lastKeyLocation(){return settings.value("Options/LastKeyLocation").toString();}
	tKeyType lastKeyType(){return stringToKeyType(settings.value("Options/LastKeyType").toString());}
	QByteArray mainWindowGeometry();
	bool minimizeToTray(){return settings.value("Options/MinimizeToTray",false).toBool();} 	
	bool minimizeTray(){return settings.value("Options/MinimizeTray",false).toBool();}
	bool startMinimized(){return settings.value("Options/StartMinimized",false).toBool();}
	bool startLocked(){return settings.value("Options/StartLocked",false).toBool();}
	QString mountDir(){return settings.value("Options/MountDir",DEFAULT_MOUNT_DIR).toString();}
	bool openLastFile(){return settings.value("Options/OpenLastFile",true).toBool();}
	bool autoSave(){return settings.value("Options/AutoSave",false).toBool();}
	bool autoSaveChange(){return settings.value("Options/AutoSaveChange",false).toBool();}
	bool backup(){return settings.value("Options/Backup",true).toBool();}
	bool backupDelete(){return settings.value("Options/BackupDelete",false).toBool();}
	int backupDeleteAfter(){return settings.value("Options/BackupDeleteAfter",14).toInt();}
	int pwGenCategory(){return settings.value("Options/PwGenCategory",0).toInt();}
	QString pwGenCharList(){return settings.value("Options/PwGenCharList").toString();}
	bool pwGenExcludeLookAlike(){return settings.value("Options/PwGenExcludeLookAlike").toBool();}
	bool pwGenEveryGroup(){return settings.value("Options/PwGenEveryGroup").toBool();}
	int pwGenLength(){return settings.value("Options/PwGenLength",25).toInt();}
	QBitArray pwGenOptions(){return stringToBitArray(settings.value("Options/PwGenOptions","11111000011110").toString(),14);}
	bool rememberLastKey(){return settings.value("Options/RememberLastKey",true).toBool();}
	bool saveFileDlgHistory(){return settings.value("Options/SaveFileDlgHistory",true).toBool();}
	bool saveRelativePaths(){return settings.value("Options/SaveRelativePaths",true).toBool();}
	QBitArray searchOptions(){return stringToBitArray(settings.value("Options/SearchOptions","001101111").toString(),9);}
	bool showEntryDetails(){return settings.value("UI/ShowEntryDetails",true).toBool();}
	bool showPasswords(){return settings.value("Options/ShowPasswords",false).toBool();}
	bool showPasswordsPasswordDlg(){return settings.value("Options/ShowPasswordsPasswordDlg",false).toBool();}
	bool lockOnMinimize(){return settings.value("Options/LockOnMinimize",false).toBool();}
	bool lockOnInactivity(){return settings.value("Options/LockOnInactivity",false).toBool();}
	int lockAfterSec(){return settings.value("Options/LockAfterSec",30).toInt();}
	bool showStatusbar(){return settings.value("UI/ShowStatusbar",true).toBool();}
	bool showSysTrayIcon(){return settings.value("Options/ShowSysTrayIcon",false).toBool();}
	bool showToolbar(){return settings.value("UI/ShowToolbar",true).toBool();}
	int toolbarIconSize(){return settings.value("UI/ToolbarIconSize",16).toInt();}
	QString urlCmd(){return settings.value("Options/UrlCmd").toString();}
	bool urlCmdDef(){return settings.value("Options/UrlCmdDef",true).toBool();}
	QByteArray vSplitterPos(){return settings.value("UI/VSplitterPos").toByteArray();}
	bool askBeforeDelete(){return settings.value("Options/AskBeforeDelete",true).toBool();}
#ifdef AUTOTYPE
	int autoTypePreGap(){return settings.value("Options/AutoTypePreGap",500).toInt();}
	int autoTypeKeyStrokeDelay(){return settings.value("Options/AutoTypeKeyStrokeDelay",5).toInt();}
#endif
#ifdef GLOBAL_AUTOTYPE
	Shortcut globalShortcut();
	bool entryTitlesMatch(){return settings.value("Options/EntryTitlesMatch",true).toBool();}
#endif
	//bool featureBookmarks(){return settings.value("Features/Bookmarks",true).toBool();}
	bool featureBookmarks(){return true;}
	QString language(){return settings.value("Options/Language","auto").toString();}
	
	void setAlternatingRowColors(bool value){settings.setValue("Options/AlternatingRowColors",value);}
	void setBannerColor1(const QColor& value){settings.setValue("Options/BannerColor1",colorToString(value));}
	void setBannerColor2(const QColor& value){settings.setValue("Options/BannerColor2",colorToString(value));}
	void setBannerTextColor(const QColor& value){settings.setValue("Options/BannerTextColor",colorToString(value));}
	void setClipboardTimeOut(int value){settings.setValue("Options/ClipboardTimeOut",value);}
	void setColumns(const QBitArray& value){settings.setValue("UI/Columns",bitArrayToString(value));}
	void setColumnOrder(const QList<int>& value){settings.setValue("UI/ColumnOrder",intArrayToString(value));}
	void setColumnSizes(const QList<int>& value){settings.setValue("UI/ColumnSizes",intArrayToString(value));}
	void setColumnSort(int value){settings.setValue("UI/ColumnSort",value);}
	void setColumnSortOrder(int value){settings.setValue("UI/ColumnSortOrder",value);}
	void setSearchColumns(const QBitArray& value){settings.setValue("UI/SearchColumns",bitArrayToString(value));}
	void setSearchColumnOrder(const QList<int>& value){settings.setValue("UI/SearchColumnOrder",intArrayToString(value));}
	void setSearchColumnSizes(const QList<int>& value){settings.setValue("UI/SearchColumnSizes",intArrayToString(value));}
	void setSearchColumnSort(int value){settings.setValue("UI/SearchColumnSort",value);}
	void setSearchColumnSortOrder(int value){settings.setValue("UI/SearchColumnSortOrder",value);}
	void setFileDlgHistory(unsigned index,const QStringList& value){settings.setValue(QString("FileDlgHistory/ENTRY%1").arg(index), value);}
	void setGroupTreeState(GrpTreeState value){settings.setValue("Options/GroupTreeState",grpTreeStateToString(value));}
	void setHidePasswords(bool value){settings.setValue("UI/HidePasswords",value);}
	void setHideUsernames(bool value){settings.setValue("UI/HideUsernames",value);}
	void setHSplitterPos(const QByteArray& value){settings.setValue("UI/HSplitterPos",value);}
	void setAlwaysOnTop(bool value){settings.setValue("UI/AlwaysOnTop",value);}
	void setIntegrPlugin(IntegrPluginType value){settings.setValue("Options/IntegrPlugin",integrPluginTypeToString(value));}
	void setLastFile(const QString& value){settings.setValue("Options/LastFile",value);}
	void setLastKeyLocation(const QString& value){settings.setValue("Options/LastKeyLocation",value);}
	void setLastKeyType(tKeyType value){settings.setValue("Options/LastKeyType",keyTypeToString(value));}
	void setMainWindowGeometry(const QByteArray& value){settings.setValue("UI/MainWindowGeometry",value);}
	void setMinimizeToTray(bool value){settings.setValue("Options/MinimizeToTray",value);}
	void setMinimizeTray(bool value){settings.setValue("Options/MinimizeTray",value);}
	void setStartMinimized(bool value){settings.setValue("Options/StartMinimized",value);}
	void setStartLocked(bool value){settings.setValue("Options/StartLocked",value);}
	void setMountDir(const QString& value){settings.setValue("Options/MountDir",value);}
	void setOpenLastFile(bool value){settings.setValue("Options/OpenLastFile",value);}
	void setAutoSave(bool value){settings.setValue("Options/AutoSave",value);}
	void setAutoSaveChange(bool value){settings.setValue("Options/AutoSaveChange",value);}
	void setBackup(bool value){settings.setValue("Options/Backup",value);}
	void setBackupDelete(bool value){settings.setValue("Options/BackupDelete",value);}
	void setBackupDeleteAfter(int value){settings.setValue("Options/BackupDeleteAfter",value);}
	void setPwGenCategory(int value){settings.setValue("Options/PwGenCategory",value);}
	void setPwGenCharList(const QString& value){settings.setValue("Options/PwGenCharList",value);}
	void setPwGenExcludeLookAlike(bool value){settings.setValue("Options/PwGenExcludeLookAlike",value);}
	void setPwGenEveryGroup(bool value){settings.setValue("Options/PwGenEveryGroup",value);}
	void setPwGenLength(int value){settings.setValue("Options/PwGenLength",value);}
	void setPwGenOptions(const QBitArray& value){settings.setValue("Options/PwGenOptions",bitArrayToString(value));}
	void setRememberLastKey(bool value){settings.setValue("Options/RememberLastKey",value);}
	void setSaveFileDlgHistory(bool value){settings.setValue("Options/SaveFileDlgHistory",value);}
	void setSaveRelativePaths(bool value){settings.setValue("Options/SaveRelativePaths",value);}
	void setSearchOptions(const QBitArray& value){settings.setValue("Options/SearchOptions",bitArrayToString(value));}
	void setShowEntryDetails(bool value){settings.setValue("UI/ShowEntryDetails",value);}
	void setShowPasswords(bool value){settings.setValue("Options/ShowPasswords",value);}
	void setShowPasswordsPasswordDlg(bool value){settings.setValue("Options/ShowPasswordsPasswordDlg",value);}
	void setLockOnMinimize(bool value){settings.setValue("Options/LockOnMinimize",value);}
	void setLockOnInactivity(bool value){settings.setValue("Options/LockOnInactivity",value);}
	void setLockAfterSec(int value){settings.setValue("Options/LockAfterSec",value);}
	void setShowStatusbar(bool value){settings.setValue("UI/ShowStatusbar",value);}
	void setShowSysTrayIcon(bool value){settings.setValue("Options/ShowSysTrayIcon",value);}
	void setShowToolbar(bool value){settings.setValue("UI/ShowToolbar",value);}
	void setToolbarIconSize(int value){settings.setValue("UI/ToolbarIconSize",value);}
	void setUrlCmd(const QString& value){settings.setValue("Options/UrlCmd",value);}
	void setUrlCmdDef(bool value){settings.setValue("Options/UrlCmdDef",value);}
	void setVSplitterPos(const QByteArray& value){settings.setValue("UI/VSplitterPos",value);}
	void setAskBeforeDelete(bool value){settings.setValue("Options/AskBeforeDelete",value);}
#ifdef AUTOTYPE
	void setAutoTypePreGap(int value){settings.setValue("Options/AutoTypePreGap",value);}
	void setAutoTypeKeyStrokeDelay(int value){settings.setValue("Options/AutoTypeKeyStrokeDelay",value);}
#endif
#ifdef GLOBAL_AUTOTYPE
	void setGlobalShortcut(const Shortcut& s);
	void setEntryTitlesMatch(bool value){settings.setValue("Options/EntryTitlesMatch",value);}
#endif
	//void setFeatureBookmarks(bool value){settings.setValue("Features/Bookmarks",value);}
	void setLanguage(const QString& value){settings.setValue("Options/Language",value);}

	unsigned fileDlgHistorySize();
    void clearFileDlgHistory(){settings.remove("FileDlgHistory");}

    QRect dialogGeometry(const QWidget* widget);
    void setDialogGeometry(const QWidget* widget);
	
	QString detailViewTemplate();
	QString defaultDetailViewTemplate();
	void setDetailViewTemplate(const QString& value);

private:
	QSettings settings;
	QString configFile;

	QColor stringToColor(const QString& str);
	QBitArray stringToBitArray(const QString& str, unsigned count);
	GrpTreeState stringToGrpTreeState(const QString& str);
	QList<int> stringToIntArray(const QString& str, unsigned count);
	IntegrPluginType stringToIntegrPluginType(const QString& str);
	tKeyType stringToKeyType(const QString& str);

	QString colorToString(const QColor& color){return QString("%1,%2,%3").arg(color.red()).arg(color.green()).arg(color.blue());}
	QString bitArrayToString(const QBitArray& bitArray);
	QString grpTreeStateToString(GrpTreeState grpTreeState);
	QString intArrayToString(const QList<int>& intArray);
	QString integrPluginTypeToString(IntegrPluginType integrPluginType);
	QString keyTypeToString(tKeyType keyType);
};

#endif
