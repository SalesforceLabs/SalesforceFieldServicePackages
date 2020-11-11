/**
 * @author Oren Yulzary
 * @date 2020-07-14
 */
@IsTest
public class FSK_TestFactory {
    public static User createUser(String name, String profileName, String resourceType) {
        List<Profile> p = [SELECT Id FROM Profile WHERE Name = :profileName];

        User u = new User(Alias = name, Email = 'standarduser@asperii.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p[0].Id,
                TimeZoneSidKey = 'America/Los_Angeles', Username = name + '@asperii.com', FSK_FSL_Resource_Type__c = resourceType);

        return u;
    }

    public static ServiceResource createServiceResource(User user) {
        ServiceResource sr = new ServiceResource();
        sr.Name = (String.isBlank(user.FirstName) ? '' : user.FirstName + ' ') + user.LastName;
        sr.RelatedRecordId = user.Id;
        sr.ResourceType = 'T';
        sr.IsActive = true;
        return sr;
    }
}