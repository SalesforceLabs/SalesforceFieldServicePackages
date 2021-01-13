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
        FSK_SettingsWrapper skTest = FSK_SettingsPageCtrl.getSettings();
        
        System.assertNotEquals(skTest, null);
        skTest.actualTimesOnGantt = true;
        skTest.setGanttLabel = true;
        FSK_SettingsPageCtrl.saveSettings(skTest);   
        FSK_SettingsWrapper skTestUpdated = FSK_SettingsPageCtrl.getSettings();

        System.assertEquals(skTest.actualTimesOnGantt, skTestUpdated.actualTimesOnGantt);

        Test.stopTest();

     }
    
}