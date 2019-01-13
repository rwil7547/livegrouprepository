/**
 * Created by Ronan Williams on 30/05/2018.
 */

public with sharing class ReservationController {
    // RETIRED BY R.WILLIAMS 18/10/2018

//
//    public Opportunity opp {get; set;}
//    public Opportunity oppDetails {get; set;}
//    public Date start {get; set;}
//    public Date endDate {get; set;}
//    public List<Reservation__c> reservations {get;set;}
//    public List<Equipment__c> equipment {get;set;}
//    public List<preReserve> preReserves {get;set;}
//    public List<equipmentReserve> equipmentReserves {get;set;}
//    public Integer reservationsSize {get;set;}
//    public Integer equipmentSize {get;set;}
//    public String stage {get; private set;}
//
//    public void populateValues(){
//
//        Set<Id> reservedIds = new Set<Id>();
//
//        preReserves = new List<preReserve>();
//        equipmentReserves = new List<equipmentReserve>();
//
//
//        reservations = [SELECT Id, Equipment__c, Name__c, Model__c, Type__c,
//                                Start_Date__c, End_Date__c
//                        FROM Reservation__c
//                        WHERE Opportunity__c = :opp.Id
//                        ORDER BY Name__c ASC];
//
//        for (Reservation__c er : reservations) {
//            reservedIds.add(er.Equipment__c);
//            equipmentReserve err = new equipmentReserve(er);
//            equipmentReserves.add(err);
//        }
//
//        reservationsSize = reservations.size();
//
//        List<Reservation__c> otherReservations = [
//                                SELECT Id, Equipment__c
//                                FROM Reservation__c
//                                WHERE Start_Date__c <=: endDate
//                                AND End_Date__c >=: start];
//
//        for (Reservation__c eq : otherReservations){
//            reservedIds.add(eq.Equipment__c);
//        }
//
//
//        equipment = [SELECT Id, Name__c, Model__c, Type__c
//                    FROM Equipment__c
//                    WHERE Id NOT IN :reservedIds
//                    AND Onsite__c = True
//                    ORDER BY Name__c ASC];
//
//        equipmentSize = equipment.size();
//
//        for (Equipment__c eq : equipment){
//            preReserve p = new preReserve(eq);
//            preReserves.add(p);
//        }
//
//
//    }
//
//
//    public PageReference reserveEquipment(){
//
//        List<Equipment__c> equip = new List<Equipment__c>();
//        List<Reservation__c>  resList = new List<Reservation__c>();
//
//        for (preReserve p : preReserves){
//            if (p.reserved){
//                equip.add(p.eq);
//            }
//        }
//
//        for (Equipment__c eq : equip ){
//            Reservation__c er   = new Reservation__c();
//            er.Equipment__c     = eq.Id;
//            er.Start_Date__c    = start;
//            er.End_Date__c      = endDate;
//            er.Opportunity__c   = opp.Id;
//            resList.add(er);
//        }
//
//        insert resList;
//
//        populateValues();
//
//        return null;
//
//    }
//
//    public PageReference releaseEquipment(){
//
//        List<Reservation__c> toDelete = new List<Reservation__c>();
//
//        for (equipmentReserve er : equipmentReserves){
//            if (er.release){
//                toDelete.add(er.er);
//            }
//        }
//
//        delete toDelete;
//
//        populateValues();
//
//        return null;
//    }
//
//    public PageReference saveChanges(){
//
//        String errors = 'Unable to save the dates you have selected for the following equipment: <br/><br/>';
//
//        List<Reservation__c> toUpdate = new List<Reservation__c>();
//
//        for (Reservation__c r : reservations){
//
//            List<Reservation__c> conflicts =
//                        [SELECT Id, Equipment__c, Opportunity__r.Name,
//                                Start_Date__c, End_Date__c
//                        FROM Reservation__c
//                        WHERE Equipment__c = :r.Equipment__c
//                        AND Opportunity__c != :opp.Id
//                        AND Start_Date__c <=: r.End_Date__c
//                        AND End_Date__c >=: r.Start_Date__c];
//
//            if (conflicts.isEmpty()){
//                toUpdate.add(r);
//            } else {
//                errors += r.Name__c + ' from ' + r.Start_Date__c.format() + ' to ' +
//                        r.End_Date__c.format() + ' conflicts with: <br/>';
//                for (Reservation__c conflict : conflicts){
//                    errors += '*' + conflict.Opportunity__r.Name + ': ' + conflict.Start_Date__c.format() +
//                            ' - ' + conflict.End_Date__c.format() + '<br/>';
//                }
//                errors += '<br/>';
//            }
//
//        }
//
//        update toUpdate;
//
//        if (toUpdate.size() < reservations.size()){
//            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errors));
//            populateValues();
//            return null;
//        } else {
//            populateValues();
//            return null;
//        }
//    }
//
//    public PageReference setCustomDates() {
//
//        if (oppDetails.Equipment_Start__c == null || oppDetails.Equipment_End__c == null) {
//            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
//                    'Please specify both a start and end date for the custom range'));
//            return null;
//        } else {
//
//            update oppDetails;
//
//            start   = oppDetails.Equipment_Start__c;
//            endDate = oppDetails.Equipment_End__c;
//
//            for (Reservation__c r : reservations){
//                r.Start_Date__c = start;
//                r.End_Date__c = endDate;
//            }
//
//            PageReference pr = saveChanges();
//
//            return pr;
//        }
//
//    }
//
//    public class equipmentReserve {
//
//        public Reservation__c er {get;set;}
//        public Boolean release {get;set;}
//        //public Boolean changed {get;set;}
//
//        public equipmentReserve(Reservation__c er){
//            this.er = er;
//            this.release = false;
//        }
//
//    }
//
//    public class preReserve {
//
//        public Equipment__c eq {get;set;}
//        public Boolean reserved {get;set;}
//
//        public preReserve(Equipment__c eq){
//            this.eq = eq;
//            this.reserved = false;
//        }
//
//    }
//
//    public ReservationController(ApexPages.StandardController stdController) {
//
//        this.opp = (Opportunity) stdController.getRecord();
//
//        oppDetails = [SELECT Project_Start__c,
//                            Project_End__c, Equipment_Start__c,
//                            Equipment_End__c, StageName
//                        FROM Opportunity
//                        WHERE Id = :opp.Id];
//
//        if (oppDetails.Equipment_Start__c == null || oppDetails.Equipment_End__c == null){
//            start   = oppDetails.Project_Start__c ;
//            endDate = oppDetails.Project_End__c ;
//        } else {
//            start   = oppDetails.Equipment_Start__c ;
//            endDate = oppDetails.Equipment_End__c ;
//        }
//
//        stage   = oppDetails.StageName;
//
//        populateValues();
//
//    }
//
//
}