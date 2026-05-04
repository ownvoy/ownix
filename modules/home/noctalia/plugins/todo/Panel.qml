import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons

Item {
  id: root

  property var pluginApi: null
  readonly property var geometryPlaceholder: panelContainer
  readonly property bool allowAttach: true
  property real contentPreferredWidth: 680 * Style.uiScaleRatio
  property real contentPreferredHeight: 520 * Style.uiScaleRatio
  property string draftText: ""
  property int pageIndex: 0

  anchors.fill: parent

  function mainInstance() {
    return pluginApi ? pluginApi.mainInstance : null;
  }

  function pages() {
    if (pluginApi && pluginApi.pluginSettings && pluginApi.pluginSettings.pages)
      return pluginApi.pluginSettings.pages;
    return [{id: 0, name: "General"}];
  }

  function currentPageId() {
    var list = pages();
    if (pageIndex < 0 || pageIndex >= list.length)
      return 0;
    return list[pageIndex].id;
  }

  function currentTodos() {
    var showCompleted;
    var todos;
    var filtered;
    var i;

    showCompleted = true;
    if (pluginApi && pluginApi.pluginSettings && pluginApi.pluginSettings.showCompleted !== undefined)
      showCompleted = pluginApi.pluginSettings.showCompleted;

    todos = [];
    if (pluginApi && pluginApi.pluginSettings && pluginApi.pluginSettings.todos)
      todos = pluginApi.pluginSettings.todos;

    filtered = [];
    for (i = 0; i < todos.length; ++i) {
      if (todos[i].pageId === currentPageId() && (showCompleted || !todos[i].completed))
        filtered.push(todos[i]);
    }
    return filtered;
  }

  Rectangle {
    id: panelContainer
    anchors.fill: parent
    color: Color.mSurfaceVariant
    radius: Style.radiusL

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Style.marginM
      spacing: Style.marginM

      RowLayout {
        Layout.fillWidth: true

        Label {
          text: pluginApi ? pluginApi.tr("panel.header.title") : "Todo List"
          font.pixelSize: 22
        }

        Item {
          Layout.fillWidth: true
        }

        Button {
          text: pluginApi ? pluginApi.tr("panel.header.export_button") : "Export"
          onClicked: {
            var main = mainInstance();
            if (main)
              main.doExportTodos();
          }
        }

        Button {
          text: pluginApi ? pluginApi.tr("panel.header.clear_completed_button") : "Clear Completed"
          enabled: pluginApi && pluginApi.pluginSettings && (pluginApi.pluginSettings.completedCount || 0) > 0
          onClicked: {
            var main = mainInstance();
            if (main)
              main.clearCompletedTodos();
          }
        }
      }

      TabBar {
        id: tabs
        Layout.fillWidth: true
        currentIndex: pageIndex
        onCurrentIndexChanged: {
          pageIndex = currentIndex;
          if (pluginApi && pluginApi.pluginSettings) {
            pluginApi.pluginSettings.current_page_id = currentPageId();
            pluginApi.saveSettings();
          }
        }

        Repeater {
          model: pages()
          TabButton {
            text: modelData.name
          }
        }
      }

      RowLayout {
        Layout.fillWidth: true

        TextField {
          Layout.fillWidth: true
          placeholderText: pluginApi ? pluginApi.tr("panel.add_todo.placeholder") : "Enter a new todo item..."
          text: draftText
          onTextChanged: draftText = text
          onAccepted: addButton.clicked()
        }

        Button {
          id: addButton
          text: "+"
          onClicked: {
            var main = mainInstance();
            if (!draftText.trim() || !main)
              return;
            main.createTodo(draftText.trim(), "medium", currentPageId());
            draftText = "";
          }
        }
      }

      ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: 8
        model: currentTodos()

        delegate: Rectangle {
          required property var modelData
          width: ListView.view.width
          height: col.implicitHeight + 16
          radius: 8
          color: Color.mSurface

          ColumnLayout {
            id: col
            anchors.fill: parent
            anchors.margins: 8
            spacing: 6

            RowLayout {
              Layout.fillWidth: true

              CheckBox {
                checked: modelData.completed === true
                onToggled: {
                  var main = mainInstance();
                  if (main)
                    main.updateTodo(modelData.id, {completed: checked});
                }
              }

              Label {
                Layout.fillWidth: true
                text: modelData.text
                wrapMode: Text.Wrap
              }

              Button {
                text: "x"
                onClicked: {
                  var main = mainInstance();
                  if (main)
                    main.deleteTodo(modelData.id);
                }
              }
            }

            Label {
              visible: !!modelData.details
              Layout.fillWidth: true
              text: modelData.details || ""
              wrapMode: Text.Wrap
              opacity: 0.8
            }
          }
        }

        footer: Item {
          width: ListView.view.width
          height: ListView.view.count === 0 ? 120 : 0

          Label {
            visible: ListView.view.count === 0
            anchors.centerIn: parent
            text: pluginApi ? pluginApi.tr("panel.empty_state.message") : "No todo items yet"
            opacity: 0.7
          }
        }
      }
    }
  }
}
