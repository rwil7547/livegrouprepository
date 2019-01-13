/**
 * Created by Ronan Williams on 25/09/2018.
 */

@IsTest
public class ProjectTrackerRemoterTest {

    @IsTest
    public static void testGetOpps(){

        Account acc = (Account)SmartFactory.createSOBject('Account');
        insert acc;

        // Insert opp which should be returned by method
        Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp.AccountId   = acc.Id;
        opp.Amount      = 5000;
        opp.StageName   = 'Closed Won';
        opp.Invoice_Schedule__c = 'Single post-event invoice';
        opp.Event_Start__c  = Date.today();
        opp.Event_End__c    = Date.today();
        insert opp;

        // Insert opp which should not be returned by method due to dates
        Opportunity opp2 = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp2.AccountId   = acc.Id;
        opp2.Amount      = 5000;
        opp2.StageName   = 'Closed Won';
        opp2.Invoice_Schedule__c = 'Single post-event invoice';
        opp2.Event_Start__c  = Date.today().addDays(-100);
        opp2.Event_End__c    = Date.today().addDays(-100);
        insert opp2;

        // Insert opp which should not be returned by method due to stage name
        Opportunity opp3 = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp3.AccountId   = acc.Id;
        opp3.Amount      = 5000;
        opp3.StageName   = 'Closed Lost';
        opp3.Event_Start__c  = Date.today();
        opp3.Event_End__c    = Date.today();
        insert opp3;

        // Insert opp which should not be returned by method due to project tracker status
        Opportunity opp4 = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp4.AccountId   = acc.Id;
        opp4.Amount      = 5000;
        opp4.StageName   = 'Closed Won';
        opp4.Invoice_Schedule__c = 'Single post-event invoice';
        opp4.Exclude_from_project_tracker2__c = 'Yes';
        opp4.Event_Start__c  = Date.today();
        opp4.Event_End__c    = Date.today();
        insert opp4;

        // invoke controller opp method
        String startString  = String.valueOf(Date.today().addDays(-10));
        String endString    = String.valueOf(Date.today().addDays(10));
        List<Opportunity> returnedOpps = ProjectTrackerRemoter.getOpps(startString,endString);

        // assert that the method only returns one opportunity
        System.AssertEquals(1, returnedOpps.size());

    }


    @IsTest
    public static void getSingleOppDetails(){

        Account acc = (Account)SmartFactory.createSOBject('Account');
        insert acc;

        // Insert opp which should be returned by method
        Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp.AccountId   = acc.Id;
        opp.Amount      = 5000;
        opp.StageName   = 'Closed Won';
        opp.Invoice_Schedule__c = 'Single post-event invoice';
        opp.Event_Start__c  = Date.today();
        opp.Event_End__c    = Date.today();
        insert opp;

        // insert contact and contact role
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
        insert con;
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = opp.Id, ContactId = con.Id);
        insert ocr;

        // insert employee and employee reservation
        Employee1__c emp = new Employee1__c(FirstName__c = 'Test', LastName__c = 'Employee', Active__c = True, Onsite__c = True);
        insert emp;
        CrewBooking__c cb = new CrewBooking__c(Opportunity__c = opp.Id, Employee__c = emp.Id);
        insert cb;

        // insert equipment item and reservation
        Equipment__c eq = new Equipment__c(Name__c = 'Test', Model__c = 'Test Model',
                                            Onsite_Override__c = true, Active__c = true, Type__c = 'Printer');
        insert eq;
        Reservation__c res = new Reservation__c(Opportunity__c = opp.Id, Equipment__c = eq.Id);
        insert res;

        // invoke getOppDetail()
        Opportunity returnedOpp1 = ProjectTrackerRemoter.getOppDetail(opp.Id);

        // assert returned values
        System.assertNotEquals(null, returnedOpp1);
        System.assertEquals(1, returnedOpp1.CrewBookings__r.size());
        System.assertEquals(1, returnedOpp1.Reservations__r.size());
        System.assertEquals(1, returnedOpp1.OpportunityContactRoles.size());

        // invoke getOppMiniDetail()
        Opportunity returnedOpp2 = ProjectTrackerRemoter.getOppMiniDetail(opp.Id);

        // assert returned values
        System.assertNotEquals(null, returnedOpp2);
        System.assertEquals(1, returnedOpp2.CrewBookings__r.size());
        System.assertEquals(1, returnedOpp2.Reservations__r.size());

        // insert quote and relevant quote lines
        Product2 prod = new Product2(Name = 'Test', Family = 'On-site & delivery');
        insert prod;

        SBQQ__Quote__c quote = (SBQQ__Quote__c)SmartFactory.createSOBject('SBQQ__Quote__c');
        quote.SBQQ__Opportunity2__c     = opp.Id;
        quote.SBQQ__PrimaryContact__c   = con.Id;
        quote.SBQQ__Primary__c          = true;
        insert quote;

        SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(
                SBQQ__Quote__c          = quote.Id,
                SBQQ__Description__c    = 'Test',
                SBQQ__Product__c        = prod.Id,
                SBQQ__Quantity__c       = 1
        );
        insert line;

        // invoke getOppQuoteLines()
        List<SBQQ__QuoteLine__c> lines = ProjectTrackerRemoter.getOppQuoteLines(opp.Id);

        // assert return values
        System.assertEquals(1, lines.size());

        // invoke getOppMiniQuoteLines()
        List<SBQQ__QuoteLine__c> miniLines = ProjectTrackerRemoter.getOppMiniQuoteLines(opp.Id);

        // assert return values
        System.assertEquals(1, miniLines.size());

    }


    @IsTest
    public static void testGetRoadshows(){

        Account acc = (Account)SmartFactory.createSOBject('Account');
        insert acc;

        // Insert opp which should be returned by method
        Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp.AccountId   = acc.Id;
        opp.Amount      = 5000;
        opp.StageName   = 'Closed Won';
        opp.Invoice_Schedule__c = 'Single post-event invoice';
        opp.Event_Start__c  = Date.today();
        opp.Event_End__c    = Date.today();
        insert opp;

        Roadshow_Event__c rs1 = new Roadshow_Event__c(
                Parent_Opportunity__c = opp.Id,
                Event_Start__c = Date.today(),
                Event_End__c   = Date.today()
        );
        insert rs1;

        // Insert opp which should not be returned by method due to dates
        Opportunity opp2 = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp2.AccountId   = acc.Id;
        opp2.Amount      = 5000;
        opp2.StageName   = 'Closed Won';
        opp2.Invoice_Schedule__c = 'Single post-event invoice';
        opp2.Event_Start__c  = Date.today().addDays(-100);
        opp2.Event_End__c    = Date.today().addDays(-100);
        insert opp2;

        Roadshow_Event__c rs2 = new Roadshow_Event__c(
                Parent_Opportunity__c = opp2.Id,
                Event_Start__c = Date.today().addDays(-100),
                Event_End__c   = Date.today().addDays(-100)
        );
        insert rs2;

        // Insert opp which should not be returned by method due to stage name
        Opportunity opp3 = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp3.AccountId   = acc.Id;
        opp3.Amount      = 5000;
        opp3.StageName   = 'Closed Lost';
        opp3.Event_Start__c  = Date.today();
        opp3.Event_End__c    = Date.today();
        insert opp3;

        Roadshow_Event__c rs3 = new Roadshow_Event__c(
                Parent_Opportunity__c = opp3.Id,
                Event_Start__c = Date.today(),
                Event_End__c   = Date.today()
        );
        insert rs3;

        // Insert opp which should not be returned by method due to project tracker status
        Opportunity opp4 = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp4.AccountId   = acc.Id;
        opp4.Amount      = 5000;
        opp4.StageName   = 'Closed Won';
        opp4.Invoice_Schedule__c = 'Single post-event invoice';
        opp4.Exclude_from_project_tracker2__c = 'Yes';
        opp4.Event_Start__c  = Date.today();
        opp4.Event_End__c    = Date.today();
        insert opp4;

        Roadshow_Event__c rs4 = new Roadshow_Event__c(
                Parent_Opportunity__c = opp4.Id,
                Event_Start__c = Date.today(),
                Event_End__c   = Date.today()
        );
        insert rs4;

        String startString  = String.valueOf(Date.today().addDays(-10));
        String endString    = String.valueOf(Date.today().addDays(10));

        // invoke controller roadshows method
        List<Roadshow_Event__c> returnedShows = ProjectTrackerRemoter.getRoadShows(startString,endString);

        // assert that the method only returns one roadshows
        System.AssertEquals(2, returnedShows.size());
    }


    @IsTest
    public static void testSingleRoadshowDetails(){

        Account acc = (Account)SmartFactory.createSOBject('Account');
        insert acc;

        // Insert opp which should be returned by method
        Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp.AccountId   = acc.Id;
        opp.Amount      = 5000;
        opp.StageName   = 'Closed Won';
        opp.Invoice_Schedule__c = 'Single post-event invoice';
        opp.Event_Start__c  = Date.today();
        opp.Event_End__c    = Date.today();
        insert opp;

        Roadshow_Event__c rs1 = new Roadshow_Event__c(
                Parent_Opportunity__c = opp.Id,
                Event_Start__c = Date.today(),
                Event_End__c   = Date.today()
        );
        insert rs1;

        // insert contact and contact role
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
        insert con;
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = opp.Id, ContactId = con.Id);
        insert ocr;

        // insert employee and employee reservation
        Employee1__c emp = new Employee1__c(FirstName__c = 'Test', LastName__c = 'Employee', Active__c = True, Onsite__c = True);
        insert emp;
        CrewBooking__c cb = new CrewBooking__c(Roadshow_Event__c = rs1.Id, Employee__c = emp.Id);
        insert cb;

        // insert equipment item and reservation
        Equipment__c eq = new Equipment__c(Name__c = 'Test', Model__c = 'Test Model',
                Onsite_Override__c = true, Active__c = true, Type__c = 'Printer');
        insert eq;
        Reservation__c res = new Reservation__c(Roadshow_Event__c = rs1.Id, Equipment__c = eq.Id);
        insert res;

        // invoke getRoadshowDetail()
        Roadshow_Event__c returnedShow = ProjectTrackerRemoter.getRoadshowDetail(rs1.Id);

        // assert returned values
        System.assertNotEquals(null, returnedShow);
        System.assertEquals(1, returnedShow.CrewBookings__r.size());
        System.assertEquals(1, returnedShow.Reservations__r.size());

        // invoke getRoadshowMiniDetail()
        Roadshow_Event__c returnedShow2 = ProjectTrackerRemoter.getRoadshowDetail(rs1.Id);

        // assert returned values
        System.assertNotEquals(null, returnedShow2);
        System.assertEquals(1, returnedShow2.CrewBookings__r.size());
        System.assertEquals(1, returnedShow2.Reservations__r.size());

        // invoke getParentOppContactRoles()
        Opportunity returnedOpp = ProjectTrackerRemoter.getParentOppContactRoles(opp.Id);

        // assert returned values
        System.assertNotEquals(null, returnedOpp);
        System.assertEquals(1, returnedOpp.OpportunityContactRoles.size());

    }

    @IsTest
    public static void testGetEntriesForRoadshow() {

        Account acc = (Account)SmartFactory.createSOBject('Account');
        insert acc;

        // Insert opp
        Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp.AccountId   = acc.Id;
        opp.Amount      = 5000;
        opp.StageName   = 'Closed Won';
        opp.Invoice_Schedule__c = 'Single post-event invoice';
        opp.Event_Start__c  = Date.today();
        opp.Event_End__c    = Date.today();
        insert opp;

        Roadshow_Event__c rs1 = new Roadshow_Event__c(
                Parent_Opportunity__c = opp.Id,
                Event_Start__c = Date.today(),
                Event_End__c   = Date.today()
        );
        insert rs1;

        // insert three employees, only one of which should be returned by the method
        Employee1__c emp = new Employee1__c(FirstName__c = 'Test', LastName__c = 'Employee', Active__c = True, Onsite__c = True);
        insert emp;
        Employee1__c emp2 = new Employee1__c(FirstName__c = 'Test', LastName__c = 'Employee', Active__c = False, Onsite__c = True);
        insert emp2;
        Employee1__c emp3 = new Employee1__c(FirstName__c = 'Test', LastName__c = 'Employee', Active__c = True, Onsite__c = False);
        insert emp3;

        // assert only 1 employee returned
        List<Employee1__c> emps = ProjectTrackerRemoter.getEmployees(rs1.Id,'Roadshow');
        System.assertEquals(1, emps.size());


        // insert three equipment items, only one of which should be returned by the method
        Equipment__c eq = new Equipment__c(Name__c = 'Test', Model__c = 'Test Model',
                Onsite_Override__c = true, Active__c = false, Type__c = 'Printer');
        insert eq;
        Equipment__c eq2 = new Equipment__c(Name__c = 'Test', Model__c = 'Test Model',
                Onsite_Override__c = false, Active__c = true, Type__c = 'Headset');
        insert eq2;
        Equipment__c eq3 = new Equipment__c(Name__c = 'Test', Model__c = 'Test Model',
                Onsite_Override__c = true, Active__c = true, Type__c = 'Printer');
        insert eq3;

        // assert only 1 equipment item returned
        List<Equipment__c> eqs = ProjectTrackerRemoter.getEquipment(rs1.Id,'Roadshow');
        System.assertEquals(1, eqs.size());
    }

    @IsTest
    public static void testGetEntriesForOpp() {

        Account acc = (Account)SmartFactory.createSOBject('Account');
        insert acc;

        // Insert opp
        Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp.AccountId   = acc.Id;
        opp.Amount      = 5000;
        opp.StageName   = 'Closed Won';
        opp.Invoice_Schedule__c = 'Single post-event invoice';
        opp.Event_Start__c  = Date.today();
        opp.Event_End__c    = Date.today();
        insert opp;

        // insert three employees, only one of which should be returned by the method
        Employee1__c emp = new Employee1__c(FirstName__c = 'Test', LastName__c = 'Employee', Active__c = True, Onsite__c = True);
        insert emp;
        Employee1__c emp2 = new Employee1__c(FirstName__c = 'Test', LastName__c = 'Employee', Active__c = False, Onsite__c = True);
        insert emp2;
        Employee1__c emp3 = new Employee1__c(FirstName__c = 'Test', LastName__c = 'Employee', Active__c = True, Onsite__c = False);
        insert emp3;

        // assert only 1 employee returned
        List<Employee1__c> emps = ProjectTrackerRemoter.getEmployees(opp.Id,'Opportunity');
        System.assertEquals(1, emps.size());

        // insert three equipment items, only one of which should be returned by the method
        Equipment__c eq = new Equipment__c(Name__c = 'Test', Model__c = 'Test Model',
                Onsite_Override__c = true, Active__c = false, Type__c = 'Printer');
        insert eq;
        Equipment__c eq2 = new Equipment__c(Name__c = 'Test', Model__c = 'Test Model',
                Onsite_Override__c = false, Active__c = true, Type__c = 'Headset');
        insert eq2;
        Equipment__c eq3 = new Equipment__c(Name__c = 'Test', Model__c = 'Test Model',
                Onsite_Override__c = true, Active__c = true, Type__c = 'Printer');
        insert eq3;

        // assert only 1 equipment item returned
        List<Equipment__c> eqs = ProjectTrackerRemoter.getEquipment(opp.Id,'Opportunity');
        System.assertEquals(1, eqs.size());

    }

    @IsTest
    public static void testGetHolidays(){

        // insert three employees with holidays, only one of which should be returned by the method
        Employee1__c emp = new Employee1__c(FirstName__c = 'Test', LastName__c = 'Employee', Active__c = True, Onsite__c = True);
        insert emp;
        Holiday__c hol = new Holiday__c(Start__c = Date.today(), End__c = Date.today(), Employee__c = emp.Id);
        insert hol;

        Employee1__c emp2 = new Employee1__c(FirstName__c = 'Test', LastName__c = 'Employee', Active__c = false, Onsite__c = True);
        insert emp2;
        Holiday__c hol2 = new Holiday__c(Start__c = Date.today(), End__c = Date.today(), Employee__c = emp2.Id);
        insert hol2;

        Employee1__c emp3 = new Employee1__c(FirstName__c = 'Test', LastName__c = 'Employee', Active__c = True, Onsite__c = false);
        insert emp3;
        Holiday__c hol3 = new Holiday__c(Start__c = Date.today(), End__c = Date.today(), Employee__c = emp3.Id);
        insert hol3;

        // invoke controller method and assert only one value found
        String startString  = String.valueOf(Date.today().addDays(-10));
        String endString    = String.valueOf(Date.today().addDays(10));
        List<Holiday__c> hols = ProjectTrackerRemoter.getHolidays(startString, endString);
        System.assertEquals(3, hols.size());

    }

    @IsTest
    public static void testAllocateEntities(){

        Account acc = (Account)SmartFactory.createSOBject('Account');
        insert acc;

        // Insert opp
        Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp.AccountId   = acc.Id;
        opp.Amount      = 5000;
        opp.StageName   = 'Closed Won';
        opp.Invoice_Schedule__c = 'Single post-event invoice';
        opp.Event_Start__c  = Date.today();
        opp.Event_End__c    = Date.today();
        insert opp;

        // test allocate employee
        Employee1__c emp = new Employee1__c(FirstName__c = 'Test', LastName__c = 'Employee', Active__c = True, Onsite__c = True);
        insert emp;

        String resultOne = ProjectTrackerRemoter.allocateCrew(emp.Id, opp.Id, 'Opportunity');
        System.assertNotEquals(null, resultOne);
        System.assertEquals(1, [SELECT Id FROM CrewBooking__c].size());

        // test allocate equipment
        Equipment__c eq = new Equipment__c(Name__c = 'Test', Model__c = 'Test Model',
                Onsite_Override__c = true, Active__c = false, Type__c = 'Printer');
        insert eq;

        String resultTwo = ProjectTrackerRemoter.allocateKit(eq.Id, opp.Id, 'Opportunity');
        System.assertNotEquals(null, resultTwo);
        System.assertEquals(1, [SELECT Id FROM Reservation__c].size());
    }

    @IsTest
    public static void testTogglesDeleteCreate(){

        Account acc = (Account)SmartFactory.createSOBject('Account');
        insert acc;

        // Insert opp
        Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp.AccountId   = acc.Id;
        opp.Amount      = 5000;
        opp.StageName   = 'Closed Won';
        opp.Invoice_Schedule__c = 'Single post-event invoice';
        opp.Event_Start__c  = Date.today();
        opp.Event_End__c    = Date.today();
        opp.NoCrew__c       = false;
        opp.Exclude_from_project_tracker2__c = 'No';
        insert opp;

        // invoke controller and verify result
        Boolean resultOne = ProjectTrackerRemoter.toggleNoCrew(opp.Id, 'Opportunity');
        System.assertEquals(true, resultOne);
        System.assertEquals(1, [SELECT Id FROM Opportunity WHERE NoCrew__c = true].size());

        Boolean resultTwo = ProjectTrackerRemoter.removeProject(opp.Id, 'Opportunity');
        System.assertEquals(true, resultTwo);
        System.assertEquals(1, [SELECT Id FROM Opportunity WHERE Exclude_from_project_tracker2__c = 'Yes'].size());

        // insert roadshow
        Roadshow_Event__c rs1 = new Roadshow_Event__c(
                Parent_Opportunity__c = opp.Id,
                Event_Start__c = Date.today(),
                Event_End__c   = Date.today()
        );
        insert rs1;

        // invoke controller and verify result
        Boolean resultThree = ProjectTrackerRemoter.toggleNoCrew(rs1.Id, 'Roadshow');
        System.assertEquals(true, resultThree);
        System.assertEquals(1, [SELECT Id FROM Roadshow_Event__c WHERE NoCrew__c = true].size());

        Boolean resultFour = ProjectTrackerRemoter.removeProject(rs1.Id, 'Roadshow');
        System.assertEquals(true, resultFour);
        System.assertEquals(1, [SELECT Id FROM Roadshow_Event__c WHERE Exclude_from_project_tracker__c = 'Yes'].size());

        // verify remove crew booking
        Employee1__c emp = new Employee1__c(FirstName__c = 'Test', LastName__c = 'Employee', Active__c = True, Onsite__c = True);
        insert emp;
        CrewBooking__c cb = new CrewBooking__c(Roadshow_Event__c = rs1.Id, Employee__c = emp.Id);
        insert cb;

        String resultFive = ProjectTrackerRemoter.removeCrewBooking(cb.Id);
        System.assertNotEquals('error', resultFive);
        System.assertEquals(0, [SELECT Id FROM CrewBooking__c].size());

        // verify remove kit reservation
        Equipment__c eq = new Equipment__c(Name__c = 'Test', Model__c = 'Test Model',
                Onsite_Override__c = true, Active__c = true, Type__c = 'Printer');
        insert eq;
        Reservation__c res = new Reservation__c(Roadshow_Event__c = rs1.Id, Equipment__c = eq.Id);
        insert res;

        String resultSix = ProjectTrackerRemoter.removeReservation(res.Id);
        System.assertNotEquals('error', resultSix);
        System.assertEquals(0, [SELECT Id FROM Reservation__c].size());

        // verify employee create
        delete [SELECT Id FROM Employee1__c];
        Employee1__c newEmp = ProjectTrackerRemoter.createNewCrew('Test', 'Employee');
        System.assertNotEquals(null, newEmp);
        System.assertEquals(1,[SELECT Id FROM Employee1__c].size());

    }


    @IsTest
    public static void testGetEmployeesByStatus(){

        // insert five employees
        Employee1__c emp = new Employee1__c(FirstName__c = 'Test', LastName__c = 'Employee', Active__c = true, Onsite__c = true);
        insert emp;
        Employee1__c emp2 = new Employee1__c(FirstName__c = 'Test', LastName__c = 'Employee', Active__c = false, Onsite__c = true);
        insert emp2;
        Employee1__c emp3 = new Employee1__c(FirstName__c = 'Test', LastName__c = 'Employee', Active__c = true, Onsite__c = false);
        insert emp3;
        Employee1__c emp4 = new Employee1__c(FirstName__c = 'Test', LastName__c = 'Employee', Active__c = true, Onsite__c = true);
        insert emp4;
        Employee1__c emp5 = new Employee1__c(FirstName__c = 'Test', LastName__c = 'Employee', Active__c = true, Onsite__c = true);
        insert emp5;

        // insert holiday
        Holiday__c hol = new Holiday__c(Start__c = Date.today(), End__c = Date.today(), Employee__c = emp4.Id);
        insert hol;

        // insert booking
        Account acc = (Account)SmartFactory.createSOBject('Account');
        insert acc;

        // Insert opp
        Opportunity opp = (Opportunity)SmartFactory.createSOBject('Opportunity');
        opp.AccountId   = acc.Id;
        opp.Amount      = 5000;
        opp.StageName   = 'Closed Won';
        opp.Invoice_Schedule__c = 'Single post-event invoice';
        opp.Event_Start__c  = Date.today();
        opp.Event_End__c    = Date.today();
        opp.NoCrew__c       = false;
        opp.Exclude_from_project_tracker2__c = 'No';
        insert opp;

        CrewBooking__c cb = new CrewBooking__c(Opportunity__c = opp.Id, Employee__c = emp5.Id);
        insert cb;

        // assert return values from controller methods
        System.assertEquals(1, ProjectTrackerRemoter.getInactiveEmployees().size());
        System.assertEquals(1, ProjectTrackerRemoter.getNoOnsiteEmployees().size());
        System.assertEquals(1, ProjectTrackerRemoter.getAllBookedCrew(opp.Id, 'Opportunity').size());
        System.assertEquals(1, ProjectTrackerRemoter.getAllHolidaysCrew(opp.Id, 'Opportunity').size());
    }

}