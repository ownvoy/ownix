import QtQuick
import Quickshell
import qs.Services.UI
import qs.Widgets

NIconButtonHot {
  property ShellScreen screen
  property var pluginApi: null

  icon: "clipboard-check"

  function getTooltipText() {
    var todoCount;
    var completedCount;
    var activeCount;
    var key;

    if (!pluginApi)
      return "Todo List";

    todoCount = pluginApi.pluginSettings && pluginApi.pluginSettings.count ? pluginApi.pluginSettings.count : 0;
    completedCount = pluginApi.pluginSettings && pluginApi.pluginSettings.completedCount ? pluginApi.pluginSettings.completedCount : 0;
    activeCount = todoCount - completedCount;
    key = activeCount === 1 ? "bar_widget.todo_count_singular" : "bar_widget.todo_count_plural";
    return pluginApi.tr(key).replace("{count}", activeCount);
  }

  tooltipText: getTooltipText()

  onClicked: {
    if (pluginApi)
      pluginApi.togglePanel(screen);
  }

  onRightClicked: {
    if (pluginApi && pluginApi.manifest)
      BarService.openPluginSettings(screen, pluginApi.manifest);
  }
}
