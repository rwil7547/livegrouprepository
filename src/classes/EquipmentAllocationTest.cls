/**
 * Created by Ronan Williams on 31/05/2018.
 */

@IsTest
public class EquipmentAllocationTest {

    // RETIRED BY R.WILLIAMS 18/10/2018
//    @TestSetup
//    public static void setupData(){
//
//        // Insert two Opporunities with overlapping dates
//        Account acc = (Account)SmartFactory.createSObject('Account');
//        insert acc;
//
//        Opportunity opp1        = (Opportunity)SmartFactory.createSObject('Opportunity');
//        opp1.Name               = '1';
//        opp1.AccountId          = acc.Id;
//        opp1.Amount             = 6000;
//        opp1.StageName          = 'Closed Won';
//        opp1.Invoice_Schedule__c = 'Three stage invoice';
//        opp1.Event_start__c     = Date.today().addDays(-1);
//        opp1.Event_end__c       = Date.today();
//        insert opp1;
//
//        Opportunity opp2        = (Opportunity)SmartFactory.createSObject('Opportunity');
//        opp2.Name               = '2';
//        opp2.AccountId          = acc.Id;
//        opp2.Amount             = 6000;
//        opp2.StageName          = 'Closed Won';
//        opp2.Invoice_Schedule__c = 'Three stage invoice';
//        opp2.Event_start__c     = Date.today();
//        opp2.Event_end__c       = Date.today().addDays(1);
//        insert opp2;
//
//        // insert two equipment items eligible for allocation, and allocate one to each opportunity
//        Equipment__c eq1    = new Equipment__c();
//        eq1.Name__c         = 'Laptop 1';
//        eq1.Model__c        = 'Lenovo';
//        eq1.Type__c         = 'Laptop';
//        eq1.Active__c       = true;
//        insert eq1;
//
//        Reservation__c res1 = new Reservation__c();
//        res1.Opportunity__c = opp1.Id;
//        res1.Equipment__c   = eq1.Id;
//        res1.Start_Date__c  = opp1.Event_start__c;
//        res1.End_Date__c    = opp1.Event_end__c;
//        insert res1;
//
//        Equipment__c eq2    = new Equipment__c();
//        eq2.Name__c         = 'Laptop 2';
//        eq2.Model__c        = 'Lenovo';
//        eq2.Type__c         = 'Laptop';
//        eq2.Active__c       = true;
//        insert eq2;
//
//        Reservation__c res2 = new Reservation__c();
//        res2.Opportunity__c = opp2.Id;
//        res2.Equipment__c   = eq2.Id;
//        res2.Start_Date__c  = opp2.Event_start__c;
//        res2.End_Date__c    = opp2.Event_end__c;
//        insert res2;
//
//        // insert one additional available equipment item
//        Equipment__c eq3    = new Equipment__c();
//        eq3.Name__c         = 'Laptop 3';
//        eq3.Model__c        = 'Lenovo';
//        eq3.Type__c         = 'Laptop';
//        eq3.Active__c       = true;
//        insert eq3;
//
//        // Insert one inactive equipment item
//        Equipment__c eq4    = new Equipment__c();
//        eq4.Name__c         = 'Laptop 3';
//        eq4.Model__c        = 'Lenovo';
//        eq4.Type__c         = 'Laptop';
//        eq4.Active__c       = false;
//        insert eq4;
//
//        // Insert one active item which is not onsite
//        Equipment__c eq5    = new Equipment__c();
//        eq5.Name__c         = 'Laptop 4';
//        eq5.Model__c        = 'Lenovo';
//        eq5.Type__c         = 'IT Support';
//        eq5.Active__c       = true;
//        insert eq5;
//
//    }
//
//    @IsTest
//    public static void testController() {
//
//        // test controller for Opp1
//        Opportunity opp1 = [SELECT Id FROM Opportunity WHERE Name = '1'];
//
//        ApexPages.StandardController sc1 = new ApexPages.StandardController(opp1);
//        ReservationController rc1 = new ReservationController(sc1);
//
//        System.assertEquals(Date.today().addDays(-1), rc1.start);
//        System.assertEquals(Date.today(), rc1.endDate);
//        System.assertEquals(1, rc1.reservations.size());
//        System.assertEquals(1, rc1.equipment.size());
//        System.assertEquals(1, rc1.equipmentReserves.size());
//        System.assertEquals(1, rc1.preReserves.size());
//        System.assertEquals(1, rc1.reservationsSize);
//        System.assertEquals(1, rc1.equipmentSize);
//        System.assertEquals('Closed Won', rc1.stage);
//
//        // set one custom date and ensure error is thrown and custom date is not saved
//        rc1.oppDetails.Equipment_Start__c  = Date.today().addDays(-2);
//
//        rc1.setCustomDates();
//        System.assertEquals(Date.today().addDays(-1), rc1.start);
//        System.assertEquals(Date.today(), rc1.endDate);
//
//        // set the second custom date and ensure dates are then successfully
//        // changed by the controller
//        rc1.oppDetails.Equipment_Start__c  = Date.today().addDays(-2);
//        rc1.oppDetails.Equipment_End__c    = Date.today().addDays(1);
//
//        rc1.setCustomDates();
//        System.assertEquals(Date.today().addDays(-2), rc1.start);
//        System.assertEquals(Date.today().addDays(1), rc1.endDate);
//        System.assertEquals(Date.today().addDays(-2), [SELECT Equipment_Start__c FROM Opportunity WHERE Name = '1'].Equipment_Start__c);
//        System.assertEquals(Date.today().addDays(1), [SELECT Equipment_End__c FROM Opportunity WHERE Name = '1'].Equipment_End__c);
//        System.assertEquals(rc1.start, rc1.reservations[0].Start_Date__c);
//        System.assertEquals(rc1.endDate, rc1.reservations[0].End_Date__c);
//
//        // release the equipment and check that two items are now available to reserve
//        rc1.equipmentReserves[0].release = true;
//        rc1.releaseEquipment();
//        System.assertEquals(0, rc1.reservations.size());
//        System.assertEquals(2, rc1.equipment.size());
//        System.assertEquals(0, rc1.equipmentReserves.size());
//        System.assertEquals(2, rc1.preReserves.size());
//        System.assertEquals(0, rc1.reservationsSize);
//        System.assertEquals(2, rc1.equipmentSize);
//
//        // reserve both available items of equipment and ensure none remain to be reserved
//        for (ReservationController.preReserve pr : rc1.preReserves){
//            pr.reserved = true;
//        }
//
//        rc1.reserveEquipment();
//        System.assertEquals(2, rc1.reservations.size());
//        System.assertEquals(0, rc1.equipment.size());
//        System.assertEquals(2, rc1.equipmentReserves.size());
//        System.assertEquals(0, rc1.preReserves.size());
//        System.assertEquals(2, rc1.reservationsSize);
//        System.assertEquals(0, rc1.equipmentSize);
//
//    }
//
//    @IsTest
//    public static void testTriggerStageChange() {
//
//        // verify that two equipment reservations exist
//        System.assertEquals(2, [SELECT Id FROM Reservation__c].size());
//
//        // set both opportunities to closed lost
//        for (Opportunity opp : [SELECT Id FROM Opportunity]){
//            opp.StageName = 'Closed Lost';
//            update opp;
//        }
//
//        // verify that both equipment reservations have been deleted
//        System.assertEquals(0, [SELECT Id FROM Reservation__c].size());
//    }
//
//    @IsTest
//    public static void testTriggerDateChange() {
//
//        Opportunity opp = [SELECT Id, Event_start__c, Event_end__c FROM Opportunity
//                            WHERE Name = '1'];
//
//        // verify that the reservation currently matches the opportunity event dates
//        Reservation__c resBefore = [SELECT Start_Date__c, End_Date__c FROM Reservation__c
//                                    WHERE Opportunity__c = :opp.Id];
//
//        System.assertEquals(opp.Event_start__c, resBefore.Start_Date__c);
//        System.assertEquals(opp.Event_end__c, resBefore.End_Date__c);
//
//        // verify that a date change to the opportunity will update the reservation
//        opp.Event_start__c  = Date.today().addDays(-30);
//        opp.Event_end__c    = Date.today().addDays(30);
//        update opp;
//
//        Reservation__c resAfter = [SELECT Start_Date__c, End_Date__c FROM Reservation__c
//                                    WHERE Opportunity__c = :opp.Id];
//
//        System.assertEquals(opp.Event_start__c, resAfter.Start_Date__c);
//        System.assertEquals(opp.Event_end__c, resAfter.End_Date__c);
//
//    }
}