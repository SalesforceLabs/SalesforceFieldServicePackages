/**
 * @author Shani Joffe
 * @Date 30/12/2020
 */

@IsTest
public with sharing class FSK_SettingsPageCtrlTest {

    @IsTest
    public static void testgetSK_SettingsCSFromOrg() {
        
        Test.startTest();   
        FSK_FSL_Starter_Kit__c sk = FSK_FSL_Starter_Kit__c.getOrgDefaults();
        FSK_FSL_Starter_Kit__c skTest = FSK_SettingsPageCtrl.getSK_SettingsCSFromOrg();
        
        System.assertNotEquals(skTest, null);
        skTest.Actual_Times_on_Gantt__c = true;
        FSK_SettingsPageCtrl.saveSkSettings(skTest);   
        FSK_FSL_Starter_Kit__c skTestUpdated = FSK_SettingsPageCtrl.getSK_SettingsCSFromOrg();

        System.assertEquals(skTest.Actual_Times_on_Gantt__c, skTestUpdated.Actual_Times_on_Gantt__c);

        Test.stopTest();

     }
    
}