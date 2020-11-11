/**
 * @author Oren Yulzary
 * @date 2020-08-06
 */
@IsTest
public with sharing class FSK_SAStatusCheckboxGroupTest {

    @IsTest
    public static void getAppointmentStatus_Success() {
        List<String> excludeCategory = new List<String>{'Canceled','None'};
        List<ServiceAppointmentStatus> statuses = [SELECT Id, MasterLabel,ApiName,StatusCode FROM ServiceAppointmentStatus WHERE StatusCode NOT IN :excludeCategory];

        System.Test.startTest();
        List<FSK_SAStatusCheckboxGroupController.PicklistValue> picklistValues = FSK_SAStatusCheckboxGroupController.getAppointmentStatus(excludeCategory);
        System.Test.stopTest();

        System.assertEquals(statuses.size(), picklistValues.size());
    }

}