/**
 * Created by Ronan Williams on 05/09/2018.
 */

global class ProjectTrackerRemoter {

    @RemoteAction
    global static List<Opportunity> getOpps(String startString, String endString) {

        Date startDate  = Date.valueOf(startString);
        Date endDate    = Date.valueOf(endString);

        return [
                SELECT Name, Id, Project_Start__c, Project_End__c, StageName,
                        Filtered_Account_Name__c, Account.Abbreviation__c, Primary_Service__c,
                        NoCrew__c, Probability, Quote_Status__c
                FROM Opportunity
                WHERE StageName != 'Closed Lost'
                AND Exclude_from_project_tracker2__c != 'Yes'
                AND Project_Start__c > :startDate
                AND Project_End__c < :endDate
        ];

    }


    // A FINAL COMMENT mnnb,mbm,jbgi

    @RemoteAction
    global static Opportunity getOppDetail(String Id) {

        return [
                SELECT Name, Id, Project_Start__c, Project_End__c, StageName,
                        Filtered_Account_Name__c, Account.Abbreviation__c, Primary_Service__c,
                        Location__c, Venue__c, Filtered_Job_Number__c, NoCrew__c, Project_Manager__r.FirstName,
                        Project_Manager__r.LastName, Owner.FirstName, Owner.LastName, Amount_Calder__c,
                        Gross_profit_2__c, SBQQ__PrimaryQuote__c, Probability, Owner.ImageLink__c,
                        Project_Manager__r.ImageLink__c, Owner.Title, Project_Manager__r.Title,
                        Gross_Margin__c, Filtered_Cost_of_Sale__c,Quickbooks_COS__c, Quickbooks_COS_Paid__c,
                        Amount_Invoiced2__c, Amount_Paid__c, Amount_Remaining__c,
                        (SELECT Id, Employee__r.FirstName__c, Employee__r.LastName__c,
                                Employee__r.Position__c, Employee__r.ImageLink__c
                        FROM CrewBookings__r),
                        (SELECT Id, Name__c, Model__c, Type__c, Icon__c, Reference__c
                        FROM Reservations__r),
                        (SELECT Id, Contact.FirstName, Contact.LastName, Contact.Title
                        FROM OpportunityContactRoles)
                FROM Opportunity
                WHERE Id = :Id
        ];

    }

    @RemoteAction
    global static Opportunity getOppMiniDetail(String Id) {

        return [
                SELECT Id, Primary_Service__c, Location__c, Venue__c, Filtered_Job_Number__c,
                        Project_Manager__r.FirstName, Project_Manager__r.LastName,
                        Owner.FirstName, Owner.LastName, Amount_Calder__c, Gross_profit_2__c,
                        Project_Start__c, Project_End__c, StageName, Probability, NoCrew__c,
                        (SELECT Employee__r.Initials__c, Employee__r.ImageLink__c
                        FROM CrewBookings__r),
                        (SELECT Icon__c
                        FROM Reservations__r)
                FROM Opportunity
                WHERE Id = :Id
        ];

    }

    @RemoteAction
    global static List<SBQQ__QuoteLine__c> getOppMiniQuoteLines(String Id){


        List<SBQQ__QuoteLine__c> lines = [SELECT Id
                            FROM SBQQ__QuoteLine__c
                            WHERE SBQQ__Quote__r.SBQQ__Opportunity2__c = :Id
                            AND SBQQ__Quote__r.SBQQ__Primary__c  = TRUE
                            AND SBQQ__ProductFamily__c = 'On-site & delivery'
                            AND SBQQ__Product__r.Name != 'Miscellaneous'];

        return lines;

    }

    @RemoteAction
    global static List<SBQQ__QuoteLine__c> getOppQuoteLines(String Id){


        List<SBQQ__QuoteLine__c> lines = [SELECT Id, SBQQ__Description__c, SBQQ__Product__r.Name,
                                                SBQQ__Quantity__c
                                          FROM SBQQ__QuoteLine__c
                                          WHERE SBQQ__Quote__r.SBQQ__Opportunity2__c = :Id
                                          AND SBQQ__Quote__r.SBQQ__Primary__c  = TRUE
                                          AND SBQQ__ProductFamily__c = 'On-site & delivery'
                                          AND SBQQ__Product__r.Name != 'Miscellaneous'];

        return lines;

    }

    @RemoteAction
    global static List<Roadshow_Event__c> getRoadShows(String startString, String endString) {

        Date startDate  = Date.valueOf(startString);
        Date endDate    = Date.valueOf(endString);

        return [
                SELECT Name, Id, Project_Start__c, Project_End__c, Stage__c, NoCrew__c,
                        Account__c, Parent_Opportunity__r.Account.Abbreviation__c, Primary_Service__c,
                        Parent_Opportunity__r.Probability, Parent_Opportunity__r.Quote_Status__c
                FROM Roadshow_Event__c
                WHERE Stage__c != 'Closed Lost'
                AND Exclude_from_project_tracker__c != 'Yes'
                AND Project_Start__c > :startDate
                AND Project_End__c < :endDate
        ];

    }

    @RemoteAction
    global static Roadshow_Event__c getRoadshowDetail(String Id) {

        return [
                SELECT Name, Id, Project_Start__c, Project_End__c, Stage__c, Parent_Opportunity__c,
                        Account__c, Parent_Opportunity__r.Account.Name,
                        Primary_Service__c, Location__c, Venue__c, Job_Number__c, NoCrew__c,
                        Project_Manager__c, Parent_Opportunity__r.Owner.FirstName,
                        Parent_Opportunity__r.Owner.LastName,
                        Parent_Opportunity__r.Owner.ImageLink__c,
                        Parent_Opportunity__r.Project_Manager__r.ImageLink__c,
                        Parent_Opportunity__r.Project_Manager__r.FirstName,
                        Parent_Opportunity__r.Project_Manager__r.LastName,
                        Parent_Opportunity__r.Owner.Title, Parent_Opportunity__r.Project_Manager__r.Title,
                        Parent_Opportunity__r.Filtered_Cost_of_Sale__c, Parent_Opportunity__r.Amount_Calder__c,
                        Parent_Opportunity__r.Gross_profit_2__c, Parent_Opportunity__r.Amount_Remaining__c,
                        Parent_Opportunity__r.Amount_Invoiced2__c, Parent_Opportunity__r.Amount_Paid__c,
                        Parent_Opportunity__r.Quickbooks_COS__c, Parent_Opportunity__r.Quickbooks_COS_Paid__c,
                        Parent_Opportunity__r.Gross_Margin__c,
                        (SELECT Id, Employee__r.FirstName__c, Employee__r.LastName__c,
                                Employee__r.Position__c, Employee__r.ImageLink__c
                        FROM CrewBookings__r),
                        (SELECT Id, Name__c, Model__c, Type__c, Icon__c
                        FROM Reservations__r)
                FROM Roadshow_Event__c
                WHERE Id = :Id
        ];

    }

    @RemoteAction
    global static Opportunity getParentOppContactRoles(String Id) {

        return [
                SELECT (SELECT Id, Contact.FirstName, Contact.LastName, Contact.Title
                        FROM OpportunityContactRoles)
                FROM Opportunity
                WHERE Id = :Id
        ];

    }

    @RemoteAction
    global static Roadshow_Event__c getRoadshowMiniDetail(String Id) {

        return [
                SELECT Id, Primary_Service__c, Location__c, Venue__c, Job_Number__c,
                        Project_Start__c, Project_End__c, Stage__c, Parent_Opportunity__r.Probability,
                        Parent_Opportunity__r.Project_Manager__r.FirstName, NoCrew__c,
                        Parent_Opportunity__r.Project_Manager__r.LastName,
                        Parent_Opportunity__r.Owner.FirstName, Parent_Opportunity__r.Owner.LastName,
                        Parent_Opportunity__r.Amount_Calder__c, Parent_Opportunity__r.Gross_profit_2__c,
                        (SELECT Employee__r.Initials__c, Employee__r.ImageLink__c
                        FROM CrewBookings__r),
                        (SELECT Icon__c
                        FROM Reservations__r)
                FROM Roadshow_Event__c
                WHERE Id = :Id
        ];

    }

    @RemoteAction
    global static List<Employee1__c> getEmployees(String Id, String type){

        Date startDate;
        Date endDate;

        if (type == 'Opportunity'){
            Opportunity opp = [SELECT Project_Start__c, Project_End__c
                                FROM Opportunity WHERE Id = :Id];
            startDate       = opp.Project_Start__c;
            endDate         = opp.Project_End__c;
        } else if (type == 'Roadshow'){
            Roadshow_Event__c rds = [SELECT Project_Start__c, Project_End__c
                                     FROM Roadshow_Event__c WHERE Id = :Id];
            startDate       = rds.Project_Start__c;
            endDate         = rds.Project_End__c;
        }

        Set<Id> unavailableEmployees = new Set<Id>();

        for (CrewBooking__c c : [SELECT Employee__r.Id FROM CrewBooking__c
                                 WHERE (Opportunity__c = :Id OR Roadshow_Event__c = :Id)
                                    OR (Start__c <= :endDate AND End__c >= :startDate)]){
            unavailableEmployees.add(c.Employee__r.Id);
        }

        for (Holiday__c h : [SELECT Employee__r.Id FROM Holiday__c
                            WHERE Start__c <= :endDate AND End__c >= :startDate]){
            unavailableEmployees.add(h.Employee__r.Id);
        }

        return [
                SELECT Id, FirstName__c, LastName__c, Position__c, ImageLink__c
                FROM Employee1__c
                WHERE Active__c = TRUE
                AND Onsite__c = TRUE
                AND Id NOT IN :unavailableEmployees
        ];

    }

    @RemoteAction
    global static List<Equipment__c> getEquipment(String Id, String type){

        Date startDate;
        Date endDate;

        if (type == 'Opportunity'){
            Opportunity opp = [SELECT Project_Start__c, Project_End__c
                                FROM Opportunity WHERE Id = :Id];
            startDate       = opp.Project_Start__c;
            endDate         = opp.Project_End__c;
        } else if (type == 'Roadshow'){
            Roadshow_Event__c rds = [SELECT Project_Start__c, Project_End__c
                                    FROM Roadshow_Event__c WHERE Id = :Id];
            startDate       = rds.Project_Start__c;
            endDate         = rds.Project_End__c;
        }

        Set<Id> unavailableEquipment = new Set<Id>();

        for (Reservation__c res : [SELECT Equipment__c FROM Reservation__c
                                WHERE (Opportunity__c = :Id OR Roadshow_Event__c = :Id)
                                OR (Start__c <= :endDate AND End__c >= :startDate)]){
            unavailableEquipment.add(res.Equipment__c);
        }

        return [
                SELECT Id, Name__c, Type__c, Icon__c, Name, Model__c
                FROM Equipment__c
                WHERE Active__c = TRUE
                AND Onsite__c = TRUE
                AND Id NOT IN :unavailableEquipment
                ORDER BY Type__c
        ];

    }

    @RemoteAction
    global static List<Holiday__c> getHolidays(String startString, String endString) {

        Date startDate  = Date.valueOf(startString);
        Date endDate    = Date.valueOf(endString);

        return [
                SELECT Id, Name__c, Start__c, End__c
                FROM Holiday__c
                WHERE Start__c > :startDate
                AND End__c < :endDate
        ];

    }

    @RemoteAction
    global static String allocateCrew(String crewId, String jobId, String type){

        String resultId = null;

        CrewBooking__c booking = new CrewBooking__c();

        if (type == 'Opportunity'){
            booking.Opportunity__c  = jobId;
            booking.Employee__c     = crewId;
            insert booking;
            resultId = booking.Id;
        } else if (type == 'Roadshow'){
            booking.Roadshow_Event__c = jobId;
            booking.Employee__c = crewId;
            insert booking;
            resultId = booking.Id;
        }

        return resultId;
    }

    @RemoteAction
    global static String allocateKit(String equipmentId, String jobId, String type){

        String resultId = null;

        Reservation__c res = new Reservation__c();

        if (type == 'Opportunity'){
            res.Opportunity__c  = jobId;
            res.Equipment__c    = equipmentId;
            insert res;
            resultId = res.Id;
        } else if (type == 'Roadshow'){
            res.Roadshow_Event__c   = jobId;
            res.Equipment__c        = equipmentId;
            insert res;
            resultId = res.Id;
        }

        return resultId;
    }

    @RemoteAction
    global static Boolean toggleNoCrew(String jobId, String type){

        Boolean success = false;

        if (type == 'Opportunity'){
            Opportunity opp = [SELECT Id, NoCrew__c FROM Opportunity WHERE Id = :jobId];

            if (opp.NoCrew__c) {
                opp.NoCrew__c = false;
            } else {
                opp.NoCrew__c = true;
                delete [SELECT Id FROM CrewBooking__c WHERE Opportunity__c = :jobId];
            }

            Database.saveResult result = Database.update(opp);
            if (result.isSuccess()){
                success = true;
            }
        } else if (type == 'Roadshow'){
            Roadshow_Event__c rs = [SELECT Id, NoCrew__c FROM Roadshow_Event__c WHERE Id = :jobId];

            if (rs.NoCrew__c) {
                rs.NoCrew__c = false;
            } else {
                rs.NoCrew__c = true;
                delete [SELECT Id FROM CrewBooking__c WHERE Roadshow_Event__c = :jobId];
            }
            Database.saveResult result = Database.update(rs);
            if (result.isSuccess()){
                success = true;
            }
        }

        return success;
    }

    @RemoteAction
    global static Boolean removeProject(String Id, String type){

        Boolean success = false;

        if (type == 'Opportunity'){
            Opportunity opp = new Opportunity(
                    Id = Id,
                    Exclude_from_project_tracker2__c = 'Yes'
            );

            Database.saveResult result = Database.update(opp);
            if (result.isSuccess()){
                delete [SELECT Id FROM CrewBooking__c WHERE Opportunity__c = :Id];
                success = true;
            }
        } else if (type == 'Roadshow'){
            Roadshow_Event__c rde = new Roadshow_Event__c(
                    Id = Id,
                    Exclude_from_project_tracker__c = 'Yes'
            );

            Database.saveResult result = Database.update(rde);
            if (result.isSuccess()){
                delete [SELECT Id FROM CrewBooking__c WHERE Roadshow_Event__c = :Id];
                success = true;
            }
        }

        return success;

    }

    @RemoteAction
    global static String removeCrewBooking(String bookingId){

        String success = 'error';

        CrewBooking__c cb = new CrewBooking__c(Id = bookingId);

        Database.DeleteResult result = Database.delete(cb);
        if (result.isSuccess()){
            success = bookingId;
        }

        return success;
    }

    @RemoteAction
    global static String removeReservation(String reservationId){

        String success = 'error';

        Reservation__c res = new Reservation__c(Id = reservationId);

        Database.DeleteResult result = Database.delete(res);
        if (result.isSuccess()){
            success = reservationId;
        }

        return success;
    }


    @RemoteAction
    global static List<Employee1__c> getInactiveEmployees(){

        return [SELECT Id, FirstName__c, LastName__c, Position__c, ImageLink__c
                FROM Employee1__c
                WHERE Active__c = FALSE];
    }

    @RemoteAction
    global static List<Employee1__c> getNoOnsiteEmployees(){

        return [SELECT Id, FirstName__c, LastName__c, Position__c, ImageLink__c
                FROM Employee1__c
                WHERE Active__c = TRUE
                AND Onsite__c = FALSE];
    }

    @RemoteAction
    global static List<CrewBooking__c> getAllBookedCrew(String id, String type) {

        Date startDate;
        Date endDate;

        if (type == 'Opportunity'){
            Opportunity opp = [SELECT Project_Start__c, Project_End__c
            FROM Opportunity WHERE Id = :id];
            startDate       = opp.Project_Start__c;
            endDate         = opp.Project_End__c;
        } else if (type == 'Roadshow'){
            Roadshow_Event__c rds = [SELECT Project_Start__c, Project_End__c
            FROM Roadshow_Event__c WHERE Id = :id];
            startDate       = rds.Project_Start__c;
            endDate         = rds.Project_End__c;
        }

        return [SELECT Employee__c, Employee__r.FirstName__c, Employee__r.LastName__c,
                        Employee__r.ImageLink__c, Employee__r.Position__c, Opportunity__r.Name
                FROM CrewBooking__c
                WHERE Start__c <= :endDate AND End__c >= :startDate];

    }

    @RemoteAction
    global static List<Holiday__c> getAllHolidaysCrew(String id, String type) {

        Date startDate;
        Date endDate;

        if (type == 'Opportunity'){
            Opportunity opp = [SELECT Project_Start__c, Project_End__c
            FROM Opportunity WHERE Id = :id];
            startDate       = opp.Project_Start__c;
            endDate         = opp.Project_End__c;
        } else if (type == 'Roadshow'){
            Roadshow_Event__c rds = [SELECT Project_Start__c, Project_End__c
            FROM Roadshow_Event__c WHERE Id = :id];
            startDate       = rds.Project_Start__c;
            endDate         = rds.Project_End__c;
        }

        return [SELECT Employee__c, Employee__r.FirstName__c, Employee__r.LastName__c,
                        Employee__r.ImageLink__c, Employee__r.Position__c
                FROM Holiday__c
                WHERE Start__c <= :endDate AND End__c >= :startDate];

    }

    @RemoteAction
    global static Employee1__c createNewCrew(String firstName, String lastName){

        Employee1__c emp = new Employee1__c(
                FirstName__c = firstName,
                LastName__c = lastName,
                Position__c = 'Freelancer',
                Active__c   = true,
                Onsite__c   = true
        );

        Database.saveResult result = Database.insert(emp);
        if (result.isSuccess()){
            return emp;
        } else {
            return null;
        }
    }

}