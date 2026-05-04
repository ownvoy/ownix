import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.UI

Item {
  property var pluginApi: null
  property var rawTodos: []
  property var rawPages: []
  property string currentExportPath: ""

  Process {
    id: exportProcess
    running: false
    onExited: function (code) {
      if (!pluginApi)
        return;
      if (code === 0) {
        var displayPath = currentExportPath.replace(Quickshell.env("HOME"), "~");
        ToastService.showNotice(pluginApi.tr("main.exported_todos") + displayPath);
      } else {
        ToastService.showError(pluginApi.tr("main.export_failed"));
      }
    }
  }

  Component.onCompleted: {
    var i;

    if (!pluginApi)
      return;

    if (!pluginApi.pluginSettings.pages) {
      pluginApi.pluginSettings.pages = [{id: 0, name: "General"}];
      pluginApi.pluginSettings.current_page_id = 0;
    }
    if (!pluginApi.pluginSettings.todos) {
      pluginApi.pluginSettings.todos = [];
      pluginApi.pluginSettings.count = 0;
      pluginApi.pluginSettings.completedCount = 0;
    }
    if (pluginApi.pluginSettings.isExpanded === undefined)
      pluginApi.pluginSettings.isExpanded = false;
    if (pluginApi.pluginSettings.useCustomColors === undefined)
      pluginApi.pluginSettings.useCustomColors = false;
    if (!pluginApi.pluginSettings.exportPath)
      pluginApi.pluginSettings.exportPath = "~/Documents";
    if (!pluginApi.pluginSettings.exportFormat)
      pluginApi.pluginSettings.exportFormat = "markdown";
    if (pluginApi.pluginSettings.exportEmptySections === undefined)
      pluginApi.pluginSettings.exportEmptySections = false;
    if (!pluginApi.pluginSettings.priorityColors) {
      pluginApi.pluginSettings.priorityColors = {
        "high": Color.mError,
        "medium": Color.mPrimary,
        "low": Color.mOnSurfaceVariant
      };
    }

    rawTodos = pluginApi.pluginSettings.todos.slice();
    rawPages = pluginApi.pluginSettings.pages.slice();

    for (i = 0; i < rawTodos.length; ++i) {
      if (rawTodos[i].pageId === undefined)
        rawTodos[i].pageId = 0;
      if (rawTodos[i].priority === undefined || !isValidPriority(rawTodos[i].priority))
        rawTodos[i].priority = "medium";
      if (rawTodos[i].details === undefined)
        rawTodos[i].details = "";
    }

    pluginApi.saveSettings();
  }

  function isValidPriority(priority) {
    return priority === "high" || priority === "medium" || priority === "low";
  }

  function getCurrentPageId() {
    if (!pluginApi || !pluginApi.pluginSettings || pluginApi.pluginSettings.current_page_id === undefined || pluginApi.pluginSettings.current_page_id === null)
      return 0;
    return pluginApi.pluginSettings.current_page_id;
  }

  function countCompletedTodos() {
    var completed;
    var i;

    completed = 0;
    for (i = 0; i < rawTodos.length; ++i) {
      if (rawTodos[i].completed)
        completed += 1;
    }
    return completed;
  }

  function saveTodos() {
    if (!pluginApi || !pluginApi.pluginSettings)
      return;
    pluginApi.pluginSettings.todos = rawTodos.slice();
    pluginApi.pluginSettings.count = rawTodos.length;
    pluginApi.pluginSettings.completedCount = countCompletedTodos();
    pluginApi.saveSettings();
  }

  function savePages() {
    if (!pluginApi || !pluginApi.pluginSettings)
      return;
    pluginApi.pluginSettings.pages = rawPages.slice();
    pluginApi.saveSettings();
  }

  IpcHandler {
    target: "plugin:todo"

    function togglePanel() {
      if (!pluginApi)
        return;
      pluginApi.withCurrentScreen(function (screen) {
        pluginApi.togglePanel(screen);
      });
    }

    function getTodos() {
      return JSON.stringify(rawTodos);
    }

    function getTodo(id) {
      var todo = findTodo(id);
      return todo ? JSON.stringify(todo) : "";
    }

    function getCount() {
      var completed = countCompletedTodos();
      return JSON.stringify({
        total: rawTodos.length,
        active: rawTodos.length - completed,
        completed: completed
      });
    }

    function addTodo(text, priority, pageId) {
      var targetPageId;

      if (!text || !text.trim()) {
        ToastService.showError(pluginApi.tr("main.error_text_empty"));
        return;
      }
      if (!isValidPriority(priority)) {
        ToastService.showError(pluginApi.tr("main.error_invalid_priority"));
        return;
      }

      if (pageId === undefined || pageId === null)
        targetPageId = getCurrentPageId();
      else
        targetPageId = pageId;

      if (!pageExists(targetPageId)) {
        ToastService.showError(pluginApi.tr("main.error_page_not_found"));
        return;
      }

      createTodo(text.trim(), priority, targetPageId);
      ToastService.showNotice(pluginApi.tr("main.added_new_todo"));
    }

    function addTodoDefault(text) {
      addTodo(text, "medium", getCurrentPageId());
    }

    function setTodoPriority(id, priority) {
      if (updateTodo(id, {priority: priority}))
        ToastService.showNotice(pluginApi.tr("main.updated_todo_priority"));
      else
        ToastService.showError(pluginApi.tr("main.error_update_failed"));
    }

    function setTodoCompleted(id, completed) {
      if (updateTodo(id, {completed: completed}))
        ToastService.showNotice(pluginApi.tr("main.updated_todo"));
      else
        ToastService.showError(pluginApi.tr("main.error_update_failed"));
    }

    function setTodoDetails(id, details) {
      if (updateTodo(id, {details: details}))
        ToastService.showNotice(pluginApi.tr("main.updated_todo"));
      else
        ToastService.showError(pluginApi.tr("main.error_update_failed"));
    }

    function setTodoText(id, text) {
      if (updateTodo(id, {text: text}))
        ToastService.showNotice(pluginApi.tr("main.updated_todo"));
      else
        ToastService.showError(pluginApi.tr("main.error_update_failed"));
    }

    function toggleTodo(id) {
      var todo;
      var completed;

      todo = findTodo(id);
      if (!todo) {
        ToastService.showError(pluginApi.tr("main.error_todo_not_found"));
        return;
      }

      completed = !todo.completed;
      updateTodo(id, {completed: completed});
      ToastService.showNotice(pluginApi.tr("main.todo_status_changed") + (completed ? pluginApi.tr("main.todo_completed") : pluginApi.tr("main.todo_marked_incomplete")));
    }

    function removeTodo(id) {
      if (deleteTodo(id))
        ToastService.showNotice(pluginApi.tr("main.removed_todo"));
      else
        ToastService.showError(pluginApi.tr("main.error_remove_failed"));
    }

    function clearCompleted() {
      var cleared = clearCompletedTodos();
      ToastService.showNotice(pluginApi.tr("main.cleared_completed_todos") + cleared + pluginApi.tr("main.completed_todos_suffix"));
    }

    function clearAll() {
      clearAllTodos();
      ToastService.showNotice(pluginApi.tr("main.cleared_all_todos"));
    }

    function getPages() {
      return JSON.stringify(rawPages);
    }

    function addPage(name) {
      var trimmedName = name.trim();
      if (!trimmedName) {
        ToastService.showError(pluginApi.tr("settings.pages.empty_name"));
        return;
      }
      if (pageNameExists(trimmedName)) {
        ToastService.showError(pluginApi.tr("settings.pages.name_exists"));
        return;
      }
      createPage(trimmedName);
      ToastService.showNotice(pluginApi.tr("settings.pages.added_page") + trimmedName);
    }

    function renamePage(pageId, newName) {
      var trimmedName = newName.trim();
      if (!trimmedName) {
        ToastService.showError(pluginApi.tr("settings.pages.empty_name"));
        return;
      }
      if (!pageExists(pageId)) {
        ToastService.showError(pluginApi.tr("main.error_page_not_found"));
        return;
      }
      if (pageNameExistsExcluding(pageId, trimmedName)) {
        ToastService.showError(pluginApi.tr("settings.pages.name_exists"));
        return;
      }
      renamePageInternal(pageId, trimmedName);
      ToastService.showNotice(pluginApi.tr("settings.pages.renamed_page"));
    }

    function removePage(pageId) {
      if (pageId === 0) {
        ToastService.showError(pluginApi.tr("settings.pages.cannot_delete_default"));
        return;
      }
      if (isLastPage()) {
        ToastService.showError(pluginApi.tr("settings.pages.cannot_delete_last"));
        return;
      }
      if (!pageExists(pageId)) {
        ToastService.showError(pluginApi.tr("main.error_page_not_found"));
        return;
      }
      deletePage(pageId);
      ToastService.showNotice(pluginApi.tr("settings.pages.deleted_page"));
    }

    function exportTodos() {
      doExportTodos();
    }
  }

  function createTodo(text, priority, pageId) {
    rawTodos.push({
      id: Date.now(),
      text: text,
      completed: false,
      createdAt: new Date().toISOString(),
      pageId: pageId,
      priority: priority,
      details: ""
    });
    saveTodos();
    return true;
  }

  function updateTodo(id, updates) {
    var index;
    var oldCompleted;

    index = findTodoIndex(id);
    if (index === -1)
      return false;

    oldCompleted = rawTodos[index].completed;
    if (updates.text !== undefined)
      rawTodos[index].text = updates.text;
    if (updates.completed !== undefined)
      rawTodos[index].completed = updates.completed;
    if (updates.priority !== undefined)
      rawTodos[index].priority = updates.priority;
    if (updates.details !== undefined)
      rawTodos[index].details = updates.details;

    if (updates.completed !== undefined && oldCompleted !== updates.completed)
      moveTodoToCorrectPosition(id);
    else
      saveTodos();

    return true;
  }

  function deleteTodo(id) {
    var index;

    index = findTodoIndex(id);
    if (index === -1)
      return false;

    rawTodos.splice(index, 1);
    saveTodos();
    return true;
  }

  function clearCompletedTodos() {
    var active;
    var i;
    var cleared;

    active = [];
    for (i = 0; i < rawTodos.length; ++i) {
      if (!rawTodos[i].completed)
        active.push(rawTodos[i]);
    }

    cleared = rawTodos.length - active.length;
    rawTodos = active;
    saveTodos();
    return cleared;
  }

  function clearAllTodos() {
    rawTodos = [];
    saveTodos();
  }

  function createPage(name) {
    var newId;
    var i;

    newId = 0;
    for (i = 0; i < rawPages.length; ++i) {
      if (rawPages[i].id >= newId)
        newId = rawPages[i].id + 1;
    }

    rawPages.push({id: newId, name: name});
    savePages();
    return true;
  }

  function renamePageInternal(pageId, newName) {
    var i;

    for (i = 0; i < rawPages.length; ++i) {
      if (rawPages[i].id === pageId) {
        rawPages[i].name = newName;
        break;
      }
    }

    savePages();
    return true;
  }

  function deletePage(pageId) {
    var keptPages;
    var i;

    for (i = 0; i < rawTodos.length; ++i) {
      if (rawTodos[i].pageId === pageId)
        rawTodos[i].pageId = 0;
    }

    keptPages = [];
    for (i = 0; i < rawPages.length; ++i) {
      if (rawPages[i].id !== pageId)
        keptPages.push(rawPages[i]);
    }
    rawPages = keptPages;

    if (pluginApi.pluginSettings.current_page_id === pageId)
      pluginApi.pluginSettings.current_page_id = 0;

    saveTodos();
    savePages();
    return true;
  }

  function moveTodoToCorrectPosition(todoId) {
    var todoIndex;
    var movedTodo;

    todoIndex = findTodoIndex(todoId);
    if (todoIndex === -1)
      return;

    movedTodo = rawTodos[todoIndex];
    rawTodos.splice(todoIndex, 1);

    if (movedTodo.completed)
      rawTodos.push(movedTodo);
    else
      rawTodos.unshift(movedTodo);

    saveTodos();
  }

  function moveTodo(todoId, fromIndex, toIndex, pageId) {
    var pageTodos;
    var i;
    var item;
    var pageTodoId;
    var rawIndex;
    var clampedIndex;

    pageTodos = [];
    for (i = 0; i < rawTodos.length; ++i) {
      if (rawTodos[i].pageId === pageId)
        pageTodos.push(rawTodos[i]);
    }

    if (fromIndex < 0 || fromIndex >= pageTodos.length || toIndex < 0 || toIndex >= pageTodos.length)
      return;

    pageTodoId = pageTodos[fromIndex].id;
    rawIndex = findTodoIndex(pageTodoId);
    item = rawTodos[rawIndex];
    rawTodos.splice(rawIndex, 1);

    clampedIndex = toIndex;
    if (clampedIndex < 0)
      clampedIndex = 0;
    if (clampedIndex > rawTodos.length)
      clampedIndex = rawTodos.length;

    rawTodos.splice(clampedIndex, 0, item);
    saveTodos();
  }

  function moveTodoItem(fromIndex, toIndex) {
    moveTodo("", fromIndex, toIndex, getCurrentPageId());
  }

  function findTodo(id) {
    var i;

    for (i = 0; i < rawTodos.length; ++i) {
      if (rawTodos[i].id == id)
        return rawTodos[i];
    }

    return null;
  }

  function findTodoIndex(id) {
    var i;

    for (i = 0; i < rawTodos.length; ++i) {
      if (rawTodos[i].id == id)
        return i;
    }

    return -1;
  }

  function pageExists(pageId) {
    var i;

    for (i = 0; i < rawPages.length; ++i) {
      if (rawPages[i].id === pageId)
        return true;
    }

    return false;
  }

  function pageNameExists(name) {
    var i;
    var loweredName = name.toLowerCase();

    for (i = 0; i < rawPages.length; ++i) {
      if (rawPages[i].name.toLowerCase() === loweredName)
        return true;
    }

    return false;
  }

  function pageNameExistsExcluding(excludeId, name) {
    var i;
    var loweredName = name.toLowerCase();

    for (i = 0; i < rawPages.length; ++i) {
      if (rawPages[i].id !== excludeId && rawPages[i].name.toLowerCase() === loweredName)
        return true;
    }

    return false;
  }

  function isLastPage() {
    return rawPages.length <= 1;
  }

  function doExportTodos() {
    var format;
    var content;

    if (!pluginApi)
      return;

    format = pluginApi.pluginSettings.exportFormat;
    if (format === "json")
      content = JSON.stringify(rawTodos, null, 2);
    else
      content = generateExportMarkdown();

    exportTodosToFile(content, format === "json" ? ".json" : ".md");
  }

  function exportTodosToFile(content, fileExtension) {
    try {
      var timestamp = new Date().toISOString().split("T")[0];
      var timeSuffix = new Date().toISOString().replace(/[:.]/g, "-").split("T")[1];
      var fileName = "todo_" + timestamp + "_" + timeSuffix + fileExtension;
      var exportPath = pluginApi.pluginSettings.exportPath.replace("~", Quickshell.env("HOME"));
      var filePath;

      if (exportPath.charAt(exportPath.length - 1) === "/")
        exportPath = exportPath.slice(0, -1);

      filePath = exportPath + "/" + fileName;
      currentExportPath = filePath;
      exportProcess.command = ["sh", "-c", "cat > \"" + filePath + "\" <<'EOF'\n" + content + "\nEOF"];
      exportProcess.running = true;
    } catch (e) {
      ToastService.showError(pluginApi.tr("main.export_failed"));
    }
  }

  function generateExportMarkdown() {
    var lines;
    var p;
    var i;
    var page;
    var pageTodos;

    lines = [];
    lines.push("# " + pluginApi.tr("main.export_title"));
    lines.push("");

    for (p = 0; p < rawPages.length; ++p) {
      page = rawPages[p];
      pageTodos = [];

      for (i = 0; i < rawTodos.length; ++i) {
        if (rawTodos[i].pageId === page.id)
          pageTodos.push(rawTodos[i]);
      }

      if (!pluginApi.pluginSettings.exportEmptySections && pageTodos.length === 0)
        continue;

      lines.push("## " + page.name);
      lines.push("");

      for (i = 0; i < pageTodos.length; ++i)
        lines.push("- [" + (pageTodos[i].completed ? "x" : " ") + "] " + pageTodos[i].text);

      lines.push("");
    }

    return lines.join("\n");
  }
}
