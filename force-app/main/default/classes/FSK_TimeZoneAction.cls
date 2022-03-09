global with sharing class FSK_TimeZoneAction {
    @InvocableMethod(label='Convert Time Zone' description='Converts a Datetime according to the given time zone' category='Account')
    global static List<TimeZoneActionOutput> convertTimeZone(List<TimeZoneActionInput> inputList) {
        List<TimeZoneActionOutput> outputList = new List<TimeZoneActionOutput>();
        for(TimeZoneActionInput input : inputList) {
            TimeZoneActionOutput output = new TimeZoneActionOutput();
            output.dateOutput = getDate(input.dt, input.timeZone);
            output.timeOutput = getTime(input.dt, input.timeZone);
            output.dateString = input.dt.format(input.dateFormat, input.timeZone);
            output.timeString = input.dt.format(input.timeFormat, input.timeZone);

            outputList.add(output);
        }
        return outputList;
    }

    private static Date getDate(Datetime dt, String timeZoneName) {
        Datetime newDt = convertTZtoGMT(dt, timeZoneName);
        return newDt.dateGmt();
    }

    public static Time getTime(Datetime dt, String timeZoneName) {
        Datetime newDt = convertTZtoGMT(dt, timeZoneName);
        return newDt.timeGmt();
    }

    private static Datetime convertTZtoGMT(Datetime dt, String timeZoneName) {
        return doConversion(dt, timeZoneName, true);
    }

    private static Datetime doConversion(Datetime dt, String timeZoneName, Boolean addOrRemove) {
        Integer multiplier = (addOrRemove ? 1 : -1);
        Integer offsetInMinute = getTimezoneOffsetInMinutes(dt, timeZoneName);
        dt = dt.addMinutes(multiplier * offsetInMinute);
        return dt;
    }

    private static Integer getTimezoneOffsetInMinutes(Datetime dt, String timeZoneName) {
        TimeZone storeTimeZone = TimeZone.getTimeZone(timeZoneName);
        Integer offsetInMinute = storeTimeZone.getOffset(dt) / (60 * 1000);
        return offsetInMinute;
    }

    global class TimeZoneActionInput {
        @InvocableVariable(label='Datetime' required=true)
        global Datetime dt;

        @InvocableVariable(label='Time Zone' required=true)
        global String timeZone;

        @InvocableVariable(label='Date Format' required=true)
        global String dateFormat;

        @InvocableVariable(label='Time Format' required=true)
        global String timeFormat;
    }

    global class TimeZoneActionOutput {
        @InvocableVariable(label='Date' required=true)
        global Date dateOutput;

        @InvocableVariable(label='Time' required=true)
        global Time timeOutput;

        @InvocableVariable(label='Date String' required=true)
        global String dateString;

        @InvocableVariable(label='Time String' required=true)
        global String timeString;
    }
}

