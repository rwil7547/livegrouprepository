/**
 * Created by Ronan Williams on 09/08/2018.
 */

/**
 * Created by Ronan Williams on 06/08/2018.
 */

public class CashFlowControl {

    @Future(Callout=true)
    public static void buildFlow() {

        Map<Date, CashFlow__c> flowMap = CashFlowUtils.getFlowMap();

        List<CashFlowEntry__c> oldEntries = [SELECT Id, Amount__c, AmountAdjusted__c, Adjusted__c, Paid__c,
                                                    QuickbooksId__c, OutFlow__c, InFlow__c,
                                                    OutFlow__r.Date__c, InFlow__r.Date__c, Description__c
                                            FROM CashFlowEntry__c
                                            WHERE Source__c != 'Custom'];

        List<CashFlowEntry__c> entriesToDelete = new List<CashFlowEntry__c>();

        Map<String,Date> adjustmentsMap            = new Map<String,Date>();
        Map<String,Decimal> amountAdjustmentsMap   = new Map<String,Decimal>();
        Set<String> paidEntries                    = new Set<String>();

        for (CashFlowEntry__c entry : oldEntries) {

            if (entry.Paid__c){
                paidEntries.add(entry.QuickbooksId__c);
            } else {
                // If the date on the entry has been manually adjusted, store in the date adjustment map
                if (entry.Adjusted__c && entry.QuickbooksId__c != null) {
                    if (entry.OutFlow__c != null) {
                        adjustmentsMap.put(entry.QuickbooksId__c, entry.OutFlow__r.Date__c);
                    } else if (entry.InFlow__c != null) {
                        adjustmentsMap.put(entry.QuickbooksId__c, entry.InFlow__r.Date__c);
                    }
                }
                // if the amount has been manually adjusted, store in the amount adjustment map
                if (entry.AmountAdjusted__c && entry.QuickbooksId__c != null) {
                    amountAdjustmentsMap.put(entry.QuickbooksId__c, entry.Amount__c);
                }

                entriesToDelete.add(entry);
            }
        }

        List<CashFlowEntry__c> customEntries = [ SELECT Id, Amount__c, Description__c, InFlow__c,
                                                        InFlow__r.Date__c, OutFlow__c, OutFlow__r.Date__c
                                                FROM CashFlowEntry__c
                                                WHERE Source__c = 'Custom'];

        for (CashFlowEntry__c custom : customEntries) {
            if (custom.InFlow__c != null && flowMap.containsKey(custom.InFlow__r.Date__c)) {
                flowMap.get(custom.InFlow__r.Date__c).In__c += custom.Amount__c;
            } else if (custom.OutFlow__c != null && flowMap.containsKey(custom.OutFlow__r.Date__c)) {
                flowMap.get(custom.OutFlow__r.Date__c).Out__c += custom.Amount__c;
            } else {
                oldEntries.add(custom);
            }
        }

        List<CashFlowEntry__c> newEntries       = new List<CashFlowEntry__c>();
        Map<String, Decimal> payMap             = CashFlowUtils.getPayMap();

        ////// TRACK MONTHLY OVERHEADS
        Map<Integer, Decimal> monthlyOverheads  = CashFlowUtils.getMonthlyOverheadMap();

        ////////////// STEP 1 - CURRENT ACCOUNT BALANCE
        String query1 = 'query?query=select%20%2a%20from%20account%20where%20name%20' +
                '%3d%20%27Bank%20Current%20Account%27&minorversion=4';

        // do callout
        Http http1              = new Http();
        HttpRequest request1    = CashFlowUtils.doCallout(query1);
        HttpResponse response1  = http1.send(request1);

        if (response1.getStatusCode() == 200) {
            JSONParserQBOCurrentAccount parsedResults = JSONParserQBOCurrentAccount.parse(response1.getBody());

            Decimal balance = parsedResults.QueryResponse.Account[0].CurrentBalance;
            flowMap.get(Date.today().addDays(-1)).In__c = balance;
        }

        ////////////// STEP 2 - QUICKBOOKS INVOICES
        String query2 = 'query?query=select%20%2a%20from%20invoice%20where%20Balance%20' +
                '%3e%20%270%27&minorversion=4';

        // do callout
        Http http2 = new Http();
        HttpRequest request2 = CashFlowUtils.doCallout(query2);
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

                    Decimal balance = (creditMap.containsKey(inv.Id)) ?
                            inv.Balance - creditMap.get(inv.Id) : inv.Balance;

                    Date dueDate        = Date.valueOf(inv.DueDate);
                    String dateDetail   = 'System generated date \n';

                    String scheduleNumber = '';

                    for (JSONParserQBOInvoiceFlow.cls_CustomField customField : inv.CustomField) {
                        if (customField.Name == 'Schedule') {
                            scheduleNumber = customField.StringValue;
                        }
                    }

                    // logic: if the invoice has been marked with an adjuste date on the overview page,
                    // use the adjusted date, otherwise if we know how long the customer tends to take to pay,
                    // use this value of the expected payment date
                    if (adjustmentsMap.containsKey(inv.Id)) {
                        dueDate      = adjustmentsMap.get(inv.Id);
                        dateDetail   = 'Custom date manually specified \n';

                    } else if (payMap.containsKey(inv.CustomerRef.value)) {
                        dueDate = Date.valueOf(inv.MetaData.CreateTime).addDays(Integer.valueOf(payMap.get(inv.CustomerRef.value)));
                    }

                    if (dueDate == Date.today()) {
                        dueDate = Date.today().addDays(1);
                    }

                    // logic: if the invoice is due in the past, the more overdue the invoice,
                    // the less likely it will be paid imminently
                    if (dueDate < Date.today()) {
                        Integer daysOverdue = Date.valueOf(inv.MetaData.CreateTime).daysBetween(Date.today()) / 2;
                        dueDate = Date.today().addDays(3 + daysOverdue);
                    }

                    String details = dateDetail;
                    details += (Date.valueOf(inv.DueDate) < Date.today()) ?
                            'Aged: due ' + Date.valueOf(inv.DueDate).daysBetween(Date.today()) + ' days ago':
                            (Date.valueOf(inv.DueDate) == Date.today()) ?
                            'Officially due today' :
                            'Officially due in ' + Date.today().daysBetween(Date.valueOf(inv.DueDate)) + ' days';

                    if (flowMap.containsKey(dueDate)) {
                        flowMap.get(dueDate).In__c += balance;
                        newEntries.add(new CashFlowEntry__c(
                                InFlow__c       = flowMap.get(dueDate).Id,
                                Source__c       = 'Quickbooks',
                                Category__c     = (customerMap.containsKey(scheduleNumber)) ? customerMap.get(scheduleNumber) : inv.CustomerRef.name,
                                Description__c  = inv.CustomerRef.name + ' Inv. ' + inv.DocNumber,
                                Details__c      = details,
                                Amount__c       = balance,
                                QuickbooksId__c = inv.Id,
                                Adjusted__c     = (adjustmentsMap.containsKey(inv.Id)) ? true : false));
                    }
                }
            }
        }

        ////////////// STEP 3 - QUICKBOOKS BILLS

        //// GET QB SUPPLIER PROFILE RECORDS
        Map<String, QBSupplierProfile__c> supplierProfilesMap = CashFlowUtils.getSupplierProfilesMap();

        //// GET DATES OF UNPAID JOBS
        Map<String, Date> unpaidMap             = CashFlowUtils.getUnpaidMap();
        Set<String> billSet                     = new Set<String>();
        Map<Integer, Set<String>> billMonthMap  = new Map<Integer, Set<String>>();

        String query3 = 'query?query=select%20%2a%20from%20bill%20where%20Balance%20' +
                '%21%3d%20%270%27&minorversion=4';

        // do callout
        Http http3 = new http();
        HttpRequest request3 = CashFlowUtils.doCallout(query3);
        HttpResponse response3 = http3.send(request3);

        if (response3.getStatusCode() == 200) {
            JSONParserQBOBillFlow parsedResults = JSONParserQBOBillFlow.parse(response3.getBody());

            if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.Bill != null) {

                Date nextPaymentRun = Date.today() <= Date.today().toStartOfWeek().addDays(3) ?
                        Date.today().toStartOfWeek().addDays(3) : Date.today().addDays(7).toStartOfWeek().addDays(3);

                Map<String, CashFlowEntry__c> billEntries = new Map<String, CashFlowEntry__c>();

                for (JSONParserQBOBillFlow.cls_Bill bill : parsedResults.QueryResponse.Bill) {

                    Boolean hasProfile      = supplierProfilesMap.containsKey(Bill.VendorRef.value);
                    Boolean directDebit     = (hasProfile && supplierProfilesMap.get(Bill.VendorRef.value).Terms__c == 'Direct debit') ?
                            true : false;
                    Boolean freeLancer      = (hasProfile && supplierProfilesMap.get(Bill.VendorRef.value).Category__c == 'Freelancers') ?
                            true : false;

                    String jobNumber = '';

                    // prepare bill amounts to be added to overhead collections
                    Decimal overheadAmount = 0;
                    Decimal fullBillAmount = hasProfile ? bill.TotalAmt / supplierProfilesMap.get(Bill.VendorRef.value).Split__c : bill.Balance;

                    for (JSONParserQBOBillFlow.cls_Line line : bill.Line) {

                        if (line.AccountBasedExpenseLineDetail.CustomerRef != null) {
                            String extendedName = line.AccountBasedExpenseLineDetail.CustomerRef.name.substring(
                                    line.AccountBasedExpenseLineDetail.CustomerRef.name.lastIndexOf(':') + 1);
                            jobNumber = extendedName.substring(0, 5);
                        } else if (hasProfile) {
                            overheadAmount += Decimal.valueOf(line.Amount) / supplierProfilesMap.get(Bill.VendorRef.value).Split__c;
                        } else {
                            overheadAmount += Decimal.valueOf(line.Amount);
                        }
                    }

                    // align bill payment date with the next likely payment run date or direct debit payment date
                    Date dueDate        = Date.valueOf(bill.DueDate).toStartOfWeek().addDays(3);
                    String dateDetail   = 'System generated date \n';

                    // if the bill has had a custom due date specified
                    if (adjustmentsMap.containsKey(bill.Id)) {
                        dueDate     = adjustmentsMap.get(bill.Id);
                        dateDetail  = 'Custom date manually specified \n';

                    // if the bill is a direct debit with specified payment terms
                    } else if (directDebit) {

                        // remove barclaycard bill entries as they are collectively paid in a single direct debit
                        if (bill.VendorRef.name != 'Barclaycard' &&
                                Bill.Id != supplierProfilesMap.get(Bill.VendorRef.value).LastBillId__c) {
                            Integer day         = Integer.valueOf(supplierProfilesMap.get(Bill.VendorRef.value).Day__c);
                            Integer frequency   = 12 / Integer.valueOf(supplierProfilesMap.get(Bill.VendorRef.value).Frequency__c);
                            dueDate             = Date.newInstance(Date.today().year(), Date.today().month(), day);
                            if (dueDate <= Date.today()) {
                                dueDate = dueDate.addMonths(1);
                            }
                            supplierProfilesMap.get(Bill.VendorRef.value).LastInstance__c   = dueDate;
                            supplierProfilesMap.get(Bill.VendorRef.value).NextInstance__c   = dueDate.addMonths(frequency);
                            supplierProfilesMap.get(Bill.VendorRef.value).LastAmount__c     = fullBillAmount;
                            supplierProfilesMap.get(Bill.VendorRef.value).LastBillId__c     = Bill.Id;
                        }
                    // if the bill is a freelancer
                    } else if (freeLancer){
                        if (Bill.Id != supplierProfilesMap.get(Bill.VendorRef.value).LastBillId__c) {
                            QBSupplierProfile__c profile = supplierProfilesMap.get(Bill.VendorRef.value);
                            Integer monthFrequency      = (profile.Terms__c == 'Weekly') ? 0 : Integer.valueOf(12 / profile.Frequency__c );
                            Integer dayFrequency        = Integer.valueOf(profile.DayFrequency__c);
                            dueDate                     = profile.NextInstance__c;
                            supplierProfilesMap.get(Bill.VendorRef.value).LastInstance__c = dueDate;
                            supplierProfilesMap.get(Bill.VendorRef.value).NextInstance__c = dueDate.addMonths(monthFrequency).addDays(dayFrequency);
                            supplierProfilesMap.get(Bill.VendorRef.value).LastAmount__c   = fullBillAmount;
                            supplierProfilesMap.get(Bill.VendorRef.value).LastBillId__c   = Bill.Id;
                        }
                    // if the bill is for a project and money for the project has not yet been recieved paid
                    } else if (unpaidMap.containsKey(jobNumber) && unpaidMap.get(jobNumber) >= nextPaymentRun) {
                        dueDate = unpaidMap.get(jobNumber).toStartOfWeek().addDays(3);
                    // if the bill due date is already in the past
                    } else if (dueDate <= nextPaymentRun) {
                        dueDate = nextPaymentRun;
                    }

                    // assign the bill to the flow map
                    if (flowMap.containsKey(dueDate)) {
                        flowMap.get(dueDate).Out__c += fullBillAmount;

                        String details = dateDetail;

                        details += (Date.valueOf(bill.DueDate) < Date.today()) ?
                                'Aged: due ' + Date.valueOf(bill.DueDate).daysBetween(Date.today()) + ' days ago':
                                (Date.valueOf(bill.DueDate) == Date.today()) ?
                                        'Officially due today' :
                                        'Officially due in ' + Date.today().daysBetween(Date.valueOf(bill.DueDate)) + ' days';

                        // detect duplicate supplier bills for the same day
                        if (billEntries.containsKey(String.valueOf(dueDate) + bill.VendorRef.name)) {
                            billEntries.get(String.valueOf(dueDate) + bill.VendorRef.name).Amount__c += fullBillAmount;
                        } else {
                            billEntries.put(String.valueOf(dueDate) + bill.VendorRef.name, new CashFlowEntry__c(
                                    OutFlow__c      = flowMap.get(dueDate).Id,
                                    Source__c       = 'Quickbooks',
                                    Category__c     = hasProfile ? supplierProfilesMap.get(Bill.VendorRef.value).Category__c : 'Payment run',
                                    Description__c  = (directDebit) ? '(DD) ' + bill.VendorRef.name : bill.VendorRef.name,
                                    Details__c      = details,
                                    Amount__c       = fullBillAmount,
                                    QuickbooksId__c = bill.Id,
                                    Adjusted__c     = (adjustmentsMap.containsKey(bill.Id)) ? true : false));
                        }
                    }

                    billSet.add(bill.Id);

                    if (billMonthMap.containsKey(dueDate.month())) {
                        billMonthMap.get(dueDate.month()).add(bill.Id);
                        billMonthMap.get(dueDate.month()).add(bill.VendorRef.name);
                    } else {
                        billMonthMap.put(dueDate.month(), new Set<String>{
                                bill.Id, bill.VendorRef.name
                        });
                    }

                    // if the bill is for a supplier which currently has no profile record in salesforce,
                    // add a new profile
                    if (!hasProfile) {
                        QBSupplierProfile__c newProfile = new QBSupplierProfile__c(
                                Name            = bill.VendorRef.name,
                                SupplierId__c   = bill.VendorRef.value,
                                Category__c     = 'Payment run',
                                Frequency__c    = 12,
                                DayFrequency__c = 0,
                                Day__c          = 0,
                                Split__c        = 1,
                                Terms__c        = 'Post payment'
                        );
                        supplierProfilesMap.put(newProfile.SupplierId__c, newProfile);
                    }
                }
                newEntries.addAll(billEntries.values());
            }
        }


        ////////////// STEP 3 - ADDING DIRECT DEBITS, CREDIT CARD AND FREELANCERS
        Set<String> debitsAndFreelancers = new Set<String>();

        for (QBSupplierProfile__c supplier : supplierProfilesMap.values()){

            if (supplier.Terms__c == 'Direct debit') {
                debitsAndFreelancers.add(supplier.Name);
                Date dueDate        = supplier.NextInstance__c;
                Integer frequency   = Integer.valueOf(12 / supplier.Frequency__c );
                Integer day         = Integer.valueOf(supplier.Day__c);
                while (!flowMap.containsKey(dueDate)) {
                    dueDate = dueDate.addMonths(frequency).toStartOfMonth().addDays(day);
                }
                while (flowMap.containsKey(dueDate)) {

                    String directDebitlId = supplier.Name + dueDate.year() + dueDate.month();

                    if (!paidEntries.contains(directDebitlId)) {

                        Decimal amount = supplier.LastAmount__c;
                        Boolean amountAdjusted  = false;
                        Boolean dateAdjusted    = false;
                        String dateDetail       = 'System generated date \n';
                        String amountDetail     = 'System generated amount';

                        if (amountAdjustmentsMap.containsKey(directDebitlId)) {
                            amount          = amountAdjustmentsMap.get(directDebitlId);
                            amountDetail    = 'Custom amount manually specified';
                            amountAdjusted  = true;
                        }

                        if (adjustmentsMap.containsKey(directDebitlId)) {
                            dueDate         = adjustmentsMap.get(directDebitlId);
                            dateDetail      = 'Custom date manually specified \n';
                            dateAdjusted    = true;
                        }

                        flowMap.get(dueDate).Out__c += amount;
                        newEntries.add(new CashFlowEntry__c(
                                OutFlow__c      = flowMap.get(dueDate).Id,
                                QuickbooksId__c = directDebitlId,
                                Source__c       = 'Overheads',
                                Category__c     = supplier.Category__c,
                                Description__c  = '(DD) ' + supplier.Name,
                                Details__c      = dateDetail + amountDetail,
                                Amount__c       = amount,
                                Adjusted__c     = dateAdjusted,
                                AmountAdjusted__c = amountAdjusted));
                    }

                    dueDate = dueDate.addMonths(frequency);
                }
            } else if (supplier.Category__c == 'Freelancers' && supplier.Frequency__c > 0){
                debitsAndFreelancers.add(supplier.Name);
                Date dueDate                = supplier.NextInstance__c;
                Integer monthFrequency      = (supplier.Terms__c == 'Weekly') ? 0 : Integer.valueOf(12 / supplier.Frequency__c );
                Integer weekFrequency       = Integer.valueOf(supplier.DayFrequency__c);

                while (!flowMap.containsKey(dueDate)) {
                    dueDate = dueDate.addMonths(monthFrequency).addDays(weekFrequency);
                }

                while (flowMap.containsKey(dueDate)) {

                    String freelancerlId = supplier.Name + dueDate.year() + dueDate.month();

                    if (!paidEntries.contains(freelancerlId)) {

                        Decimal amount = supplier.LastAmount__c;
                        Boolean amountAdjusted  = false;
                        Boolean dateAdjusted    = false;
                        String dateDetail       = 'System generated date \n';
                        String amountDetail     = 'System generated amount';

                        if (amountAdjustmentsMap.containsKey(freelancerlId)) {
                            amount = amountAdjustmentsMap.get(freelancerlId);
                            amountDetail = 'Custom amount manually specified';
                            amountAdjusted = true;
                        }

                        if (adjustmentsMap.containsKey(freelancerlId)) {
                            dueDate = adjustmentsMap.get(freelancerlId);
                            dateDetail = 'Custom date manually specified \n';
                            dateAdjusted = true;
                        }
                        flowMap.get(dueDate).Out__c += supplier.LastAmount__c;
                        newEntries.add(new CashFlowEntry__c(
                                OutFlow__c      = flowMap.get(dueDate).Id,
                                QuickbooksId__c = freelancerlId,
                                Source__c       = 'Overheads',
                                Category__c     = 'Freelancers',
                                Description__c  = supplier.Name,
                                Details__c      = dateDetail + amountDetail,
                                Amount__c       = supplier.LastAmount__c,
                                Adjusted__c     = dateAdjusted,
                                AmountAdjusted__c = amountAdjusted));
                    }

                    dueDate = dueDate.addMonths(monthFrequency).addDays(weekFrequency);
                }
            }
        }


        ////////////// STEP 4 - ADD OVERHEADS FROM QUICKBOOKS
        String startValue = String.valueOf(Date.today().addMonths(-3).toStartOfMonth()).substring(0, 10);
        String endValue = String.valueOf(Date.today().toStartOfMonth()).substring(0, 10);

        String query4 = 'query?query=select%20%2a%20from%20bill%20where%20metadata.createtime%20%3e%20%27' + startValue +
                'T02%3a32%3a09-07%3a00%27%20and%20metadata.createtime%20%3c%20%27' + endValue +
                'T02%3a32%3a09-07%3a00%27%20MAXRESULTS%20500&minorversion=4';

        // do callout
        Http http4 = new http();
        HttpRequest request4 = CashFlowUtils.doCallout(query4);
        HttpResponse response4 = http4.send(request4);

        if (response4.getStatusCode() == 200) {
            JSONParserQBOBillFlow parsedResults = JSONParserQBOBillFlow.parse(response4.getBody());

            if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.Bill != null) {

                Map<String, Set<Integer>> billFrequencyMap      = new Map<String, Set<Integer>>();
                Map<String, Date> lastInstanceMap               = new Map<String, Date>();
                Map<String, Decimal> averageAmountMap           = new Map<String,Decimal>();
                Map<String, CashFlowEntry__c> overheadEntries   = new Map<String, CashFlowEntry__c>();

                for (JSONParserQBOBillFlow.cls_Bill bill : parsedResults.QueryResponse.Bill) {

                    for (JSONParserQBOBillFlow.cls_Line line : bill.Line) {
                        if (line.AccountBasedExpenseLineDetail.CustomerRef == null &&
                                !debitsAndFreelancers.contains(bill.VendorRef.name)) {

                            String lineKey      = bill.VendorRef.name + line.AccountBasedExpenseLineDetail.AccountRef.name;
                            Integer lastUpdate  = Date.valueOf(bill.MetaData.LastUpdatedTime).month();

                            if (billFrequencyMap.containsKey(lineKey)) {
                                billFrequencyMap.get(lineKey).add(lastUpdate);
                            } else {
                                billFrequencyMap.put(lineKey, new Set<Integer>{lastUpdate});
                            }

                            if (averageAmountMap.containsKey(lineKey)){
                                averageAmountMap.put(lineKey, line.Amount + averageAmountMap.get(lineKey));
                            } else {
                                averageAmountMap.put(lineKey, line.Amount);
                            }

                            if (!lastInstanceMap.containsKey(lineKey) ||
                                    Date.valueOf(bill.MetaData.LastUpdatedTime) > lastInstanceMap.get(lineKey)) {
                                lastInstanceMap.put(lineKey, Date.valueOf(bill.MetaData.LastUpdatedTime));
                            }
                        }
                    }
                }

                for (JSONParserQBOBillFlow.cls_Bill bill : parsedResults.QueryResponse.Bill) {

                    for (JSONParserQBOBillFlow.cls_Line line : bill.Line) {
                        String lineKey = bill.VendorRef.name + line.AccountBasedExpenseLineDetail.AccountRef.name;

                        if (billFrequencyMap.containsKey(lineKey) && billFrequencyMap.get(lineKey).size() > 2) {

                            Integer frequency = billFrequencyMap.get(lineKey).size();
                            billFrequencyMap.remove(lineKey);
                            Date dueDate = Date.valueOf(lastInstanceMap.get(lineKey)).toStartOfWeek().addDays(3);

                            String accountType = line.AccountBasedExpenseLineDetail.AccountRef.name;
                            String accountTypeShort = accountType.substring(5);
                            if (accountTypeShort.contains(':')){
                                accountTypeShort = accountTypeShort.substring(0, accountTypeShort.indexOf(':'));
                            }

                            while (!flowMap.containsKey(dueDate)) {
                                dueDate = dueDate.addMonths(1).toStartOfWeek().addDays(3);
                            }

                            while (flowMap.containsKey(dueDate)) {

                                if (!billMonthMap.containsKey(dueDate.month()) || (billMonthMap.containsKey(dueDate.month()) &&
                                        !billMonthMap.get(dueDate.month()).contains(bill.VendorRef.name))) {
                                    Decimal amount = (averageAmountMap.get(lineKey) / frequency).setScale(2);

                                    flowMap.get(dueDate).Out__c += amount;

                                    // detect duplicate supplier bills for the same day
                                    if (overheadEntries.containsKey(String.valueOf(dueDate) + accountTypeShort)) {
                                        overheadEntries.get(String.valueOf(dueDate) + accountTypeShort).Amount__c += amount;
                                        overheadEntries.get(String.valueOf(dueDate) + accountTypeShort).Details__c +=
                                                accountType + ': £' + amount + '\n';

                                    } else {
                                        overheadEntries.put(String.valueOf(dueDate) + accountTypeShort, new CashFlowEntry__c(
                                                OutFlow__c      = flowMap.get(dueDate).Id,
                                                Source__c       = 'Overheads',
                                                Category__c     = 'Payment run',
                                                Description__c  = accountTypeShort,
                                                Details__c      = 'System generated expediture based on averages in the last three months: \n' +
                                                                  accountType + ': £' + amount + '\n',
                                                Amount__c       = amount));

                                    }
                                }

                                dueDate = dueDate.addMonths(1).toStartOfWeek().addDays(3);
                            }
                        }
                    }
                }
                newEntries.addAll(overheadEntries.values());
            }
        }

        ////////////// STEP 5 - GET OUTSTANDING SALESFORCE INVOICES
        List<Invoice_Schedule__c> schedules = [SELECT Amount__c, Payment_Date__c, Send_Date__c,
                                                        Opportunity__r.Account.QuickbooksId__c, Invoice_Id__c,
                                                        Opportunity__r.Name, Opportunity__r.Event_end__c,
                                                        Name, Job_Number__c, Opportunity__r.Account.Name
                                                FROM Invoice_Schedule__c
                                                WHERE Invoice_Sent__c = FALSE
                                                AND Invoice_Paid__c = FALSE
                                                AND Opportunity__r.Event_end__c >= LAST_N_MONTHS:12];

        for (Invoice_Schedule__c schedule : schedules) {

            Decimal amount  = schedule.Amount__c;
            Date dueDate    = schedule.Send_Date__c.addDays(30);
            String detail   = 'System generated payment date \n';
            detail   = (schedule.Payment_Date__c < Date.today()) ?
                       'Officially overdue by ' + schedule.Payment_Date__c.daysBetween(Date.today()) + ' days':
                       (schedule.Payment_Date__c == Date.today()) ?
                       'Officially due today' : 'Officially due in ' + Date.today().daysBetween(schedule.Payment_Date__c) + ' days';

            if (schedule.Opportunity__r.Account.QuickbooksId__c != null
                    && payMap.containsKey(schedule.Opportunity__r.Account.QuickbooksId__c)) {
                dueDate = schedule.Send_Date__c.addDays(
                        Integer.valueOf(payMap.get(schedule.Opportunity__r.Account.QuickbooksId__c))
                );
            }

            if (dueDate < Date.today().addDays(35)) {
                if (schedule.Opportunity__r.Event_end__c <= Date.today().addDays(35)) {
                    Integer delay = schedule.Opportunity__r.Event_end__c.daysBetween(Date.today().addDays(35));
                    dueDate = Date.today().addDays(35 + delay);
                } else {
                    Integer advance = Date.today().addDays(35).daysBetween(schedule.Opportunity__r.Event_end__c);
                    dueDate = Date.today().addDays(35 + (advance / 2));
                }
            } else if (dueDate.daysBetween(schedule.Opportunity__r.Event_end__c) > 90) {
                dueDate = schedule.Opportunity__r.Event_end__c.addDays(-90);
                if (dueDate < Date.today().addDays(35)) {
                    dueDate = Date.today().addDays(35);
                }
            }

            if (flowMap.containsKey(dueDate)) {
                flowMap.get(dueDate).In__c += (amount * 1.2).setScale(2);
                newEntries.add(new CashFlowEntry__c(
                        InFlow__c       = flowMap.get(dueDate).Id,
                        Source__c       = 'Salesforce',
                        Category__c     = schedule.Opportunity__r.Account.Name,
                        Description__c  = schedule.Opportunity__r.Name + ' ' + schedule.Name,
                        Details__c      = detail,
                        Amount__c       = (amount * 1.2).setScale(2)));
            }
        }

        ////////////// STEP 5 - GET OUTSTANDING COS
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

                Boolean approaching         = opp.Event_end__c < Date.today();
                String age                  = approaching ? ' (' + opp.Event_end__c.daysBetween(Date.today()) + ' days old)' : '';
                String status               = approaching ? ' COS accrual' : ' COS event allocation';
                Date dateOne                = (opp.Event_end__c > Date.today().addDays(35)) ? opp.Event_end__c :
                                              (opp.Event_end__c > Date.today()) ? Date.today().addDays(35) :
                                              Date.today().addDays(35 + opp.Event_end__c.daysBetween(Date.today()));
                Date dateTwo                = (opp.Event_end__c > Date.today().addDays(35)) ? opp.Event_end__c.addDays(20) :
                                              (opp.Event_end__c > Date.today()) ? Date.today().addDays(55) :
                                              Date.today().addDays(55 + opp.Event_end__c.daysBetween(Date.today()));
                List<Date> dates            = new List<Date>{dateOne, dateTwo};
                Decimal amount = (((opp.Filtered_Cost_of_Sale__c - opp.Quickbooks_COS__c) * 1.2)/2).setScale(2);

                for (Date cosDate : dates) {
                    cosDate = cosDate.toStartOfWeek().addDays(3);

                    if (flowMap.containsKey(cosDate)) {
                        // detect duplicate cos entries for the same day
                        if (cosEntries.containsKey(String.valueOf(cosDate) + status)) {
                            flowMap.get(cosDate).Out__c += amount;
                            cosEntries.get(String.valueOf(cosDate) + status).Amount__c += amount;
                            cosEntries.get(String.valueOf(cosDate) + status).Details__c += '£' +
                                    amount + ': ' + opp.Name + age + '\n' ;
                        } else {
                            flowMap.get(cosDate).Out__c += amount.setScale(2);
                            cosEntries.put(String.valueOf(cosDate) + status, new CashFlowEntry__c(
                                    OutFlow__c      = flowMap.get(cosDate).Id,
                                    Source__c       = 'Salesforce',
                                    Category__c     = 'Payment run',
                                    Description__c  = status,
                                    Details__c      = 'System generated payment run entry: \n' +
                                                      '£' + amount + ': ' +  opp.Name + age + '\n',
                                    Amount__c       = amount));
                        }
                    }
                }
            }
        }

        newEntries.addAll(cosEntries.values());


        ////////////// STEP 6 - ADDING SALARY INFORMATION FROM QUICKBOOKS
        String dateValue = String.valueOf(Date.today().addDays(-35)).substring(0, 10);

        String query5 = 'query?query=select%20%2a%20from%20journalentry%20where%20TxnDate%20%3e%20%27'
                + dateValue + '%27&minorversion=4';

        // do callout
        Http http5 = new http();
        HttpRequest request5 = CashFlowUtils.doCallout(query5);
        HttpResponse response5 = http5.send(request5);

        if (response5.getStatusCode() == 200) {
            JSONParserQBOJournalFlow parsedResults = JSONParserQBOJournalFlow.parse(response5.getBody());

            if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.JournalEntry != null) {

                // isolate the relevant journal codes
                Map<String,Integer> journalDateMap = new Map<String,Integer>();
                journalDateMap.put('2220 Net Wages', -6);
                journalDateMap.put('2210 P.A.Y.E.', 13);
                journalDateMap.put('2230 Pension Fund', 10);


                // find the largest amount associated with each relevant journal entry
                List<JSONParserQBOJournalFlow.cls_Line> allEntries          = new List<JSONParserQBOJournalFlow.cls_Line>();
                Map<String, JSONParserQBOJournalFlow.cls_Line> lineValueMap = new Map<String, JSONParserQBOJournalFlow.cls_Line>();

                Integer size = parsedResults.QueryResponse.JournalEntry.size();

                for (Integer x = 0; x < size; x++) {
                    allEntries.addAll(parsedResults.QueryResponse.JournalEntry[x].Line);
                }

                // extract the highest value journal entry for each of the relevant journal codes in the set above
                for (JSONParserQBOJournalFlow.cls_Line entryLine : allEntries) {
                    if (journalDateMap.containsKey(entryLine.JournalEntryLineDetail.AccountRef.name) &&
                            !entryLine.Description.contains('Paycheck')) {
                        if (!lineValueMap.containsKey(entryLine.JournalEntryLineDetail.AccountRef.name)) {
                            lineValueMap.put(entryLine.JournalEntryLineDetail.AccountRef.name, entryLine);
                        } else if (entryLine.Amount > lineValueMap.get(entryLine.JournalEntryLineDetail.AccountRef.name).Amount) {
                            lineValueMap.put(entryLine.JournalEntryLineDetail.AccountRef.name, entryLine);
                        }
                    }
                }

                for (JSONParserQBOJournalFlow.cls_Line entryLine : lineValueMap.values()) {

                    String accountRef = entryLine.JournalEntryLineDetail.AccountRef.name;
                    Date insertDate = Date.newInstance(Date.today().year(), Date.today().month(), 5).addDays(journalDateMap.get(accountRef));

                    while (!flowMap.containsKey(insertDate)) {
                        insertDate = insertDate.addMonths(1);
                    }

                    while (flowMap.containsKey(insertDate)) {

                        String payrollId = entryLine.JournalEntryLineDetail.AccountRef.name + insertDate.year() + insertDate.month();

                        if (!paidEntries.contains(payrollId)) {

                            Decimal amount          = entryLine.Amount;
                            Boolean amountAdjusted  = false;
                            Boolean dateAdjusted    = false;
                            String dateDetail       = 'System generated date \n';
                            String amountDetail     = 'System generated amount';

                            if (amountAdjustmentsMap.containsKey(payrollId)){
                                amount          = amountAdjustmentsMap.get(payrollId);
                                amountDetail    = 'Custom amount manually specified';
                                amountAdjusted  = true;
                            }

                            if (adjustmentsMap.containsKey(payrollId)){
                                insertDate      = adjustmentsMap.get(payrollId);
                                dateDetail      = 'Custom date manually specified \n';
                                dateAdjusted    = true;
                            }

                            flowMap.get(insertDate).Out__c += entryLine.Amount;
                            newEntries.add(new CashFlowEntry__c(
                                    OutFlow__c      = flowMap.get(insertDate).Id,
                                    Source__c       = 'Overheads',
                                    Category__c     = 'Payroll / pension',
                                    QuickbooksId__c = payrollId,
                                    Description__c  = 'Salaries: ' + entryLine.JournalEntryLineDetail.AccountRef.name,
                                    Details__c      = dateDetail + amountDetail,
                                    Amount__c       = amount,
                                    Adjusted__c     = dateAdjusted,
                                    AmountAdjusted__c = amountAdjusted));

                        }

                        insertDate = insertDate.addMonths(1);

                    }
                }
            }
        }

        ////////////// STEP 7 - ADDING DIVIDEND INFORMATION FROM QUICKBOOKS
        String dividendDateValue = String.valueOf(Date.today().addDays(-35)).substring(0, 10);

        String query6 = 'query?query=select%20%2a%20from%20journalentry%20where%20docNumber%' +
                '20Like%20%27%25dividend%25%27%20and%20TxnDate%20%3e%20%27' + dividendDateValue + '%27&minorversion=4';

        // do callout
        Http http6 = new http();
        HttpRequest request6 = CashFlowUtils.doCallout(query6);
        HttpResponse response6 = http5.send(request6);

        if (response5.getStatusCode() == 200) {
            JSONParserQBOJournalFlow parsedResults = JSONParserQBOJournalFlow.parse(response6.getBody());

            if (parsedResults.QueryResponse != null && parsedResults.QueryResponse.JournalEntry != null) {

                List<JSONParserQBOJournalFlow.cls_Line> entryLines = new List<JSONParserQBOJournalFlow.cls_Line>();

                Integer size = parsedResults.QueryResponse.JournalEntry.size();

                for (Integer x = 0; x < size; x++) {
                    entryLines.addAll(parsedResults.QueryResponse.JournalEntry[x].Line);
                }

                for (JSONParserQBOJournalFlow.cls_Line entryLine : entryLines) {

                    Date insertDate = Date.newInstance(Date.today().year(), Date.today().month(), 25);

                    if (entryLine.JournalEntryLineDetail.AccountRef.name == '1200 Bank Current Account') {

                        while (!flowMap.containsKey(insertDate)) {
                            insertDate = insertDate.addMonths(1);
                        }

                        while (flowMap.containsKey(insertDate)) {

                            String dividendId = entryLine.JournalEntryLineDetail.AccountRef.name + insertDate.year() + insertDate.month();

                            if (!paidEntries.contains(dividendId)){

                                Decimal amount          = entryLine.Amount;
                                Boolean amountAdjusted  = false;
                                Boolean dateAdjusted    = false;
                                String dateDetail       = 'System generated date \n';
                                String amountDetail     = 'System generated amount';

                                if (amountAdjustmentsMap.containsKey(dividendId)){
                                    amount          = amountAdjustmentsMap.get(dividendId);
                                    amountDetail    = 'Custom amount manually specified';
                                    amountAdjusted  = true;
                                }

                                if (adjustmentsMap.containsKey(dividendId)){
                                    insertDate      = adjustmentsMap.get(dividendId);
                                    dateDetail      = 'Custom date manually specified \n';
                                    dateAdjusted    = true;
                                }

                                flowMap.get(insertDate).Out__c += entryLine.Amount;
                                newEntries.add(new CashFlowEntry__c(
                                        OutFlow__c      = flowMap.get(insertDate).Id,
                                        Source__c       = 'Overheads',
                                        Category__c     = 'Management fees',
                                        QuickbooksId__c = dividendId,
                                        Description__c  = 'Dividend: Management fee',
                                        Details__c      = dateDetail + amountDetail,
                                        Amount__c       = amount,
                                        AmountAdjusted__c = amountAdjusted,
                                        Adjusted__c     = amountAdjusted));
                            }

                            insertDate = insertDate.addMonths(1);
                        }
                    }
                }
            }
        }

        ////////////// STEP 8 - ADDING VAT QUARTERLY PAYMENTS
        Set<Integer> vatMonths = new Set<Integer>{2, 5, 8, 11};
        Date vatCalcDate = Date.today().toStartOfMonth().addDays(10);

        if (vatCalcDate < Date.today()) {
            vatCalcDate = vatCalcDate.addMonths(1);
        }

        while (!vatMonths.contains(vatCalcDate.month())){
            vatCalcDate = vatCalcDate.addMonths(1);
        }

        while (flowMap.containsKey(vatCalcDate)){

            // set the Id for the cashflow entry
            String vatID = 'VAT' + vatCalcDate.year() + vatCalcDate.month();

            // establish that the entry has not been marked as paid
            if (!paidEntries.contains(vatID)){

                Decimal vatAmount       = 0;
                Date flowDate           = vatCalcDate;
                String dateDetail       = 'System generated date \n';
                String amountDetail     = 'System generated amount';
                Boolean amountAdjusted  = false;
                Boolean dateAdjusted    = false;

                // determime if the amount has been manually adjusted
                if (amountAdjustmentsMap.containsKey(vatID)){
                    vatAmount       = amountAdjustmentsMap.get(vatID);
                    amountDetail    = 'Custom amount manually specified';
                    amountAdjusted  = true;
                } else {
                    Date vatStart   = vatCalcDate.toStartOfMonth().addMonths(-4);
                    Date vatEnd     = vatCalcDate.toStartOfMonth().addMonths(-1).addDays(-1);
                    vatAmount       = CashFlowUtils.calculateVAT(vatStart, vatEnd);
                }

                // determine if the entry has been given a custom date
                if (adjustmentsMap.containsKey(vatID)){
                    flowDate     = adjustmentsMap.get(vatID);
                    dateDetail   = 'Custom date manually specified \n';
                    dateAdjusted = true;
                }

                flowMap.get(flowDate).Out__c += vatAmount;
                newEntries.add(new CashFlowEntry__c(
                        OutFlow__c      = flowMap.get(flowDate).Id,
                        QuickbooksId__c = vatID,
                        Source__c       = 'Overheads',
                        Category__c     = 'VAT',
                        Description__c  = 'VAT quarterly payment',
                        Details__c      = dateDetail + amountDetail,
                        Amount__c       = vatAmount,
                        Adjusted__c     = dateAdjusted,
                        AmountAdjusted__c = amountAdjusted
                ));
            }
            vatCalcDate = vatCalcDate.addMonths(3);
        }

        ////////////// STEP 9 - ADDING PIPELINE REVENUE AND COST OF SALES
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

            Decimal amountAdded = 0;

            Decimal inAmount = (((opp.Amount_Calder__c * (opp.Probability / 100)) * 1.2) / 2).setScale(2);
            Decimal outAmount = (((opp.Filtered_Cost_of_Sale__c * (opp.Probability / 100)) * 1.2) / 2).setScale(2);
            Date inDate = (opp.Event_end__c < Date.today().addDays(45)) ?
                    Date.today().addDays(45) : opp.Event_end__c;

            for (Integer x = 0; x < 2; x++) {
                if (x > 0){
                    inDate = inDate.addDays(30);
                }

                if (flowMap.containsKey(inDate)) {
                    amountAdded += inAmount;
                    flowMap.get(inDate).InPlus__c += inAmount;
                    newEntries.add(new CashFlowEntry__c(
                            InFlow__c       = flowMap.get(inDate).Id,
                            Source__c       = 'SalesforceP',
                            Category__c     = opp.Account.Name,
                            Description__c  = 'Prob. ' + opp.Probability + '% : ' + opp.Name + ' Inv. ' + (x + 1),
                            Details__c      = 'System generated payment date using weighted amount \n' +
                                              'Last activity by ' + opp.LastModifiedBy.Name + ' ' +
                                              Date.valueOf(opp.LastModifiedDate).daysBetween(Date.today()) + ' days ago',
                            Amount__c       = inAmount));
                }

                if (flowMap.containsKey(inDate.toStartOfWeek().addDays(3)) && outAmount > 0) {

                    Date ouDate = inDate.toStartOfWeek().addDays(3);
                    flowMap.get(ouDate).OutPlus__c += outAmount;

                    if (pipelineCosEntries.containsKey(ouDate)) {
                        pipelineCosEntries.get(ouDate).Amount__c += outAmount;
                        pipelineCosEntries.get(ouDate).Details__c += '£' + outAmount +
                                ': Prob. ' + opp.Probability + '%: ' + opp.Name + '\n' ;
                    } else {
                        pipelineCosEntries.put(ouDate, new CashFlowEntry__c(
                                OutFlow__c      = flowMap.get(ouDate).Id,
                                Source__c       = 'SalesforceP',
                                Category__c     = 'Payment run',
                                Description__c  = 'Pipeline COS provision',
                                Details__c      = 'System generated payment run entry using weighted cost of sales: \n' +
                                                  '£' + outAmount + ': Prob. ' + opp.Probability + '%: ' + opp.Name + '\n' ,
                                Amount__c       = outAmount));
                    }
                }
            }
        }

        newEntries.addAll(pipelineCosEntries.values());

        ////////////// STEP 10 - ADDING PREDICTIVE FIGURES - USE AVERAGES FROM PRIOR YEARS OF UNKNOWN REVENUE
        Map<Date, List<Opportunity>> unknowOpportunitiesByDates = CashFlowUtils.getPedictiveCashFlow();

        Map<Date, CashFlowEntry__c> predictiveRevenueEntries    = new Map<Date, CashFlowEntry__c>();
        Map<Date, CashFlowEntry__c> predictiveCOSEntries        = new Map<Date, CashFlowEntry__c>();

        for (Date predictiveDate : unknowOpportunitiesByDates.keySet()){

            if (flowMap.containsKey(predictiveDate)){

                for (Opportunity opp : unknowOpportunitiesByDates.get(predictiveDate)){
                    Decimal inAmount  = ((opp.Amount_Calder__c / 2) * 1.2).setScale(2);
                    Decimal outAmount = ((opp.Filtered_Cost_of_Sale__c / 2) * 1.2).setScale(2);

                    flowMap.get(predictiveDate).InPredict__c    += inAmount;
                    flowMap.get(predictiveDate).OutPredict__c   += outAmount;

                    String description = (opp.Account.MostRecentOpportunity__c > Date.today().addMonths(-12)) ?
                         'Active ' : 'Inactive ';

                    if (opp.Amount_Calder__c > 0) {
                        if (predictiveRevenueEntries.containsKey(predictiveDate)) {
                            predictiveRevenueEntries.get(predictiveDate).Amount__c += inAmount;
                            predictiveRevenueEntries.get(predictiveDate).Details__c += description
                                    + 'precedent: ' + opp.Account.Name + ' ' + opp.Filtered_Job_Number__c + ' £'
                                    + inAmount + '\n';
                        } else {
                            predictiveRevenueEntries.put(predictiveDate, new CashFlowEntry__c(
                                    InFlow__c       = flowMap.get(predictiveDate).Id,
                                    Source__c       = 'Predictive',
                                    Category__c     = 'Predictive Revenue',
                                    Description__c  = 'Predictive revenue',
                                    Details__c      = description + 'precedent: ' + opp.Account.Name + ' ' +
                                                        opp.Filtered_Job_Number__c + ' £' + inAmount + '\n',
                                    Amount__c       = inAmount));
                        }
                    }

                    if (opp.Filtered_Cost_of_Sale__c > 0) {
                        if (predictiveCOSEntries.containsKey(predictiveDate)) {
                            predictiveCOSEntries.get(predictiveDate).Amount__c += outAmount;
                            predictiveCOSEntries.get(predictiveDate).Details__c += description
                                    + 'precedent: ' + opp.Account.Name + ' ' + opp.Filtered_Job_Number__c + ' £'
                                    + outAmount + '\n';
                        } else {
                            predictiveCOSEntries.put(predictiveDate, new CashFlowEntry__c(
                                    OutFlow__c      = flowMap.get(predictiveDate).Id,
                                    Source__c       = 'Predictive',
                                    Category__c     = 'Payment run',
                                    Description__c  = 'Predictive COS provision',
                                    Details__c      = description + 'precedent: ' + opp.Account.Name + ' ' +
                                                        opp.Filtered_Job_Number__c + ' £' + outAmount + '\n',
                                    Amount__c       = outAmount));
                        }
                    }
                }
            }
        }

        newEntries.addAll(predictiveRevenueEntries.values());
        newEntries.addAll(predictiveCOSEntries.values());

        ////////////// STEP 11 - RECALCULATE BALANCES AND ADD OVERHEAD AMOUNTS TO THE 1ST OF EACH MONTH
        Decimal balance         = 0;
        Decimal balancePlus     = 0;
        Decimal balancePredict  = 0;

        for (CashFlow__c flow : flowMap.values()) {
            balance             += (flow.In__c - flow.Out__c);
            balancePlus         += (flow.In__c + flow.InPlus__c - flow.Out__c - flow.OutPlus__c);
            balancePredict      += (flow.In__c + flow.InPlus__c + flow.InPredict__c - flow.Out__c - flow.OutPlus__c - flow.OutPredict__c);
            flow.Balance__c     = balance;
            flow.BalancePlus__c = balancePlus;
            flow.BalancePredict__c = balancePredict;

            if (flow.Date__c.day() == Date.daysInMonth(flow.Date__c.year(), flow.Date__c.month()) &&
                    monthlyOverheads.containsKey(flow.Date__c.month())) {
                flow.Overhead__c = monthlyOverheads.get(flow.Date__c.month());
            }
        }

        delete entriesToDelete;

        insert newEntries;

        update flowMap.values();

        upsert supplierProfilesMap.values();
    }
}