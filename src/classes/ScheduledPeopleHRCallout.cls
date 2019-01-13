/**
 * Created by Ronan Williams on 25/09/2018.
 */

public class ScheduledPeopleHRCallout implements Schedulable {

    public void execute(SchedulableContext ctx) {

        // get employees
        PeopleHRCallout.getEmployees();

        // get holidays
        PeopleHRCallout.getHolidays();

    }

}