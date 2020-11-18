/**
 * @author Oren Yulzary
 * @date 2020-08-06
 */
 ({
    getOptions : function(component) {
        let excludeCategoriesValues = this.getExcludeCategories(component);

        let action = component.get("c.getAppointmentStatus");
        action.setParams(
            {
                excludeCategories : excludeCategoriesValues
            }
        );
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var statuses = response.getReturnValue();
                component.set("v.options", statuses);
            }
        });
        $A.enqueueAction(action);
    },

    getExcludeCategories : function(component) {
       let excludeCategoriesStr = component.get("v.excludeCategories");
       let excludeCategoriesValues = [];
       if(excludeCategoriesStr != null && excludeCategoriesStr != "") {
           excludeCategoriesValues = excludeCategoriesStr.split(',');
       }

       return excludeCategoriesValues;
    },

    setDefaultValues : function(component) {
        let defaultValuesStr = component.get("v.selectedValue");
        let values = [];
        if(defaultValuesStr != null && defaultValuesStr != "") {
            values = defaultValuesStr.split(',');
        }
        component.set('v.values', values);
    },
});