public class InvoiceScheduleExtension {

    private final Opportunity opp;
    public List<cSchedule> cSchedules {get; set;}
    public transient List<Expense__c> expenses {get;set;}
    public boolean editMode {get; set;}
    public Decimal defaultValue {get; set;}

    public pageReference allowEdit() {

        String isId = System.currentPageReference().getParameters().get('selectedId');

        for (cSchedule cs : cSchedules) {
            if (cs.is.Id == isId) cs.selected = true;    
        }

        editMode = true;
        return null;
    }

    public pageReference doEdit() {

        String editId = System.currentPageReference().getParameters().get('editId');

        for (cSchedule cs : cSchedules) {
            if (cs.is.Id == editId) {
                update cs.is;
                cs.selected = false;
            }
        }

        editMode = false;
        return null;
    }

    public pageReference doCancel() {

        String editId = System.currentPageReference().getParameters().get('editId');

        for (cSchedule cs : cSchedules) {
            if (cs.is.Id == editId) {
                cs.selected = false;
            }
        }

        editMode = false;
        return null;
    }

    public class cSchedule {
        public Invoice_Schedule__c is {get; set;}
        public Boolean selected {get; set;}

        public cSchedule(Invoice_Schedule__c is, Boolean selected){
            this.is             = is;
            this.selected       = selected;
        }
    }   

    public InvoiceScheduleExtension(ApexPages.StandardController stdController) {

        this.opp = (Opportunity)stdController.getRecord();

        List<Invoice_Schedule__c> schedules = 
                        [SELECT Id, Name, Amount__c, Send_Date__c, Invoice_Sent__c,
                            Custom_Value__c, Invoice_Paid__c, Payment_Date__c,
                            Invoice_Id__c, Invoice_Amount__c, Purchase_Order__c, Invoice_Number__c,
                            Credit_Note_Number__c, Credit_Note__c
                        FROM Invoice_Schedule__c
                        WHERE Opportunity__c = :opp.Id
                        ORDER BY Name ASC];

        cSchedules = new List<cSchedule>();

        for (Invoice_Schedule__c is : schedules) {
            cSchedule cs = new cSchedule(is, false);
            cSchedules.add(cs);
        }                

        editMode = false;

        expenses = [SELECT Id, Name, Amount__c, Description__c, Paid__c,
                            Supplier__c, Supplier_Ref__c, Due_Date__c
                    FROM Expense__c
                    WHERE Opportunity__c = :opp.Id];

        Opportunity oppRecord = [SELECT Amount_Calder__c, Amount_Invoiced2__c, 
                                        Amount_Remaining__c, ScheduleCount__c, 
                                        ProcessedInvoices__c,Custom_Values__c 
                                FROM Opportunity
                                WHERE Id = :opp.Id];            

        Decimal rawValue = 0;

        if ((oppRecord.Amount_Calder__c - oppRecord.Amount_Invoiced2__c) != 0 ) {
            if ((oppRecord.ScheduleCount__c - oppRecord.ProcessedInvoices__c) > 0) {
                rawValue = (oppRecord.Amount_Calder__c - oppRecord.Amount_Invoiced2__c) / (oppRecord.ScheduleCount__c - oppRecord.ProcessedInvoices__c); 
            } else {
                rawValue = (oppRecord.Amount_Calder__c - oppRecord.Amount_Invoiced2__c);
            }
        }
         
        defaultValue = rawValue.setScale(2);

    }

}