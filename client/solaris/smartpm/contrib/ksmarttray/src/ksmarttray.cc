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
#include <kuniqueapplication.h>
#include <kcmdlineargs.h>
#include <ksystemtray.h>
#include <kstandarddirs.h>
#include <kmainwindow.h>
#include <knotifyclient.h>
#include <kpopupmenu.h>
#include <kaction.h>

#include <qtooltip.h>

#include <ksmarttray.h>

int main(int argc, char **argv)
{
    KCmdLineArgs::init(argc, argv, "ksmarttray", "KSmartTray", "", "");
    KUniqueApplication app;
    app.dirs()->addResourceDir("appicon", app.applicationDirPath());
    KSmartTray smarttray;
    app.exec();
    return 0;
}

KMySystemTray::KMySystemTray()
{
    hasActions = false;
    checkAction.setText("Check");
    stopAction.setText("Stop");
    stopAction.setIcon("stop");
    stopAction.setEnabled(false);
}

void KMySystemTray::contextMenuAboutToShow(KPopupMenu *menu)
{
    if (!hasActions) {
        hasActions = true;
        checkAction.plug(menu, 1);
        //stopAction.plug(menu, 2);
    }
}

void KMySystemTray::mousePressEvent(QMouseEvent *e)
{
    if (rect().contains(e->pos())) {
        if (e->button() == LeftButton) {
            emit activated();
        } else {
            KSystemTray::mousePressEvent(e);
        }
    }
}

KSmartTray::KSmartTray()
{
    sysTray.setPixmap(sysTray.loadIcon("ksmarttray"));
    sysTray.show();

    state = StateWaiting;

    blinkFlag = false;
    updateFailed = false;

    connect(&checkTimer, SIGNAL(timeout()), this, SLOT(checkUpgrades()));
    connect(&process, SIGNAL(processExited(KProcess *)),
            this, SLOT(processDone(KProcess *)));

    connect(this, SIGNAL(foundNewUpgrades()), this, SLOT(startBlinking()));
    connect(this, SIGNAL(foundNoUpgrades()), this, SLOT(stopBlinking()));
    connect(&sysTray, SIGNAL(mouseEntered()), this, SLOT(stopBlinking()));
    connect(&blinkTimer, SIGNAL(timeout()), this, SLOT(toggleBlink()));

    connect(&sysTray.checkAction, SIGNAL(activated()),
            this, SLOT(manualCheckUpgrades()));
    connect(&sysTray.stopAction, SIGNAL(activated()),
            this, SLOT(stopChecking()));
    connect(&sysTray, SIGNAL(quitSelected()),
            KApplication::kApplication(), SLOT(quit()));

    connect(&sysTray, SIGNAL(activated()), this, SLOT(runUpgrades()));

    checkTimer.start(5*60*1000);

    checkUpgrades();
}

void KSmartTray::internalCheckUpgrades(bool manual)
{
    if (!manual && blinkTimer.isActive())
        return;
    if (state == StateWaiting) {
        sysTray.checkAction.setEnabled(false);
        sysTray.stopAction.setEnabled(true);
        process.resetAll();
        if (manual)
            process << "smart-update";
        else
            process << "smart-update" << "--after" << "60";
        if (!process.start()) {
            KNotifyClient::event(sysTray.winId(), "fatalerror",
                                 "Couldn't run 'smart-update'.");
        } else {
            QToolTip::add(&sysTray, "Updating channels...");
            state = StateUpdating;
        }
    }
}

void KSmartTray::checkUpgrades()
{
    internalCheckUpgrades(false);
}

void KSmartTray::manualCheckUpgrades()
{
    internalCheckUpgrades(true);
}

void KSmartTray::runUpgrades()
{
    if (state != StateWaiting) {
        KNotifyClient::event(sysTray.winId(), "fatalerror",
                             "There is a running process.");
    } else {
        sysTray.checkAction.setEnabled(false);
        sysTray.stopAction.setEnabled(false);
        process.resetAll();
        process << "kdesu" << "-d" << "-c" << "smart --gui upgrade";
        if (!process.start()) {
            KNotifyClient::event(sysTray.winId(), "fatalerror",
                                 "Couldn't run 'smart upgrade'.");
        } else {
            state = StateUpgrading;
            QToolTip::remove(&sysTray);
            QToolTip::add(&sysTray, "Running Smart Package Manager...");
        }
    }
}

void KSmartTray::stopChecking()
{
    process.kill();
}

void KSmartTray::processDone(KProcess *)
{
    switch (state) {

        case StateUpdating:
            if (!process.normalExit() || process.exitStatus() != 0)
                updateFailed = true;
            if (updateFailed && !lastKnownStatus.isEmpty()) {
                state = StateWaiting;
            } else {
                process.resetAll();
                process << "smart" << "upgrade" << "--check-update";
                if (!process.start()) {
                    KNotifyClient::event(sysTray.winId(), "fatalerror",
                                         "Couldn't run 'smart upgrade'.");
                    state = StateWaiting;
                    lastKnownStatus = "";
                } else {
                    QToolTip::remove(&sysTray);
                    QToolTip::add(&sysTray,
                                  "Verifying upgradable packages...");
                    state = StateChecking;
                }
            }
            break;

        case StateChecking:
            state = StateWaiting;
            if (process.normalExit()) {
                if (process.exitStatus() == 0) {
                    lastKnownStatus = "There are new upgrades available!";
                    KNotifyClient::event(sysTray.winId(), "found-new-upgrades",
                                         lastKnownStatus);
                    emit foundNewUpgrades();
                } else if (process.exitStatus() == 1) {
                    lastKnownStatus = "There are pending upgrades!";
                    if (!updateFailed)
                        KNotifyClient::event(sysTray.winId(),
                                             "found-old-upgrades",
                                             lastKnownStatus);
                    emit foundOldUpgrades();
                } else if (process.exitStatus() == 2) {
                    lastKnownStatus = "No interesting upgrades available.";
                    if (!updateFailed)
                        KNotifyClient::event(sysTray.winId(),
                                             "found-no-upgrades",
                                             lastKnownStatus);
                    emit foundNoUpgrades();
                } else {
                    lastKnownStatus = "";
                }
            }
            break;

        case StateUpgrading:
            state = StateWaiting;
            lastKnownStatus = "";
            break;

        default:
            /* Error! */
            break;
    }

    if (state == StateWaiting) {
        updateFailed = false;
        sysTray.checkAction.setEnabled(true);
        sysTray.stopAction.setEnabled(false);
        if (!lastKnownStatus.isEmpty())
        {
            QToolTip::remove(&sysTray);
            QToolTip::add(&sysTray, lastKnownStatus);
        }
        else
            QToolTip::remove(&sysTray);
    }
}

void KSmartTray::startBlinking()
{
    if (!blinkTimer.isActive())
        blinkTimer.start(500);
}

void KSmartTray::stopBlinking()
{
    if (blinkTimer.isActive())
        blinkTimer.stop();
    sysTray.setPixmap(sysTray.loadIcon("ksmarttray"));
}

void KSmartTray::toggleBlink()
{
    if (blinkFlag)
        sysTray.setPixmap(NULL);
    else
        sysTray.setPixmap(sysTray.loadIcon("ksmarttray"));
    blinkFlag = !blinkFlag;
}
