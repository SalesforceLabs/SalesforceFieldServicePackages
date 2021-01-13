/**
 * @author Shani Joffe
 * @date 2020-28-12
 */
public with sharing class FSK_SettingsPageCtrl {

    @AuraEnabled
    public static FSK_SettingsWrapper getSettings() {
        FSK_FSL_Starter_Kit__c sk = FSK_FSL_Starter_Kit__c.getOrgDefaults();
        System.debug('sk ON LOAD == > ' +sk);
        //Take fields of custom settings and build custom settings object wrapper.
        FSK_SettingsWrapper  skObj = new FSK_SettingsWrapper();
        if(sk.Id != null){
            skObj.id = sk.Id;
        }

        //First section -status Base Flow
        skObj.mobileStatusSatiation  = sk.Mobile_Status_Satiation__c;
        skObj.actualTimes  = sk.ActualTimes__c;
        skObj.actualTimesOnGantt  = sk.Actual_Times_on_Gantt__c;

        //First section  - Status 
        skObj.startingStatus = sk.StartingStatus__c;
        skObj.endingStatus = sk.EndingStatus__c;

        //second section - Mobile notifications
        skObj.mobileCannedCustomNotification = sk.Mobile_Canned_Custom_Notification__c;
        skObj.hoursforDispNotif  = sk.Hours_for_Dispatched_Notification__c;
        skObj.dispatchedNotification  = sk.Dispatched_Notification__c;
        skObj.emerDispatchedNotification  = sk.Emergency_Dispatched_Notification__c;
        skObj.cancelationNotification  = sk.Cancelation_Notification__c;

        //Third section General
        skObj.daysUntilFirstMain  = sk.Days_Until_First_Maintenance__c;
        skObj.successfulAssetInstallation = sk.Successful_Asset_Installation_Status__c;

        skObj.addAssetToMaintenancePlan  = sk.Add_Asset_to_Maintenance_Plan__c;
        skObj.createFSLResourceFromUser  = sk.Create_FSL_Resource_From_User__c;
        skObj.excludedSROnSARejection  = sk.Excluded_SR_on_SA_Rejection__c;
        skObj.assignResourceOnServiceAppointment  = sk.Assign_Resource_On_Service_Appointment__c;
        skObj.populateWorkOrderLookup  = sk.Populate_Work_Order_Lookup__c;
        skObj.setGanttLabel  = sk.Set_Gantt_Label__c;
        skObj.removeLicensesOnDeactivation  = sk.Remove_Licenses_on_Deactivation__c;

        System.debug('sk == >' + JSON.serializePretty(sk));
        System.debug('skObj == >' + JSON.serializePretty(skObj));

       // return sk;
       return skObj;
    }

//TODO : Change class reposnse name to Response wrappper 
//TODO: chnage status to boolean
//TODO: FSK_Response_error_msg => settings page repsonse 

    @AuraEnabled
    public static ResponseMsg saveSettings(FSK_SettingsWrapper skWrapperObj) {
        ResponseMsg resp = new ResponseMsg();
        try {
            System.debug('skWrapperObj == >' + skWrapperObj);

            //Check if the Custom settings exsits, if not create an instanse. 
            FSK_FSL_Starter_Kit__c skToSave = FSK_FSL_Starter_Kit__c.getOrgDefaults();
            if(skToSave == NULL){
                skToSave = new FSK_FSL_Starter_Kit__c();
            }
            
            //Take fields from wrapper - UI and insert those fields to the skToSave which we want to update/create.
            skToSave.ActualTimes__c =  skWrapperObj.actualTimes;
            skToSave.Actual_Times_on_Gantt__c =  skWrapperObj.actualTimesOnGantt;

            skToSave.StartingStatus__c =  skWrapperObj.startingStatus;
            skToSave.EndingStatus__c =  skWrapperObj.endingStatus;

            skToSave.Mobile_Canned_Custom_Notification__c = skWrapperObj.mobileCannedCustomNotification;
            skToSave.Hours_for_Dispatched_Notification__c =  skWrapperObj.hoursforDispNotif;

            skToSave.Dispatched_Notification__c =  skWrapperObj.dispatchedNotification;
            skToSave.Emergency_Dispatched_Notification__c =  skWrapperObj.emerDispatchedNotification;
            skToSave.Cancelation_Notification__c =  skWrapperObj.cancelationNotification;

            skToSave.Days_Until_First_Maintenance__c =  skWrapperObj.daysUntilFirstMain;
            skToSave.Mobile_Status_Satiation__c =  skWrapperObj.mobileStatusSatiation;
            skToSave.Successful_Asset_Installation_Status__c =  skWrapperObj.successfulAssetInstallation;

            skToSave.Add_Asset_to_Maintenance_Plan__c =  skWrapperObj.addAssetToMaintenancePlan;
            skToSave.Create_FSL_Resource_From_User__c =  skWrapperObj.createFSLResourceFromUser;
            skToSave.Excluded_SR_on_SA_Rejection__c =  skWrapperObj.excludedSROnSARejection;
            skToSave.Assign_Resource_On_Service_Appointment__c =  skWrapperObj.assignResourceOnServiceAppointment;
            skToSave.Set_Gantt_Label__c =  skWrapperObj.setGanttLabel;
            skToSave.Remove_Licenses_on_Deactivation__c =  skWrapperObj.removeLicensesOnDeactivation;

            System.debug('skToSave == > ' + JSON.serialize(skToSave));
                    
            if(skToSave.Set_Gantt_Label__c == true){

                //update PermissionSetLicense
                Set<String> devNames = new Set<String>();
                devNames.add('FieldServiceMobilePsl');
                devNames.add('FieldServiceDispatcherPsl');
                devNames.add('FieldServiceSchedulingPsl');

                Map<String,String> devNameToIdPslMap = new  Map<String,String>();

                List<PermissionSetLicense>  pslList = [SELECT Id ,DeveloperName
                                            FROM PermissionSetLicense
                                            WHERE DeveloperName IN: devNames];
                System.debug('pslList == > ' + pslList);

                for(PermissionSetLicense psl : pslList){
                    devNameToIdPslMap.put(psl.DeveloperName,psl.Id);
                }
                System.debug('devNameToIdPslMap == > ' + devNameToIdPslMap);

                skToSave.Mobile_PSL_ID__c = devNameToIdPslMap.get('FieldServiceMobilePsl');
                skToSave.Dispatcher_PSL_ID__c = devNameToIdPslMap.get('FieldServiceDispatcherPsl');
                skToSave.Scheduling_PSL_ID__c = devNameToIdPslMap.get('FieldServiceSchedulingPsl');

                //update PermissionSet
                Set<String> psNames = new Set<String>();
                psNames.add('FSL_Dispatcher_Permissions');
                psNames.add('FSL_Dispatcher_License');
                psNames.add('FSL_Resource_License');
                psNames.add('FSL_Resource_Permissions');
                psNames.add('FSL_Mobile_License');
                psNames.add('FSL_Community_Dispatcher_License');
                psNames.add('FSL_Community_Dispatcher_Permissions');

                Map<String,String> psNameToIdPlMap = new Map<String,String>();
                List<PermissionSet>  psList = [ SELECT Id ,Name
                                                FROM PermissionSet
                                                WHERE Name IN: psNames];
                for(PermissionSet ps : psList){
                    psNameToIdPlMap.put(ps.Name,ps.Id);
                }
                skToSave.Dispatcher_License_Permission_ID__c = psNameToIdPlMap.get('FSL_Dispatcher_Permissions');
                skToSave.Dispatcher_Permissions_ID__c = psNameToIdPlMap.get('FSL_Dispatcher_License');
                skToSave.Resource_License_Permission_ID__c = psNameToIdPlMap.get('FSL_Resource_License');
                skToSave.Resource_Permissions_ID__c = psNameToIdPlMap.get('FSL_Resource_Permissions');
                skToSave.Mobile_License_Permission_ID__c = psNameToIdPlMap.get('FSL_Mobile_License');
                skToSave.Community_Dispatcher_License__c = psNameToIdPlMap.get('FSL_Community_Dispatcher_License');
                skToSave.Community_Dispatcher_License__c = psNameToIdPlMap.get('FSL_Community_Dispatcher_Permissions');         
            }

            upsert skToSave;
            resp.isSuccess = true;
            resp.msg = Label.FSK_Settings_Page_Success_Response;

        } catch(Exception e) {
            resp.isSuccess = false;
            resp.msg = Label.FSK_Settings_Page_Error_Response;
            resp.error = e.getMessage() + '\n ' + e.getCause() + '\n ' + e.getStackTraceString();
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        return resp;
    }

    public class ResponseMsg{

        @AuraEnabled
        public boolean isSuccess {get; set;}

        @AuraEnabled
        public String msg {get; set;}

        @AuraEnabled
        public String error {get; set;}

        public ResponseMsg(){
            isSuccess = false;
            msg = '';
        }
    }
}