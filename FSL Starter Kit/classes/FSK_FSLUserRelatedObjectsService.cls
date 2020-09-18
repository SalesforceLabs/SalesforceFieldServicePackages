/**
 * @author Oren Yulzary
 * @date 2020-07-14
 */
public with sharing class FSK_FSLUserRelatedObjectsService {
    private static FSK_FSLUserRelatedObjectsService instance;

    @TestVisible
    private static List<String> infoList = new List<String>();
    private static List<String> errorList = new List<String>();

    private Map<String, SObject> groupsPermissionSetByNameMap;
    private Map<String, SObject> groupsPermissionSetLicenseByNameMap;

    @TestVisible
    private Map<String, Set<String>> permissionSetByRoleTypeMap = new Map<String, Set<String>>{
            'Resource' => new Set<String>{'FSL_Resource_License', 'FSL_Resource_Permissions'},
            'Mobile' => new Set<String>{'FSL_Mobile_License'},
            'Dispatcher' => new Set<String>{'FSL_Dispatcher_License', 'FSL_Dispatcher_Permissions'},
            'Community' => new Set<String>{'FSL_Community_Dispatcher_License', 'FSL_Community_Dispatcher_Permissions'}
    };

    @TestVisible
    private Map<String, Set<String>> permissionSetLicenseByRoleTypeMap = new Map<String, Set<String>>{
            'Resource' => new Set<String>{'FieldServiceSchedulingPsl'},
            'Mobile' => new Set<String>{'FieldServiceMobilePsl'},
            'Dispatcher' => new Set<String>{'FieldServiceDispatcherPsl'}
    };

    private FSK_FSLUserRelatedObjectsService() {
    }

    /**
     * @return Singleton instance of this class
     */
    public static FSK_FSLUserRelatedObjectsService getInstance() {
        if(instance == null) {
            instance = new FSK_FSLUserRelatedObjectsService();
        }
        return instance;
    }

    /**
     * @param featureName The feature API name that we want to check
     *
     * @return return true if this feature is active, otherwise return false
     */
    private Boolean isFeatureActive(String featureName) {
        FSK_FSL_Starter_Kit__c settings = FSK_FSL_Starter_Kit__c.getInstance();
        if(settings == null) {
            return false;
        }

        Boolean isActive = (Boolean) settings.get(featureName);
        if(isActive == null) {
            return false;
        }

        return isActive;
    }

    /**
     * @param usersList users that we want to handle
     * @param oldItemsMap old users map
     */
    public void createFSLRelatedLicencesForUser(List<User> usersList, Map<Id, User> oldItemsMap) {
        try {
            Boolean isActive = isFeatureActive('Create_FSL_Resource_From_User__c');
            if (!isActive) {
                return;
            }

            init();

            deleteExistingPermissionSetAssignment(oldItemsMap, usersList);
            createFSLUserRelatedObjects(usersList);
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }
    }

    /**
     * Initiate permissions name lists
     */
    private void init() {
        Set<String> permissionsNameList = getPermissionsNames(permissionSetByRoleTypeMap);
        List<PermissionSet> permissionSetList = [SELECT Id, Name FROM PermissionSet WHERE Name IN:permissionsNameList];
        groupsPermissionSetByNameMap = groupSObjectByField(permissionSetList, 'Name');
        System.debug('*** groupsPermissionSetByNameMap: ' + groupsPermissionSetByNameMap);

        Set<String> customPermissionsSetLicenseList = getPermissionsNames(permissionSetLicenseByRoleTypeMap);
        List<PermissionSetLicense> permissionSetLicenseList = [SELECT Id, DeveloperName FROM PermissionSetLicense WHERE DeveloperName IN: customPermissionsSetLicenseList];
        groupsPermissionSetLicenseByNameMap = groupSObjectByField(permissionSetLicenseList, 'DeveloperName');
    }

    /**
     * @description create for each user the related permissions set and service resource (if needed)
     * @param usersList users that we want to handle
     */
    private void createFSLUserRelatedObjects(List<User> usersList) {
        List<ServiceResource> serviceResourceToInsert = new List<ServiceResource>();
        List<PermissionSetAssignment> permissionSetAssignmentToInsert = new List<PermissionSetAssignment>();

        Map<Id, ServiceResource> serviceResourcesByUserIdMap = getExistingServiceResources(usersList);

        for (User user : usersList) {
            Set<String> fslRoleTypeSet = getFslRoleTypeSet(user);
            createRelatedObjectsForRoleTypeList(fslRoleTypeSet, user, serviceResourcesByUserIdMap, permissionSetAssignmentToInsert, serviceResourceToInsert);
        }

        if (!permissionSetAssignmentToInsert.isEmpty()) {
            insertObjects(permissionSetAssignmentToInsert, 'PermissionSetAssignment', errorList);
            if (serviceResourceToInsert.isEmpty()) {
                sendEmail(errorList, infoList);
            }
        }

        if (!serviceResourceToInsert.isEmpty()) {
            DelayedInsertSObjects insertObjectsQueue = new DelayedInsertSObjects(serviceResourceToInsert, 'ServiceResource', errorList, infoList);
            System.enqueueJob(insertObjectsQueue);
        }
    }

    /**
     * @param usersList users that we want to get the existing service resources
     *
     * @return map with all the existing service resources by the user id
     */
    private Map<Id, ServiceResource> getExistingServiceResources(List<User> usersList) {
        List<ServiceResource> serviceResources = [SELECT Id, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId IN :usersList AND ResourceType = 'T'];
        Map<Id, ServiceResource> serviceResourceByUserIdMap = new Map<Id, ServiceResource>();
        for (ServiceResource sr : serviceResources) {
            serviceResourceByUserIdMap.put(sr.RelatedRecordId, sr);
        }

        return serviceResourceByUserIdMap;
    }

    /**
     * @description delete for each user the related permissions set that were defined in Resource_Type picklist
     * @param oldItemsMap old users map
     * @param usersList users that we want to handle
     */
    private void deleteExistingPermissionSetAssignment(Map<Id, User> oldItemsMap, List<User> usersList) {
        if (oldItemsMap != null) {
            Map<Id, User> userWithPermissionSetAssignmentMap = getCurrentUserPermissionSetAssignments(usersList);

            List<PermissionSetAssignment> permissionSetAssignmentToDeleteList = new List<PermissionSetAssignment>();
            List<PermissionSetLicenseAssign> permissionSetLicenseAssignmentToDeleteList = new List<PermissionSetLicenseAssign>();
            for (User user : usersList) {
                List<PermissionSetAssignment> permissionSetAssignments = getUserPriorPermissionSetAssignments(oldItemsMap.get(user.Id), userWithPermissionSetAssignmentMap);
                List<PermissionSetLicenseAssign> permissionSetLicenseAssignments = getUserPriorPermissionSetLicenceAssignments(oldItemsMap.get(user.Id), userWithPermissionSetAssignmentMap);

                permissionSetAssignmentToDeleteList.addAll(permissionSetAssignments);
                permissionSetLicenseAssignmentToDeleteList.addAll(permissionSetLicenseAssignments);
            }

            if (!permissionSetAssignmentToDeleteList.isEmpty()) {
                deleteObjects(permissionSetAssignmentToDeleteList, 'PermissionSetAssignment');
            }

            if (!permissionSetLicenseAssignmentToDeleteList.isEmpty()) {
                deleteObjects(permissionSetLicenseAssignmentToDeleteList, 'PermissionSetLicenseAssignment');
            }
        }
    }

    /**
     * @param oldUser the user object before the update
     * @param userWithPermissionSetAssignmentMap user map with related list of the permissions set assignments for each user
     *
     * @return all permissions set assignments that should be deleted
     */
    private List<PermissionSetAssignment> getUserPriorPermissionSetAssignments(User oldUser, Map<Id, User> userWithPermissionSetAssignmentMap) {
        User userWithPermissionSetAssignment = userWithPermissionSetAssignmentMap.get(oldUser.Id);
        List<PermissionSetAssignment> permissionSetAssignments = userWithPermissionSetAssignment.PermissionSetAssignments;
        if(permissionSetAssignments.isEmpty()) {
            return new List<PermissionSetAssignment>();
        }

        Set<String> oldFslRoleTypeSet = getFslRoleTypeSet(oldUser);

        List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
        for (String fslRoleType : oldFslRoleTypeSet) {
            Set<String> permissionNameList = permissionSetByRoleTypeMap.get(fslRoleType);
            if(permissionNameList != null) {
                for (PermissionSetAssignment psa : permissionSetAssignments) {
                    if (permissionNameList.contains(psa.PermissionSet.Name)) {
                        permissionSetAssignmentList.add(psa);
                    }
                }
            }
        }

        return permissionSetAssignmentList;
    }

    /**
 * @param oldUser the user object before the update
 * @param userWithPermissionSetAssignmentMap user map with related list of the permissions set licence assignments for each user
 *
 * @return all permissions set licence assignments that should be deleted
 */
    private List<PermissionSetLicenseAssign> getUserPriorPermissionSetLicenceAssignments(User oldUser, Map<Id, User> userWithPermissionSetAssignmentMap) {
        User userWithPermissionSetAssignment = userWithPermissionSetAssignmentMap.get(oldUser.Id);
        List<PermissionSetLicenseAssign> permissionSetLicenseAssignments = userWithPermissionSetAssignment.PermissionSetLicenseAssignments;
        if(permissionSetLicenseAssignments.isEmpty()) {
            return new List<PermissionSetLicenseAssign>();
        }

        Set<String> oldFslRoleTypeSet = getFslRoleTypeSet(oldUser);

        List<PermissionSetLicenseAssign> permissionSetLicenseAssignmentList = new List<PermissionSetLicenseAssign>();
        for (String fslRoleType : oldFslRoleTypeSet) {
            Set<String> permissionNameList = permissionSetLicenseByRoleTypeMap.get(fslRoleType);
            if(permissionNameList != null) {
                for (PermissionSetLicenseAssign psl : permissionSetLicenseAssignments) {
                    if (permissionNameList.contains(psl.PermissionSetLicense.DeveloperName)) {
                        permissionSetLicenseAssignmentList.add(psl);
                    }
                }
            }
        }

        return permissionSetLicenseAssignmentList;
    }

    /**
     * @param usersList users that we want to get existing permissions set assignments
     *
     * @return user map with related list of the permissions set assignments (Permission Set + Permission Set License) for each user
     */
    private Map<Id, User> getCurrentUserPermissionSetAssignments(List<User> usersList) {
        Map<Id, User> userWithPermissionSetAssignmentMap = new Map<Id, User>([SELECT Id, (SELECT Id, PermissionSet.Name FROM PermissionSetAssignments), (SELECT Id, PermissionSetLicense.DeveloperName FROM PermissionSetLicenseAssignments) FROM User WHERE Id IN :usersList]);
        return userWithPermissionSetAssignmentMap;
    }

    /**
     * @param user User Object
     *
     * @return permission set types that the user requires
     */
    private Set<String> getFslRoleTypeSet(User user) {
        String fslRoleType = user.FSK_FSL_Resource_Type__c;
        if(fslRoleType == null) {
            return new Set<String>();
        }

        List<String> fslRoleTypeList = fslRoleType.split('_');
        Set<String> fslRoleTypeSet = new Set<String>(fslRoleTypeList);
        return fslRoleTypeSet;
    }

    /**
     * @param fslRoleTypeList permission set types that the user requires
     * @param user User Object
     * @param serviceResourcesByUserIdMap map with all the existing service resources by the user id
     * @param permissionSetAssignmentToInsert This method will fill the Permission Set Assignment that should be inserted
     * @param serviceResourceToInsert This method will fill the Service Resources that should be inserted
     */
    private void createRelatedObjectsForRoleTypeList(Set<String> fslRoleTypeList, User user, Map<Id, ServiceResource> serviceResourcesByUserIdMap, List<PermissionSetAssignment> permissionSetAssignmentToInsert, List<ServiceResource> serviceResourceToInsert) {
        for (String fslRoleType : fslRoleTypeList) {
            createRelatedObjectsForRoleType(fslRoleType, user, serviceResourcesByUserIdMap, permissionSetAssignmentToInsert, serviceResourceToInsert);
        }
    }

    /**
     * @param fslRoleType permission set type that the user requires
     * @param user User Object
     * @param serviceResourcesByUserIdMap map with all the existing service resources by the user id
     * @param permissionSetAssignmentToInsert This method will fill the Permission Set Assignment that should be inserted
     * @param serviceResourceToInsert This method will fill the Service Resources that should be inserted
     */
    private void createRelatedObjectsForRoleType(String fslRoleType, User user, Map<Id, ServiceResource> serviceResourcesByUserIdMap, List<PermissionSetAssignment> permissionSetAssignmentToInsert, List<ServiceResource> serviceResourceToInsert) {
        Set<String> permissionNameList = permissionSetByRoleTypeMap.get(fslRoleType);
        for (String permissionName : permissionNameList) {
            PermissionSet permissionSet = (PermissionSet) groupsPermissionSetByNameMap.get(permissionName);
            PermissionSetAssignment permissionSetAssignment = createPermissionSetAssignment(user, permissionSet);
            permissionSetAssignmentToInsert.add(permissionSetAssignment);
        }

        if (fslRoleType == 'Resource') {
            ServiceResource existServiceResource = serviceResourcesByUserIdMap.get(user.Id);
            if (existServiceResource != null) {
                infoList.add('The service resource for the user \'' + user.Id + '\' already exists \'' + existServiceResource.Id + '\'');
            }
            else {
                ServiceResource serviceResource = createServiceResource(user);
                serviceResourceToInsert.add(serviceResource);
            }
        }
    }

    /**
     * @param user User Object
     * @param permissionSet PermissionSet Object
     *
     * @return new PermissionSetAssignment
     */
    private PermissionSetAssignment createPermissionSetAssignment(User user, PermissionSet permissionSet) {
        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(
                AssigneeId = user.Id,
                PermissionSetId = permissionSet.Id
        );

        return permissionSetAssignment;
    }

    /**
     * @param customPermissionMap Map of all the permissions set names
     *
     * @return Set of all the permissions set names
     */
    private Set<String> getPermissionsNames(Map<String, Set<String>> customPermissionMap) {
        Set<String> allPermissions = new Set<String>();
        List<Set<String>> permissionsList = customPermissionMap.values();
        for(Set<String> profilePermissions : permissionsList) {
            allPermissions.addAll(profilePermissions);
        }
        return allPermissions;
    }

    /**
     * @param sObjectList Sobject list to group be the name field
     * @param groupByField field API name to map by
     *
     * @return Map with the field to group by as a key and the sObject as a value
     */
    private Map<String, SObject> groupSObjectByField(List<SObject> sObjectList, String groupByField) {
        Map<String, SObject> groupsByMap = new Map<String, SObject>();
        for(SObject sObj : sObjectList) {
            String key = sObj.get(groupByField) != null ? sObj.get(groupByField).toString() : '';
            groupsByMap.put(key, sObj);
        }

        return groupsByMap;
    }

    /**
     * @param user User object that will be related to the service resource
     *
     * @return new ServiceResource object that related to the user
     */
    private ServiceResource createServiceResource(User user) {
        ServiceResource sr = new ServiceResource();
        sr.Name = (String.isBlank(user.FirstName) ? '' : user.FirstName + ' ') + user.LastName;
        sr.RelatedRecordId = user.Id;
        sr.ResourceType = 'T';
        sr.IsActive = true;
        return sr;
    }

    /**
     * @param sObjectList Sobject List to insert
     * @param objectName Sobject name
     * @param errorList list of all the errors. This method will add all the errors that occurred due to the inserting action.
     */
    private static void insertObjects(List<SObject> sObjectList, String objectName, List<String> errorList) {
        if(sObjectList.size() > 0) {
            List<Database.SaveResult> srList = Database.insert(sObjectList, false);
            for (Integer i=0; i<srList.size(); i++) {
                Database.SaveResult sr = srList[i];
                SObject sObj = sObjectList[i];
                if (!sr.isSuccess()) {
                    String errorMsg = 'Error on inserting ' + objectName + '. SObject: ' + JSON.serialize(sObj) + '\', Errors: ' + JSON.serialize(sr.getErrors());
                    System.debug(LoggingLevel.ERROR, errorMsg);
                    errorList.add(errorMsg);
                }
            }
        }
    }

    /**
     * @param sObjectList Sobject List to update
     * @param objectName Sobject name
     */
    private void deleteObjects(List<SObject> sObjectList, String objectName) {
        if(sObjectList.size() > 0) {
            List<Database.DeleteResult> deleteResults = Database.delete(sObjectList, false);
            for (Integer i = 0; i < deleteResults.size(); i++) {
                Database.DeleteResult dr = deleteResults[i];
                SObject sObj = sObjectList[i];
                if (!dr.isSuccess()) {
                    String errorMsg = 'Error on deleting ' + objectName + '. SObject: ' + JSON.serialize(sObj) + '\', Errors: ' + JSON.serialize(dr.getErrors());
                    System.debug(LoggingLevel.ERROR, errorMsg);
                    errorList.add(errorMsg);
                }
            }
        }
    }

    /**
     * @param errorList the errors that we want to send by email message as attached file
     * @param infoList the info messages that we want to send by email message as attached file
     */
    private static void sendEmail(List<String> errorList, List<String> infoList) {
        System.debug('infoList: ' + infoList);
        System.debug('errorList: ' + errorList);
        if(errorList.isEmpty() && infoList.isEmpty()) {
            return;
        }

        EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Automate_FSL_User_Creation_Email'];

        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {UserInfo.getUserEmail()};
        mail.setToAddresses(toAddresses);
        mail.templateId = emailTemplate.Id;
        mail.targetObjectId = UserInfo.getUserId();
        mail.saveAsActivity = false;

        String fileBody =
                'Info ('+infoList.size()+'):\n' +
                        String.join(infoList, '\n') + '\n\n' +
                'Errors ('+errorList.size()+'):\n' +
                        String.join(errorList, '\n');


        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('Results.txt');
        efa.setBody(Blob.valueOf(fileBody));
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{efa});

        List<Messaging.SendEmailResult> sendEmailResultsList = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }, false);
        for (Messaging.SendEmailResult result : sendEmailResultsList) {
            if (!result.isSuccess()) {
                System.debug(LoggingLevel.ERROR, result.errors);
            }
        }

        errorList.clear();
    }

    @TestVisible
    class DelayedInsertSObjects implements Queueable {
        private String objectName;
        private List<SObject> SObjectListToInsert;
        private List<String> errorList;
        private List<String> infoList;

        public DelayedInsertSObjects(List<SObject> sObjectList, String objectName, List<String> errorList, List<String> infoList){
            this.SObjectListToInsert = sObjectList;
            this.objectName = objectName;
            this.errorList = errorList;
            this.infoList = infoList;
        }

        public void execute(QueueableContext context) {
            insertObjects(SObjectListToInsert, objectName, errorList);
            sendEmail(errorList, infoList);
        }
    }
}