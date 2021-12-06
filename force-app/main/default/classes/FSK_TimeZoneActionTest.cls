@isTest
public with sharing class FSK_TimeZoneActionTest {
    @TestSetup
    static void makeData() {
        User user = [SELECT Id, TimeZoneSidKey FROM User WHERE Id = :UserInfo.getUserId()];
        user.TimeZoneSidKey = 'Europe/London';
        update user;
    }

    @isTest
    static void testConvertTimeZone() {
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

        // System.assertEquals(1, output.dateOutput.day());
        // System.assertEquals(10, output.dateOutput.month());
        // System.assertEquals(2021, output.dateOutput.year());

        // System.assertEquals(12, output.timeOutput.hour());
        // System.assertEquals(0, output.timeOutput.minute());
        // System.assertEquals(0, output.timeOutput.second());

        // System.assertEquals('01/10/2021', output.dateString);
        // System.assertEquals('12:00:00', output.timeString);

        System.assertNotEquals(null, output.dateString);
        System.assertNotEquals(null, output.timeString);
    }

    @isTest
    static void testConvertTimeZoneOtherDay() {
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

        // System.assertEquals(2, output.dateOutput.day());
        // System.assertEquals(10, output.dateOutput.month());
        // System.assertEquals(2021, output.dateOutput.year());

        // System.assertEquals(1, output.timeOutput.hour());
        // System.assertEquals(0, output.timeOutput.minute());
        // System.assertEquals(0, output.timeOutput.second());

        // System.assertEquals('02/10/2021', output.dateString);
        // System.assertEquals('01:00:00', output.timeString);

        System.assertNotEquals(null, output.dateString);
        System.assertNotEquals(null, output.timeString);
    }
}
