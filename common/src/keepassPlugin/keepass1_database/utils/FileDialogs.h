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
#ifndef _FILE_DIALOGS_H_
#define _FILE_DIALOGS_H_

#include "plugins/interfaces/IFileDialog.h"


class FileDlgHistory:public QObject{
	Q_OBJECT
	public:
		QString getDir(const QString& name);
		int getFilter(const QString& name);
	public slots:
		void set(const QString& name,const QString& dir,int filter);
		void save();
		void load();
		void clear();
	private:
		class Entry{
			public:
				Entry(){Filter=-1;}
				QString Dir;
				int Filter;
				bool isNull(){
					if(Filter==-1)
						return true;
					else
						return false;
				}
		};
		
		QHash<QString,Entry>History;
	
};


class KpxFileDialogs{
	public:
	static void setPlugin(IFileDialog* FileDlgPlugin);
	static QString openExistingFile(QWidget* parent, const QString& Name,
	                                const QString& Title,
	                                const QStringList& Filters,
	                                QString Dir=QString(),
	                                int SelectedFilter=-1);
	static QStringList openExistingFiles(QWidget* parent, const QString& Name,
	                                     const QString& Title,
	                                     const QStringList& Filters,
	                                     const QString Dir=QString(),
	                                     int SelectedFilter=-1);
	static QString saveFile(QWidget* parent, const QString& Name,
	                        const QString& Title,
	                        const QStringList& Filters,
	                        bool ShowOverwriteWarning=true,
	                        QString Dir=QString(),
	                        int SelectedFilter=-1);		
	private:
	static IFileDialog* iFileDialog;
};


class QtStandardFileDialogs:public QObject,public IFileDialog{
	Q_OBJECT	
	Q_INTERFACES(IFileDialog);
	public:
	QString openExistingFileDialog(QWidget* parent,QString title,QString dir,QStringList Filters,int SelectedFilter);
	QStringList openExistingFilesDialog(QWidget* parent,QString title,QString dir,QStringList Filters,int SelectedFilter);		
	QString saveFileDialog(QWidget* parent,QString title,QString dir,QStringList Filters,int SelectedFilter,bool ShowOverwriteWarning);
	int getLastFilter();
	private:
	static QString toSingleStringFilter(const QStringList& filterList);
	int LastFilter;
};

extern FileDlgHistory fileDlgHistory; 
 
#endif
