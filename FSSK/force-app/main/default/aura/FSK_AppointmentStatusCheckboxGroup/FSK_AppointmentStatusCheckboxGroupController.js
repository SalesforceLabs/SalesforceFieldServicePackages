/**
 * @author Oren Yulzary
 * @date 2020-08-06
 */
({
    init: function(component, event, helper) {
        helper.setDefaultValues(component);
        helper.getOptions(component);
    },

    handleChange: function (component, event) {
        component.set("v.selectedValue",event.getParam('value').toString())
    }
});