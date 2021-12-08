@isTest
public with sharing class FSK_TimeZoneActionTest {
    @testSetup
    static void makeData() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User newUser = new User(Alias='newUser', Email='timezoneuser@testorg.com',
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
         LocaleSidKey='en_US', ProfileId = p.Id,
         TimeZoneSidKey='Europe/London', UserName='timezoneuser@testorg.com');
        insert newUser;
    }

    @isTest
    static void testConvertTimeZone() {
        User newUser = [SELECT Id FROM User WHERE UserName='timezoneuser@testorg.com'];
        
        System.runAs(newUser) {
            String dateFormat = 'dd/MM/yyyy';
            String timeFormat = 'HH:mm:ss';
            Datetime dt = datetime.newInstance(2021, 10, 1, 10, 0, 0);
            String timeZone = 'Asia/Jerusalem';

            FSK_TimeZoneAction.TimeZoneActionInput input = new FSK_TimeZoneAction.TimeZoneActionInput();
            input.dt = dt;
            input.dateFormat = dateFormat;
            input.timeFormat = timeFormat;
            input.timeZone = timeZone;
            
            List<FSK_TimeZoneAction.TimeZoneActionInput> inputList = new List<FSK_TimeZoneAction.TimeZoneActionInput>();
            inputList.add(input);

            List<FSK_TimeZoneAction.TimeZoneActionOutput> outputList = FSK_TimeZoneAction.convertTimeZone(inputList);
            FSK_TimeZoneAction.TimeZoneActionOutput output = outputList[0];

            System.assertEquals(1, output.dateOutput.day());
            System.assertEquals(10, output.dateOutput.month());
            System.assertEquals(2021, output.dateOutput.year());

            System.assertEquals(12, output.timeOutput.hour());
            System.assertEquals(0, output.timeOutput.minute());
            System.assertEquals(0, output.timeOutput.second());

            System.assertEquals('01/10/2021', output.dateString);
            System.assertEquals('12:00:00', output.timeString);

            System.assertNotEquals(null, output.dateString);
            System.assertNotEquals(null, output.timeString);
        }
    }

    @isTest
    static void testConvertTimeZoneOtherDay() {
        User newUser = [SELECT Id FROM User WHERE UserName='timezoneuser@testorg.com'];

        System.runAs(newUser) {
            String dateFormat = 'dd/MM/yyyy';
            String timeFormat = 'HH:mm:ss';
            Datetime dt = datetime.newInstance(2021, 10, 1, 23, 0, 0);
            String timeZone = 'Asia/Jerusalem';

            FSK_TimeZoneAction.TimeZoneActionInput input = new FSK_TimeZoneAction.TimeZoneActionInput();
            input.dt = dt;
            input.dateFormat = dateFormat;
            input.timeFormat = timeFormat;
            input.timeZone = timeZone;
            
            List<FSK_TimeZoneAction.TimeZoneActionInput> inputList = new List<FSK_TimeZoneAction.TimeZoneActionInput>();
            inputList.add(input);

            List<FSK_TimeZoneAction.TimeZoneActionOutput> outputList = FSK_TimeZoneAction.convertTimeZone(inputList);
            FSK_TimeZoneAction.TimeZoneActionOutput output = outputList[0];

            System.assertEquals(2, output.dateOutput.day());
            System.assertEquals(10, output.dateOutput.month());
            System.assertEquals(2021, output.dateOutput.year());

            System.assertEquals(1, output.timeOutput.hour());
            System.assertEquals(0, output.timeOutput.minute());
            System.assertEquals(0, output.timeOutput.second());

            System.assertEquals('02/10/2021', output.dateString);
            System.assertEquals('01:00:00', output.timeString);

            System.assertNotEquals(null, output.dateString);
            System.assertNotEquals(null, output.timeString);
        }
    }
}
