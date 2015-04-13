/***************************************************************************
 *   Copyright (C) 2005-2008 by Tarek Saidi, Felix Geyer                   *
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

#include "AutoTypeGlobalX11.h"

#include "mainwindow.h"
#include "lib/HelperX11.h"
#include "dialogs/AutoTypeDlg.h"
#include <QX11Info>

AutoTypeGlobal* autoType = NULL;

void initAutoType(KeepassMainWindow* mainWin) {
	autoType = new AutoTypeGlobalX11(mainWin);
}

AutoTypeGlobalX11::AutoTypeGlobalX11(KeepassMainWindow* mainWin) : AutoTypeX11(mainWin) {
	wm_state = XInternAtom(dpy, "WM_STATE", true);
	windowRoot = XRootWindow(dpy, mainWin->x11Info().screen());
	shortcut.key = 0;
	focusedWindow = 0;
	oldCode = 0;
	oldMod = 0;
	inGlobalAutoType = false;
	
	//windowBlacklist << "kicker" << "KDE Desktop";
	classBlacklist << "desktop_window" << "gnome-panel"; // Gnome
	classBlacklist << "kdesktop" << "kicker"; // KDE 3
	classBlacklist << "Plasma"; // KDE 4
	classBlacklist << "xfdesktop" << "xfce4-panel"; // Xfce 4
}

void AutoTypeGlobalX11::updateKeymap() {
	AutoTypeX11::updateKeymap();
	registerGlobalShortcut(shortcut);
}

void AutoTypeGlobalX11::perform(IEntryHandle* entry, bool hideWindow, int nr, bool wasLocked){
	if (inGlobalAutoType)
		return;
	inGlobalAutoType = true;
	
	if (focusedWindow && (!hideWindow || wasLocked)) { // detect if global auto-type
		XSetInputFocus(dpy, focusedWindow, RevertToPointerRoot, CurrentTime);
		focusedWindow = 0;
	}
	else {
		focusWindow = NULL;
	}
	
	AutoTypeX11::perform(entry, hideWindow, nr, wasLocked);
	
	inGlobalAutoType = false;
}

void AutoTypeGlobalX11::windowTitles(Window window, QStringList& titleList){
	Atom type = None;
	int format;
	unsigned long nitems, after;
	unsigned char* data;
	XGetWindowProperty(dpy, window, wm_state, 0, 0, false, AnyPropertyType, &type, &format, &nitems, &after, &data);
	if (type){
		XTextProperty textProp;
		if (XGetWMName(dpy, window, &textProp) != 0) {
			char** list = NULL;
			int count;
			if (Xutf8TextPropertyToTextList(dpy, &textProp, &list, &count)>=0 && list){
				QString title = QString::fromUtf8(list[0]);
				
				QString className;
				XClassHint* wmClass = XAllocClassHint();
				if (XGetClassHint(dpy, window, wmClass)!=0 && wmClass->res_name!=NULL)
					className = QString::fromLocal8Bit(wmClass->res_name);
				XFree(wmClass);
				
				if (window!=windowRoot && window!=mainWin->winId() &&
						(QApplication::activeWindow()==NULL || window!=QApplication::activeWindow()->winId()) &&
						// !windowBlacklist.contains(title) &&
						(className.isNull() || !classBlacklist.contains(className))
				){
					titleList.append(title);
				}
				XFreeStringList(list);
			}
		}
	}
	
	Window root;
	Window parent;
	Window* children = NULL;
	unsigned int num_children;
	int tree = XQueryTree(dpy, window, &root, &parent, &children, &num_children);
	if (tree && children) {
		for (uint i=0; i<num_children; i++)
			windowTitles(children[i], titleList);
	}
	else {
		XFree(children);
	}
}
 
 QStringList AutoTypeGlobalX11::getAllWindowTitles(){
	QStringList titleList;
	if (wm_state) // don't do anything if WM_STATE doesn't exist
		windowTitles(windowRoot, titleList);
	return titleList;
}

void AutoTypeGlobalX11::performGlobal(){
	if (AutoTypeDlg::isDialogVisible()) {
		qWarning("Already performing auto-type, ignoring this one");
		return;
	}
	
	focusWindow = getFocusWindow();
	
	bool wasLocked = mainWin->isLocked();
	if (wasLocked)
		mainWin->OnUnLockWorkspace();
	
	if (!mainWin->isOpened())
		return;
	
	Window w;
	int revert_to_return;
	XGetInputFocus(dpy, &w, &revert_to_return);
	char** list = NULL;
	int tree;
	do {
		XTextProperty textProp;
		if (XGetWMName(dpy, w, &textProp) != 0) {
			int count;
			if (Xutf8TextPropertyToTextList(dpy, &textProp, &list, &count)<0) return;
			if (list) break;
		}
		Window root = 0;
		Window parent = 0;
		Window* children = NULL;
		unsigned int num_children;
		tree = XQueryTree(dpy, w, &root, &parent, &children, &num_children);
		w = parent;
		if (children) XFree(children);
	} while (tree && w);
	if (!list) return;
	QString title = QString::fromUtf8(list[0]).toLower();
	XFreeStringList(list);
	
	QList<IEntryHandle*> validEntries;
	QList<int> entryNumbers;
	QList<IEntryHandle*> entries = mainWin->db->entries();
	QRegExp lineMatch("Auto-Type-Window(?:-(\\d+)|):([^\\n]+)", Qt::CaseInsensitive, QRegExp::RegExp2);
	QDateTime now = QDateTime::currentDateTime();
	for (int i=0; i<entries.size(); i++){
		if ( (entries[i]->expire()!=Date_Never && entries[i]->expire()<now) ||
			 (getRootGroupName(entries[i]).compare("backup",Qt::CaseInsensitive)==0)
		){
			continue;
		}
		
		bool hasWindowEntry=false;
		QString comment = entries[i]->comment();
		int offset = 0;
		while ( (offset=lineMatch.indexIn(comment, offset))!=-1 ){
			QStringList captured = lineMatch.capturedTexts();
			offset += captured[0].length();
			int nr;
			QString entryWindow;
			bool valid;
			if (captured.size()==2){
				nr = 0;
				entryWindow = captured[1].trimmed().toLower();
			}
			else{
				nr = captured[1].toInt();
				entryWindow = captured[2].trimmed().toLower();
			}
			if (entryWindow.length()==0) continue;
			
			hasWindowEntry = true;
			bool wildStart = (entryWindow[0]=='*');
			bool wildEnd = (entryWindow[entryWindow.size()-1]=='*');
			if (wildStart&&wildEnd){
				entryWindow.remove(0,1);
				if (entryWindow.length()!=0){
					entryWindow.remove(entryWindow.size()-1,1);
					valid = title.contains(entryWindow);
				}
				else
					valid = true;
			}
			else if (wildStart){
				entryWindow.remove(0,1);
				valid = title.endsWith(entryWindow);
			}
			else if (wildEnd){
				entryWindow.remove(entryWindow.size()-1,1);
				valid = title.startsWith(entryWindow);
			}
			else {
				valid = (title==entryWindow);
			}
			
			if (valid){
				validEntries << entries[i];
				entryNumbers << nr;
				break;
			}
		}
		
		if (!hasWindowEntry && config->entryTitlesMatch()){
			QString entryTitle = entries[i]->title().toLower();
			if (!entryTitle.isEmpty() && title.contains(entryTitle)){
				validEntries << entries[i];
				entryNumbers << 0;
			}
		}
	}
	
	if (validEntries.size()==1){
		focusedWindow = 0;
		perform(validEntries[0],wasLocked,entryNumbers[0],wasLocked);
	}
	else if (validEntries.size()>1){
		focusedWindow = w;
		AutoTypeDlg* dlg = new AutoTypeDlg(validEntries, entryNumbers, wasLocked);
		dlg->show();
	}
}

bool AutoTypeGlobalX11::registerGlobalShortcut(const Shortcut& s){
	if (s.key == 0)
		return false;
	
	int code=XKeysymToKeycode(dpy, HelperX11::getKeysym(s.key));
	uint mod=HelperX11::getShortcutModifierMask(s);
	
	if (s.key==shortcut.key && s.ctrl==shortcut.ctrl && s.shift==shortcut.shift && s.alt==shortcut.alt && s.altgr==shortcut.altgr && s.win==shortcut.win && code==oldCode && mod==oldMod)
		return true;
	
	HelperX11::startCatchErrors();
	XGrabKey(dpy, code, mod, windowRoot, true, GrabModeAsync, GrabModeAsync);
	XGrabKey(dpy, code, mod | Mod2Mask, windowRoot, true, GrabModeAsync, GrabModeAsync);
	XGrabKey(dpy, code, mod | LockMask, windowRoot, true, GrabModeAsync, GrabModeAsync);
	XGrabKey(dpy, code, mod | Mod2Mask | LockMask, windowRoot, true, GrabModeAsync, GrabModeAsync);
	HelperX11::stopCatchErrors();
	
	if (HelperX11::errorOccurred()){
		XUngrabKey(dpy, code, mod, windowRoot);
		XUngrabKey(dpy, code, mod | Mod2Mask, windowRoot);
		XUngrabKey(dpy, code, mod | LockMask, windowRoot);
		XUngrabKey(dpy, code, mod | Mod2Mask | LockMask, windowRoot);
		return false;
	}
	else {
		unregisterGlobalShortcut();
		shortcut = s;
		oldCode = code;
		oldMod = mod;
		return true;
	}
}

void AutoTypeGlobalX11::unregisterGlobalShortcut(){
	if (shortcut.key==0) return;
	
	XUngrabKey(dpy, oldCode, oldMod, windowRoot);
	XUngrabKey(dpy, oldCode, oldMod | Mod2Mask, windowRoot);
	XUngrabKey(dpy, oldCode, oldMod | LockMask, windowRoot);
	XUngrabKey(dpy, oldCode, oldMod | Mod2Mask | LockMask, windowRoot);
	
	shortcut.key = 0;
	oldCode = 0;
	oldMod = 0;
}

QString AutoTypeGlobalX11::getRootGroupName(IEntryHandle* entry){
	IGroupHandle* group = entry->group();
	int level = group->level();
	for (int i=0; i<level; i++)
		group = group->parent();
	
	return group->title();
}
