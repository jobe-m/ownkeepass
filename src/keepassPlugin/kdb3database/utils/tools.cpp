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

#include <QDesktopServices>
#include <QLibraryInfo>
#include <QProcess>
#include <QTranslator>
#include <QPixmap>
#include <QPainter>
//#include <Qt/qapplication.h> // <QApplication>
#include <QUrl>
//#include <Qt/qmessagebox.h> // <QMessageBox>
#include <QDir>
#include <QLocale>
#include <QSet>

#include "config/keepassx.h"
#include "database/Database.h"
#include "crypto/yarrow.h"

//#if defined(Q_WS_X11) || defined(Q_WS_MAC)
	#include <sys/mman.h>
	#include <unistd.h>
//#elif defined(Q_WS_WIN)
//	#include <QLibrary>
//	#include <windows.h>
//	#include <io.h>
//#endif

//void createBanner(QPixmap* Pixmap,const QPixmap* IconAlpha,const QString& Text,int Width){
//	createBanner(Pixmap,IconAlpha,Text,Width,config->bannerColor1(),config->bannerColor2(),config->bannerTextColor());
//}

//void createBanner(QPixmap* Pixmap,const QPixmap* IconAlpha,const QString& Text,int Width, QColor Color1, QColor Color2, QColor TextColor){
//	*Pixmap=QPixmap(Width,50);
//	QPainter painter(Pixmap);
//	QLinearGradient grad(0,0,Width,0);
//	grad.setColorAt(0,Color1);
//	grad.setColorAt(1,Color2);
//	painter.setPen(Qt::NoPen);
//	painter.setBrush(grad);
//	painter.drawRect(0,0,Width,50);
	
//	QPixmap Icon(32,32);
//	if(IconAlpha){
//		Icon.fill(TextColor);
//		Icon.setAlphaChannel(*IconAlpha);
//		painter.drawPixmap(10,10,Icon);
//	}
	
//	painter.setPen(QPen(TextColor));
//	painter.setFont(QFont(QApplication::font().family(),16));
//	painter.drawText(50,35,Text);
//}

QString decodeFileError(QFile::FileError Code){
	switch(Code){
        case QFile::NoError: return QString("No error occurred.");
        case QFile::ReadError: return QString("An error occurred while reading from the file.");
        case QFile::WriteError: return QString("An error occurred while writing to the file.");
        case QFile::FatalError: return QString("A fatal error occurred.");
        case QFile::ResourceError: return QString("An resource error occurred.");
        case QFile::OpenError: return QString("The file could not be opened.");
        case QFile::AbortError: return QString("The operation was aborted.");
        case QFile::TimeOutError: return QString("A timeout occurred.");
        case QFile::UnspecifiedError: return QString("An unspecified error occurred.");
        case QFile::RemoveError: return QString("The file could not be removed.");
        case QFile::RenameError: return QString("The file could not be renamed.");
        case QFile::PositionError: return QString("The position in the file could not be changed.");
        case QFile::ResizeError: return QString("The file could not be resized.");
        case QFile::PermissionsError: return QString("The file could not be accessed.");
        case QFile::CopyError: return QString("The file could not be copied.");
	}
	return QString();
}

void openBrowser(IEntryHandle* entry){
	QString url = entry->url();
	url.replace("{TITLE}", entry->title(), Qt::CaseInsensitive);
	url.replace("{USERNAME}", entry->username(), Qt::CaseInsensitive);
	
	if (url.contains("{PASSWORD}",Qt::CaseInsensitive)){
		SecString password=entry->password();
		password.unlock();
		url.replace("{PASSWORD}", password, Qt::CaseInsensitive);
	}
	
	openBrowser(url);
}

// TODO (Marko Koschak) check if this function is needed somewhere
void openBrowser(const QString& UrlString){
	if (UrlString.trimmed().isEmpty())
		return;
	
	if (UrlString.startsWith("cmd://") && UrlString.length()>6){
		QProcess::startDetached(UrlString.right(UrlString.length()-6));
		return;
	}
	
	QUrl url(UrlString);
	if(url.scheme().isEmpty())
		url=QUrl("http://"+UrlString);
	if(config->urlCmdDef() || url.scheme()=="mailto"){
		QDesktopServices::openUrl(url);
	}
	else{
		QByteArray UrlEncoded = url.toEncoded();
		QString browser = config->urlCmd();
		if (browser.contains("%u", Qt::CaseInsensitive))
			browser.replace("%u", UrlEncoded, Qt::CaseInsensitive);
		else if (browser.contains("%1"))
			browser.replace("%1", UrlEncoded);
		else
			browser.append(" ").append(UrlEncoded);
		QProcess::startDetached(browser);
	}
}


QString makePathRelative(const QString& AbsDir,const QString& CurDir){
	QStringList abs=AbsDir.split('/');
	QStringList cur=CurDir.split('/');
	QString rel="./";
	int common;
	for(common=0; common < abs.size() && common < cur.size(); common++){
		if(abs[common]!=cur[common])break;
	}
	for(int i=0;i<cur.size()-common;i++)
		rel.append("../");
	for(int i=common;i<abs.size();i++)
		rel.append(abs[i]+"/");
	return rel;
}

//void showErrMsg(const QString& msg,QWidget* parent){
//	QMessageBox::critical(parent, QApplication::translate("Main","Error"), msg);
//}

QString getImageFile(const QString& name){
	if (QFile::exists(DataDir+"/icons/"+name))
		return DataDir+"/icons/"+name;
	else{
//		QString errMsg = QApplication::translate("Main","File '%1' could not be found.").arg(name);
//		showErrMsg(errMsg);
        qFatal("File '%s' could not be found.", CSTR(name));
		return QString();
	}
}

//const QIcon& getIcon(const QString& name){
//    static QHash<QString,QIcon*>IconCache;
//    QIcon* CachedIcon=IconCache.value(name);
//	if(CachedIcon)
//		return *CachedIcon;
//    QIcon* NewIcon=NULL;
//	if(IconLoader){
//        NewIcon=new QIcon(IconLoader->getIcon(name));
//		if(NewIcon->isNull()){
//			delete NewIcon;
//			NewIcon=NULL;
//		}
//		else
//			IconCache.insert(name,NewIcon);
//	}
//	if(!NewIcon)
//	{
//        NewIcon=new QIcon(getImageFile(name+".png"));
//		IconCache.insert(name,NewIcon);
//	}
//	return *NewIcon;
//}

const QPixmap* getPixmap(const QString& name){
	static QHash<QString,QPixmap*>PixmapCache;
	QPixmap* CachedPixmap=PixmapCache.value(name);
	if(CachedPixmap)
		return CachedPixmap;
	QImage img(getImageFile(name+".png"));
	QPixmap* NewPixmap=new QPixmap(QPixmap::fromImage(img));
	PixmapCache.insert(name,NewPixmap);
	return NewPixmap;
}


bool createKeyFile(const QString& filename,QString* error,int length, bool Hex){
	QFile file(filename);
	if(!file.open(QIODevice::WriteOnly|QIODevice::Truncate|QIODevice::Unbuffered)){
		*error=decodeFileError(file.error());
		return false;
	}
	if(Hex)length*=2;
	unsigned char* key=new unsigned char[length];
	randomize(key,length);
	if(Hex){
		// convert binary data to hex code (8 bit ==> 2 digits)
		for(int i=0; i<length; i+=2){
			unsigned char dig1,dig2;
			dig1=key[i]/16;
			key[i]-=(16*dig1);
			dig2=key[i];
			if(dig1>9)key[i]='A'+dig1-10;
			else key[i]='0'+dig1;
			if(dig2>9)key[i+1]='A'+dig2-10;
			else key[i+1]='0'+dig2;
		}
	}
	if(file.write((char*)key,length)==-1){
		delete [] key;
		*error=decodeFileError(file.error());
		file.close();
		return false;
	}
	file.close();
	delete [] key;
	return true;
}

bool lockPage(void* addr, int len){
//#if defined(Q_WS_X11) || defined(Q_WS_MAC)
	return (mlock(addr, len)==0);
//#elif defined(Q_WS_WIN)
//	return VirtualLock(addr, len);
//#else
//	return false;
//#endif
}

bool unlockPage(void* addr, int len){
//#if defined(Q_WS_X11) || defined(Q_WS_MAC)
	return (munlock(addr, len)==0);
//#elif defined(Q_WS_WIN)
//	return VirtualUnlock(addr, len);
//#else
//	return false;
//#endif
}

bool syncFile(QFile* file) {
	if (!file->flush())
		return false;
//#if defined(Q_WS_X11) || defined(Q_WS_MAC)
	return (fsync(file->handle())==0);
//#elif defined(Q_WS_WIN)
//	return (_commit(file->handle())==0);
//#else
//	return false;
//#endif
}

QTranslator* translator = new QTranslator();
QTranslator* qtTranslator = new QTranslator();
bool translatorActive = false;
bool qtTranslatorActive = false;

bool loadTranslation(QTranslator* tr,const QString& prefix,const QString& loc,const QStringList& paths){
	for (int i=0;i<paths.size();i++){
		if(tr->load(prefix+loc+".qm",paths[i]))
			return true;
	}
	
	for (int i=0;i<paths.size();i++){
		QDir dir(paths[i]);
		QStringList TrFiles=dir.entryList(QStringList()<<"*.qm",QDir::Files);
		for (int j=0;j<TrFiles.size();j++){
			if (TrFiles[j].left(prefix.length()+2)==prefix+loc.left(2)){
				if (tr->load(TrFiles[j],paths[i]))
					return true;
			}
		}
	}
	return false;
}

//void deactivateTranslators(bool qtOnly=false){
//	if (translatorActive && !qtOnly){
//		QApplication::removeTranslator(translator);
//		translatorActive = false;
//	}
	
//	if (qtTranslatorActive){
//		QApplication::removeTranslator(qtTranslator);
//		qtTranslatorActive = false;
//	}
//}

//void installTranslator(){
//	QString language = config->language();
//	if (language=="auto")
//		language = QLocale::system().name();
	
//	if (language.isEmpty() || language=="en_US"){
//		deactivateTranslators();
//		return;
//	}
	
//	if (loadTranslation(translator,"keepassx-",language,QStringList()
//		<< HomeDir << DataDir+"/i18n/"))
//	{
//		if (!translatorActive){
//			QApplication::installTranslator(translator);
//			translatorActive = true;
//		}
//	}
//	else{
//		deactivateTranslators();
//		return;
//	}
	
//	if (loadTranslation(qtTranslator,"qt_",language,QStringList()
//		<< HomeDir << DataDir+"/i18n/"
//		<< QLibraryInfo::location(QLibraryInfo::TranslationsPath)))
//	{
//		if (!qtTranslatorActive){
//			QApplication::installTranslator(qtTranslator);
//			qtTranslatorActive = true;
//		}
//	}
//	else{
//		deactivateTranslators(true);
//	}
//}

//bool isTranslationActive(){
//	return translatorActive;
//}

//bool operator<(const Translation& t1, const Translation& t2){
//	return t1.nameLong < t2.nameLong;
//}

//QList<Translation> getAllTranslations(){
//	QTranslator tmpTranslator;
//	QList<Translation> translations;
//	QSet<QString> names;
	
//	QStringList paths = QStringList() << DataDir+"/i18n/" << HomeDir;
//	QRegExp filename("keepassx-([^_]{2}_[^\\.]{2}|[^\\.]{2})\\.qm");
//	for (int i=0;i<paths.size();i++){
//		QDir dir(paths[i]);
//		QStringList TrFiles=dir.entryList(QStringList()<<"*.qm",QDir::Files);
//		for (int j=0;j<TrFiles.size();j++){
//			if (filename.exactMatch(TrFiles[j]) && TrFiles[j]!="keepassx-xx_XX.qm" &&
//				tmpTranslator.load(TrFiles[j],paths[i]) && !names.contains(filename.cap(1)))
//			{
//				Translation t;
//				t.nameCode = filename.cap(1);
//				t.nameLong = tmpTranslator.translate("Translation", "$LANGUAGE_NAME", "Insert your language name in the format: English (United States)");
//				t.author = tmpTranslator.translate("Translation", "$TRANSLATION_AUTHOR");
				
//				QLocale l(t.nameCode);
//				t.nameEnglish = QLocale::languageToString(l.language());
//				if (t.nameCode.size()==5){
//					QString country = QLocale::countryToString(l.country());
//					int size = country.size();
//					for (int k=1; k<size; k++){
//						if (country[k].isUpper()){
//							country.insert(k, " ");
//							k += 2;
//							size++;
//						}
//					}
//					t.nameEnglish.append(" (").append(country).append(")");
//				}
				
//				if (t.nameLong.isEmpty())
//					t.nameLong = t.nameEnglish;
				
//				translations << t;
//				names << t.nameCode;
//			}
//		}
//	}
	
//	qSort(translations.begin(), translations.end());
//	return translations;
//}

// from src/corelib/qsettings.cpp:
//#ifdef Q_OS_WIN
//QString qtWindowsConfigPath(int type)
//{
//	QString result;

//	QLibrary library(QLatin1String("shell32"));
//	QT_WA( {
//		typedef BOOL (WINAPI*GetSpecialFolderPath)(HWND, LPTSTR, int, BOOL);
//		GetSpecialFolderPath SHGetSpecialFolderPath = (GetSpecialFolderPath)library.resolve("SHGetSpecialFolderPathW");
//		if (SHGetSpecialFolderPath) {
//			TCHAR path[MAX_PATH];
//			SHGetSpecialFolderPath(0, path, type, FALSE);
//			result = QString::fromUtf16((ushort*)path);
//		}
//	} , {
//		typedef BOOL (WINAPI*GetSpecialFolderPath)(HWND, char*, int, BOOL);
//		GetSpecialFolderPath SHGetSpecialFolderPath = (GetSpecialFolderPath)library.resolve("SHGetSpecialFolderPathA");
//		if (SHGetSpecialFolderPath) {
//			char path[MAX_PATH];
//			SHGetSpecialFolderPath(0, path, type, FALSE);
//			result = QString::fromLocal8Bit(path);
//		}
//	} );

//	return result;
//}
//#endif // Q_OS_WIN
