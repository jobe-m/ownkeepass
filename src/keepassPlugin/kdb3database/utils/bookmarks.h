/***************************************************************************
 *   Copyright (C) 2007 by Tarek Saidi                                     *
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
#ifndef _BOOKMARKS_H_
#define _BOOKMARKS_H_

class KpxBookmarks {	
	public:
		static void load();
		static int add(const QString& Title,const QString& Path);
		static void remove(int id);
		static void edit(const QString& Title,const QString& Path, int Index);
		static int count();
		static void resort(QList<int> order);
		static QString title(int Index);
		static QString path(int Index);
	private:
		static void save();
		class BookmarkEntry {
			public:
				QString Title;
				QString Path;
				int Index;		
		};
		static QList<BookmarkEntry> Bookmarks;
		static QString filename;

};


#endif
