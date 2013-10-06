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

#include <QHeaderView>
#include <QClipboard>
#include <QProcess>
#include <algorithm>
#include "lib/AutoType.h"
#include "lib/EntryView.h"
#include "dialogs/EditEntryDlg.h"

#define NUM_COLUMNS 11

// just for the lessThan funtion
/*QList<EntryViewItem*>* pItems;
KeepassEntryView* pEntryView;*/

KeepassEntryView::KeepassEntryView(QWidget* parent) : QTreeWidget(parent) {
	ViewMode=Normal;
	AutoResizeColumns = true;
	header()->setResizeMode(QHeaderView::Interactive);
	header()->setStretchLastSection(false);
	header()->setClickable(true);
	header()->setCascadingSectionResizes(true);
	setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
	retranslateColumns();
	restoreHeaderView();
	
	connect(header(), SIGNAL(sectionResized(int,int,int)), SLOT(resizeColumns()));
	connect(this,SIGNAL(itemSelectionChanged()), SLOT(OnItemsChanged()));
	connect(&ClipboardTimer, SIGNAL(timeout()), SLOT(OnClipboardTimeOut()));
	connect(this, SIGNAL(itemActivated(QTreeWidgetItem*,int)), SLOT(OnEntryActivated(QTreeWidgetItem*,int)));
	connect(this, SIGNAL(itemDoubleClicked(QTreeWidgetItem*,int)), SLOT(OnEntryDblClicked(QTreeWidgetItem*,int)));
	Clipboard=QApplication::clipboard();
	ContextMenu=new QMenu(this);
	setAlternatingRowColors(config->alternatingRowColors());

	/*pItems=&Items;
	pEntryView=this;*/
}

KeepassEntryView::~KeepassEntryView(){
	saveHeaderView();
	if (ClipboardTimer.isActive()) {
		ClipboardTimer.stop();
		OnClipboardTimeOut();
	}
}

void KeepassEntryView::retranslateColumns() {
	setHeaderLabels( QStringList() << tr("Title") << tr("Username") << tr("URL") << tr("Password") << tr("Comments")
		<< tr("Expires") << tr("Creation") << tr("Last Change") << tr("Last Access") << tr("Attachment") << tr("Group") );
}

bool KeepassEntryView::columnVisible(int col) {
	return !header()->isSectionHidden(col);
}

void KeepassEntryView::setColumnVisible(int col, bool visible) {
	if (columnVisible(col) == visible)
		return; // nothing to do
	
	header()->setSectionHidden(col, !visible);
	if (visible)
		header()->resizeSection(col, columnSizes[col]);
}

void KeepassEntryView::saveHeaderView() {
	QBitArray columns(NUM_COLUMNS);
	QList<int> columnOrder;
	int columnSort = header()->sortIndicatorSection();
	Qt::SortOrder columnSortOrder = header()->sortIndicatorOrder();
	
	for (int i=0; i<NUM_COLUMNS; ++i) {
		columns.setBit(i, columnVisible(i));
		columnOrder << header()->visualIndex(i);
	}
	
	if (ViewMode == Normal) {
		config->setColumns(columns);
		config->setColumnOrder(columnOrder);
		config->setColumnSizes(columnSizes);
		config->setColumnSort(columnSort);
		config->setColumnSortOrder(columnSortOrder);
	}
	else {
		config->setSearchColumns(columns);
		config->setSearchColumnOrder(columnOrder);
		config->setSearchColumnSizes(columnSizes);
		config->setSearchColumnSort(columnSort);
		config->setSearchColumnSortOrder(columnSortOrder);
	}
}

void KeepassEntryView::restoreHeaderView() {
	AutoResizeColumns = false;
	
	QBitArray columns;
	QList<int> columnOrder;
	int columnSort;
	Qt::SortOrder columnSortOrder;
	
	if (ViewMode == Normal) {
		columns = config->columns();
		columnOrder = config->columnOrder();
		columnSizes = config->columnSizes();
		columnSort = config->columnSort();
		columnSortOrder = config->columnSortOrder();
		columns[10] = 0; // just to be sure
	}
	else {
		columns = config->searchColumns();
		columnOrder = config->searchColumnOrder();
		columnSizes = config->searchColumnSizes();
		columnSort = config->searchColumnSort();
		columnSortOrder = config->searchColumnSortOrder();
	}
	
	// compatibility with KeePassX <= 0.4.0 (100 = column hidden)
	int lastVisibleIndex = -1;
	for (int i=0; i<NUM_COLUMNS; ++i) {
		if (columnOrder[i]!=100 && columnOrder[i]>lastVisibleIndex)
			lastVisibleIndex = columnOrder[i];
	}
	
	QMap<int,int> order; // key=visual index; value=logical index
	for (int i=0; i<NUM_COLUMNS; ++i) {
		if (columnOrder[i] == 100)
			columnOrder[i] = ++lastVisibleIndex;
		
		order.insert(columnOrder[i], i);
		setColumnVisible(i, false); // initally hide all columns
		if (columnSizes[i] < header()->minimumSectionSize())
			columnSizes[i] = header()->minimumSectionSize();
	}
	
	for (QMap<int,int>::const_iterator i = order.constBegin(); i != order.constEnd(); ++i) {
		header()->moveSection(header()->visualIndex(i.value()), NUM_COLUMNS-1);
		header()->resizeSection(i.value(), columnSizes[i.value()]);
		setColumnVisible(i.value(), columns.testBit(i.value()));
	}
	
	header()->setSortIndicator(columnSort, columnSortOrder);
	
	AutoResizeColumns = true;
	
	resizeColumns();
}

void KeepassEntryView::resizeColumns() {
	if (!AutoResizeColumns)
		return;
	
	AutoResizeColumns = false;
	
	int w = viewport()->width();
	int sum = 0;
	
	for (int i=0; i<NUM_COLUMNS; ++i) {
		if (columnVisible(i))
			sum += header()->sectionSize(i);
	}
	
	double stretch = (double)w / (double)sum;
	
	for (int i=0; i<NUM_COLUMNS; ++i) {
		if (columnVisible(i) && header()->sectionSize(i)!=0) {
			int size = qRound(header()->sectionSize(i) * stretch);
			header()->resizeSection(i, size);
			columnSizes[i] = size;
		}
		else {
			columnSizes[i] = qRound(columnSizes[i] * stretch);
		}
	}
	
	AutoResizeColumns = true;
}

void KeepassEntryView::OnGroupChanged(IGroupHandle* group){
	CurrentGroup=group;
	showGroup(group);
}

void KeepassEntryView::OnShowSearchResults(){
	CurrentGroup=NULL;
	showSearchResults();
}

void KeepassEntryView::OnItemsChanged(){
	switch(selectedItems().size()){
		case 0:	emit selectionChanged(NONE);
				break;
		case 1:	emit selectionChanged(SINGLE);
				break;
		default:emit selectionChanged(MULTIPLE);
	}
}

void KeepassEntryView::OnSaveAttachment(){
	if (selectedItems().size() == 0) return;
	CEditEntryDlg::saveAttachment(((EntryViewItem*)selectedItems().first())->EntryHandle,this);
}

void KeepassEntryView::OnCloneEntry(){
	QList<QTreeWidgetItem*> entries=selectedItems();
	for(int i=0; i<entries.size();i++){
		Items.append(new EntryViewItem(this));
		Items.back()->EntryHandle=
			db->cloneEntry(((EntryViewItem*)entries[i])->EntryHandle);
		updateEntry(Items.back());
	}
	if (header()->isSortIndicatorShown())
		sortByColumn(header()->sortIndicatorSection(), header()->sortIndicatorOrder());
	emit fileModified();
}

void KeepassEntryView::OnDeleteEntry(){
	QList<QTreeWidgetItem*> entries=selectedItems();
	
	if(config->askBeforeDelete()){
		QString text;
		if(entries.size()==1)
			text=tr("Are you sure you want to delete this entry?");
		else
			text=tr("Are you sure you want to delete these %1 entries?").arg(entries.size());
		if(QMessageBox::question(this,tr("Delete?"),text,QMessageBox::Yes | QMessageBox::No,QMessageBox::No)==QMessageBox::No)
			return;
	}
	
	bool backup = false;
	IGroupHandle* bGroup = NULL;
	if (config->backup() && ((EntryViewItem*)entries[0])->EntryHandle->group() != (bGroup=db->backupGroup()))
		backup = true;
	if (backup && !bGroup) {
		emit requestCreateGroup("Backup", 4, NULL);
		bGroup = db->backupGroup();
	}
	for(int i=0; i<entries.size();i++){
		IEntryHandle* entryHandle = ((EntryViewItem*)entries[i])->EntryHandle;
		if (backup && bGroup){
			db->moveEntry(entryHandle, bGroup);
			QDateTime now = QDateTime::currentDateTime();
			entryHandle->setLastAccess(now);
			entryHandle->setLastMod(now);
		}
		else{
			db->deleteEntry(entryHandle);
		}
		Items.removeAt(Items.indexOf((EntryViewItem*)entries[i]));
		delete entries[i];
	}
	emit fileModified();
}

QString KeepassEntryView::columnString(IEntryHandle* entry, int col, bool forceClearText) {
	switch (col) {
		case 0:
			return entry->title();
		case 1:
			if (config->hideUsernames() && !forceClearText)
				return "******";
			else
				return entry->username();
		case 2:
			return entry->url();
		case 3:
		{
			if (config->hidePasswords() && !forceClearText) {
				return "******";
			}
			else {
				SecString password = entry->password();
				password.unlock();
				return password.string();
			}
		}
		case 4:
		{
			QString comment = entry->comment();
			int toPos = comment.indexOf(QRegExp("[\\r\\n]"));
			if (toPos == -1)
				return comment;
			else
				return comment.left(toPos);
		}
		case 5:
			return entry->expire().dateToString(Qt::SystemLocaleDate);
		case 6:
			return entry->creation().dateToString(Qt::SystemLocaleDate);
		case 7:
			return entry->lastMod().dateToString(Qt::SystemLocaleDate);
		case 8:
			return entry->lastAccess().dateToString(Qt::SystemLocaleDate);
		case 9:
			return entry->binaryDesc();
		case 10:
			return entry->group()->title();
		default:
			Q_ASSERT(false);
			return QString();
	}
}

void KeepassEntryView::updateEntry(EntryViewItem* item){
	IEntryHandle* entry = item->EntryHandle;
	
	int cols = NUM_COLUMNS - 1;
	if (ViewMode == ShowSearchResults) {
		item->setIcon(10, db->icon(entry->group()->image()));
		++cols;
	}
	
	for (int i=0; i<cols; ++i) {
		item->setText(i, columnString(entry, i));
	}
	item->setIcon(0, db->icon(entry->image()));
}

void KeepassEntryView::editEntry(EntryViewItem* item){
	IEntryHandle* handle = item->EntryHandle;
	CEntry old = handle->data();
	
	CEditEntryDlg dlg(db,handle,this,true);
	int result = dlg.exec();
	switch(result){
		case 0: //canceled or no changes
			break;
		case 1: //modifications but same group
			updateEntry(item);
			emit fileModified();
			break;
		//entry moved to another group
		case 2: //modified
		case 3: //not modified
			Items.removeAll(item);
			delete item;
			emit fileModified();
			break;
	}
	
	IGroupHandle* bGroup;
	if ((result==1 || result==2) && config->backup() && handle->group() != (bGroup=db->backupGroup())){
		old.LastAccess = QDateTime::currentDateTime();
		old.LastMod = old.LastAccess;
		if (bGroup==NULL)
			emit requestCreateGroup("Backup", 4, NULL);
		if ((bGroup = db->backupGroup())!=NULL)
			db->addEntry(&old, bGroup);
	}
	
	if (result == 1)
		OnItemsChanged();
}


void KeepassEntryView::OnNewEntry(){
	IGroupHandle* ParentGroup;
	
	if (!CurrentGroup){ // We must be viewing search results. Add the new entry to the first group.
		if (db->groups().size() > 0)
			ParentGroup = db->sortedGroups()[0];
			
		else{
			QMessageBox::critical(NULL,tr("Error"),tr("At least one group must exist before adding an entry."),tr("OK"));
		}
	}
	else{
		ParentGroup = CurrentGroup;
	}
	
	IEntryHandle* NewEntry = db->newEntry(ParentGroup);
	NewEntry->setImage(ParentGroup->image());
	
	CEditEntryDlg dlg(db,NewEntry,this,true);
	if(!dlg.exec()){
		db->deleteLastEntry();
	}
	else{
		Items.append(new EntryViewItem(this));
		Items.back()->EntryHandle=NewEntry;
		updateEntry(Items.back());
		emit fileModified();
		if (header()->isSortIndicatorShown())
			sortByColumn(header()->sortIndicatorSection(), header()->sortIndicatorOrder());
		setCurrentItem(Items.back());
	}

}

void KeepassEntryView::OnEntryActivated(QTreeWidgetItem* item, int Column){
	Q_UNUSED(item);
	
	switch (Column){
		case 1:
			OnUsernameToClipboard();
			break;
		case 2:
			OnEditOpenUrl();
			break;
		case 3:
			OnPasswordToClipboard();
			break;
	}
}

void KeepassEntryView::OnEntryDblClicked(QTreeWidgetItem* item, int Column){
	if (Column == 0)
		editEntry((EntryViewItem*)item);
}

void KeepassEntryView::OnEditEntry(){
	if (selectedItems().size() == 0) return;
	editEntry((EntryViewItem*)selectedItems().first());
}

void KeepassEntryView::OnEditOpenUrl(){
	if (selectedItems().size() == 0) return;
	openBrowser( ((EntryViewItem*)selectedItems().first())->EntryHandle );
}

void KeepassEntryView::OnEditCopyUrl(){
	if (selectedItems().size() == 0) return;
	QString url = ((EntryViewItem*)selectedItems().first())->EntryHandle->url();
	if (url.startsWith("cmd://") && url.length()>6)
		url = url.right(url.length()-6);
	
	Clipboard->setText(url,  QClipboard::Clipboard);
	if(Clipboard->supportsSelection()){
		Clipboard->setText(url, QClipboard::Selection);
	}
}

void KeepassEntryView::OnUsernameToClipboard(){
	if (selectedItems().size() == 0) return;
	QString username = ((EntryViewItem*)selectedItems().first())->EntryHandle->username();
	Clipboard->setText(username,  QClipboard::Clipboard);
	if(Clipboard->supportsSelection()){
		Clipboard->setText(username, QClipboard::Selection);
	}
	
	if (config->clipboardTimeOut()!=0 && !username.trimmed().isEmpty()) {
		ClipboardTimer.setSingleShot(true);
		ClipboardTimer.start(config->clipboardTimeOut()*1000);
	}
}

void KeepassEntryView::OnPasswordToClipboard(){
	if (selectedItems().size() == 0) return;
	SecString password;
	password=((EntryViewItem*)selectedItems().first())->EntryHandle->password();
	password.unlock();
	Clipboard->setText(password.string(), QClipboard::Clipboard);
	if(Clipboard->supportsSelection()){
		Clipboard->setText(password.string(), QClipboard::Selection);
	}
	
	if (config->clipboardTimeOut()!=0 && !password.string().isEmpty()) {
		ClipboardTimer.setSingleShot(true);
		ClipboardTimer.start(config->clipboardTimeOut()*1000);
	}
}

void KeepassEntryView::OnClipboardTimeOut(){
	Clipboard->clear(QClipboard::Clipboard);
	if(Clipboard->supportsSelection()){
		Clipboard->clear(QClipboard::Selection);
	}
#ifdef Q_WS_X11
	QProcess::startDetached("dcop klipper klipper clearClipboardHistory");
	QProcess::startDetached("dbus-send --type=method_call --dest=org.kde.klipper /klipper "
		"org.kde.klipper.klipper.clearClipboardHistory");
#endif
}


void KeepassEntryView::contextMenuEvent(QContextMenuEvent* e){
	if(itemAt(e->pos())){
		EntryViewItem* item=(EntryViewItem*)itemAt(e->pos());
		if(!selectedItems().size()){
			setItemSelected(item,true);
		}
		else{
				if(!isItemSelected(item)){
					while(selectedItems().size()){
						setItemSelected(selectedItems().first(),false);
					}
					setItemSelected(item,true);
				}
			}
	}
	else{
		while (selectedItems().size())
			setItemSelected(selectedItems().first(),false);
	}
	e->accept();
	ContextMenu->popup(e->globalPos());
}

void KeepassEntryView::resizeEvent(QResizeEvent* e){
	resizeColumns();
	QTreeWidget::resizeEvent(e);
}


void KeepassEntryView::showSearchResults(){
	if(ViewMode == Normal){
		saveHeaderView();
		ViewMode = ShowSearchResults;
		restoreHeaderView();
		emit viewModeChanged(true);
	}
	clear();
	Items.clear();
	createItems(SearchResults);
}


void KeepassEntryView::showGroup(IGroupHandle* group){
	if(ViewMode == ShowSearchResults){
		saveHeaderView();
		ViewMode = Normal;
		restoreHeaderView();
		emit viewModeChanged(false);
	}
	clear();
	Items.clear();
	if(group==NULL)return;
	QList<IEntryHandle*>entries=db->entries(group);
	createItems(entries);
}

void KeepassEntryView::createItems(QList<IEntryHandle*>& entries){
	for (int i=0; i<entries.size(); ++i) {
		if (!entries[i]->isValid())
			continue;
		
		EntryViewItem* item = new EntryViewItem(this);
		Items.push_back(item);
		Items.back()->EntryHandle = entries[i];
		
		updateEntry(item);
	}
}

void KeepassEntryView::updateIcons(){
	for(int i=0;i<Items.size();i++){
		Items[i]->setIcon(0,db->icon(Items[i]->EntryHandle->image()));
	}
}

void KeepassEntryView::refreshItems(){
	for (int i=0;i<Items.size();i++)
		updateEntry(Items.at(i));
}

void KeepassEntryView::mousePressEvent(QMouseEvent *event){
	//save event position - maybe this is the start of a drag
	if (event->button() == Qt::LeftButton)
		DragStartPos = event->pos();
	QTreeWidget::mousePressEvent(event);
}

void KeepassEntryView::mouseMoveEvent(QMouseEvent *event){
	if (!(event->buttons() & Qt::LeftButton))
		return;
	if ((event->pos() - DragStartPos).manhattanLength() < QApplication::startDragDistance())
		return;

	DragItems.clear();
	EntryViewItem* DragStartItem=(EntryViewItem*)itemAt(DragStartPos);
	if(!DragStartItem){
		while(selectedItems().size()){
			setItemSelected(selectedItems().first(),false);
		}
		return;
	}
	if(selectedItems().isEmpty()){
			setItemSelected(DragStartItem,true);
	}
	else{
		bool AlreadySelected=false;
		for(int i=0;i<selectedItems().size();i++){
			if(selectedItems()[i]==DragStartItem){
				AlreadySelected=true;
				break;
			}
		}
		if(!AlreadySelected){
			while(selectedItems().size()){
				setItemSelected(selectedItems().first(),false);
			}
			setItemSelected(DragStartItem,true);
		}
	}

	DragItems=selectedItems();
	QDrag *drag = new QDrag(this);
	QMimeData *mimeData = new QMimeData;
	void* pDragItems=&DragItems;
	if (header()->logicalIndexAt(event->pos()) != -1) {
		mimeData->setText(columnStringView(DragStartItem, header()->logicalIndexAt(event->pos()), true));
	}
	mimeData->setData("application/x-keepassx-entry",QByteArray((char*)&pDragItems,sizeof(void*)));
	drag->setMimeData(mimeData);
	EventOccurredBlock = true;
	drag->exec(Qt::MoveAction);
	EventOccurredBlock = false;
}

void KeepassEntryView::removeDragItems(){
	for(int i=0;i<DragItems.size();i++){
		for(int j=0;j<Items.size();j++){
			if(Items[j]==DragItems[i]){
				Items.removeAt(j);
				j--;
				delete DragItems[i];
			}
		}
	}
}

#ifdef AUTOTYPE
void KeepassEntryView::OnAutoType(){
	if (selectedItems().size() == 0) return;
	autoType->perform(((EntryViewItem*)selectedItems().first())->EntryHandle);
}
#endif

void KeepassEntryView::paintEvent(QPaintEvent * event){
QTreeWidget::paintEvent(event);
}


EntryViewItem::EntryViewItem(QTreeWidget *parent):QTreeWidgetItem(parent){

}

EntryViewItem::EntryViewItem(QTreeWidget *parent, QTreeWidgetItem *preceding):QTreeWidgetItem(parent,preceding){

}

EntryViewItem::EntryViewItem(QTreeWidgetItem *parent):QTreeWidgetItem(parent){

}

EntryViewItem::EntryViewItem(QTreeWidgetItem *parent, QTreeWidgetItem *preceding):QTreeWidgetItem(parent,preceding){

}


bool EntryViewItem::operator<(const QTreeWidgetItem& other) const{
	int SortCol = treeWidget()->header()->sortIndicatorSection();
	int ListIndex = ((KeepassEntryView*)treeWidget())->header()->logicalIndex(SortCol);
	
	int comp = compare(other, SortCol, ListIndex);
	if (comp!=0)
		return (comp<0);
	else {
		int visibleCols = treeWidget()->header()->count() - treeWidget()->header()->hiddenSectionCount();
		int ListIndexOrg = ListIndex;
		for (int i=0; i<visibleCols; i++){
			SortCol = treeWidget()->header()->logicalIndex(i);
			ListIndex = ((KeepassEntryView*)treeWidget())->header()->logicalIndex(SortCol);
			if (ListIndex==ListIndexOrg || ListIndex==3) // sort or password column
				continue;
			
			comp = compare(other, SortCol, ListIndex);
			if (comp!=0)
				return (comp<0);
		}
		return true; // entries are equal
	}
}

int EntryViewItem::compare(const QTreeWidgetItem& other, int col, int index) const{
	if (index < 5 || index > 8){ //columns with string values (Title, Username, Password, URL, Comment, Group)
		return QString::localeAwareCompare(text(col),other.text(col));
	}
	
	KpxDateTime DateThis;
	KpxDateTime DateOther;

	switch (index){
		case 5:
			DateThis=EntryHandle->expire();
			DateOther=((EntryViewItem&)other).EntryHandle->expire();
			break;
		case 6:
			DateThis=EntryHandle->creation();
			DateOther=((EntryViewItem&)other).EntryHandle->creation();
			break;
		case 7:
			DateThis=EntryHandle->lastMod();
			DateOther=((EntryViewItem&)other).EntryHandle->lastMod();
			break;
		case 8:
			DateThis=EntryHandle->lastAccess();
			DateOther=((EntryViewItem&)other).EntryHandle->lastAccess();
			break;
		default:
			Q_ASSERT(false);
	}
	
	if (DateThis==DateOther)
		return 0;
	else if (DateThis < DateOther)
		return -1;
	else
		return 1;
}

void KeepassEntryView::setCurrentEntry(IEntryHandle* entry){
	bool found=false;
	int i;
	for(i=0;i<Items.size();i++)
		if(Items.at(i)->EntryHandle==entry){found=true; break;}
	if(!found)return;
	setCurrentItem(Items.at(i));
}
