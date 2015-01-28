#!/usr/bin/python
from smart.progress import Progress
from qt import *

import sys, os, time

class QtProgressSubItem(QListViewItem):

    def __init__(self, listview, index):
        self.index = index

        self.progresspm = None
        self.subtopic = ""

        QListViewItem.__init__(self, listview)

        self.progress = QProgressBar()
        self.progress.setSizePolicy(QSizePolicy.Fixed, QSizePolicy.Fixed)
        self.progress.setFixedSize(110, self.height())

    def update(self, subtopic, percent):
        self.progress.setProgress(percent)
        self.progresspm = QPixmap.grabWidget(self.progress)
        self.subtopic = subtopic

    def text(self, column):
        if column == 1:
            return self.subtopic
        return ""

    def pixmap(self, column):
        if column == 0:
            return self.progresspm

    def width(self, fm, lv, column):
        if column == 0:
            return 110+1+lv.itemMargin()*2
        return QListViewItem.width(self, fm, lv, column)

    def compare(self, other, column, ascending):
        return cmp(self.index, other.index)

class QtProgress(Progress, QDialog):

    def __init__(self):
        Progress.__init__(self)
        QDialog.__init__(self)

        self.setModal(True)
        self.setCaption("Operation Progress")

        self.layout = QVBoxLayout(self, 5, 5)

        self.topic = QLabel(self)
        self.layout.addWidget(self.topic)

        self.progress = QProgressBar(self)
        self.layout.addWidget(self.progress)

        self.listview = QListView(self)
        self.listview.addColumn("Progress")
        self.listview.addColumn("Description")
        self.layout.addWidget(self.listview)

        self.subprogress = {}
        self.subindex = 0

    def expose(self, topic, percent, subkey, subtopic, subpercent, data):
        QDialog.show(self)

        self.topic.setText(topic)
        self.progress.setProgress(percent)

        if subkey:
            if subkey in self.subprogress:
                item = self.subprogress[subkey]
            else:
                item = QtProgressSubItem(self.listview, self.subindex)
                self.subindex += 1
                self.subprogress[subkey] = item
            item.update(subtopic, subpercent)
        else:
            self.listview.triggerUpdate()
            qApp.processEvents()

def test():
    a = QApplication(sys.argv)

    prog = QtProgress()
    data = {"item-number": 0}
    total, subtotal = 100, 100
    prog.start(True)
    prog.setTopic("Installing packages...")
    for n in range(1,total+1):
        data["item-number"] = n
        prog.set(n, total)
        prog.setSubTopic(n, "package-name%d" % n)
        for i in range(0,subtotal+1):
            prog.setSub(n, i, subtotal, subdata=data)
            prog.show()
            time.sleep(0.01)
    prog.stop()

if __name__ == "__main__":
    test()
