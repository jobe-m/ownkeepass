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


#include "EntryView.h"
#include "GroupView.h"
#include "dialogs/EditGroupDlg.h"

#include <QBrush>
#include <QHeaderView>

#define INSERT_AREA_WIDTH 4

KeepassGroupView::KeepassGroupView(QWidget* parent):QTreeWidget(parent){
	db=NULL;
	ContextMenu=new QMenu(this);
	ContextMenuSearchGroup=new QMenu(this);
	connect(this,SIGNAL(currentItemChanged(QTreeWidgetItem*,QTreeWidgetItem*)),this,SLOT(OnCurrentGroupChanged(QTreeWidgetItem*)));
	connect(this,SIGNAL(itemExpanded(QTreeWidgetItem*)),this,SLOT(OnItemExpanded(QTreeWidgetItem*)));
	connect(this,SIGNAL(itemCollapsed(QTreeWidgetItem*)),this,SLOT(OnItemCollapsed(QTreeWidgetItem*)));
}

void KeepassGroupView::createItems(){
	clear();
	Items.clear();
	InsLinePos=-1;
	QList<IGroupHandle*> groups=db->groups();
	for(int i=0;i<groups.size();i++){
		if(groups[i]->parent()==NULL){
			Items.append(new GroupViewItem(this));
			Items.back()->setText(0,groups[i]->title());
			Items.back()->GroupHandle=groups[i];
			addChildren(Items.back());
		}
	}
	for(int i=0;i<Items.size();i++){
		Items[i]->setIcon(0,db->icon(Items[i]->GroupHandle->image()));
		Items[i]->setExpanded(Items[i]->GroupHandle->expanded());
	}
	SearchResultItem=new GroupViewItem();
	retranslateUi();
}

void KeepassGroupView::retranslateUi() {
	SearchResultItem->setText(0,tr("Search Results"));
}

void KeepassGroupView::updateIcons(){
	for(int i=0;i<Items.size();i++){
		Items[i]->setIcon(0,db->icon(Items[i]->GroupHandle->image()));
	}
}

void KeepassGroupView::showSearchResults(){
	if(topLevelItem(topLevelItemCount()-1)!=SearchResultItem){
		addTopLevelItem(SearchResultItem);
	}
	setCurrentItem(SearchResultItem);
	emit searchResultsSelected();
}

void KeepassGroupView::addChildren(GroupViewItem* item){
	QList<IGroupHandle*>children=item->GroupHandle->children();
	if(!children.size())
		return;
	for(int i=0; i<children.size(); i++){
		Items.push_back(new GroupViewItem(item));
		Items.back()->setText(0,children[i]->title());
		Items.back()->GroupHandle=children[i];
		addChildren(Items.back());
	}	
}

void KeepassGroupView::OnDeleteGroup(){
	if(config->askBeforeDelete()){
		if(QMessageBox::question(this,tr("Delete?"),
		   tr("Are you sure you want to delete this group, all its child groups and all their entries?"),
			  QMessageBox::Yes | QMessageBox::No,QMessageBox::No) == QMessageBox::No)
			return;			
	}
	GroupViewItem* item=(GroupViewItem*)currentItem();
	if(item){
		db->deleteGroup(item->GroupHandle);
		delete item;
		emit fileModified();
	}
}

void KeepassGroupView::OnHideSearchResults(){
	takeTopLevelItem(topLevelItemCount()-1);
}

void KeepassGroupView::OnNewGroup(){
	CGroup NewGroup;
	CEditGroupDialog dlg(db,&NewGroup,parentWidget());
	if(dlg.exec())
		createGroup(NewGroup.Title, NewGroup.Image, NULL);
}

void KeepassGroupView::OnNewSubgroup(){
	GroupViewItem* parent=(GroupViewItem*)currentItem();
	CGroup NewGroup;
	CEditGroupDialog dlg(db,&NewGroup,parentWidget());
	if(dlg.exec())
		createGroup(NewGroup.Title, NewGroup.Image, parent);
}

void KeepassGroupView::createGroup(const QString& title, quint32 image, GroupViewItem* parent){
	CGroup NewGroup;
	NewGroup.Title = title;
	NewGroup.Image = image;
	
	IGroupHandle* group;
	if(parent){
		group=db->addGroup(&NewGroup,parent->GroupHandle);
		Items.append(new GroupViewItem(parent));
	}
	else{
		if(topLevelItemCount()){
			int i=1;
			if(topLevelItem(topLevelItemCount()-i)==SearchResultItem)
				i++;
			if(title!="Backup" && topLevelItem(topLevelItemCount()-i)->text(0)=="Backup")
				i++;
			Items.append(new GroupViewItem(this,topLevelItem(topLevelItemCount()-i)));
		}
		else
			Items.append(new GroupViewItem(this));
		
		group = db->addGroup(&NewGroup,NULL);
	}
	
	Items.back()->GroupHandle = group;
	Items.back()->setText(0, group->title());
	Items.back()->setIcon(0, db->icon(group->image()));
	emit fileModified();
}

void KeepassGroupView::OnEditGroup(){
	GroupViewItem* item=(GroupViewItem*)currentItem();
	CEditGroupDialog dlg(db,item->GroupHandle,parentWidget());
	int r=dlg.exec();
	if(r){
		item->setIcon(0,db->icon(item->GroupHandle->image()));
		item->setText(0,item->GroupHandle->title());
		if(r==2)emit fileModified();
	}
}

void KeepassGroupView::contextMenuEvent(QContextMenuEvent* e){
	if(!(GroupViewItem*)itemAt(e->pos()))
		return;
	
	e->accept();
	if(currentItem()==SearchResultItem)
		ContextMenuSearchGroup->popup(e->globalPos());
	else
		ContextMenu->popup(e->globalPos());
}

void KeepassGroupView::OnCurrentGroupChanged(QTreeWidgetItem* cur){
	if(cur){
		if(cur==SearchResultItem)
			emit searchResultsSelected();
		else
			emit groupChanged(((GroupViewItem*)cur)->GroupHandle);
	}
	else
		emit groupChanged(NULL);
}


void KeepassGroupView::setCurrentGroup(IGroupHandle* group){
	bool found=false;
	int i;
	for(i=0;i<Items.size();i++)
		if(Items[i]->GroupHandle==group){found=true; break;}
	if(!found)return;
	setCurrentItem(Items[i]);
}

void KeepassGroupView::selectFirstGroup(){
	if (Items.isEmpty())
		return;
	
	setCurrentItem(Items[0]);
}

void KeepassGroupView::dragEnterEvent ( QDragEnterEvent * event ){
	LastHoverItem=NULL;
	InsLinePos=-1;
	
	if (event->source() == NULL)
		return; // drag event came from another application
	
	if(event->mimeData()->hasFormat("application/x-keepassx-group")){
		DragType=GroupDrag;
		event->acceptProposedAction();
		return;
	}
	if(event->mimeData()->hasFormat("application/x-keepassx-entry")){
		DragType=EntryDrag;
		memcpy(&EntryDragItems,event->mimeData()->data("application/x-keepassx-entry").data(),sizeof(void*));
		event->acceptProposedAction();
		return;
	}
	
}



void KeepassGroupView::dragLeaveEvent ( QDragLeaveEvent * event ){
	Q_UNUSED(event);
	if(LastHoverItem){
		LastHoverItem->setBackgroundColor(0,QApplication::palette().color(QPalette::Base));
		LastHoverItem->setForeground(0,QBrush(QApplication::palette().color(QPalette::Text)));
	}
	if(InsLinePos!=-1){
		int RemoveLine=InsLinePos;
		InsLinePos=-1;
		viewport()->update(QRegion(0,RemoveLine-2,viewport()->width(),4));
	}
	
}

void KeepassGroupView::entryDropEvent( QDropEvent * event ){
	GroupViewItem* Item=(GroupViewItem*)itemAt(event->pos());
	if(!Item){
		event->ignore();
		return;
	}
	else{
		if(Item->GroupHandle==((EntryViewItem*)(*EntryDragItems)[0])->EntryHandle->group())
			return;
		for(int i=0;i<EntryDragItems->size();i++){
			db->moveEntry(((EntryViewItem*)(*EntryDragItems)[i])->EntryHandle,Item->GroupHandle);
		}
		emit entriesDropped();
		emit fileModified();
	}
	
}


void KeepassGroupView::dropEvent( QDropEvent * event ){
	if(LastHoverItem){
		LastHoverItem->setBackgroundColor(0,QApplication::palette().color(QPalette::Base));
		LastHoverItem->setForeground(0,QBrush(QApplication::palette().color(QPalette::Text)));
	}
	
	if(DragType==EntryDrag){
		entryDropEvent(event);
		return;
	}

	if(InsLinePos!=-1){
		int RemoveLine=InsLinePos;
		InsLinePos=-1;
		viewport()->update(QRegion(0,RemoveLine-2,viewport()->width(),4));
	}
	GroupViewItem* Item=(GroupViewItem*)itemAt(event->pos());
	
	if(!Item){
		qDebug("Append at the end");
		db->moveGroup(DragItem->GroupHandle,NULL,-1);
		if(DragItem->parent()){
			DragItem->parent()->takeChild(DragItem->parent()->indexOfChild(DragItem));
		}
		else{
			takeTopLevelItem(indexOfTopLevelItem(DragItem));
		}
		insertTopLevelItem(topLevelItemCount(),DragItem);
		if(topLevelItemCount()>1){
			if(topLevelItem(topLevelItemCount()-2)==SearchResultItem){
				takeTopLevelItem(topLevelItemCount()-2);
				insertTopLevelItem(topLevelItemCount(),SearchResultItem);	
			}			
		}
		emit fileModified();
	}
	else{
		if (DragItem->GroupHandle==Item->GroupHandle)
			return;
		
		QRect ItemRect=visualItemRect(Item);
		if(event->pos().y()>ItemRect.y()+2 && event->pos().y()<ItemRect.y()+ItemRect.height()-2){
			qDebug("Append as child of '%s'",((char*)Item->text(0).toUtf8().data()));
			db->moveGroup(DragItem->GroupHandle,Item->GroupHandle,-1);
			if(DragItem->parent()){
				DragItem->parent()->takeChild(DragItem->parent()->indexOfChild(DragItem));
			}
			else{
				takeTopLevelItem(indexOfTopLevelItem(DragItem));
			}
			Item->insertChild(Item->childCount(),DragItem);
			emit fileModified();
		}
		else{
			if(event->pos().y()>ItemRect.y()+2){
				qDebug("Insert behind sibling '%s'",((char*)Item->text(0).toUtf8().data()));
				if(DragItem->parent()){
					DragItem->parent()->takeChild(DragItem->parent()->indexOfChild(DragItem));
				}
				else{
					takeTopLevelItem(indexOfTopLevelItem(DragItem));
				}				
				if(Item->parent()){
					int index=Item->parent()->indexOfChild(Item)+1;
					db->moveGroup(DragItem->GroupHandle,((GroupViewItem*)Item->parent())->GroupHandle,index);
					Item->parent()->insertChild(index,DragItem);
				}
				else{
					int index=indexOfTopLevelItem(Item)+1;
					db->moveGroup(DragItem->GroupHandle,NULL,index);
					insertTopLevelItem(index,DragItem);	
				}
				emit fileModified();
			}
			else{	
				qDebug("Insert before sibling '%s'",((char*)Item->text(0).toUtf8().data()));
				if(DragItem->parent()){
					DragItem->parent()->takeChild(DragItem->parent()->indexOfChild(DragItem));
				}
				else{
					takeTopLevelItem(indexOfTopLevelItem(DragItem));
				}				
				if(Item->parent()){
					int index=Item->parent()->indexOfChild(Item);
					db->moveGroup(DragItem->GroupHandle,((GroupViewItem*)Item->parent())->GroupHandle,index);
					Item->parent()->insertChild(index,DragItem);
				}
				else{
					int index=indexOfTopLevelItem(Item);
					db->moveGroup(DragItem->GroupHandle,NULL,index);
					insertTopLevelItem(index,DragItem);	
				}
				emit fileModified();	
			}
		}
		
		
	}
	
}

void KeepassGroupView::entryDragMoveEvent(QDragMoveEvent* event){

	GroupViewItem* Item=(GroupViewItem*)itemAt(event->pos());
	if(!Item){
		if(LastHoverItem){
			LastHoverItem->setBackgroundColor(0,QApplication::palette().color(QPalette::Base));
			LastHoverItem->setForeground(0,QBrush(QApplication::palette().color(QPalette::Text)));
			LastHoverItem=NULL;
		}
		event->ignore();
		return;
	}
	if(Item==SearchResultItem){
		if(LastHoverItem){
			LastHoverItem->setBackgroundColor(0,QApplication::palette().color(QPalette::Base));
			LastHoverItem->setForeground(0,QBrush(QApplication::palette().color(QPalette::Text)));
			LastHoverItem=NULL;
		}
		event->ignore();
		return;
	}
	if(LastHoverItem != Item){
		if(LastHoverItem){
			LastHoverItem->setBackgroundColor(0,QApplication::palette().color(QPalette::Base));
			LastHoverItem->setForeground(0,QBrush(QApplication::palette().color(QPalette::Text)));
		}
		Item->setBackgroundColor(0,QApplication::palette().color(QPalette::Highlight));
		Item->setForeground(0,QBrush(QApplication::palette().color(QPalette::HighlightedText)));
		LastHoverItem=Item;
	}
	event->acceptProposedAction();
	return;
	
}

void KeepassGroupView::dragMoveEvent(QDragMoveEvent* event){
	if(DragType==EntryDrag){
		entryDragMoveEvent(event);
		return;
	}	
	if(DragItem){
		GroupViewItem* Item=(GroupViewItem*)itemAt(event->pos());
		if(!Item){
			if(LastHoverItem){
				LastHoverItem->setBackgroundColor(0,QApplication::palette().color(QPalette::Base));
				LastHoverItem=NULL;
			}
			if(InsLinePos!=-1){
				int RemoveLine=InsLinePos;
				InsLinePos=-1;
				viewport()->update(QRegion(0,RemoveLine-2,viewport()->width(),4));
			}
			event->acceptProposedAction();
			return;
		}
		if(Item==DragItem || Item==SearchResultItem){
			event->ignore();
			return;
		}
		if(!db->isParent(DragItem->GroupHandle,Item->GroupHandle)){
			QRect ItemRect=visualItemRect(Item);
			if(event->pos().y()>ItemRect.y()+2 && event->pos().y()<ItemRect.y()+ItemRect.height()-2){
				if(InsLinePos!=-1){
					int RemoveLine=InsLinePos;
					InsLinePos=-1;
					viewport()->update(QRegion(0,RemoveLine-2,viewport()->width(),4));
				}
				if(LastHoverItem != Item){
					if(LastHoverItem){
						LastHoverItem->setBackgroundColor(0,QApplication::palette().color(QPalette::Base));
					}
					Item->setBackgroundColor(0,QApplication::palette().color(QPalette::Highlight));
					LastHoverItem=Item;
				}
			}
			else{
				if(LastHoverItem){
					LastHoverItem->setBackgroundColor(0,QApplication::palette().color(QPalette::Base));
					LastHoverItem=NULL;
				}
				if(InsLinePos!=-1){
					int RemoveLine=InsLinePos;
					InsLinePos=-1;
					viewport()->update(QRegion(0,RemoveLine-2,viewport()->width(),4));
				}
				if(event->pos().y()>ItemRect.y()+2){
					InsLinePos=ItemRect.y()+ItemRect.height();
				}
				else{	
					InsLinePos=ItemRect.y();
				}
				InsLineStart=ItemRect.x();
				viewport()->update(QRegion(0,InsLinePos-2,viewport()->width(),4));
			}
			event->acceptProposedAction();
			return;
		}		
		
	}
	event->ignore();
}

void KeepassGroupView::paintEvent(QPaintEvent* event){

	QTreeWidget::paintEvent(event);
	if(InsLinePos != -1){
		QPainter painter(viewport());
		painter.setBrush(QBrush(QColor(0,0,0),Qt::Dense4Pattern));
		painter.setPen(Qt::NoPen);
		painter.drawRect(InsLineStart,InsLinePos-2,viewport()->width(),4);
	}
}


void KeepassGroupView::mousePressEvent(QMouseEvent *event){
	if (event->button() == Qt::LeftButton)
		DragStartPos = event->pos();
	QTreeWidget::mousePressEvent(event);	
}

void KeepassGroupView::mouseMoveEvent(QMouseEvent *event){
	if (!(event->buttons() & Qt::LeftButton))
		return;
	if ((event->pos() - DragStartPos).manhattanLength()
			< QApplication::startDragDistance())
		return;
	
	DragItem=(GroupViewItem*)itemAt(event->pos());
	if(!DragItem)return;
	
	if(DragItem==SearchResultItem){
		qDebug("SearchGroup");
		DragItem=NULL;
		return;
	}
	
	setCurrentItem(DragItem);
	
	QDrag *drag = new QDrag(this);
	QMimeData *mimeData = new QMimeData;

	mimeData->setData("application/x-keepassx-group",QByteArray());
	drag->setMimeData(mimeData);

	EventOccurredBlock = true;
	drag->exec(Qt::MoveAction);
	EventOccurredBlock = false;
}

void KeepassGroupView::OnItemExpanded(QTreeWidgetItem* item){
	static_cast<GroupViewItem*>(item)->GroupHandle->setExpanded(true);
}

void KeepassGroupView::OnItemCollapsed(QTreeWidgetItem* item){
	static_cast<GroupViewItem*>(item)->GroupHandle->setExpanded(false);
}

void KeepassGroupView::OnSort() {
	QHash<QTreeWidgetItem*,int> oldIndex;
	for (int i=0; i<Items.size(); i++) {
		if (Items[i]->parent())
			oldIndex.insert(Items[i], Items[i]->parent()->indexOfChild(Items[i]));
		else
			oldIndex.insert(Items[i], invisibleRootItem()->indexOfChild(Items[i]));
	}
	
	sortItems(0, Qt::AscendingOrder);
	
	bool modified = false;
	QMutableHashIterator<QTreeWidgetItem*, int> i(oldIndex);
	while (i.hasNext()) {
		i.next();
		int newIndex;
		IGroupHandle* parent;
		if (i.key()->parent()) {
			newIndex = i.key()->parent()->indexOfChild(i.key());
			parent = static_cast<GroupViewItem*>(i.key()->parent())->GroupHandle;
		}
		else {
			newIndex = invisibleRootItem()->indexOfChild(i.key());
			parent = NULL;
		}
		
		if (newIndex != i.value()) {
			db->moveGroup(static_cast<GroupViewItem*>(i.key())->GroupHandle, parent, newIndex);
			modified = true;
		}
	}
	
	if (modified)
		emit fileModified();
}



GroupViewItem::GroupViewItem():QTreeWidgetItem(){
}

GroupViewItem::GroupViewItem(QTreeWidget *parent):QTreeWidgetItem(parent){
}

GroupViewItem::GroupViewItem(QTreeWidget *parent, QTreeWidgetItem *preceding):QTreeWidgetItem(parent,preceding){
}

GroupViewItem::GroupViewItem(QTreeWidgetItem *parent):QTreeWidgetItem(parent){
}

GroupViewItem::GroupViewItem(QTreeWidgetItem *parent, QTreeWidgetItem *preceding):QTreeWidgetItem(parent,preceding){
}

bool GroupViewItem::operator<(const QTreeWidgetItem& other) const {
	const GroupViewItem* otherItem = static_cast<const GroupViewItem*>(&other);
	KeepassGroupView* groupView = static_cast<KeepassGroupView*>(treeWidget());
	
	// Search result is always at the bottom
	if (this == groupView->SearchResultItem)
		return false;
	if (otherItem == groupView->SearchResultItem)
		return true;
	
	// Backup group is always at the bottom but above search results
	if (!parent() && text(0).compare("Backup", Qt::CaseInsensitive) == 0)
		return false;
	if (!other.parent() && other.text(0).compare("Backup", Qt::CaseInsensitive) == 0)
		return true;
	
	return QString::localeAwareCompare(text(0), other.text(0)) < 0;
}
