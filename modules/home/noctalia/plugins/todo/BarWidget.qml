import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.UI
import qs.Widgets

Item {
  id: root

  property var pluginApi: null
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  readonly property string screenName: screen ? screen.name : ""
  readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
  readonly property bool isVertical: barPosition === "left" || barPosition === "right"
  readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
  readonly property real barFontSize: Style.getBarFontSizeForScreen(screenName)
  readonly property real contentWidth: root.isVertical ? root.capsuleHeight : horizontalRow.implicitWidth + Style.marginM * 2
  readonly property real contentHeight: root.capsuleHeight
  readonly property int todoCount: getIntValue(getPluginSetting("count"), getDefaultSetting("count", 0))
  readonly property int completedCount: getIntValue(getPluginSetting("completedCount"), getDefaultSetting("completedCount", 0))
  readonly property int activeCount: todoCount - completedCount
  readonly property color contentColor: mouseArea.containsMouse ? Color.mOnHover : Color.mOnSurface
  readonly property string tooltipText: {
    var count = root.activeCount;
    var key = count === 1 ? "bar_widget.todo_count_singular" : "bar_widget.todo_count_plural";
    return translate(key).replace("{count}", count);
  }

  implicitWidth: contentWidth
  implicitHeight: contentHeight

  function getPluginSetting(key) {
    if (pluginApi && pluginApi.pluginSettings)
      return pluginApi.pluginSettings[key];
    return undefined;
  }

  function getDefaultSetting(key, fallback) {
    if (pluginApi && pluginApi.manifest && pluginApi.manifest.metadata && pluginApi.manifest.metadata.defaultSettings && pluginApi.manifest.metadata.defaultSettings[key] !== undefined)
      return pluginApi.manifest.metadata.defaultSettings[key];
    return fallback;
  }

  function getIntValue(value, defaultValue) {
    return typeof value === "number" ? Math.floor(value) : defaultValue;
  }

  function translate(key) {
    if (pluginApi)
      return pluginApi.tr(key);
    return key;
  }

  Rectangle {
    anchors.centerIn: parent
    width: root.contentWidth
    height: root.contentHeight
    radius: Style.radiusL
    color: mouseArea.containsMouse ? Color.mHover : Style.capsuleColor
    border.color: Style.capsuleBorderColor
    border.width: Style.capsuleBorderWidth

    Row {
      id: horizontalRow
      anchors.centerIn: parent
      spacing: Style.marginS
      visible: !root.isVertical

      NIcon {
        anchors.verticalCenter: parent.verticalCenter
        icon: "clipboard-check"
        applyUiScale: false
        color: root.contentColor
      }

      NText {
        anchors.verticalCenter: parent.verticalCenter
        text: {
          var key = activeCount === 1 ? "bar_widget.todo_count_singular" : "bar_widget.todo_count_plural";
          return translate(key).replace("{count}", activeCount);
        }
        color: root.contentColor
        pointSize: root.barFontSize
        applyUiScale: false
      }
    }

    NIcon {
      anchors.centerIn: parent
      visible: root.isVertical
      icon: "clipboard-check"
      applyUiScale: false
      color: root.contentColor
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: function (mouse) {
      if (mouse.button === Qt.LeftButton) {
        if (pluginApi)
          pluginApi.openPanel(root.screen, this);
      } else if (mouse.button === Qt.RightButton) {
        PanelService.showContextMenu(contextMenu, root, screen);
      }
    }

    onEntered: {
      if (root.isVertical)
        TooltipService.show(root, tooltipText, BarService.getTooltipDirection(root.screen ? root.screen.name : ""));
    }

    onExited: {
      TooltipService.hide();
    }
  }

  NPopupContextMenu {
    id: contextMenu

    model: [
      {
        "label": translate("actions.widget_settings"),
        "action": "widget-settings",
        "icon": "settings"
      }
    ]

    onTriggered: function (action) {
      contextMenu.close();
      PanelService.closeContextMenu(screen);
      if (action === "widget-settings" && pluginApi && pluginApi.manifest)
        BarService.openPluginSettings(screen, pluginApi.manifest);
    }
  }
}
