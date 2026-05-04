import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
  id: root

  property var pluginApi: null

  Switch {
    text: pluginApi ? pluginApi.tr("settings.show_completed.label") : "Show Completed Todos"
    checked: pluginApi && pluginApi.pluginSettings && pluginApi.pluginSettings.showCompleted !== undefined ? pluginApi.pluginSettings.showCompleted : true
    onToggled: {
      if (!pluginApi || !pluginApi.pluginSettings)
        return;
      pluginApi.pluginSettings.showCompleted = checked;
      pluginApi.saveSettings();
    }
  }

  Switch {
    text: pluginApi ? pluginApi.tr("settings.background_color.label") : "Background Color"
    checked: pluginApi && pluginApi.pluginSettings && pluginApi.pluginSettings.showBackground !== undefined ? pluginApi.pluginSettings.showBackground : true
    onToggled: {
      if (!pluginApi || !pluginApi.pluginSettings)
        return;
      pluginApi.pluginSettings.showBackground = checked;
      pluginApi.saveSettings();
    }
  }

  Label {
    text: pluginApi ? pluginApi.tr("settings.pages.label") : "Manage Pages"
  }
}
