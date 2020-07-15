import QtQuick 2.2
import Sailfish.Silica 1.0
import "../js/Util.js" as Util

ContextMenu {
    id: contextMenu
    property var nodeModel
    property bool listViewMode: false
    signal collapseClicked

    MenuItem {
        text: qsTr("Collapse %1").arg(Util.getNodeNameFromPath(nodeModel.dir))
        visible: !listViewMode
        onClicked: {
            collapseClicked()
        }
    }

    MenuItem {
        text: qsTr("Open %1").arg(Util.getNodeNameFromPath(nodeModel.dir))
        onClicked: {
            console.log("Trying to open file://" + nodeModel.dir)
            Qt.openUrlExternally("file://" + nodeModel.dir)
        }
        visible: !(nodeModel.isDir)
        enabled: Util.canHandleFile(nodeModel.dir)
    }

    MenuItem {
        text: qsTr("Delete %1").arg(Util.getNodeNameFromPath(nodeModel.dir))
        onClicked: {
            var dialog = pageStack.push("../pages/DeleteDialog.qml", {
                                            "nodeModel": nodeModel
                                        })
            dialog.accepted.connect(onDialogAccepted)
        }
        function onDialogAccepted() {
            console.log("Deleting " + nodeModel.dir)
            engine.deleteFiles(nodeModel.dir)
        }
    }
}
