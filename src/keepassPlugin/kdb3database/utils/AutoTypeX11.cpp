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

#include "AutoTypeX11.h"

#include "mainwindow.h"
#include "lib/HelperX11.h"
#include <QX11Info>

#ifndef GLOBAL_AUTOTYPE
AutoType* autoType = NULL;

void initAutoType(KeepassMainWindow* mainWin) {
	autoType = new AutoTypeX11(mainWin);
}
#endif

AutoTypeAction::AutoTypeAction(AutoTypeActionType t, KeySym d) : type(t), data(d){
}

AutoTypeX11::AutoTypeX11(KeepassMainWindow* mainWin) {
	this->mainWin = mainWin;
	dpy = QX11Info::display();
	inAutoType = false;
	
	keysym_table = NULL;
	alt_mask = 0;
	meta_mask = 0;
	altgr_mask = 0;
	altgr_keysym = NoSymbol;
	
	updateKeymap();
	reReadKeymap = false;
}

void AutoTypeX11::updateKeymap() {
	ReadKeymap();
	if (!altgr_mask)
		AddModifier(XK_Mode_switch);
	if (!meta_mask)
		meta_mask = Mod4Mask;
}

Window AutoTypeX11::getFocusWindow() {
	Window w;
	int revert_to_return;
	XGetInputFocus(dpy, &w, &revert_to_return);
	int tree;
	do {
		XTextProperty textProp;
		if (XGetWMName(dpy, w, &textProp) != 0) {
			break;
		}
		Window root = 0;
		Window parent = 0;
		Window* children = NULL;
		unsigned int num_children;
		tree = XQueryTree(dpy, w, &root, &parent, &children, &num_children);
		w = parent;
		if (children) XFree(children);
	} while (tree && w);
	
	return w;
}

void AutoTypeX11::perform(IEntryHandle* entry, bool hideWindow, int nr, bool wasLocked){
	if (inAutoType)
		return;
	inAutoType = true;
	
	QString indexStr;
	if (nr==0)
		indexStr = "Auto-Type:";
	else
		indexStr = QString("Auto-Type-%1:").arg(nr);
	QString str;
	QString comment=entry->comment();
	int c=comment.count(indexStr, Qt::CaseInsensitive);
	if(c>1) {
		qWarning("More than one 'Auto-Type:' key sequence found.\nAllowed is only one per entry.");
		return;
	}
	else if (c==1) {
		int start = comment.indexOf(indexStr,0,Qt::CaseInsensitive) + indexStr.length();
		int end = comment.indexOf("\n", start);
		if (end == -1)
			end = comment.length();
		
		str=comment.mid(start,end-start).trimmed();
		if (str.isEmpty())
			return;
	}
	else {
		bool usernameEmpty = entry->username().trimmed().isEmpty();
		SecString password=entry->password();
		password.unlock();
		bool passwordEmpty = password.string().trimmed().isEmpty();
		if (usernameEmpty && passwordEmpty)
			return;
		else if (usernameEmpty)
			str="{PASSWORD}{ENTER}";
		else if (passwordEmpty)
			str="{USERNAME}{ENTER}";
		else
			str="{USERNAME}{TAB}{PASSWORD}{ENTER}";
	}
	
	QList<AutoTypeAction> Keys;
	for(int i=0;i<str.size();i++){
		if(str[i]=='{'){
			QString tmpl;
			i++;
			while(str[i]!='}' && i<str.size()){
				tmpl += str[i];
				i++;
			}
			if(i>=str.size()){
				qWarning("Syntax Error in Auto-Type sequence near character %d\nFound '{' without closing '}'", i+10);
				return;
			}
			templateToKeysyms(tmpl.toLower(),Keys,entry);
			continue;
		}
		else{
			Keys << AutoTypeAction(TypeKey, str[i].unicode());
		}
	}
	
	/* Re-read keymap before first auto-type,
	   seems to be necessary on X.Org Server 1.6,
	   when KeePassX is in autostart */
	if (!reReadKeymap) {
		updateKeymap();
		reReadKeymap = true;
	}
	
	if (hideWindow)
		mainWin->hide();
	
	QApplication::processEvents();
	sleepTime(config->autoTypePreGap());
	
	if (!focusWindow)
		focusWindow = getFocusWindow();
	
	QString type;
	for(int i=0;i<Keys.size();i++){
		if (focusWindow != getFocusWindow()) {
			qWarning("Focus window changed, interrupting auto-type");
			break;
		}
		
		if (Keys[i].type==TypeKey){
			SendKeyPressedEvent(Keys[i].data, 0);
			sleepKeyStrokeDelay();
		}
		else if (Keys[i].type==Delay){
			QApplication::processEvents();
			sleepTime(Keys[i].data);
		}
	}
	
	if (config->lockOnMinimize()){
		if (hideWindow || wasLocked){
			if ( !(config->showSysTrayIcon() && config->minimizeTray()) )
				mainWin->showMinimized();
			else
				mainWin->OnUnLockWorkspace();
		}
	}
	else{
		if (hideWindow && !(config->showSysTrayIcon() && config->minimizeTray()) )
			mainWin->showMinimized();
	}
	
	inAutoType = false;
	focusWindow = NULL;
}

void AutoTypeX11::sleepTime(int msec){
	if (msec==0) return;
	timespec timeOut, remains;
	timeOut.tv_sec = msec/1000;
	timeOut.tv_nsec = (msec%1000)*1000000;
	nanosleep(&timeOut, &remains);
}

void AutoTypeX11::templateToKeysyms(const QString& tmpl, QList<AutoTypeAction>& keys,IEntryHandle* entry){
	//tmpl must be lower case!!!
	if(!tmpl.compare("title")){
		stringToKeysyms(entry->title(),keys);
		return;
	}
	if(!tmpl.compare("username")){
		stringToKeysyms(entry->username(),keys);
		return;
	}
	if(!tmpl.compare("url")){
		stringToKeysyms(entry->url(),keys);
		return;
	}
	if(!tmpl.compare("password")){
		SecString password=entry->password();
		password.unlock();
		stringToKeysyms(password,keys);
		return;
	}
	if(!tmpl.compare("space")){
		keys << AutoTypeAction(TypeKey, HelperX11::getKeysym(' '));
		return;
	}
	
	if(!tmpl.compare("backspace") || !tmpl.compare("bs") || !tmpl.compare("bksp")){
		keys << AutoTypeAction(TypeKey, XK_BackSpace);
		return;
	}
	
	if(!tmpl.compare("break")){
		keys << AutoTypeAction(TypeKey, XK_Break);
		return;
	}
	
	if(!tmpl.compare("capslock")){
		keys << AutoTypeAction(TypeKey, XK_Caps_Lock);
		return;
	}
	
	if(!tmpl.compare("del") || !tmpl.compare("delete")){
		keys << AutoTypeAction(TypeKey, XK_Delete);
		return;
	}
	
	if(!tmpl.compare("end")){
		keys << AutoTypeAction(TypeKey, XK_End);
		return;
	}
	
	if(!tmpl.compare("enter")){
		keys << AutoTypeAction(TypeKey, XK_Return);
		return;
	}
	
	if(!tmpl.compare("esc")){
		keys << AutoTypeAction(TypeKey, XK_Escape);
		return;
	}
	
	if(!tmpl.compare("help")){
		keys << AutoTypeAction(TypeKey, XK_Help);
		return;
	}
	
	if(!tmpl.compare("home")){
		keys << AutoTypeAction(TypeKey, XK_Home);
		return;
	}
	
	if(!tmpl.compare("insert") || !tmpl.compare("ins")){
		keys << AutoTypeAction(TypeKey, XK_Insert);
		return;
	}
	
	if(!tmpl.compare("numlock")){
		keys << AutoTypeAction(TypeKey, XK_Num_Lock);
		return;
	}
	
	if(!tmpl.compare("scroll")){
		keys << AutoTypeAction(TypeKey, XK_Scroll_Lock);
		return;
	}
	
	if(!tmpl.compare("pgdn")){
		keys << AutoTypeAction(TypeKey, XK_Page_Down);
		return;
	}
	
	if(!tmpl.compare("pgup")){
		keys << AutoTypeAction(TypeKey, XK_Page_Up);
		return;
	}
	
	if(!tmpl.compare("prtsc")){
		keys << AutoTypeAction(TypeKey, XK_3270_PrintScreen);
		return;
	}
	
	if(!tmpl.compare("up")){
		keys << AutoTypeAction(TypeKey, XK_Up);
		return;
	}
	
	if(!tmpl.compare("down")){
		keys << AutoTypeAction(TypeKey, XK_Down);
		return;
	}
	
	if(!tmpl.compare("left")){
		keys << AutoTypeAction(TypeKey, XK_Left);
		return;
	}
	
	if(!tmpl.compare("right")){
		keys << AutoTypeAction(TypeKey, XK_Right);
		return;
	}
	
	if(!tmpl.compare("f1")){
		keys << AutoTypeAction(TypeKey, XK_F1);
		return;
	}
	
	if(!tmpl.compare("f2")){
		keys << AutoTypeAction(TypeKey, XK_F2);
		return;
	}
	
	if(!tmpl.compare("f3")){
		keys << AutoTypeAction(TypeKey, XK_F3);
		return;
	}
	
	if(!tmpl.compare("f4")){
		keys << AutoTypeAction(TypeKey, XK_F4);
		return;
	}
	
	if(!tmpl.compare("f5")){
		keys << AutoTypeAction(TypeKey, XK_F5);
		return;
	}
	
	if(!tmpl.compare("f6")){
		keys << AutoTypeAction(TypeKey, XK_F6);
		return;
	}
	
	if(!tmpl.compare("f7")){
		keys << AutoTypeAction(TypeKey, XK_F7);
		return;
	}
	
	if(!tmpl.compare("f8")){
		keys << AutoTypeAction(TypeKey, XK_F8);
		return;
	}
	
	if(!tmpl.compare("f9")){
		keys << AutoTypeAction(TypeKey, XK_F9);
		return;
	}
	
	if(!tmpl.compare("f10")){
		keys << AutoTypeAction(TypeKey, XK_F10);
		return;
	}
	
	if(!tmpl.compare("f11")){
		keys << AutoTypeAction(TypeKey, XK_F11);
		return;
	}
	
	if(!tmpl.compare("f12")){
		keys << AutoTypeAction(TypeKey, XK_F12);
		return;
	}
	
	if(!tmpl.compare("f13")){
		keys << AutoTypeAction(TypeKey, XK_F13);
		return;
	}
	
	if(!tmpl.compare("f14")){
		keys << AutoTypeAction(TypeKey, XK_F14);
		return;
	}
	
	if(!tmpl.compare("f15")){
		keys << AutoTypeAction(TypeKey, XK_F15);
		return;
	}
	
	if(!tmpl.compare("f16")){
		keys << AutoTypeAction(TypeKey, XK_F16);
		return;
	}
	
	if(!tmpl.compare("add") || !tmpl.compare("plus")){
		keys << AutoTypeAction(TypeKey, HelperX11::getKeysym('+'));
		return;
	}
	
	if(!tmpl.compare("subtract")){
		keys << AutoTypeAction(TypeKey, HelperX11::getKeysym('-'));
		return;
	}
	
	if(!tmpl.compare("multiply")){
		keys << AutoTypeAction(TypeKey, HelperX11::getKeysym('+'));
		return;
	}
	
	if(!tmpl.compare("divide")){
		keys << AutoTypeAction(TypeKey, HelperX11::getKeysym('/'));
		return;
	}
	
	if(!tmpl.compare("at")){
		keys << AutoTypeAction(TypeKey, HelperX11::getKeysym('@'));
		return;
	}
	
	if(!tmpl.compare("percent")){
		keys << AutoTypeAction(TypeKey, HelperX11::getKeysym('%'));
		return;
	}
	
	if(!tmpl.compare("caret")){
		keys << AutoTypeAction(TypeKey, HelperX11::getKeysym('^'));
		return;
	}
	
	if(!tmpl.compare("tilde")){
		keys << AutoTypeAction(TypeKey, HelperX11::getKeysym('~'));
		return;
	}
	
	if(!tmpl.compare("leftbrace")){
		keys << AutoTypeAction(TypeKey, HelperX11::getKeysym('{'));
		return;
	}
	
	if(!tmpl.compare("rightbrace")){
		keys << AutoTypeAction(TypeKey, HelperX11::getKeysym('}'));
		return;
	}
	
	if(!tmpl.compare("leftparen")){
		keys << AutoTypeAction(TypeKey, HelperX11::getKeysym('('));
		return;
	}
	
	if(!tmpl.compare("rightparen")){
		keys << AutoTypeAction(TypeKey, HelperX11::getKeysym(')'));
		return;
	}
	
	if(!tmpl.compare("winl")){
		keys << AutoTypeAction(TypeKey, XK_Super_L);
		return;
	}
	
	if(!tmpl.compare("winr")){
		keys << AutoTypeAction(TypeKey, XK_Super_R);
		return;
	}
	
	if(!tmpl.compare("win")){
		keys << AutoTypeAction(TypeKey, XK_Super_L);
		return;
	}
	
	if(!tmpl.compare("tab")){
		keys << AutoTypeAction(TypeKey, XK_Tab);
		return;
	}
	
	if(tmpl.startsWith("delay ") && tmpl.length()>6){
		bool ok;
		quint16 delay = tmpl.right(tmpl.length()-6).toInt(&ok);
		if (ok && delay>0 && delay<=10000)
			keys << AutoTypeAction(Delay, delay);
	}
}

void AutoTypeX11::stringToKeysyms(const QString& string,QList<AutoTypeAction>& KeySymList){
	for(int i=0; i<string.length();i++)
		KeySymList << AutoTypeAction(TypeKey, HelperX11::getKeysym(string[i]));
}


// ----------------------------------------------------------------------
// The following code is taken from xvkbd and has been slightly modified.
// ----------------------------------------------------------------------

/*
 * xvkbd - Virtual Keyboard for X Window System
 * (Version 3.0, 2008-05-05)
 *
 * Copyright (C) 2000-2008 by Tom Sato <VEF00200@nifty.ne.jp>
 * http://homepage3.nifty.com/tsato/
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 */

/*
 * Insert a specified keysym to unused position in the keymap table.
 * This will be called to add required keysyms on-the-fly.
 * if the second parameter is TRUE, the keysym will be added to the
 * non-shifted position - this may be required for modifier keys
 * (e.g. Mode_switch) and some special keys (e.g. F20).
 */
int AutoTypeX11::AddKeysym(KeySym keysym, bool top)
{
	int keycode, pos, max_pos, inx, phase;

	if (top) {
		max_pos = 0;
	} else {
		max_pos = keysym_per_keycode - 1;
		if (4 <= max_pos) max_pos = 3;
		if (2 <= max_pos && altgr_keysym != XK_Mode_switch) max_pos = 1;
	}

	for (phase = 0; phase < 2; phase++) {
		for (keycode = max_keycode; min_keycode <= keycode; keycode--) {
			for (pos = max_pos; 0 <= pos; pos--) {
				inx = (keycode - min_keycode) * keysym_per_keycode;
				if ((phase != 0 || keysym_table[inx] == NoSymbol) && keysym_table[inx] < 0xFF00) {
					/* In the first phase, to avoid modifing existing keys, */
					/* add the keysym only to the keys which has no keysym in the first position. */
					/* If no place fuond in the first phase, add the keysym for any keys except */
					/* for modifier keys and other special keys */
					if (keysym_table[inx + pos] == NoSymbol) {
						keysym_table[inx + pos] = keysym;
						XChangeKeyboardMapping(dpy, keycode, keysym_per_keycode, &keysym_table[inx], 1);
						XFlush(dpy);
						return keycode;
					}
				}
			}
		}
	}
	qWarning("Couldn't add \"%s\" to keymap", XKeysymToString(keysym));
	return NoSymbol;
}

/*
 * Add the specified key as a new modifier.
 * This is used to use Mode_switch (AltGr) as a modifier.
 */
void AutoTypeX11::AddModifier(KeySym keysym)
{
	XModifierKeymap *modifiers;
	int keycode, i, pos;

	keycode = XKeysymToKeycode(dpy, keysym);
	if (keycode == NoSymbol) keycode = AddKeysym(keysym, TRUE);
	
	modifiers = XGetModifierMapping(dpy);
	for (i = 7; 3 < i; i--) {
		if (modifiers->modifiermap[i * modifiers->max_keypermod] == NoSymbol
			|| ((keysym_table[(modifiers->modifiermap[i * modifiers->max_keypermod]
			- min_keycode) * keysym_per_keycode]) == XK_ISO_Level3_Shift
			&& keysym == XK_Mode_switch))
		{
			for (pos = 0; pos < modifiers->max_keypermod; pos++) {
				if (modifiers->modifiermap[i * modifiers->max_keypermod + pos] == NoSymbol) {
					modifiers->modifiermap[i * modifiers->max_keypermod + pos] = keycode;
					XSetModifierMapping(dpy, modifiers);
					return;
				}
			}
		}
	}
	qWarning("Couldn't add \"%s\" as modifier", XKeysymToString(keysym));
}

/*
 * Read keyboard mapping and modifier mapping.
 * Keyboard mapping is used to know what keys are in shifted position.
 * Modifier mapping is required because we should know Alt and Meta
 * key are used as which modifier.
 */
void AutoTypeX11::ReadKeymap()
{
	int i;
	int keycode, inx, pos;
	KeySym keysym;
	XModifierKeymap *modifiers;
	int last_altgr_mask;

	XDisplayKeycodes(dpy, &min_keycode, &max_keycode);
	if (keysym_table != NULL) XFree(keysym_table);
	keysym_table = XGetKeyboardMapping(dpy,
			min_keycode, max_keycode - min_keycode + 1,
			&keysym_per_keycode);
	for (keycode = min_keycode; keycode <= max_keycode; keycode++) {
    /* if the first keysym is alphabet and the second keysym is NoSymbol,
		it is equivalent to pair of lowercase and uppercase alphabet */
		inx = (keycode - min_keycode) * keysym_per_keycode;
		if (keysym_table[inx + 1] == NoSymbol
				  && ((XK_A <= keysym_table[inx] && keysym_table[inx] <= XK_Z)
				  || (XK_a <= keysym_table[inx] && keysym_table[inx] <= XK_z)))
		{
			if (XK_A <= keysym_table[inx] && keysym_table[inx] <= XK_Z)
				keysym_table[inx] = keysym_table[inx] - XK_A + XK_a;
			keysym_table[inx + 1] = keysym_table[inx] - XK_a + XK_A;
		}
	}

	last_altgr_mask = altgr_mask;
	alt_mask = 0;
	meta_mask = 0;
	altgr_mask = 0;
	altgr_keysym = NoSymbol;
	modifiers = XGetModifierMapping(dpy);
	for (i = 0; i < 8; i++) {
		for (pos = 0; pos < modifiers->max_keypermod; pos++) {
			keycode = modifiers->modifiermap[i * modifiers->max_keypermod + pos];
			if (keycode < min_keycode || max_keycode < keycode) continue;

			keysym = keysym_table[(keycode - min_keycode) * keysym_per_keycode];
			if (keysym == XK_Alt_L || keysym == XK_Alt_R) {
				alt_mask = 1 << i;
			} else if (keysym == XK_Meta_L || keysym == XK_Meta_R) {
				meta_mask = 1 << i;
			} else if (keysym == XK_Mode_switch) {
				if (altgr_keysym == XK_ISO_Level3_Shift) {
				} else {
					altgr_mask = 0x0101 << i;
					/* I don't know why, but 0x2000 was required for mod3 on my Linux box */
					altgr_keysym = keysym;
				}
			} else if (keysym == XK_ISO_Level3_Shift) {
				/* if no Mode_switch, try to use ISO_Level3_Shift instead */
				/* however, it may not work as intended - I don't know why */
				altgr_mask = 1 << i;
				altgr_keysym = keysym;
			}
		}
	}
	XFreeModifiermap(modifiers);
}

/*
 * Send event to the focused window.
 * If input focus is specified explicitly, select the window
 * before send event to the window.
 */
void AutoTypeX11::SendEvent(XKeyEvent *event)
{
	XSync(event->display, FALSE);
	int (*oldHandler) (Display*, XErrorEvent*) = XSetErrorHandler(MyErrorHandler);

	XTestFakeKeyEvent(event->display, event->keycode, event->type == KeyPress, 0);
	XFlush(event->display);

	XSetErrorHandler(oldHandler);
}

/*
 * Send sequence of KeyPressed/KeyReleased events to the focused
 * window to simulate keyboard.  If modifiers (shift, control, etc)
 * are set ON, many events will be sent.
 */
void AutoTypeX11::SendKeyPressedEvent(KeySym keysym, unsigned int shift)
{
	Window cur_focus;
	int revert_to;
	XKeyEvent event;
	int keycode;
	int phase, inx;
	bool found;

	XGetInputFocus(dpy, &cur_focus, &revert_to);

	found = FALSE;
	keycode = 0;
	if (keysym != NoSymbol) {
		for (phase = 0; phase < 2; phase++) {
			for (keycode = min_keycode; !found && (keycode <= max_keycode); keycode++) {
				/* Determine keycode for the keysym:  we use this instead
				of XKeysymToKeycode() because we must know shift_state, too */
				inx = (keycode - min_keycode) * keysym_per_keycode;
				if (keysym_table[inx] == keysym) {
					shift &= ~altgr_mask;
					if (keysym_table[inx + 1] != NoSymbol) shift &= ~ShiftMask;
					found = TRUE;
					break;
				} else if (keysym_table[inx + 1] == keysym) {
					shift &= ~altgr_mask;
					shift |= ShiftMask;
					found = TRUE;
					break;
				}
			}
			if (!found && altgr_mask && 3 <= keysym_per_keycode) {
				for (keycode = min_keycode; !found && (keycode <= max_keycode); keycode++) {
					inx = (keycode - min_keycode) * keysym_per_keycode;
					if (keysym_table[inx + 2] == keysym) {
						shift &= ~ShiftMask;
						shift |= altgr_mask;
						found = TRUE;
						break;
					} else if (4 <= keysym_per_keycode && keysym_table[inx + 3] == keysym) {
						shift |= ShiftMask | altgr_mask;
						found = TRUE;
						break;
					}
				}
			}
			if (found) break;

			if (0xF000 <= keysym) {
				/* for special keys such as function keys,
				first try to add it in the non-shifted position of the keymap */
				if (AddKeysym(keysym, TRUE) == NoSymbol) AddKeysym(keysym, FALSE);
			} else {
				AddKeysym(keysym, FALSE);
			}
		}
	}

	event.display = dpy;
	event.window = cur_focus;
	event.root = RootWindow(event.display, DefaultScreen(event.display));
	event.subwindow = None;
	event.time = CurrentTime;
	event.x = 1;
	event.y = 1;
	event.x_root = 1;
	event.y_root = 1;
	event.same_screen = TRUE;

	Window root, child;
	int root_x, root_y, x, y;
	unsigned int mask;

	XQueryPointer(dpy, event.root, &root, &child, &root_x, &root_y, &x, &y, &mask);

	event.type = KeyRelease;
	event.state = 0;
	if (mask & ControlMask) {
		event.keycode = XKeysymToKeycode(dpy, XK_Control_L);
		SendEvent(&event);
	}
	if (mask & alt_mask) {
		event.keycode = XKeysymToKeycode(dpy, XK_Alt_L);
		SendEvent(&event);
	}
	if (mask & meta_mask) {
		event.keycode = XKeysymToKeycode(dpy, XK_Meta_L);
		SendEvent(&event);
	}
	if (mask & altgr_mask) {
		event.keycode = XKeysymToKeycode(dpy, altgr_keysym);
		SendEvent(&event);
	}
	if (mask & ShiftMask) {
		event.keycode = XKeysymToKeycode(dpy, XK_Shift_L);
		SendEvent(&event);
	}
	if (mask & LockMask) {
		event.keycode = XKeysymToKeycode(dpy, XK_Caps_Lock);
		SendEvent(&event);
	}

	event.type = KeyPress;
	event.state = 0;
	if (shift & ControlMask) {
		event.keycode = XKeysymToKeycode(dpy, XK_Control_L);
		SendEvent(&event);
		event.state |= ControlMask;
	}
	if (shift & alt_mask) {
		event.keycode = XKeysymToKeycode(dpy, XK_Alt_L);
		SendEvent(&event);
		event.state |= alt_mask;
	}
	if (shift & meta_mask) {
		event.keycode = XKeysymToKeycode(dpy, XK_Meta_L);
		SendEvent(&event);
		event.state |= meta_mask;
	}
	if (shift & altgr_mask) {
		event.keycode = XKeysymToKeycode(dpy, altgr_keysym);
		SendEvent(&event);
		event.state |= altgr_mask;
	}
	if (shift & ShiftMask) {
		event.keycode = XKeysymToKeycode(dpy, XK_Shift_L);
		SendEvent(&event);
		event.state |= ShiftMask;
	}

	if (keysym != NoSymbol) {  /* send event for the key itself */
		event.keycode = found ? keycode : XKeysymToKeycode(dpy, keysym);
		if (event.keycode == NoSymbol) {
			if ((keysym & ~0x7f) == 0 && isprint(keysym))
				qWarning("No such key: %c", (char)keysym);
			else if (XKeysymToString(keysym) != NULL)
				qWarning("No such key: keysym=%s (0x%lX)", XKeysymToString(keysym), (long)keysym);
			else
				qWarning("No such key: keysym=0x%lX", (long)keysym);
		} else {
			SendEvent(&event);
			event.type = KeyRelease;
			SendEvent(&event);
		}
	}

	event.type = KeyRelease;
	if (shift & ShiftMask) {
		event.keycode = XKeysymToKeycode(dpy, XK_Shift_L);
		SendEvent(&event);
		event.state &= ~ShiftMask;
	}
	if (shift & altgr_mask) {
		event.keycode = XKeysymToKeycode(dpy, altgr_keysym);
		SendEvent(&event);
		event.state &= ~altgr_mask;
	}
	if (shift & meta_mask) {
		event.keycode = XKeysymToKeycode(dpy, XK_Meta_L);
		SendEvent(&event);
		event.state &= ~meta_mask;
	}
	if (shift & alt_mask) {
		event.keycode = XKeysymToKeycode(dpy, XK_Alt_L);
		SendEvent(&event);
		event.state &= ~alt_mask;
	}
	if (shift & ControlMask) {
		event.keycode = XKeysymToKeycode(dpy, XK_Control_L);
		SendEvent(&event);
		event.state &= ~ControlMask;
	}
}

int AutoTypeX11::MyErrorHandler(Display *my_dpy, XErrorEvent *event)
{
	char msg[200];

	if (event->error_code == BadWindow) {
		return 0;
	}
	XGetErrorText(my_dpy, event->error_code, msg, sizeof(msg) - 1);
	qWarning("X error trapped: %s, request-code=%d\n", msg, event->request_code);
	return 0;
}
