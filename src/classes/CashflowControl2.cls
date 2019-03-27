/**
 * Created by Ronan Williams on 25/03/2019.
 */

public with sharing class CashflowControl2 {


    public static void buildFlow(){

        // get the cashflow entries
        Map<Date, CashFlow__c> flowMap            = CashFlowUtils.getFlowMap();

        Map<String,Date> adjustmentsMap           = new Map<String,Date>();
        Map<String,Decimal> amountAdjustmentsMap  = new Map<String,Decimal>();

        // hold current values for each area of the budget
        Map<String,Map<String,Decimal>> budgetOffset = new Map<String,Map<String,Decimal>>();

        List<CashFlowEntry__c> newEntries         = new List<CashFlowEntry__c>();


        // get all old entries
        List<CashFlowEntry__c> oldEntries = [SELECT Id, Amount__c, AmountAdjusted__c, Adjusted__c, Paid__c,
                                                    QuickbooksId__c, OutFlow__c, InFlow__c,
                                                    OutFlow__r.Date__c, InFlow__r.Date__c, Description__c
                                            FROM CashFlowEntry__c
                                            WHERE Source__c != 'Custom'];


        // get direct debit and freelancer supplier profiles
        Map<String,QBSupplierProfile__c> directDebits   = new Map<String,QBSupplierProfile__c>();
        Set<String> freelancerIds                       = new Set<String>();
        for (QBSupplierProfile__c profile : [SELECT Id, Amount__c, EndDate__c, Day__c,
                                                Frequency__c, SupplierId__c, Terms__c
                                            FROM QBSupplierProfile__c]){
            if (profile.Terms__c == 'DD'){
                directDebits.put(profile.SupplierId__c, profile);
            } else {
                freelancerIds.add(profile.SupplierId__c);
            }
        }


        // INIT: GET CURRENT BALANCE
        String query1 = 'query?query=select%20%2a%20from%20account%20where%20name%20' +
                '%3d%20%27Bank%20Current%20Account%27&minorversion=4';

        // do callout
        Http http1              = new Http();
        HttpRequest request1    = CashFlowUtils.doCallout(query1);
        HttpResponse response1  = http1.send(request1);

        if (response1.getStatusCode() == 200) {
            JSONParserQBOCurrentAccount parsedResults = JSONParserQBOCurrentAccount.parse(response1.getBody());
            Decimal balance = parsedResults.QueryResponse.Account[0].CurrentBalance;
            flowMap.get(Date.today().addDays(-1)).Balance__c = balance;
        }


        // STEP 1: GET QUICKBOOKS INVOICES
        String invoiceQuery = 'query?query=select%20%2a%20from%20invoice%20where%20Balance%20' +
                '%3e%20%270%27&minorversion=4';

        // do callout
        Http http2 = new Http();
        HttpRequest request2 = CashFlowUtils.doCallout(invoiceQuery);
        HttpResponse response2 = http2.send(request2);

        if (response2.getStatusCode() == 200) {
            JSONParserQBOInvoiceFlow parsedResults = JSONParserQBOInvoiceFlow.parse(response2.getBody());

            Set<String> invoiceIds      = new Set<String>();
            Set<String> scheduleNumbers = new Set<String>();

            if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.Invoice != null) {
                for (JSONParserQBOInvoiceFlow.cls_Invoice inv : parsedResults.QueryResponse.Invoice) {
                    invoiceIds.add(inv.Id);

                    for (JSONParserQBOInvoiceFlow.cls_CustomField customField : inv.CustomField) {
                        if (customField.Name == 'Schedule') {
                            scheduleNumbers.add(customField.StringValue);
                        }
                    }

                }
            }

            Map<String, Decimal> creditMap   = new Map<String, Decimal>();
            Map<String, String> customerMap  = CashFlowUtils.getCustomerMap(scheduleNumbers);

            List<Invoice_Schedule__c> credits = [SELECT Credit_Note__c, QBOInvoiceId__c
                                                FROM Invoice_Schedule__c
                                                WHERE QBOInvoiceId__c IN :invoiceIds
                                                AND Credit_Note__c > 0];

            for (Invoice_Schedule__c is : credits) {
                creditMap.put(is.QBOInvoiceId__c, is.Credit_Note__c * 1.2);
            }

            if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.Invoice != null) {
                for (JSONParserQBOInvoiceFlow.cls_Invoice inv : parsedResults.QueryResponse.Invoice) {

                    Decimal balance  = (creditMap.containsKey(inv.Id)) ? inv.Balance - creditMap.get(inv.Id) : inv.Balance;
                    Date dueDate     = adjustmentsMap.containsKey(inv.Id) ? adjustmentsMap.get(inv.Id) : Date.valueOf(inv.DueDate);

                    if (dueDate <= Date.today()) {
                        dueDate = Date.today().addDays(1);
                    }

                    String scheduleNumber = '';

                    for (JSONParserQBOInvoiceFlow.cls_CustomField customField : inv.CustomField) {
                        if (customField.Name == 'Schedule') {
                            scheduleNumber = customField.StringValue;
                        }
                    }

                    if (flowMap.containsKey(dueDate)) {
                        newEntries.add(new CashFlowEntry__c(
                                CashFlow__c     = flowMap.get(dueDate).Id,
                                Source__c       = 'Quickbooks',
                                Category__c     = (customerMap.containsKey(scheduleNumber)) ? customerMap.get(scheduleNumber) : inv.CustomerRef.name,
                                Description__c  = inv.CustomerRef.name + ' Inv. ' + inv.DocNumber,
                                Amount__c       = balance,
                                QuickbooksId__c = inv.Id,
                                Stage__c        = 'Confirmed',
                                Adjusted__c     = adjustmentsMap.containsKey(inv.Id)));
                    }

                    // calculate budget offset
//                    if (!budgetOffset.containsKey())


                }
            }
        }


        // STEP 2: GET SALESFORCE INVOICES
        List<Invoice_Schedule__c> schedules = [SELECT Id, Amount__c, Payment_Date__c, Send_Date__c,
                                                    Opportunity__r.Account.QuickbooksId__c, Invoice_Id__c,
                                                    Opportunity__r.Name, Opportunity__r.Event_end__c,
                                                    Name, Job_Number__c, Opportunity__r.Account.Name
                                                FROM Invoice_Schedule__c
                                                WHERE Invoice_Sent__c = FALSE
                                                AND Invoice_Paid__c = FALSE
                                                AND Opportunity__r.Event_end__c >= LAST_N_MONTHS:12];

        for (Invoice_Schedule__c schedule : schedules) {

            Date dueDate    = adjustmentsMap.containsKey(schedule.Id) ? adjustmentsMap.get(schedule.Id) : schedule.Send_Date__c.addDays(30);

            if (dueDate < Date.today().addDays(35)){
                dueDate = Date.today().addDays(35);
            }

            if (flowMap.containsKey(dueDate)) {
                newEntries.add(new CashFlowEntry__c(
                        CashFlow__c     = flowMap.get(dueDate).Id,
                        Source__c       = 'Salesforce',
                        Category__c     = schedule.Opportunity__r.Account.Name,
                        Description__c  = schedule.Opportunity__r.Name + ' ' + schedule.Name,
                        QuickbooksId__c = schedule.Id,
                        Stage__c        = 'Confirmed',
                        Amount__c       = (schedule.Amount__c * 1.2).setScale(2)));
            }
        }


        // STEP 3: GET QUICKBOOKS BILLS

        //// GET QB SUPPLIER PROFILE RECORDS
//        Map<String, QBSupplierProfile__c> supplierProfilesMap = CashFlowUtils.getSupplierProfilesMap();

        String billQuery = 'query?query=select%20%2a%20from%20bill%20where%20Balance%20' +
                '%21%3d%20%270%27&minorversion=4';

        // do callout
        Http billHttp               = new Http();
        HttpRequest billRequest     = CashFlowUtils.doCallout(billQuery);
        HttpResponse billResponse   = billHttp.send(billRequest);

        if (billResponse.getStatusCode() == 200) {
            JSONParserQBOBillFlow parsedResults = JSONParserQBOBillFlow.parse(billResponse.getBody());

            if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.Bill != null) {

                for (JSONParserQBOBillFlow.cls_Bill bill : parsedResults.QueryResponse.Bill) {

                    if (!directDebits.containsKey(bill.VendorRef.value)) {

                        Date dueDate = adjustmentsMap.containsKey(bill.Id) ? adjustmentsMap.get(bill.Id) : Date.valueOf(bill.DueDate);

                        if (dueDate <= Date.today()) {
                            dueDate = Date.today().addDays(1);
                        }

                        String details = (Date.valueOf(bill.DueDate) < Date.today()) ?
                                'Aged: due ' + Date.valueOf(bill.DueDate).daysBetween(Date.today()) + ' days ago' :
                                (Date.valueOf(bill.DueDate) == Date.today()) ?
                                        'Officially due today' :
                                        'Officially due in ' + Date.today().daysBetween(Date.valueOf(bill.DueDate)) + ' days';

                        newEntries.add(new CashFlowEntry__c(
                                CashFlow__c     = flowMap.get(dueDate).Id,
                                Out__c          = true,
                                Source__c       = 'Quickbooks',
                                Category__c     = (freelancerIds.contains(bill.VendorRef.value)) ?
                                                    bill.VendorRef.value : 'Payment run',
                                Description__c  = bill.VendorRef.name,
                                Details__c      = details,
                                Amount__c       = bill.Balance,
                                QuickbooksId__c = bill.Id,
                                Adjusted__c     = (adjustmentsMap.containsKey(bill.Id)) ? true : false));

                    }
                }
            }
        }

        // STEP 4: GET SALESFORCE COS
        List<Opportunity> opps = [SELECT Filtered_Cost_of_Sale__c, Name,
                                        Quickbooks_COS__c, Event_end__c, Filtered_Job_Number__c
                                FROM Opportunity
                                WHERE StageName = 'Closed Won'
                                AND Quote_Status__c != 'Reconciliation - completed'
                                AND Event_end__c >= LAST_N_DAYS:100];

        Map<String, CashFlowEntry__c> cosEntries = new Map<String, CashFlowEntry__c>();

        for (Opportunity opp : opps) {

            // if there is still forecast COS, split into two batches
            if (opp.Filtered_Cost_of_Sale__c > opp.Quickbooks_COS__c)  {

                String age                  = opp.Event_end__c < Date.today() ? ' (' + opp.Event_end__c.daysBetween(Date.today()) + ' days old)' : '';
                String status               = opp.Event_end__c < Date.today() ? ' COS accrual' : ' COS event allocation';
                Date paymentDate            = (opp.Event_end__c < Date.today().addDays(35)) ?
                                                Date.today().addDays(35).toStartOfWeek().addDays(3) :
                                                opp.Event_end__c.toStartOfWeek().addDays(3);
                Decimal amount              = (((opp.Filtered_Cost_of_Sale__c - opp.Quickbooks_COS__c) * 1.2)).setScale(2);

                if (flowMap.containsKey(paymentDate)) {
                    // detect duplicate cos entries for the same day
                    if (cosEntries.containsKey(String.valueOf(paymentDate) + status)) {
                        cosEntries.get(String.valueOf(paymentDate) + status).Amount__c += amount;
                        cosEntries.get(String.valueOf(paymentDate) + status).Details__c += '£' +
                                amount + ': ' + opp.Name + age + '\n' ;
                    } else {
                        cosEntries.put(String.valueOf(paymentDate) + status, new CashFlowEntry__c(
                                CashFlow__c     = flowMap.get(paymentDate).Id,
                                Out__c          = true,
                                Source__c       = 'Salesforce',
                                Category__c     = 'Payment run',
                                Description__c  = status,
                                Details__c      = 'System generated payment run entry: \n' +
                                                  '£' + amount + ': ' +  opp.Name + age + '\n',
                                Stage__c        = 'Confirmed',
                                Amount__c       = amount));
                    }
                }
            }
        }

        newEntries.addAll(cosEntries.values());

        // STEP 5: GET SALESFORCE PIPELINE DATA
        List<Opportunity> unconfirmedOpps = [SELECT Amount_Calder__c, Name, Probability, Event_end__c,
                                                    Filtered_Cost_of_Sale__c, Filtered_Job_Number__c, ExpectedRevenue,
                                                    Account.Name, LastModifiedDate, LastModifiedBy.Name
                                            FROM Opportunity
                                            WHERE StageName != 'Closed Won'
                                            AND StageName != 'Closed Lost'
                                            AND StageName != 'Repeat Prospect'
                                            AND Amount > 0 AND Event_end__c > TODAY
                                            AND Event_end__c != NULL AND Event_start__c != NULL];

        Map<Date, CashFlowEntry__c> pipelineCosEntries = new Map<Date, CashFlowEntry__c>();

        for (Opportunity opp : unconfirmedOpps) {

            Decimal inAmount    = (((opp.Amount_Calder__c * (opp.Probability / 100)) * 1.2)).setScale(2);
            Decimal outAmount   = (((opp.Filtered_Cost_of_Sale__c * (opp.Probability / 100)) * 1.2)).setScale(2);
            Date inDate         = (opp.Event_end__c < Date.today().addDays(45)) ?
                                    Date.today().addDays(45) : opp.Event_end__c;

            if (flowMap.containsKey(inDate)) {
                newEntries.add(new CashFlowEntry__c(
                        CashFlow__c     = flowMap.get(inDate).Id,
                        Source__c       = 'SalesforceP',
                        Category__c     = opp.Account.Name,
                        Description__c  = 'Prob. ' + opp.Probability + '% : ' + opp.Name,
                        Details__c      = 'System generated payment date using weighted amount \n' +
                                          'Last activity by ' + opp.LastModifiedBy.Name + ' ' +
                                          Date.valueOf(opp.LastModifiedDate).daysBetween(Date.today()) + ' days ago',
                        Stage__c        = 'Pipeline',
                        Amount__c       = inAmount));
            }

            if (flowMap.containsKey(inDate.toStartOfWeek().addDays(3)) && outAmount > 0) {

                Date ouDate = inDate.toStartOfWeek().addDays(3);

                if (pipelineCosEntries.containsKey(ouDate)) {
                    pipelineCosEntries.get(ouDate).Amount__c += outAmount;
                    pipelineCosEntries.get(ouDate).Details__c += '£' + outAmount +
                            ': Prob. ' + opp.Probability + '%: ' + opp.Name + '\n' ;
                } else {
                    pipelineCosEntries.put(ouDate, new CashFlowEntry__c(
                            CashFlow__c     = flowMap.get(ouDate).Id,
                            Out__c          = true,
                            Source__c       = 'SalesforceP',
                            Category__c     = 'Payment run',
                            Description__c  = 'Pipeline COS provision',
                            Details__c      = 'System generated payment run entry using weighted cost of sales: \n' +
                                              '£' + outAmount + ': Prob. ' + opp.Probability + '%: ' + opp.Name + '\n' ,
                            Stage__c        = 'Pipeline',
                            Amount__c       = outAmount));
                }
            }
        }

        newEntries.addAll(pipelineCosEntries.values());


        // STEP 7: PLOT SUPPLIER PROFILES
        // DIRECT DEBIT

//        List<QBSupplierProfile__c> directDebits = [SELECT Id, Amount__c, EndDate__c, Day__c,
//                                                        Frequency__c, SupplierId__c
//                                                    FROM QBSupplierProfile__c];



        // VAT






        // STEP 6: PLOT REMAINING BUDGET ENTRIES
        // FREELANCER






        // MANAGEMENT FEES






        // SALARY




        // CREDIT CARD





    }

}