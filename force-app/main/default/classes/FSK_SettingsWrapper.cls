public with sharing class FSK_SettingsWrapper {
    @AuraEnabled public String id {get;set;}

    //First section -status Base Flow
    @AuraEnabled public boolean mobileStatusSatiation {get;set;}
    @AuraEnabled public boolean actualTimes {get;set;}
    @AuraEnabled public boolean actualTimesOnGantt {get;set;}

    //First section  - Status 
    @AuraEnabled public String startingStatus {get;set;}
    @AuraEnabled public String endingStatus {get;set;}

    //second section - Mobile notifications
    @AuraEnabled public boolean mobileCannedCustomNotification {get;set;}
    @AuraEnabled public Decimal hoursforDispNotif {get;set;}

    @AuraEnabled public boolean dispatchedNotification {get;set;}
    @AuraEnabled public boolean emerDispatchedNotification {get;set;}
    @AuraEnabled public boolean cancelationNotification {get;set;}

    //Third section General
    @AuraEnabled public Decimal daysUntilFirstMain {get;set;}
    @AuraEnabled public String successfulAssetInstallation {get;set;}

    @AuraEnabled public boolean cancelChildSaOnWoCancellation {get;set;}
    @AuraEnabled public String serviceAppointmentParentStructure {get;set;}
    @AuraEnabled public boolean showTimesInDifferentTimezone {get;set;}
    @AuraEnabled public boolean populateWoliLookup {get;set;}
    @AuraEnabled public boolean addAssetToMaintenancePlan {get;set;}
    @AuraEnabled public boolean createFSLResourceFromUser {get;set;}
    @AuraEnabled public boolean excludedSROnSARejection {get;set;}
    @AuraEnabled public boolean assignResourceOnServiceAppointment {get;set;}
    @AuraEnabled public boolean populateWorkOrderLookup {get;set;}
    @AuraEnabled public boolean setGanttLabel {get;set;}
    @AuraEnabled public boolean removeLicensesOnDeactivation {get;set;}

    public FSK_SettingsWrapper(){
        this.id = null;
        this.mobileStatusSatiation = false;
        this.actualTimes = false;
        this.actualTimesOnGantt = false;

        //First section  - Status 
        this.startingStatus = '';
        this.endingStatus = '';

        //second section - Mobile notifications
        this.hoursforDispNotif = 0;

        this.dispatchedNotification = false;
        this.emerDispatchedNotification = false;
        this.cancelationNotification = false;

        //Third section General
        this.daysUntilFirstMain= 0;
        this.successfulAssetInstallation = '';


        this.cancelChildSaOnWoCancellation = false;
        this.serviceAppointmentParentStructure = '';
        this.showTimesInDifferentTimezone = false;
        this.populateWoliLookup = false;
        this.addAssetToMaintenancePlan = false;
        this.createFSLResourceFromUser = false;
        this.excludedSROnSARejection = false;
        this.assignResourceOnServiceAppointment = false;
        this.populateWorkOrderLookup = false;
        this.setGanttLabel = false;
        this.removeLicensesOnDeactivation = false;
    }
}