public class InvoiceScheduleController {

    public Date defaultStart {get; set;}
    public Date defaultEnd {get; set;}
    public List<cOpportunity> copps {get; set;}
    public Set<String> monthGroupings {get;set;}
    public Map<String,List<cOpportunity>> coppsMap {get ; set;}
    public List<Opportunity> opportunities {get; set;}
    public String invoiceDate {get; set;}
    public String currentId {get; set;}
    public String currentAmount {get; set;}
    public String baseurl {get;set;}

    public PageReference processOppsRange() {

            copps            = new List<cOpportunity>();
            coppsMap         = new Map<String,List<cOpportunity>>();

            opportunities = [SELECT  Id, Name, Account.Name, Filtered_Job_Number__c,
                                Event_start__c, PO_Number__c, Calder_Opportunity__c, Event_end__c,
                                Amount_Calder__c, Amount_Invoiced2__c,
                                Amount_Paid__c, Owner.Name, Project_Manager__r.Name,
                                Event_End_Text__c, Comments__c,
                                (SELECT  Id, Name, Invoice_Number__c, Credit_Note_Number__c,
                                Amount__c, Payment_Date__c, Send_Date__c,
                                Invoice_Paid__c, Invoice_Sent__c
                                FROM   Invoice_Schedules__r
                                ORDER BY Name ASC)
                            FROM Opportunity
                            WHERE StageName = 'Closed Won'
                            AND Event_end__c <= :defaultEnd
                            AND Event_end__c >= :defaultStart
                            ORDER BY Event_end__c DESC ];

            for (Opportunity opp : opportunities){
                    cOpportunity copp = new cOpportunity(opp, opp.Event_End_Text__c);
                    copps.add(copp);

                    if (!coppsMap.containsKey(opp.Event_End_Text__c)) {
                            coppsMap.put(opp.Event_End_Text__c, new List<cOpportunity>());
                            coppsMap.get(opp.Event_End_Text__c).add(copp);
                    } else {
                            coppsMap.get(opp.Event_End_Text__c).add(copp);
                    }
            }

            monthGroupings = coppsMap.keySet();

            return null;

        }

        public PageReference saveChanges() {

            update opportunities;

            return null;
        }

        public PageReference updateInvoiceDate() {

            Date currentInvoiceDate = Date.valueOf(invoiceDate);
            Decimal currentInvoiceAmount = Decimal.valueOf(currentAmount.replaceAll('[,£]',''));
            Invoice_Schedule__c is = [SELECT Id FROM Invoice_Schedule__c WHERE Id = :currentId];
            is.Send_Date__c = currentInvoiceDate;
            is.Amount__c = currentInvoiceAmount;
            update is;

            return null;
        }

        public PageReference calloutQuickbooks() {

            QuickbooksChangeDataCapture.getInvoices();
            QuickbooksChangeDataCapture.getCreditMemos();

            Long startingTime = System.now().getTime();
            Integer delayInMilliseconds = 10000;
            while (System.now().getTime() - startingTime < delayInMilliseconds) {}

            processOppsRange();
            return null;
        }

        public class cOpportunity {
            public Opportunity oppy {get; set;}
            public List<Invoice> invoices {get; set;}
            public String monthGrouping {get; set;}
            public String link {get; set;}
            public String shortId {get; set;}
            public Integer count {get; set;}

            public cOpportunity(Opportunity opp, String monthGrouping) {
                this.oppy               = opp;
                this.monthGrouping      = monthGrouping;
                this.count              = opp.Invoice_Schedules__r.size();
                this.invoices           = new List<Invoice>();
                this.shortId            = String.valueOf(opp.Id).substring(0, 15);
                this.link                       = 'apex/InvoiceSchedulesRelatedList?id=' + shortId;

                for (Integer x = 0; x < 6; x++) {
                    if (opp.Invoice_Schedules__r.size() >= x+1) {
                        String creditNumber = (opp.Invoice_Schedules__r[x].Credit_Note_Number__c != null) ? ' / '
                                                                + opp.Invoice_Schedules__r[x].Credit_Note_Number__c : null;
                        String invoiceNumber = (creditNumber != null) ? opp.Invoice_Schedules__r[x].Invoice_Number__c + creditNumber :
                                                                        opp.Invoice_Schedules__r[x].Invoice_Number__c;
                        String dateSent = String.valueOf(opp.Invoice_Schedules__r[x].Send_Date__c.day())+
                                                        '/'+String.valueOf(opp.Invoice_Schedules__r[x].Send_Date__c.month())+
                                                        '/'+String.valueOf(opp.Invoice_Schedules__r[x].Send_Date__c.year());
                        Boolean overdue = (!opp.Invoice_Schedules__r[x].Invoice_Sent__c &&
                                                        opp.Invoice_Schedules__r[x].Send_Date__c < Date.today());
                        Integer daysOverdue = (Date.today().daysBetween(Date.valueOf(opp.Invoice_Schedules__r[x].Send_Date__c))) *-1;
                        Invoice inv = new Invoice(
                                opp.Invoice_Schedules__r[x].Name,
                                invoiceNumber,
                                opp.Invoice_Schedules__r[x].Amount__c,
                                dateSent,
                                opp.Invoice_Schedules__r[x].Invoice_Paid__c,
                                overdue,
                                daysOverdue,
                                Datetime.newInstance(opp.Invoice_Schedules__r[x].Send_Date__c,Time.newInstance(3, 3, 3, 0)),
                                opp.Invoice_Schedules__r[x].Id);
                        invoices.add(inv);
                    } else {
                        invoices.add(new invoice());
                    }
                }
            }
        }

        public class Invoice {

            public String invoiceName {get; set;}
            public String invoiceNumber {get; set;}
            public Decimal amount {get; set;}
            public String dateSent {get; set;}
            public String overdue {get; set;}
            public String paid {get; set;}
            public Boolean empty {get; set;}
            public String sendDate {get; set;}
            public String invoiceId {get; set;}

            public Invoice(String invoiceName, String invoiceNumber, Decimal amount,
                            String dateSent, Boolean paidFlag,
                            Boolean overdue, Integer daysOverdue, Datetime sendDate, String invoiceId) {
                this.invoiceName      = invoiceName;
                this.invoiceNumber    = (invoiceNumber != null) ? invoiceNumber : 'UNSENT';
                this.amount           = amount;
                this.dateSent         = (overdue) ? dateSent + ' (' + daysOverdue + ')' : dateSent;
                this.paid             = (paidFlag) ? 'Y' : 'N';
                this.overdue          = (overdue) ? 'Y' : 'N';
                this.empty            = false;
                this.sendDate         = sendDate.format('yyyy-MM-dd\'T\'HH:mm:ss').substring(0,10);
                this.invoiceId        = invoiceId;
            }

            public Invoice(){
                this.empty            = true;
            }
        }

        public InvoiceScheduleController() {

            baseurl      = String.valueOf(URL.getSalesforceBaseUrl().toExternalForm());
            defaultStart = Date.today().month() < 4 ?
                           Date.newInstance(Date.today().addYears(-1).year(),04,01) :
                           Date.newInstance(Date.today().year(),04,01);
            defaultEnd   = defaultStart.addYears(1).addDays(-1);

            processOppsRange();
        }
}