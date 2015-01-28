/*

 Copyright (c) 2004 Conectiva, Inc.

 Written by Gustavo Niemeyer <niemeyer@conectiva.com>

 This file is part of Smart Package Manager.

 Smart Package Manager is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License as published
 by the Free Software Foundation; either version 2 of the License, or (at
 your option) any later version.

 Smart Package Manager is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Smart Package Manager; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*/
#include <qtimer.h>
#include <qobject.h>

#include <ksystemtray.h>
#include <kprocess.h>
#include <kprocio.h>
#include <kaction.h>

class KMySystemTray : public KSystemTray
{
    Q_OBJECT

    public:

    KMySystemTray();

    KAction checkAction;
    KAction stopAction;

    protected:

    bool hasActions;

    void contextMenuAboutToShow(KPopupMenu *menu);
    void enterEvent(QEvent *) { emit mouseEntered(); };
    void mousePressEvent(QMouseEvent *e);

    signals:

    void activated();
    void mouseEntered();
};

class KSmartTray : public QObject
{
    Q_OBJECT

    protected:

    enum State {
        StateWaiting,
        StateUpdating,
        StateChecking,
        StateUpgrading,
    };

    State state;
    QString lastKnownStatus;
    bool updateFailed;
    bool manualCheck;

    QTimer checkTimer;
    QTimer blinkTimer;
    bool blinkFlag;
    KMySystemTray sysTray;
    KProcIO process;

    signals:

    void foundNewUpgrades();
    void foundOldUpgrades();
    void foundNoUpgrades();

    protected:

    void internalCheckUpgrades(bool manual);

    protected slots:

    void processDone(KProcess *);
    void toggleBlink();
    void stopChecking();
    void startBlinking();
    void stopBlinking();

    public slots:

    void checkUpgrades();
    void manualCheckUpgrades();
    void runUpgrades();

    public:

    KSmartTray();
};
