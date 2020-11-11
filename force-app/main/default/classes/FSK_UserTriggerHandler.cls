/**
 * @author Oren Yulzary
 * @date 2020-07-14
 */
public with sharing class FSK_UserTriggerHandler {

    public static void afterInsert(Map<Id, User> newItemsMap) {
        createFSLRelatedLicencesForNewUser(newItemsMap);
    }

    public static void afterUpdate(Map<Id, User> oldItemsMap, Map<Id, User> newItemsMap) {
        handleResourceTypeChanged(oldItemsMap, newItemsMap);
    }

    private static void createFSLRelatedLicencesForNewUser(Map<Id, User> newItemsMap) {
        FSK_FSLUserRelatedObjectsService fslUserService = FSK_FSLUserRelatedObjectsService.getInstance();
        fslUserService.createFSLRelatedLicencesForUser(newItemsMap.values(), null);
    }

    private static void handleResourceTypeChanged(Map<Id, User> oldItemsMap, Map<Id, User> newItemsMap) {
        List<User> usersToHandleList = new List<User>();
        for(User newUser : newItemsMap.values()) {
            User oldUser = oldItemsMap.get(newUser.Id);
            if (oldUser.FSK_FSL_Resource_Type__c != newUser.FSK_FSL_Resource_Type__c) {
                usersToHandleList.add(newUser);
            }
        }

        FSK_FSLUserRelatedObjectsService fslUserService = FSK_FSLUserRelatedObjectsService.getInstance();
        fslUserService.createFSLRelatedLicencesForUser(usersToHandleList, oldItemsMap);
    }
}