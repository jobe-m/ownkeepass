/***************************************************************************
 *   Copyright (C) 2005 by Tarek Saidi                                     *
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

#ifndef _GROUP_VIEW_H_
#define _GROUP_VIEW_H_

#include "Kdb3Database.h"

class GroupViewItem;

class KeepassGroupView:public QTreeWidget{
	Q_OBJECT
	public:
		KeepassGroupView(QWidget* parent=0);
		IDatabase *db;
		QList<GroupViewItem*>Items;
		QMenu *ContextMenu;
		QMenu *ContextMenuSearchGroup;
		GroupViewItem* SearchResultItem;
		void createItems();
		void showSearchResults();
		void setCurrentGroup(IGroupHandle* group);
		void selectFirstGroup();
		void retranslateUi();
	
	public slots:
		void createGroup(const QString& title, quint32 image, GroupViewItem* group=NULL);
		
	private:
		virtual void dragEnterEvent(QDragEnterEvent* event);
		virtual void dragMoveEvent(QDragMoveEvent* event);
		void entryDragMoveEvent(QDragMoveEvent* event);
		virtual void dragLeaveEvent(QDragLeaveEvent* event);
		virtual void dropEvent(QDropEvent* event);
		void entryDropEvent(QDropEvent* event);
		virtual void mousePressEvent(QMouseEvent *event);
		virtual void mouseMoveEvent(QMouseEvent *event);
		virtual void paintEvent (QPaintEvent* event);
		virtual void contextMenuEvent(QContextMenuEvent* event);
		void addChildren(GroupViewItem* item);
		QPoint DragStartPos;
		GroupViewItem* DragItem;
		GroupViewItem* LastHoverItem;
		int InsLinePos;
		int InsLineStart;
		enum GroupViewDragType{EntryDrag,GroupDrag};
		GroupViewDragType DragType;
		QList<QTreeWidgetItem*>* EntryDragItems;
	
	private slots:
		void OnCurrentGroupChanged(QTreeWidgetItem*);
		void OnDeleteGroup();
		void OnNewGroup();
		void OnNewSubgroup();
		void OnEditGroup();
		void updateIcons();
		void OnHideSearchResults();
		void OnItemExpanded(QTreeWidgetItem*);
		void OnItemCollapsed(QTreeWidgetItem*);
		void OnSort();
		
	signals:
		void groupChanged(IGroupHandle* NewGroup);
		void searchResultsSelected();
		void fileModified();
		void entriesDropped();
};


class GroupViewItem:public QTreeWidgetItem{
	public:
		GroupViewItem();
		GroupViewItem(QTreeWidget *parent);
		GroupViewItem(QTreeWidget *parent, QTreeWidgetItem * preceding);
		GroupViewItem(QTreeWidgetItem *parent);
		GroupViewItem(QTreeWidgetItem *parent, QTreeWidgetItem * preceding);
		bool operator<(const QTreeWidgetItem& other) const;
		IGroupHandle* GroupHandle;
};



#endif
