/**
 * @author Oren Yulzary
 * @date 2020-07-14
 */
@IsTest
private class FSK_FSLUserRelatedObjectsServiceTest {
    @TestSetup
    static void setup() {
        FSK_FSL_Starter_Kit__c settings = new FSK_FSL_Starter_Kit__c();
        settings.Create_FSL_Resource_From_User__c = true;
        insert settings;
    }

    @IsTest
    static void insertNewResourceUser_Success() {
        insertFSLPermissionSets();

        User user = FSK_TestFactory.createUser('userT', 'System Administrator', 'Resource');

        System.Test.startTest();
        insert user;
        System.Test.stopTest();

        FSK_FSLUserRelatedObjectsService service = FSK_FSLUserRelatedObjectsService.getInstance();

        // Check that all resource permissions set were created
        Set<String> resourcePermissionSet = service.permissionSetByRoleTypeMap.get('Resource');
        List<PermissionSetAssignment> permissionSetList = [
                SELECT Id, PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE AssigneeId = :user.Id
                AND PermissionSet.Name IN :resourcePermissionSet
        ];
        System.assertEquals(resourcePermissionSet.size(), permissionSetList.size());

        // Check if service resource was created
        List<ServiceResource> serviceResources = [SELECT Id, ResourceType, IsActive FROM ServiceResource WHERE RelatedRecordId = :user.Id];
        System.assertEquals(1, serviceResources.size());
        System.assertEquals(true, serviceResources[0].IsActive);
        System.assertEquals('T', serviceResources[0].ResourceType);
    }

    @IsTest
    static void updateResourceUser_Success() {
        insertFSLPermissionSets();

        User user = FSK_TestFactory.createUser('userT', 'System Administrator', null);
        insert user;

        System.runAs(user) {
            System.Test.startTest();
            user.FSK_FSL_Resource_Type__c = 'Resource_Mobile';
            update user;
            System.Test.stopTest();
        }

        FSK_FSLUserRelatedObjectsService service = FSK_FSLUserRelatedObjectsService.getInstance();

        // Check that all resource + mobile permissions were created
        Set<String> resourceSet = service.permissionSetByRoleTypeMap.get('Resource');
        Set<String> mobileSet = service.permissionSetByRoleTypeMap.get('Mobile');
        List<PermissionSetAssignment> permissionSetList = [
                SELECT Id, PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE AssigneeId = :user.Id
                AND (PermissionSet.Name IN :resourceSet OR PermissionSet.Name IN :mobileSet)
        ];

        System.assertEquals(resourceSet.size() + mobileSet.size(), permissionSetList.size());
    }

    @IsTest
    static void updateDispatcherToResourceUser_Success() {
        insertFSLPermissionSets();

        User user = FSK_TestFactory.createUser('userT', 'System Administrator', 'Dispatcher');
        insert user;

        System.runAs(user) {
            System.Test.startTest();
            user.FSK_FSL_Resource_Type__c = 'Resource';
            update user;
            System.Test.stopTest();
        }

        FSK_FSLUserRelatedObjectsService service = FSK_FSLUserRelatedObjectsService.getInstance();

        // Check that all resource permissions were created
        Set<String> resourceSet = service.permissionSetByRoleTypeMap.get('Resource');
        List<PermissionSetAssignment> resourcePermissionSetList = [
                SELECT Id, PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE AssigneeId = :user.Id
                AND PermissionSet.Name IN :resourceSet
        ];
        System.assertEquals(resourceSet.size(), resourcePermissionSetList.size());

        // Check that all dispatcher permissions were deleted
        Set<String> dispatcherSet = service.permissionSetByRoleTypeMap.get('Dispatcher');
        List<PermissionSetAssignment> dispatcherPermissionSetList = [
                SELECT Id, PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE AssigneeId = :user.Id
                AND PermissionSet.Name IN :dispatcherSet
        ];
        System.assertEquals(0, dispatcherPermissionSetList.size());

        // Check that all dispatcher permissions set license were deleted
        Set<String> dispatcherPermissionSetLicense = service.permissionSetLicenseByRoleTypeMap.get('Dispatcher');
        List<PermissionSetLicenseAssign> dispatcherPermissionSetLicenseList = [
                SELECT Id, PermissionSetLicense.DeveloperName
                FROM PermissionSetLicenseAssign
                WHERE AssigneeId = :user.Id
                AND PermissionSetLicense.DeveloperName IN :dispatcherPermissionSetLicense
        ];
        System.assertEquals(0, dispatcherPermissionSetLicenseList.size());
    }

    @IsTest
    static void insertNewResourceUser_featureIsNotActive() {
        User user = FSK_TestFactory.createUser('userT', 'System Administrator', 'Resource');

        FSK_FSL_Starter_Kit__c settings = FSK_FSL_Starter_Kit__c.getOrgDefaults();
        settings.Create_FSL_Resource_From_User__c = false;
        update settings;

        try {
            System.Test.startTest();
            insert user;
            System.Test.stopTest();
        }
        catch(DmlException ex) {
            System.debug(LoggingLevel.INFO, 'Feature is inactive');
        }

        FSK_FSLUserRelatedObjectsService service = FSK_FSLUserRelatedObjectsService.getInstance();

        // Check that all resource permissions set weren't created
        Set<String> resourcePermissionSet = service.permissionSetByRoleTypeMap.get('Resource');
        List<PermissionSetAssignment> permissionSetList = [
                SELECT Id, PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE AssigneeId = :user.Id
                AND PermissionSet.Name IN :resourcePermissionSet
        ];
        System.assertEquals(0, permissionSetList.size());

        // Check that the service resource wasn't created
        List<ServiceResource> serviceResources = [SELECT Id, ResourceType, IsActive FROM ServiceResource WHERE RelatedRecordId = :user.Id];
        System.assertEquals(0, serviceResources.size());
    }

    @IsTest
    static void updateResourceUser_withExistingServiceResource() {

        User user = FSK_TestFactory.createUser('userT', 'System Administrator', null);
        insert user;

        ServiceResource serviceResource = FSK_TestFactory.createServiceResource(user);
        insert serviceResource;

        System.runAs(user) {
            insertFSLPermissionSets();

            System.Test.startTest();
            user.FSK_FSL_Resource_Type__c = 'Resource';
            update user;
            System.Test.stopTest();
        }

        FSK_FSLUserRelatedObjectsService service = FSK_FSLUserRelatedObjectsService.getInstance();

        // Check that all resource + mobile permissions were created
        Set<String> resourceSet = service.permissionSetByRoleTypeMap.get('Resource');
        List<PermissionSetAssignment> permissionSetList = [
                SELECT Id, PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE AssigneeId = :user.Id
                AND PermissionSet.Name IN :resourceSet
        ];
        System.assertEquals(resourceSet.size(), permissionSetList.size());

        // Check that the service resource wasn't created
        List<ServiceResource> serviceResources = [SELECT Id, ResourceType, IsActive FROM ServiceResource WHERE RelatedRecordId = :user.Id];
        System.assertEquals(1, serviceResources.size());
        System.assertEquals(serviceResource.Id, serviceResources[0].Id);
    }

    static void insertFSLPermissionSets() {
        List<PermissionSet> psList = new List<PermissionSet>();
        FSK_FSLUserRelatedObjectsService service = FSK_FSLUserRelatedObjectsService.getInstance();
        List<Set<String>> permissionSetNames = service.permissionSetByRoleTypeMap.values();
        for(Set<String> permissionSetName : permissionSetNames) {
            for( String permissionSet : permissionSetName) {
                PermissionSet ps = new PermissionSet(Name = permissionSet, Label = permissionSet);
                psList.add(ps);
            }
        }

        List<Database.SaveResult> saveResults = Database.insert(psList, false);
        for (Database.SaveResult saveResult : saveResults) {
            if(!saveResult.isSuccess()) {
                System.debug(LoggingLevel.ERROR, saveResult.errors);
            }
        }
    }
}