/**
 * @author Oren Yulzary
 * @date 2020-08-06
 */
public with sharing class FSK_SAStatusCheckboxGroupController {
    /**
     * @return Returns all the service appointment statuses that are not related to status categories 'Canceled' or 'None'.
     */
    @AuraEnabled
    public static List<PicklistValue> getAppointmentStatus(List<String> excludeCategories) {
        Set<String> statusCodes = new Set<String>{'Scheduled','Dispatched', 'InProgress', 'CannotComplete', 'Completed', 'Canceled', 'None'};
        Set<String> statusCodesToExclude = new Set<String>();
        for (String status : statusCodes) {
            if (excludeCategories.contains(status)) {
                statusCodesToExclude.add(status);
            }
        }
        List<ServiceAppointmentStatus> statuses = [SELECT Id, MasterLabel,ApiName,StatusCode FROM ServiceAppointmentStatus WHERE StatusCode NOT IN :statusCodesToExclude];
        List<PicklistValue> values = new List<PicklistValue>();

        for(ServiceAppointmentStatus status : statuses) {
            values.add(new PicklistValue(status.MasterLabel, status.ApiName));
        }
        System.debug(JSON.serialize(values));
        return values;
    }

    public class PicklistValue {
        @AuraEnabled
        public String label {get; private set;}
        @AuraEnabled
        public String value {get; private set;}

        public PicklistValue(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}