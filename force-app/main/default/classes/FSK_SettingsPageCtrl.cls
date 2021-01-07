/**
 * @author Shani Joffe
 * @date 2020-28-12
 */
public with sharing class FSK_SettingsPageCtrl {

    @AuraEnabled(cacheable=true)
    public static FSK_FSL_Starter_Kit__c getSK_SettingsCSFromOrg() {
        FSK_FSL_Starter_Kit__c sk = FSK_FSL_Starter_Kit__c.getOrgDefaults();
        System.debug('sk == >' + JSON.serializePretty(sk));
        
        return sk;
    }

    @AuraEnabled
    public static void saveSkSettings(FSK_FSL_Starter_Kit__c skToUpsert) {
        System.debug('skToUpsert == > ' + JSON.serializePretty(skToUpsert));
      upsert skToUpsert;
    }

}