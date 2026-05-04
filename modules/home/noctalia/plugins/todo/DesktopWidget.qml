import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Modules.DesktopWidgets

DraggableDesktopWidget {
  id: root

  property var pluginApi: null
  readonly property var todos: getTodos()

  function getTodos() {
    var current;
    var showCompleted;
    var todos;
    var filtered;
    var i;

    current = 0;
    showCompleted = true;
    todos = [];
    filtered = [];

    if (pluginApi && pluginApi.pluginSettings) {
      if (pluginApi.pluginSettings.current_page_id !== undefined && pluginApi.pluginSettings.current_page_id !== null)
        current = pluginApi.pluginSettings.current_page_id;
      if (pluginApi.pluginSettings.showCompleted !== undefined)
        showCompleted = pluginApi.pluginSettings.showCompleted;
      if (pluginApi.pluginSettings.todos)
        todos = pluginApi.pluginSettings.todos;
    }

    for (i = 0; i < todos.length; ++i) {
      if (todos[i].pageId === current && (showCompleted || !todos[i].completed))
        filtered.push(todos[i]);
    }

    return filtered;
  }

  showBackground: pluginApi && pluginApi.pluginSettings && pluginApi.pluginSettings.showBackground !== undefined ? pluginApi.pluginSettings.showBackground : true
  implicitWidth: 320
  implicitHeight: 80 + Math.min(todos.length, 6) * 42

  Rectangle {
    anchors.fill: parent
    radius: 12
    color: root.showBackground ? Qt.rgba(0, 0, 0, 0.2) : "transparent"

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 12
      spacing: 8

      Label {
        text: pluginApi ? pluginApi.tr("desktop_widget.header_title") : "To-Do List"
        font.pixelSize: 18
      }

      Repeater {
        model: todos.slice(0, 6)
        RowLayout {
          width: parent.width

          CheckBox {
            checked: modelData.completed
            onToggled: {
              if (pluginApi && pluginApi.mainInstance)
                pluginApi.mainInstance.updateTodo(modelData.id, {completed: checked});
            }
          }

          Label {
            Layout.fillWidth: true
            text: modelData.text
            elide: Text.ElideRight
          }
        }
      }

      Label {
        visible: todos.length === 0
        text: pluginApi ? pluginApi.tr("desktop_widget.empty_state") : "No to-dos"
        opacity: 0.7
      }
    }
  }
}
