/**
 * @author Oren Yulzary
 * @date 2020-07-14
 */
trigger FSK_UserTrigger on User (after insert, after update) {
    if(Trigger.isInsert) {
        if(Trigger.isAfter) {
            FSK_UserTriggerHandler.afterInsert(Trigger.newMap);
        }
    }
    else if(Trigger.isUpdate) {
        if(Trigger.isAfter) {
            FSK_UserTriggerHandler.afterUpdate(Trigger.oldMap, Trigger.newMap);
        }
    }
}