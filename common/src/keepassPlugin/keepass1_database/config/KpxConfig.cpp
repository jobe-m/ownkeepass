/***************************************************************************
 *   Copyright (C) 2005-2007 by Tarek Saidi                                *
 *   tarek.saidi@arcor.de                                                  *
 *                                                                         *
 *   Copyright (C) 2007 by Constantin "Dinosaur" Makshin                   *
 *   dinosaur-rus@users.sourceforge.net                                    *
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

// not available in Qt 5
//#include <Qt/qlayout.h> // <QLayout>
//#include <Qt/qwidget.h> // <QWidget>

#include <QCoreApplication>
#include "KpxConfig.h"

KpxConfig::KpxConfig(const QString& filePath) : settings(filePath,QSettings::IniFormat){
	configFile=filePath;
	if (settings.contains("Options/GroupTreeRestore") && !settings.contains("Options/GroupTreeState")){
		switch (settings.value("Options/GroupTreeRestore",1).toInt()){
			case 0:
				setGroupTreeState(RestoreLast);
				break;

			case 2:
				setGroupTreeState(DoNothing);
				break;

			default:
				setGroupTreeState(ExpandAll);
		}
		settings.remove("Options/GroupTreeRestore");
	}
	if (urlCmd()=="<<default>>")
		setUrlCmd(QString());
}

#ifdef GLOBAL_AUTOTYPE
Shortcut KpxConfig::globalShortcut(){
	Shortcut s;
	s.key = settings.value("Options/GlobalShortcutKey",0).toUInt();
	QBitArray mods = settings.value("Options/GlobalShortcutMods",QBitArray(5)).toBitArray();
	if (mods.size()!=5)
		mods = QBitArray(5);
	s.ctrl = mods.testBit(0);
	s.shift = mods.testBit(1);
	s.alt = mods.testBit(2);
	s.altgr = mods.testBit(3);
	s.win = mods.testBit(4);
	
	return s;
}

void KpxConfig::setGlobalShortcut(const Shortcut& s){
	settings.setValue("Options/GlobalShortcutKey", s.key);
	QBitArray mods(5);
	mods.setBit(0, s.ctrl);
	mods.setBit(1, s.shift);
	mods.setBit(2, s.alt);
	mods.setBit(3, s.altgr);
	mods.setBit(4, s.win);
	settings.setValue("Options/GlobalShortcutMods", mods);
}
#endif

unsigned KpxConfig::fileDlgHistorySize(){
	settings.beginGroup("FileDlgHistory");
	unsigned res=static_cast<unsigned>(settings.childKeys().size());
	settings.endGroup();
	return res;
}

QColor KpxConfig::stringToColor(const QString& str){
	QStringList ints=str.split(',');
	QColor res;
	if (ints.count()>0)
		res.setRed(ints.at(0).toInt());
	if (ints.count()>1)
		res.setGreen(ints.at(1).toInt());
	if (ints.count()>2)
		res.setBlue(ints.at(2).toInt());
	return res;
}

QBitArray KpxConfig::stringToBitArray(const QString& str, unsigned count){
	QBitArray res(static_cast<int>(count));
	if (static_cast<unsigned>(str.length())<count)
		count=static_cast<unsigned>(str.length());
	for (int i=0;i<static_cast<int>(count);i++){
		QChar c=str.at(i);
		if ((c=='1') || (c=='t') || (c=='y'))
			res.setBit(i);
	}
	return res;
}

KpxConfig::GrpTreeState KpxConfig::stringToGrpTreeState(const QString& str){
	GrpTreeState res=ExpandAll;
	if (!str.compare("Restore",Qt::CaseInsensitive))
		res=RestoreLast;
	else if (!str.compare("None",Qt::CaseInsensitive))
		res=DoNothing;
	return res;
}

QList<int> KpxConfig::stringToIntArray(const QString& str, unsigned count){
	QStringList ints=str.split(',');
	QList<int> res;
	unsigned i,
	         intsCount=qMin(static_cast<unsigned>(ints.count()),count);
	for (i=0;i<intsCount;i++)
		res.append(ints.at(i).toInt());
	for (;i<count;i++)
		res.append(0);
	return res;
}

KpxConfig::IntegrPluginType KpxConfig::stringToIntegrPluginType(const QString& str){
	IntegrPluginType res=NoIntegr;
	if (!str.compare("KDE",Qt::CaseInsensitive))
		res=KDE;
	else if (!str.compare("Gnome",Qt::CaseInsensitive))
		res=Gnome;
	return res;
}

tKeyType KpxConfig::stringToKeyType(const QString& str){
	tKeyType res=PASSWORD;
	if (!str.compare("KeyFile",Qt::CaseInsensitive))
		res=KEYFILE;
	else if (!str.compare("Composite",Qt::CaseInsensitive))
		res=BOTH;
	return res;
}

QString KpxConfig::bitArrayToString(const QBitArray& bitArray){
	QString res;
	for (int i=0;i<bitArray.count();i++)
		res.append(QString::number(bitArray.at(i)?1:0));
	return res;
}

QString KpxConfig::grpTreeStateToString(GrpTreeState grpTreeState){
	QString res;
	switch (grpTreeState){
		case RestoreLast:
			res="Restore";
			break;

		case ExpandAll:
			res="ExpandAll";
			break;

		case DoNothing:
			res="None";
	}
	return res;
}

QString KpxConfig::intArrayToString(const QList<int>& intArray){
	QString res;
	if (!intArray.isEmpty())
	{
		res.setNum(intArray.first());
		for (int i=1;i<intArray.count();i++)
			res.append(QString(",%1").arg(intArray.at(i)));
	}
	return res;
}

QString KpxConfig::integrPluginTypeToString(IntegrPluginType integrPluginType){
	QString res;
	switch (integrPluginType){
		case NoIntegr:
			res="None";
			break;

		case KDE:
			res="KDE";
			break;

		case Gnome:
			res="Gnome";
	}
	return res;
}

QString KpxConfig::keyTypeToString(tKeyType keyType){
	QString res;
	switch (keyType){
		case PASSWORD:
			res="Password";
			break;

		case KEYFILE:
			res="KeyFile";
			break;

		case BOTH:
			res="Composite";
	}
	return res;
}

QByteArray KpxConfig::mainWindowGeometry() {
	QVariant var = settings.value("UI/MainWindowGeometry");
	if (var.type() == QVariant::ByteArray)
		return var.toByteArray();
	else
		return QByteArray();
}

//QRect KpxConfig::dialogGeometry(const QWidget* widget){
//    Q_ASSERT(widget->parentWidget()!=NULL && widget->parentWidget()->window()!=NULL);
//    QSize size = settings.value(QString("UI/%1Size").arg(widget->objectName()),widget->size()).toSize();
//    QSize minSize = widget->minimumSize();
//    if (size.width() < minSize.width() || size.height() < minSize.height())
//        size = minSize;
//    if (minSize.isNull() && widget->layout()!=NULL){
//        minSize = widget->layout()->minimumSize();
//        if (size.width() < minSize.width() || size.height() < minSize.height())
//            size = minSize;
//    }

//    QRect rect;
//    rect=QRect(QPoint(), size);
//    rect.moveCenter( widget->parentWidget()->window()->geometry().center() );
//    return rect;
//}

//void KpxConfig::setDialogGeometry(const QWidget* widget){
//    settings.setValue(QString("UI/%1Size").arg(widget->objectName()),widget->size());
//}

QString KpxConfig::detailViewTemplate(){
	if (settings.contains("UI/DetailsView")){
		return QString::fromUtf8( qUncompress(settings.value("UI/DetailsView").toByteArray()) );
	}
	else{
		return defaultDetailViewTemplate();
	}
}

QString KpxConfig::defaultDetailViewTemplate(){
	QFile templ(":/default-detailview.html");
	templ.open(QIODevice::ReadOnly);
	QString value=QString::fromUtf8(templ.readAll());
	templ.close();
	value.replace("Group",QCoreApplication::translate("DetailViewTemplate","Group"));
	value.replace("Title",QCoreApplication::translate("DetailViewTemplate","Title"));
	value.replace("Username",QCoreApplication::translate("DetailViewTemplate","Username"));
	value.replace("Password",QCoreApplication::translate("DetailViewTemplate","Password"));
	value.replace("URL",QCoreApplication::translate("DetailViewTemplate","URL"));
	value.replace("Creation",QCoreApplication::translate("DetailViewTemplate","Creation"));
	value.replace("Last Access",QCoreApplication::translate("DetailViewTemplate","Last Access"));
	value.replace("Last Modification",QCoreApplication::translate("DetailViewTemplate","Last Modification"));
	value.replace("Expiration",QCoreApplication::translate("DetailViewTemplate","Expiration"));
	value.replace("Comment",QCoreApplication::translate("DetailViewTemplate","Comment"));
	return value;
}

void KpxConfig::setDetailViewTemplate(const QString& value){
	settings.setValue("UI/DetailsView", qCompress(value.toUtf8(),9) );
}
