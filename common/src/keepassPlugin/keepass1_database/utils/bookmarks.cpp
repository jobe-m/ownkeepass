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



QList<KpxBookmarks::BookmarkEntry> KpxBookmarks::Bookmarks;

void KpxBookmarks::load(){
	if (!config->settings.contains("Bookmarks/size") || config->settings.value("Bookmarks/size").toInt()==0)
		return;
	
	int size = config->settings.value("Bookmarks/size").toInt();
	for(int i=1;i<=size;i++){
		BookmarkEntry entry;
		entry.Title = config->settings.value( QString("Bookmarks/%1/Title").arg(i) ).toString();
		entry.Path = config->settings.value( QString("Bookmarks/%1/Path").arg(i) ).toString();
		if (!entry.Title.isNull() && !entry.Path.isNull())
			Bookmarks << entry;
	}
}

int KpxBookmarks::count(){
	return Bookmarks.size();
}

QString KpxBookmarks::title(int i){
	return Bookmarks[i].Title;
}

QString KpxBookmarks::path(int i){
	return Bookmarks[i].Path;
}


int KpxBookmarks::add(const QString& Title,const QString& Path){
	BookmarkEntry entry;
	entry.Title=Title;
	entry.Path=Path;
	entry.Index=Bookmarks.size();
	Bookmarks<<entry;
	save();
	return Bookmarks.size()-1;
}

void KpxBookmarks::save(){
	for (int i=0;i<count();i++){
		config->settings.setValue( QString("Bookmarks/%1/Title").arg(i+1), Bookmarks[i].Title );
		config->settings.setValue( QString("Bookmarks/%1/Path").arg(i+1), Bookmarks[i].Path );
	}
	config->settings.setValue("Bookmarks/size", count());
	
	// remove orphaned entries
	int i = count()+1;
	while ( config->settings.contains( QString("Bookmarks/%1/Title").arg(i) ) ){
		config->settings.remove( QString("Bookmarks/%1/Title").arg(i) );
		config->settings.remove( QString("Bookmarks/%1/Path").arg(i) );
		i++;
	}
}

void KpxBookmarks::remove(int index){
	Bookmarks.removeAt(index);
	save();
}

void KpxBookmarks::edit(const QString& Title,const QString& Path,int i){
	Bookmarks[i].Title=Title;
	Bookmarks[i].Path=Path;
	save();
}


void KpxBookmarks::resort(QList<int> order){
	QList<BookmarkEntry> NewList;
	for(int i=0;i<order.size();i++){
		NewList << Bookmarks[order[i]];
	}
	Bookmarks=NewList;
	save();
}
