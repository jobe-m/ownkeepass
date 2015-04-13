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

#include <QFileDialog>
#if QT_VERSION >= 0x040400
	#include <QDesktopServices>
#endif

IFileDialog* KpxFileDialogs::iFileDialog=NULL;
QtStandardFileDialogs DefaultQtDlgs;
FileDlgHistory fileDlgHistory;

void KpxFileDialogs::setPlugin(IFileDialog* plugin){
	iFileDialog=plugin;
}

QString KpxFileDialogs::openExistingFile(QWidget* Parent, const QString& Name, const QString& Title,const QStringList& Filters,QString Dir,int SelectedFilter)
{
	EventOccurredBlock = true;
	if(!iFileDialog)iFileDialog=dynamic_cast<IFileDialog*>(&DefaultQtDlgs);
	if(Dir==QString())
		Dir=fileDlgHistory.getDir(Name);
	if(SelectedFilter==-1)
		SelectedFilter=fileDlgHistory.getFilter(Name);
	QString result = iFileDialog->openExistingFileDialog(Parent,Title,Dir,Filters,SelectedFilter);
	if(!result.isEmpty()){
		fileDlgHistory.set(Name,result.left(result.lastIndexOf("/")+1),iFileDialog->getLastFilter());
	}
	EventOccurredBlock = false;
	return result;
}

QStringList KpxFileDialogs::openExistingFiles(QWidget* Parent, const QString& Name, const QString& Title,const QStringList& Filters,QString Dir,int SelectedFilter)
{
	EventOccurredBlock = true;
	if(!iFileDialog)iFileDialog=dynamic_cast<IFileDialog*>(&DefaultQtDlgs);
	if(Dir==QString())
		Dir=fileDlgHistory.getDir(Name);
	if(SelectedFilter==-1)
		SelectedFilter=fileDlgHistory.getFilter(Name);
	QStringList results=iFileDialog->openExistingFilesDialog(Parent,Title,QString(),Filters,SelectedFilter);
	if(!results.isEmpty()){
		fileDlgHistory.set(Name,results[0].left(results[0].lastIndexOf("/")+1),iFileDialog->getLastFilter());
	}
	EventOccurredBlock = false;
	return results;
}

QString KpxFileDialogs::saveFile(QWidget* Parent, const QString& Name, const QString& Title,const QStringList& Filters,bool OverWriteWarn,QString Dir,int SelectedFilter)
{
	EventOccurredBlock = true;
	if(!iFileDialog)iFileDialog=dynamic_cast<IFileDialog*>(&DefaultQtDlgs);
	if(Dir==QString())
		Dir=fileDlgHistory.getDir(Name);
	if(SelectedFilter==-1)
		SelectedFilter=fileDlgHistory.getFilter(Name);
	QString result = iFileDialog->saveFileDialog(Parent,Title,QString(),Filters,SelectedFilter,OverWriteWarn);
	if(!result.isEmpty()){
		fileDlgHistory.set(Name,result.left(result.lastIndexOf("/")+1),iFileDialog->getLastFilter());
	}
	EventOccurredBlock = false;
	return result;
}



QString QtStandardFileDialogs::toSingleStringFilter(const QStringList& filterList){
	if(!filterList.size())
		return QString();
	QString SingleString;
	for(int i=0;i<filterList.size()-1;i++){
		SingleString += filterList[i] + ";;";
	}
	SingleString += filterList.back();
	return SingleString;
}



QString QtStandardFileDialogs::openExistingFileDialog(QWidget* parent,QString title,QString dir,QStringList Filters,int SelectedFilterIndex){
	QString SelectedFilter;
	if(SelectedFilterIndex < Filters.size())
		SelectedFilter=Filters[SelectedFilterIndex];
	QString filename = QFileDialog::getOpenFileName(parent,title,dir,toSingleStringFilter(Filters),&SelectedFilter);
	LastFilter=Filters.indexOf(SelectedFilter);
	return filename;
	
}

QStringList QtStandardFileDialogs::openExistingFilesDialog(QWidget* parent,QString title,QString dir,QStringList Filters,int SelectedFilterIndex){
	QString SelectedFilter;
	if(SelectedFilterIndex < Filters.size())
		SelectedFilter=Filters[SelectedFilterIndex];
	QStringList filenames = QFileDialog::getOpenFileNames(parent,title,dir,toSingleStringFilter(Filters),&SelectedFilter);
	LastFilter=Filters.indexOf(SelectedFilter);
	return filenames;
}

QString QtStandardFileDialogs::saveFileDialog(QWidget* parent,QString title,QString dir,QStringList Filters,int SelectedFilterIndex, bool ShowOverwriteWarning){
	QString SelectedFilter;
	if(SelectedFilterIndex < Filters.size())
		SelectedFilter=Filters[SelectedFilterIndex];
	QString filepath = QFileDialog::getSaveFileName(parent,title,dir,toSingleStringFilter(Filters),&SelectedFilter,
	                                                ShowOverwriteWarning ? (QFileDialog::Option)0 : QFileDialog::DontConfirmOverwrite);
	LastFilter=Filters.indexOf(SelectedFilter);
		
	//Check whether the file has an extension which fits to the selected filter
	QFileInfo file(filepath);
	QString filename=file.fileName();
	int a=Filters[LastFilter].indexOf('(');
	int b=Filters[LastFilter].indexOf(')');
	QStringList Extensions=Filters[LastFilter].mid(a+1,b-a-1).split(" ");
	if(Extensions.contains("*"))
		return filepath;
	
	for(int i=0;i<Extensions.size();i++)
		Extensions[i].remove(0,2); //remove the *. from the extensions

	if(!file.suffix().isEmpty()){
		if(Extensions.contains(file.suffix()))
			return filepath;
		else
			return filepath+"."+Extensions[0];
	}
	else
		return filepath+"."+Extensions[0];
}

int QtStandardFileDialogs::getLastFilter(){
	return LastFilter;
}


QString FileDlgHistory::getDir(const QString& name){
	Entry e=History.value(name);
	if(e.isNull()) {
#if QT_VERSION >= 0x040400
		return QDesktopServices::storageLocation(QDesktopServices::DocumentsLocation);
#else
		return QDir::homePath();
#endif
	}
	else
		return e.Dir;
}

int FileDlgHistory::getFilter(const QString& name){
	Entry e=History.value(name);
	if(e.isNull())
		return 0;
	else
		return e.Filter;
}

void FileDlgHistory::set(const QString& name,const QString& dir, int filter){
	History[name]=Entry();
	History[name].Dir=dir;
	History[name].Filter=filter;
}
void FileDlgHistory::save(){
	if(config->saveFileDlgHistory()){
		for(unsigned i=0;i<static_cast<unsigned>(History.size());i++){
			QStringList entry;
			entry << History.keys().at(i)
				  << History.values().at(i).Dir
				  << QString::number(History.values().at(i).Filter);
			config->setFileDlgHistory(i,entry);
		}
	}
}

void FileDlgHistory::load(){
	if(config->saveFileDlgHistory()){
		unsigned count=config->fileDlgHistorySize();
		for(unsigned i=0;i</*keys.size()*/count;i++){
			Entry entry;
			QStringList value=config->fileDlgHistory(i);
			entry.Dir=value[1];
			entry.Filter=value[2].toInt();
			History[value[0]]=entry;
		}
	}
	else
		config->clearFileDlgHistory();
}

void FileDlgHistory::clear(){
	History=QHash<QString,Entry>();
	config->clearFileDlgHistory();	
}
