({
  init: function (component, event, helper) {
    var workspaceAPI = component.find("workspace");
    workspaceAPI.getFocusedTabInfo().then(function(response) {
        var focusedTabId = response.tabId;
        workspaceAPI.setTabLabel({
            tabId: focusedTabId,
            label: "Field Service Starter Kit Settings"
        });
    })
   }
});