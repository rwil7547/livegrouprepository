/**
 * Created by Ronan Williams on 05/03/2019.
 */

public class InsightsController {

    private static Map<String,List<Decimal>> buildMap(String start, String endD){

        Date startDate      = Date.valueOf(start);
        Date endDate        = Date.valueOf(endD);
        Map<Integer,String> monthsMap = new Map<Integer,String>{
                1 => 'Jan',2 => 'Feb',3 => 'Mar',4 => 'Apr',5 => 'May',6 => 'Jun',
                7 => 'Jul',8 => 'Aug',9 => 'Sep',10 => 'Oct',11 => 'Nov',12 => 'Dec'
        };


        Map<String,List<Decimal>> objectAggregates = new Map<String,List<Decimal>>();
        Date incrementDate  = startDate;
        List<String> months = new List<String>();

        while (incrementDate < endDate.addMonths(1).toStartOfMonth().addDays(-1)){

            objectAggregates.put(monthsMap.get(incrementDate.month()) + ' ' +
                    incrementDate.year(), new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0,0});
            months.add(monthsMap.get(incrementDate.month()) + ' ' +
                    incrementDate.year());
            incrementDate = incrementDate.addMonths(1);
        }

        return objectAggregates;
    }

    @RemoteAction
    public static Map<Date, List<Object>> getBalances(String start, String endD){

        Date startDate      = Date.valueOf(start);
        Date endDate        = Date.valueOf(endD);
        Map<Date, List<Object>> balanceMap = new Map<Date, List<Object>>();
        Date iterator = startDate;

        // populate object map with blank values
        while (iterator <= endDate){
            balanceMap.put(iterator, new List<Object>{'',null,null,null,null});
            iterator = iterator.addDays(1);
        }

        // add any historical balances which fit in the date range
        for (QBBalance__c b : [SELECT Date__c, DayMonthYear__c, Confirmed__c, Weighted__c,
                Predictive__c
        FROM QBBalance__c
        WHERE Date__c >= :startDate
        AND Date__c <= :endDate
        ORDER BY Date__c ASC]){

            balanceMap.get(b.Date__c)[0] = b.DayMonthYear__c;
            balanceMap.get(b.Date__c)[1] = b.Confirmed__c;
            balanceMap.get(b.Date__c)[2] = 0;
            balanceMap.get(b.Date__c)[3] = 0;
            balanceMap.get(b.Date__c)[4] = 0;
        }

        // add any forecast balances which fit in the date range
        for (CashFlow__c c : [SELECT Date__c, DayMonthYear__c, Balance__c, BalancePlus__c,
                                        BalancePredict__c
                                FROM CashFlow__c
                                WHERE Date__c >= :startDate
                                AND Date__c <= :endDate]){

            balanceMap.get(c.Date__c)[0] = c.DayMonthYear__c;
            balanceMap.get(c.Date__c)[1] = c.Date__c == Date.today().addDays(-1) ? c.Balance__c : 0;
            balanceMap.get(c.Date__c)[2] = c.Balance__c;
            balanceMap.get(c.Date__c)[3] = c.BalancePlus__c;
            balanceMap.get(c.Date__c)[4] = c.BalancePredict__c;

        }

        return balanceMap;
    }

    @RemoteAction
    public static Map<String,Object> getOppRecords(String start, String endD){

        Date startDate      = Date.valueOf(start);
        Date endDate        = Date.valueOf(endD);

        // declare map to host response data
        Map<String,Object> figuresMap                   = new Map<String,Object>();

        // declare variables to host response map data keys and values
        Map<String,List<Decimal>> revenueAggregates         = buildMap(start,endD);
        Map<String,List<Decimal>> profitAggregates          = buildMap(start,endD);
        Map<String,List<Decimal>> opexAggregates            = buildMap(start,endD);
        Map<String,List<Decimal>> netProfitAggregates       = buildMap(start,endD);
        Map<String,List<Decimal>> qbRevenueAggregates       = buildMap(start,endD);
        Map<String,List<Decimal>> qbCOSAggregates           = buildMap(start,endD);
        Map<String,List<Decimal>> qbOpexAggregates          = buildMap(start,endD);
        Map<String,List<Decimal>> budgetRevenueAggregates   = buildMap(start,endD);
        Map<String,List<Decimal>> budgetCOSAggregates       = buildMap(start,endD);
        Map<String,List<Decimal>> budgetOpexAggregates      = buildMap(start,endD);
        Map<String,Map<String,List<Object>>> reportData     = new Map<String,Map<String,List<Object>>>();
        Map<String,Map<String,Decimal>> reportValues        = new Map<String,Map<String,Decimal>>();
        Map<String,Map<String,List<Decimal>>> qbValues      = new Map<String,Map<String,List<Decimal>>>();
        Set<String> nominalStrings                          = new Set<String>();

        // declare variables to hold all totals figures
        Map<String,Decimal> totals  = new Map<String,Decimal>();
        Decimal totalRevenue        = 0;
        Decimal totalProfit         = 0;
        Decimal totalOpex           = 0;
        Decimal totalqbRevenue      = 0;
        Decimal totalqbCOS          = 0;
        Decimal totalqbOpex         = 0;
        Decimal totalBudgetRevenue  = 0;
        Decimal totalBudgetCOS      = 0;
        Decimal totalBudgetOpex     = 0;


        Map<String,List<Decimal>> totalsMap  = new Map<String,List<Decimal>>();
        List<Decimal> revenueTotals          = new List<Decimal>{0,0,0,0};
        List<Decimal> cosTotals              = new List<Decimal>{0,0,0,0};
        List<Decimal> profitTotals           = new List<Decimal>{0,0,0,0};
        List<Decimal> opexTotals             = new List<Decimal>{0,0,0,0};

        // work out if start date and end date are not clean start and end dates
        Decimal numberOfDaysStart   = Date.daysInMonth(startDate.year(), startDate.month());
        Decimal daysMissing         = startDate.day() - 1;
        Decimal startPortion        = (numberOfDaysStart - daysMissing) / numberOfDaysStart;

        Decimal numberOfDaysEnd     = Date.daysInMonth(endDate.year(), endDate.month());
        Decimal dayCountEnd         = endDate.day();
        Decimal endPortion          = (numberOfDaysEnd - (numberOfDaysEnd - dayCountEnd)) / numberOfDaysEnd;

        List<String> months = new List<String>();
        months.addAll(revenueAggregates.keySet());

        for (String month : months){

            Map<String,List<Object>> stageMap = new Map<String,List<Object>>{
                    'Closed Won'        => new List<Object>(),
                    'Costed prospect'   => new List<Object>(),
                    'Pipeline prospect' => new List<Object>(),
                    'Repeat Prospect'   => new List<Object>()
            };
            reportData.put(month, stageMap);

            Map<String,Decimal> stageValueMap = new Map<String,Decimal>{
                    'Closed Won Revenue'        => 0, 'Closed Won COS'         => 0,
                    'Costed prospect Revenue'   => 0, 'Costed prospect COS'    => 0,
                    'Pipeline prospect Revenue' => 0, 'Pipeline prospect COS'  => 0,
                    'Repeat Prospect Revenue'   => 0, 'Repeat Prospect COS'    => 0,
                    'Adjustment Revenue'        => 0, 'Adjustment Profit'      => 0,
                    'Adjustment COS'            => 0
            };
            reportValues.put(month, stageValueMap);
        }

        // get all committed opp data
        for (Opportunity opp : [SELECT Amount_Calder__c, Probability, StageName, Name, Account.Name,
                                        Event_start__c, Event_end__c, Filtered_Cost_of_Sale__c,
                                        Gross_Margin__c, Quote_Status__c, Filtered_Job_Number__c,
                                        EventMonthYear__c, Committed__c, CommittedRevenue__c,
                                        CommittedProfit__c, CommittedCOS__c, IsClosed, Amount_Paid__c, Amount_Invoiced2__c,
                                        Gross_profit_2__c, Event_End_Grouping__c, COSRemaining__c, Quickbooks_COS__c,
                                        Quickbooks_COS_Paid__c, Calder_Opportunity__c,
                                        EventMonthString__c, Owner.FirstName, Owner.LastName, Owner.ImageLink__c,
                                        Project_Manager__c, Project_Manager__r.ImageLink__c,
                                        Project_Manager__r.FirstName, Project_Manager__r.LastName, RecStatus__c,
                                        CreatedDate, LastModifiedDate,
                                        (SELECT Revenue__c, Profit__c, CostOfSale__c, EventMonthYear__c, Month__c
                                        FROM Adjustments__r)
                                FROM Opportunity
                                WHERE StageName != 'Closed Lost'
                                AND Event_start__c != NULL
                                AND Event_end__c != NULL
                                AND Event_end__c >= :startDate
                                AND Event_end__c <= :endDate]){

            reportData.get(opp.EventMonthYear__c).get(opp.StageName).add(opp);

            if (opp.Committed__c){
                totalRevenue += opp.CommittedRevenue__c;
                totalProfit += opp.CommittedProfit__c;

                revenueTotals[0]    += opp.CommittedRevenue__c;
                cosTotals[0]        += opp.CommittedCOS__c;
                profitTotals[0]     += opp.CommittedProfit__c;

                revenueAggregates.get(opp.EventMonthYear__c)[0] += opp.CommittedRevenue__c;
                profitAggregates.get(opp.EventMonthYear__c)[0] += opp.CommittedProfit__c;
                reportValues.get(opp.EventMonthYear__c).put(opp.StageName + ' Revenue',
                        reportValues.get(opp.EventMonthYear__c).get(opp.StageName + ' Revenue') + opp.CommittedRevenue__c);
                reportValues.get(opp.EventMonthYear__c).put(opp.StageName + ' COS',
                        reportValues.get(opp.EventMonthYear__c).get(opp.StageName + ' COS') + opp.CommittedCOS__c);
            } else {
                if (opp.StageName == 'Closed Won') {
                    totalRevenue += opp.Amount_Calder__c;
                    totalProfit += (opp.Gross_profit_2__c == null) ? 0 : opp.Gross_profit_2__c;

                    revenueTotals[0]    += opp.Amount_Calder__c;
                    cosTotals[0]        += opp.Filtered_Cost_of_Sale__c;
                    profitTotals[0]     += opp.Gross_profit_2__c;

                    revenueAggregates.get(opp.EventMonthYear__c)[0] += opp.Amount_Calder__c;
                    profitAggregates.get(opp.EventMonthYear__c)[0] += (opp.Gross_profit_2__c == null) ? 0 : opp.Gross_profit_2__c;
                } else {
                    if (opp.StageName == 'Costed prospect'){
                        revenueTotals[1]    += opp.Amount_Calder__c;
                        cosTotals[1]        += opp.Filtered_Cost_of_Sale__c;
                        profitTotals[1]     += opp.Gross_profit_2__c;
                    } else if (opp.StageName == 'Pipeline prospect'){
                        revenueTotals[2]    += opp.Amount_Calder__c;
                        cosTotals[2]        += opp.Filtered_Cost_of_Sale__c;
                        profitTotals[2]     += opp.Gross_profit_2__c;
                    } else if (opp.StageName == 'Repeat Prospect'){
                        revenueTotals[3]    += opp.Amount_Calder__c;
                        cosTotals[3]        += opp.Filtered_Cost_of_Sale__c;
                        profitTotals[3]     += opp.Gross_profit_2__c;
                    }
                    revenueAggregates.get(opp.EventMonthYear__c)[1] += (opp.Amount_Calder__c * opp.Probability) / 100;
                    profitAggregates.get(opp.EventMonthYear__c)[1] += (opp.Gross_profit_2__c * opp.Probability) / 100;
                    revenueAggregates.get(opp.EventMonthYear__c)[2] += opp.Amount_Calder__c - (opp.Amount_Calder__c * opp.Probability) / 100;
                    profitAggregates.get(opp.EventMonthYear__c)[2] += opp.Gross_profit_2__c - (opp.Gross_profit_2__c * opp.Probability) / 100;
                }
                if (opp.Amount_Calder__c != null){
                    reportValues.get(opp.EventMonthYear__c).put(opp.StageName + ' Revenue',
                            reportValues.get(opp.EventMonthYear__c).get(opp.StageName + ' Revenue') + opp.Amount_Calder__c);
                }
                if (opp.Filtered_Cost_of_Sale__c != null){
                    reportValues.get(opp.EventMonthYear__c).put(opp.StageName + ' COS',
                            reportValues.get(opp.EventMonthYear__c).get(opp.StageName + ' COS') + opp.Filtered_Cost_of_Sale__c);
                }
            }
        }

        for (Adjustment__c adj : [SELECT Revenue__c, Profit__c, CostOfSale__c, CreatedDate, CreatedBy.Name,
                                         EventMonthYear__c, Opportunity__r.Name, Opportunity__r.Filtered_Job_Number__c,
                                         Opportunity__c, Opportunity__r.EventMonthYear__c, Opportunity__r.Account.Name
                                    FROM Adjustment__c
                                    WHERE Month__c >= :startDate
                                    AND Month__c <= :endDate
                                    ORDER BY Opportunity__r.Event_end__c]) {

            reportData.get(adj.EventMonthYear__c).get('Closed Won').add(adj);

            totalRevenue    += adj.Revenue__c;
            totalProfit     += adj.Profit__c;
            revenueAggregates.get(adj.EventMonthYear__c)[0] += adj.Revenue__c;
            profitAggregates.get(adj.EventMonthYear__c)[0] += adj.Profit__c;

            reportValues.get(adj.EventMonthYear__c).put('Adjustment Revenue',
                    reportValues.get(adj.EventMonthYear__c).get('Adjustment Profit') + adj.Revenue__c);
            reportValues.get(adj.EventMonthYear__c).put('Adjustment Profit',
                    reportValues.get(adj.EventMonthYear__c).get('Adjustment Profit') + adj.Profit__c);
            reportValues.get(adj.EventMonthYear__c).put('Adjustment COS',
                    reportValues.get(adj.EventMonthYear__c).get('Adjustment COS') + adj.CostOfSale__c);
        }

        List<QBProfitAndLoss__c> results = [SELECT Actual__c, Parent__c, Budget__c, Grouping__c,
                                                    Month__c, EventMonthYear__c, QBUpdated__c, Opex__c
                                            FROM QBProfitAndLoss__c
                                            WHERE Month__c >= :startDate.toStartOfMonth()
                                            AND Month__c <= :endDate
                                            ORDER BY Month__c DESC];

        for (QBProfitAndLoss__c qpl : results) {

            nominalStrings.add(qpl.Parent__c);
            Decimal multiplier = 1;

            if (qpl.Month__c.month() == startDate.month()) {
                multiplier = startPortion;
            } else if (qpl.Month__c.month() == endDate.month()) {
                multiplier = endPortion;
            }

            if (qpl.Opex__c){

                totalOpex       += (qpl.Actual__c * multiplier);
                totalqbOpex     += (qpl.Actual__c * multiplier);
                totalBudgetOpex += (qpl.Budget__c * multiplier);
                opexAggregates.get(qpl.EventMonthYear__c)[1]        += (qpl.Actual__c * multiplier);
                opexAggregates.get(qpl.EventMonthYear__c)[2]        += (qpl.Budget__c * multiplier);
                profitAggregates.get(qpl.EventMonthYear__c)[3]      += (qpl.Actual__c * multiplier);

                if (qpl.Grouping__c == 'Payroll'){
                    opexAggregates.get(qpl.EventMonthYear__c)[6]    += (qpl.Actual__c * multiplier);
                } else if (qpl.Grouping__c == 'IT'){
                    opexAggregates.get(qpl.EventMonthYear__c)[7]    += (qpl.Actual__c * multiplier);
                } else if (qpl.Grouping__c == 'Bus Dev'){
                    opexAggregates.get(qpl.EventMonthYear__c)[8]    += (qpl.Actual__c * multiplier);
                } else if (qpl.Grouping__c == 'Office' || qpl.Grouping__c == 'Other'){
                    opexAggregates.get(qpl.EventMonthYear__c)[9]    += (qpl.Actual__c * multiplier);
                }
                qbOpexAggregates.get(qpl.EventMonthYear__c)[0]      += (qpl.Actual__c * multiplier);
                budgetOpexAggregates.get(qpl.EventMonthYear__c)[0]  += (qpl.Budget__c * multiplier);

            } else if (qpl.Parent__c == 'Revenue'){
                totalqbRevenue      += (qpl.Actual__c * multiplier);
                totalBudgetRevenue  += (qpl.Budget__c * multiplier);
                revenueAggregates.get(qpl.EventMonthYear__c)[3]         = (qpl.Actual__c * multiplier);
                qbRevenueAggregates.get(qpl.EventMonthYear__c)[0]      += (qpl.Actual__c * multiplier);
                budgetRevenueAggregates.get(qpl.EventMonthYear__c)[0]  += (qpl.Budget__c * multiplier);

            } else if (qpl.Parent__c == 'Cost of sales'){
                totalqbCOS      += (qpl.Actual__c * multiplier);
                totalBudgetCOS  += (qpl.Budget__c * multiplier);
                qbCOSAggregates.get(qpl.EventMonthYear__c)[0]      += (qpl.Actual__c * multiplier);
                budgetCOSAggregates.get(qpl.EventMonthYear__c)[0]  += (qpl.Budget__c * multiplier);
            }
        }

        for (Integer x = 0; x < months.size(); x++){
            netProfitAggregates.get(months[x])[0] = (profitAggregates.get(months[x])[0] - opexAggregates.get(months[x])[1]);
            netProfitAggregates.get(months[x])[1] = (profitAggregates.get(months[x])[1]);
            netProfitAggregates.get(months[x])[2] = (profitAggregates.get(months[x])[2]);
        }


        totalsMap.put('revenue', revenueTotals);
        totalsMap.put('cos', cosTotals);
        totalsMap.put('profit', profitTotals);
        totalsMap.put('opex', opexTotals);


        totals.put('revenue', totalRevenue);
        totals.put('profit', totalProfit);
        totals.put('opex', totalOpex);
        totals.put('netProfit', totalProfit - totalOpex);
        totals.put('qbRevenue', totalqbRevenue);
        totals.put('qbCOS', totalqbCOS);
        totals.put('qbOpex', totalqbOpex);
        totals.put('budgetRevenue', totalBudgetRevenue);
        totals.put('budgetCOS', totalBudgetCOS);
        totals.put('budgetOpex', totalBudgetOpex);

        for (String month : reportValues.keySet()){
            reportValues.get(month).put('Closed Won Profit',
                    (reportValues.get(month).get('Closed Won Revenue' ) - reportValues.get(month).get('Closed Won COS')));
            reportValues.get(month).put('Costed prospect Profit',
                    (reportValues.get(month).get('Costed prospect Revenue' ) - reportValues.get(month).get('Costed prospect COS')));
            reportValues.get(month).put('Pipeline prospect Profit',
                    (reportValues.get(month).get('Pipeline prospect Revenue' ) - reportValues.get(month).get('Pipeline prospect COS')));
            reportValues.get(month).put('Repeat Prospect Profit',
                    (reportValues.get(month).get('Repeat Prospect Revenue' ) - reportValues.get(month).get('Repeat Prospect COS')));
        }

        qbValues.put('qbRevenue',qbRevenueAggregates);
        qbValues.put('qbCOS',qbCOSAggregates);
        qbValues.put('qbOpex',qbOpexAggregates);
        qbValues.put('budgetRevenue',budgetRevenueAggregates);
        qbValues.put('budgetCOS',budgetCOSAggregates);
        qbValues.put('budgetOpex',budgetOpexAggregates);


        // POPULATE FINAL RESPONSE Mp
        figuresMap.put('TOTALSMAP',totalsMap);
        figuresMap.put('revenue',revenueAggregates);
        figuresMap.put('profit',profitAggregates);
        figuresMap.put('opex',opexAggregates);
        figuresMap.put('netProfit',netProfitAggregates);

        figuresMap.put('TOTALS',totals);
        figuresMap.put('REPORTDATA',reportData);
        figuresMap.put('REPORTVALUES',reportValues);
        figuresMap.put('MONTHS',months);

        figuresMap.put('QUICKBOOKSFIGURES',qbValues);
        figuresMap.put('qbRevenue',revenueAggregates);
        figuresMap.put('qbProfit',profitAggregates);

        figuresMap.put('QBCLOSE',QBClosedMonth__c.getInstance('QBClosedMonth'));
        figuresMap.put('SFCOMMIT',QBClosedMonth__c.getInstance('SFCommitMonth'));
        figuresMap.put('NOMINALSTRINGS',nominalStrings);

        List<SalesDashboardSnapshot__c> priorSnaps =
                                        [SELECT TotalRevenue__c, TotalGrossProfit__c, TotalOpex__c,
                                                TotalNetProfit__c, CreatedDate, Age__c
                                        FROM SalesDashboardSnapshot__c
                                        WHERE PeriodEnd__c = :Date.valueOf(endDate)
                                        AND TotalRevenue__c != NULL
                                        ORDER BY CreatedDate DESC];

        if (!priorSnaps.isEmpty()){
            figuresMap.put('SNAPSHOTS',priorSnaps);
        }

        return figuresMap;
    }


    @RemoteAction
    public static Boolean setQBSourceOptions(String budgetId, String forecastId, String year, String qbCloseDate,
                                             String sfCloseDate){

        QuickbooksDashboardCallout.updateOpexForecast(budgetId, forecastId, year, qbCloseDate);
        SalesDashboardUtils.commitOpportunities(Date.valueOf(sfCloseDate));

        return true;
    }

    @RemoteAction
    public static Map<String,Object> getQBSourceOptions(String year){

        String fiscalYear;

        if (year.equalsIgnoreCase('PREVIOUS FY')){
            fiscalYear = 'LAST_FISCAL_YEAR';
        } else if (year.equalsIgnoreCase('CURRENT FY')){
            fiscalYear = 'THIS_FISCAL_YEAR';
        } else if (year.equalsIgnoreCase('NEXT FY')){
            fiscalYear = 'NEXT_FISCAL_YEAR';
        }

        Map<String,Object> responseMap = new Map<String,Object>();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:QuickBooksOnline/query?query=select%20name,metadata,BudgetEntryType,StartDate,' +
                'EndDate%2c%20Id%20from%20budget&minorversion=4');
        request.setHeader('Accept', 'application/json');
        request.setMethod('GET');
        request.setTimeout(120000);
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200){
            responseMap.put('budgets', JSON.deserializeUntyped(response.getBody()));
        }

        List<QBProfitAndLoss__c> budgetSourceList =
                Database.query('SELECT BudgetSource__c, LastModifiedDate ' +
                        'FROM QBProfitAndLoss__c ' +
                        'WHERE Month__c = ' + fiscalYear  + ' ' +
                        'ORDER BY Month__c DESC LIMIT 1');

        if (!budgetSourceList.isEmpty()){
            if (budgetSourceList[0].BudgetSource__c != null){
                responseMap.put('budgetSource', budgetSourceList[0].BudgetSource__c);
            } else {
                responseMap.put('budgetSource', 'Unknown Budget');
            }

            responseMap.put('budgetUpdate', budgetSourceList[0].LastModifiedDate);
        }

        List<QBProfitAndLoss__c> forecastSourceList =
                Database.query('SELECT ForecastSource__c, LastModifiedDate ' +
                        'FROM QBProfitAndLoss__c ' +
                        'WHERE Month__c = ' + fiscalYear  + ' ' +
                        'ORDER BY Month__c DESC LIMIT 1');

        if (!forecastSourceList.isEmpty()){
            if (forecastSourceList[0].ForecastSource__c != null){
                responseMap.put('forecastSource', forecastSourceList[0].ForecastSource__c);
            } else {
                responseMap.put('forecastSource', 'Unknown Forecast');
            }
            responseMap.put('forecastUpdate', forecastSourceList[0].LastModifiedDate);
        }

        for (QBClosedMonth__c month : QBClosedMonth__c.getAll().values()){
            if (month.Name == 'QBClosedMonth'){
                responseMap.put('closedMonth', month.Month__c);
            }
        }

        return responseMap;
    }

    @RemoteAction
    public static Boolean postAdjustment(String monthDate, Decimal revenue, Decimal costOfSale,
                                         Decimal profit, String commentString){

        insert new Adjustment__c(
            Month__c        = Date.valueOf(monthDate).toStartOfMonth(),
            Revenue__c      = revenue,
            CostOfSale__c   = costOfSale,
            Profit__c       = profit,
            Comment__c      = commentString,
            Committed__c    = true
        );

        return true;
    }

    @RemoteAction
    public static Map<String,Object> changeEntryDate(String entryId, String dateString){

        Date flowDate           = Date.valueOf(dateString);
        CashFlow__c flow        = [SELECT Id, Date__c, Number__c FROM CashFlow__c WHERE Date__c = :flowDate];
        CashFlowEntry__c entry  = [SELECT Id, Description__c, BudgetKey__c, Date__c, Amount__c
                                    FROM CashFlowEntry__c WHERE Id = :entryId];

        // if the record has been moved across months, detect if budget entries need to be updated.
        Boolean monthChanged = entry.Date__c.month() != flowDate.month();

        if (monthChanged){
            // add the value of the record to the budget in the month it is being removed from
            updateBudgets(entry.Date__c,entry.BudgetKey__c,entry.Amount__c);
            // subtract the value of the record to the budget in the the month it is being removed from
            updateBudgets(flowDate,entry.BudgetKey__c, (entry.Amount__c * -1));
        }

        entry.CashFlow__c       = flow.Id;
        entry.Adjusted__c       = true;
        entry.AdjustedDate__c   = flowDate;

        update entry;

        calculateBalances();

        Map<String,Object> responseData = getCashflowData(false);

        // return the new values for the budget entries if the month has changed
        if (monthChanged){
            responseData.put('VALUES', new Map<Id,CashFlowEntry__c>(
                                        [SELECT Id,Amount__c
                                        FROM CashFlowEntry__c
                                        WHERE Id = :entryId
                                        OR (Source__c = 'Budget'
                                        AND BudgetKey__c = :entry.BudgetKey__c)]));
        }

        return responseData;

    }

    @RemoteAction
    public static Map<String,Object> updateAmount(String entryId, Decimal amount){

        CashFlowEntry__c entry = [SELECT Category__c, Amount__c, Out__c, Description__c, Source__c,
                                        CashFlow__r.DayMonthYear__c, Date__c, BudgetKey__c
                                FROM CashFlowEntry__c WHERE Id = :entryId];

        // if the entry is not a budget record, we need to return all records to the VF as changing it's value
        // will change budget record values
        Boolean returnRecords = entry.Source__c != 'Budget';

        if (returnRecords){
            updateBudgets(entry.Date__c,entry.BudgetKey__c,((amount - entry.Amount__c) * -1));
        }

        entry.Amount__c         = amount;
        entry.Adjusted__c       = true;
        entry.AmountAdjusted__c = true;

        update entry;

        calculateBalances();
        return getCashflowData(returnRecords);
    }

    @RemoteAction
    public static Map<String,Object> markAsPaid(String entryId){

        update new CashFlowEntry__c(
                Id                  = entryId,
                Paid__c             = true);
        calculateBalances();
        return getCashflowData(true);
    }

    @RemoteAction
    public static Map<String,Object> addCustomEntry(String type, String description, String budgetKey,
            Decimal amount, String dateString){

        Date flowDate       = Date.valueOf(dateString);
        CashFlow__c flow    = [SELECT Id FROM CashFlow__c WHERE Date__c = :flowDate];

        if (flow != null){
            CashFlowEntry__c customEntry    = new CashFlowEntry__c();
            customEntry.Source__c           = 'Custom';
            customEntry.Out__c              = (type != 'Revenue');
            customEntry.Category__c         = type;
            customEntry.Description__c      = description + ' (' + budgetKey + ')';
            customEntry.CashFlow__c         = flow.Id;
            customEntry.Amount__c           = amount;
            customEntry.Stage__c            = 'Confirmed';
            customEntry.BudgetKey__c        = budgetKey;
            insert customEntry;

            updateBudgets(flowDate,budgetKey,(amount * -1));

            calculateBalances();
            return getCashflowData(true);

        } else {
            return null;
        }
    }

    @RemoteAction
    public static Map<String,Object> deleteEntry(String entryId){

        CashFlowEntry__c deleteEntry = [SELECT Id, Amount__c, Date__c, BudgetKey__c
                                        FROM CashFlowEntry__c WHERE Id = :entryId];

        updateBudgets(deleteEntry.Date__c, deleteEntry.BudgetKey__c, deleteEntry.Amount__c);
        delete deleteEntry;

        calculateBalances();
        return getCashflowData(false);
    }

    @RemoteAction
    public static Boolean updateComment(String entryId, String comment){
        update new CashFlowEntry__c(
                Id          = entryId,
                Comment__c  = comment);
        return true;
    }

    @RemoteAction
    public static Boolean toggleFreelancer(String entryId){

        CashFlowEntry__c entry = [SELECT Id, Category__c, QuickbooksId__c, VendorRef__c
                                    FROM CashFlowEntry__c
                                    WHERE Id = :entryId];

        if (entry.Category__c == 'Freelancers'){
            delete [SELECT Id FROM QBSupplierProfile__c
                    WHERE SupplierId__c = :entry.VendorRef__c];
        } else {
            insert new QBSupplierProfile__c(
                    SupplierId__c   = entry.VendorRef__c,
                    Category__c     = 'Freelancers',
                    Type__c         = 'Freelancers'
            );
        }

        return true;
    }

    @RemoteAction
    public static QBSupplierProfile__c convertToDirectDebit(String vendorRef, String supplierName, String frequency,
                                                            Integer occurence, Decimal amount,
                                                            String endDate, String nominal){

        // check if there is already a supplier profile and delete if so
        delete [SELECT Id FROM QBSupplierProfile__c WHERE SupplierId__c = :vendorRef];

        // create a new supplier profile which the cashflow can use to implement the direct debits
        QBSupplierProfile__c profile = new QBSupplierProfile__c(
                SupplierId__c   = vendorRef,
                SupplierName__c = supplierName,
                Category__c     = nominal,
                Type__c         = 'DD',
                Amount__c       = amount,
                Terms__c        = frequency,
                Day__c          = occurence,
                EndDate__c      = Date.valueOf(endDate)
        );

        insert profile;
        return profile;
    }

    @RemoteAction
    public static Boolean disableDirectDebit(String supplierId){

        // remove the QB supplier profile used to calculate the direct debits
        delete [SELECT Id FROM QBSupplierProfile__c
                WHERE SupplierId__c = :supplierId
                AND Type__c = 'DD'];

        // remove the existing direct debit entries from the cashflow
        delete [SELECT Id FROM CashFlowEntry__c WHERE QuickbooksId__c = :supplierId];

        return true;
    }

    @RemoteAction
    public static Map<String,Object> rerunFlow(Boolean resetValues,Boolean resetBudgets){
        CashflowGenerator.buildFlow(resetValues, resetBudgets, null);
        return getCashflowData(true);
    }

    @RemoteAction
    public static Object getAttachmentLink(String billId){

        String attachmentQuery = 'query?query=select%20%2a%20from%20attachable%20where%20AttachableRef.EntityRef.' +
                'value%20%3d%20%27' + billId + '%27&minorversion=4';
        // do callout
        Http attachmentHttp               = new Http();
        HttpRequest attachmentRequest     = CashFlowUtils.doCallout(attachmentQuery);
        HttpResponse attachmentResponse   = attachmentHttp.send(attachmentRequest);

        return attachmentResponse.getStatusCode() == 200 ?
                JSON.deserializeUntyped(attachmentResponse.getBody()) : (Object)'error';
    }

    public static void updateBudgets(Date recordDate, String budgetKey, Decimal amount){

        Date budgetDate = recordDate.addMonths(1).toStartOfMonth().addDays(-1);

        List<CashFlowEntry__c> budgetEntries = [SELECT Id, Amount__c
                                        FROM CashFlowEntry__c
                                        WHERE Source__c = 'Budget'
                                        AND BudgetKey__c = :budgetKey
                                        AND Date__c = :budgetDate
                                        AND AmountAdjusted__c = FALSE];

        if (budgetEntries.size() == 1){
            budgetEntries[0].Amount__c += amount;
            update budgetEntries;
        }
    }

    public static void calculateBalances(){

        Decimal confirmed   = 0;
        Decimal pipeline    = 0;
        Decimal budget      = 0;

        List<CashFlow__c> flows = [SELECT Id, InConfirmed__c, InPipeline__c, InBudget__c,
                                            OutConfirmed__c, OutPipeline__c, OutBudget__c,
                                            Balance__c, BalancePlus__c, BalancePredict__c,
                                            Number__c, InDescription__c
                                    FROM CashFlow__c
                                    ORDER BY Number__c ASC];

        for (CashFlow__c flow : flows) {
            if (flow.Number__c == -1){
                confirmed   += flow.Balance__c;
            } else {
                confirmed   += (flow.InConfirmed__c - flow.OutConfirmed__c);
                pipeline    += (flow.InPipeline__c - flow.OutPipeline__c);
                budget      += (flow.InBudget__c - flow.OutBudget__c);
                flow.Balance__c         = confirmed;
                flow.BalancePlus__c     = confirmed + pipeline;
                flow.BalancePredict__c  = confirmed + pipeline + budget;
            }
        }

        update flows;
    }

    @RemoteAction
    public static Map<String,Object> getCashflowData(Boolean includeRecords){

        Map<String,Object> cashflowDataMap = new  Map<String,Object>();

        /// first - work out dates
        List<Date> dates                = new List<Date>();
        List<Decimal> figures           = new List<Decimal>();
        List<CashFlowEntry__c> records  = new List<CashFlowEntry__c>();
        List<Decimal> openingBalances   = new List<Decimal>();
        List<Decimal> closingBalances   = new List<Decimal>();
        List<Decimal> totalInflows      = new List<Decimal>();
        List<Decimal> totalOutflows     = new List<Decimal>();

        Map<String,List<Decimal>> inEntries     = new Map<String,List<Decimal>>();
        Map<String,List<Decimal>> outEntries    = new Map<String,List<Decimal>>();

        // begin payment runs on thursday
        Date entryDate = (Date.today() > Date.today().toStartOfWeek().addDays(3)) ?
                Date.today().toStartOfWeek().addDays(10) : Date.today().toStartOfWeek().addDays(3);

        for (Integer x = 0; x < 12; x++){
            if (x == 0){
                dates.add(Date.today());
            } else if (x == 1 && entryDate == Date.today()) {
                entryDate = entryDate.addDays(7);
                dates.add(entryDate);
                entryDate = entryDate.addDays(7);
            } else {
                dates.add(entryDate);
                entryDate = entryDate.addDays(7);
            }
            figures.add(0);
        }

        List<CashFlow__c> flows = [SELECT Date__c, BalancePlus__c, BalancePredict__c, Number__c
                                    FROM CashFlow__c
                                    WHERE Date__c <= :dates[11].addDays(6)
                                    ORDER BY Date__c ASC];

        Map<Date,CashFlow__c> flowMap = new Map<Date,CashFlow__c>();

        for (CashFlow__c flow : flows){
            flowMap.put(flow.Date__c, flow);
        }

        Date endDate;

        for (Integer x = 0; x < 12; x++){
            Date startDate  = Date.valueOf(dates[x]);

            if (startDate.toStartOfWeek().addDays(3) < startDate){
                endDate = startDate.toStartOfWeek().addDays(9);
            } else if (startDate.toStartOfWeek().addDays(3) > startDate) {
                endDate = startDate.toStartOfWeek().addDays(2);
            } else {
                endDate = startDate.addDays(6);
            }

            openingBalances.add(flowMap.get(startDate.addDays(-1)).BalancePredict__c);
            closingBalances.add(flowMap.get(endDate).BalancePredict__c);

            Decimal totalInflow     = 0;
            Decimal totalOutflow    = 0;

            for (CashFlow__c flow : [SELECT Date__c, InConfirmed__c, InPipeline__c, InBudget__c,
                                            OutConfirmed__c, OutPipeline__c, OutBudget__c,
                                    (SELECT Category__c, Amount__c, Out__c, Description__c, Source__c,
                                            CashFlow__r.DayMonthYear__c, QuickbooksId__c, Comment__c,
                                            TempDownloadUri__c, Details__c, VendorRef__c, BudgetKey__c,
                                            AmountAdjusted__c, HiddenBudget__c, AdjustedDate__c
                                    FROM CashFlowEntries__r
                                    WHERE Paid__c = FALSE
                                    ORDER BY CreatedDate )
                                    FROM CashFlow__c
                                    WHERE Date__c >= : startDate
                                    AND Date__c <= : endDate]){

                totalInflow += flow.InConfirmed__c + flow.InPipeline__c + flow.InBudget__c;
                totalOutflow += flow.OutConfirmed__c + flow.OutPipeline__c + flow.OutBudget__c;

                for (CashFlowEntry__c entry : flow.CashFlowEntries__r){
                    if (entry.Out__c){
                        if (!outEntries.containsKey(entry.Category__c)){
                            outEntries.put(entry.Category__c, figures.clone());
                        }
                        if (!entry.HiddenBudget__c){
                            outEntries.get(entry.Category__c)[x] += entry.Amount__c;
                        }
                        if (includeRecords){
                            entry.WeekId__c = entry.Category__c + String.valueOf(x);
                            records.add(entry);
                        }
                    } else {
                        if (!inEntries.containsKey(entry.Category__c)){
                            inEntries.put(entry.Category__c, figures.clone());
                        }
                        if (!entry.HiddenBudget__c) {
                            inEntries.get(entry.Category__c)[x] += entry.Amount__c;
                        }
                        if (includeRecords){
                            entry.WeekId__c = 'IN' + String.valueOf(x);
                            records.add(entry);
                        }
                    }
                }
            }

            totalInflows.add(totalInflow);
            totalOutflows.add(totalOutflow);
        }

        Map<String,QBSupplierProfile__c> supplierProfiles = new Map<String,QBSupplierProfile__c>();
        for (QBSupplierProfile__c profile : [SELECT Id,SupplierId__c,Category__c,Amount__c,Terms__c,Day__c,
                                                    EndDate__c,EndDateInput__c
                                             FROM QBSupplierProfile__c WHERE Type__c = 'DD']){
            supplierProfiles.put(profile.SupplierId__c, profile);
        }

        // load data map with opening balances
        cashflowDataMap.put('WEEK COMMENCING', dates);
        cashflowDataMap.put('OPENING BALANCE', openingBalances);
        cashflowDataMap.put('IN ENTRIES', inEntries);
        cashflowDataMap.put('TOTAL INFLOW', totalInflows);
        cashflowDataMap.put('OUT ENTRIES', outEntries);
        cashflowDataMap.put('TOTAL OUTFLOW', totalOutflows);
        cashflowDataMap.put('CLOSING BALANCE', closingBalances);
        cashflowDataMap.put('IN', figures.clone());
        cashflowDataMap.put('CASHFLOW', getBalances(String.valueOf(Date.today().addDays(-7)),String.valueOf(entryDate)));
        cashflowDataMap.put('CASHFLOW FULL', getBalances(String.valueOf(Date.today().addDays(-7)),String.valueOf(entryDate)));
        cashflowDataMap.put('SUPPLIER PROFILES',supplierProfiles);
        if (includeRecords) cashflowDataMap.put('RECORDS', records);

        return cashflowDataMap;

    }

    @RemoteAction
    public static Map<String,Map<String,List<Object>>> getRecordChanges(String start,
                                        String endD, Integer days, Decimal currentTotal){

//        Date startDate      = Date.valueOf(start);
//        Date endDate        = Date.valueOf(endD);
//
//        Map<String,Map<String,List<Object>>> changeMap = new Map<String,Map<String,List<Object>>>();
//
//        Map<String,String> imageMap = new Map<String,String>();
//
//        for (Employee1__c emp : [SELECT FirstName__c, LastName__c, ImageLink__c
//                                 FROM Employee1__c WHERE ImageLink__c != NULL]){
//            imageMap.put(emp.FirstName__c + emp.LastName__c, emp.ImageLink__c);
//        }
//
//        for (Integer x = 0; x < days; x++){
//            List<Object> values   = new List<Object>();
//            List<Object> records  = new List<Object>();
//            changeMap.put(String.valueOf(x), new Map<String,List<Object>>());
//            changeMap.get(String.valueOf(x)).put('VALUE',values);
//            changeMap.get(String.valueOf(x)).put('RECORDS',records);
//        }
//
//        Date fallBack = Date.valueOf(Date.today().addDays(-(days-1)));
//
//        List<SalesDashboardSnapshot__c> snapshots =
//                            [SELECT TotalGrossProfit__c, TotalRevenue__c, TotalOpex__c, TotalNetProfit__c,
//                                    DateCreated__c, CreatedDate,
//                                    CreatedBy.FirstName, CreatedBy.LastName
//                            FROM SalesDashboardSnapshot__c
//                            WHERE DateCreated__c >= :fallBack.addDays(-1)
//                            AND PeriodEnd__c <= :endDate
//                            ORDER BY CreatedDate DESC];
//
//        List<SalesDashboardSnapshot__c> snapshotsClone = snapshots.deepClone(false);
//
//        for (Integer x = 0; x < snapshots.size() - 1; x++){
//
////            if (x == 0){
////                snapshots[x].TotalGrossProfit__c = currentTotal - snapshots[x].TotalGrossProfit__c;
////            } else {
////                snapshots[x].TotalGrossProfit__c = snapshotsClone[x + 1].TotalGrossProfit__c - snapshots[x].TotalGrossProfit__c;
////            }
//
//            Decimal priorTotal = snapshots[x].TotalGrossProfit__c;
//
//            snapshots[x].TotalGrossProfit__c = currentTotal - snapshots[x].TotalGrossProfit__c;
//
//            currentTotal = priorTotal;
//
//            changeMap.get(String.valueOf(x)).get('VALUE').add(snapshots[x]);
//        }
//
//        // track date changes
//        List<OpportunityFieldHistory> dateChanges = [SELECT OpportunityId, Opportunity.Name,
//                                                        Opportunity.Filtered_Job_Number__c, Opportunity.Filtered_Cost_of_Sale__c,
//                                                        Opportunity.Gross_Profit_Field_History__c, Opportunity.Amount_Calder__c,
//                                                        Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
//                                                        CreatedBy.FirstName, CreatedBy.LastName
//                                                FROM OpportunityFieldHistory
//                                                WHERE Opportunity.StageName = 'Closed Won'
//                                                AND CreatedDate >= :fallBack
//                                                AND Field = 'Event_end__c'
//                                                ORDER BY CreatedDate DESC];
//
//        for (OpportunityFieldHistory ofs : dateChanges) {
//
//            Date createdDate = Date.newInstance(ofs.CreatedDate.year(), ofs.CreatedDate.month(), ofs.CreatedDate.day());
//            String dayString = String.valueOf(createdDate.daysBetween(Date.today()));
//
//            // Revenue which has gone out of the current financial year
//            if (((Date)ofs.OldValue >= startDate && (Date)ofs.OldValue <= endDate)
//                    && ((Date)ofs.NewValue < startDate || (Date)ofs.NewValue > endDate)) {
//
//                RecordChange change = new RecordChange();
//                change.ChangeDate = ofs.CreatedDate;
//                change.Description = ofs.Opportunity.Name;
//                change.Revenue = ofs.Opportunity.Amount_Calder__c;
//                change.CostOfSale = ofs.Opportunity.Filtered_Cost_of_Sale__c;
//                change.Profit = ofs.Opportunity.Gross_Profit_Field_History__c;
////                change.Opex;
////                change.ImageLink;
//
//                changeMap.get(dayString).get('RECORDS').add(ofs);
//
//                // Revenue which has entered the current financial year
//            } else if (((Date)ofs.OldValue < startDate || (Date)ofs.OldValue > endDate)
//                    && ((Date)ofs.NewValue >= startDate && (Date)ofs.NewValue <= endDate)) {
//
//                changeMap.get(dayString).get('RECORDS').add(ofs);
//            }
//        }
//
//
//        // capture amount changes and relevant stage (Closed Won) at time of change
//        List<OpportunityFieldHistory> revenueChanges =
//                                    [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
//                                            Opportunity.Amount_Calder__c, Opportunity.Calder_Opportunity__c,
//                                            Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
//                                            CreatedBy.FirstName, CreatedBy.LastName, CreatedById
//                                    FROM OpportunityFieldHistory
//                                    WHERE Opportunity.Event_end__c >= :startDate
//                                    AND Opportunity.Event_end__c <= :endDate
//                                    AND CreatedDate >= :fallBack
//                                    AND Field = 'Gross_Profit_Field_History__c'
//                                    ORDER BY CreatedDate DESC];
//
//        Map<Id,List<OpportunityFieldHistory>> stageHistoriesByIds   = new Map<Id,List<OpportunityFieldHistory>>();
//
//        for (OpportunityFieldHistory ofs : revenueChanges) {
//            stageHistoriesByIds.put(ofs.OpportunityId, new List<OpportunityFieldHistory>());
//        }
//
//        // track stage at time of change
//        for (OpportunityFieldHistory ofs :
//                                    [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
//                                            Opportunity.Amount, Opportunity.Calder_Opportunity__c,
//                                            Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
//                                            CreatedBy.FirstName, CreatedBy.LastName
//                                    FROM OpportunityFieldHistory
//                                    WHERE Field = 'StageName'
//                                    AND OpportunityId IN :stageHistoriesByIds.keySet()
//                                    ORDER BY CreatedDate ASC]){
//            stageHistoriesByIds.get(ofs.OpportunityId).add(ofs);
//        }
//
//        // derive possible source of profit change as Quickbooks integration
//        Map<String,List<Expense__c>> expenseMap = new Map<String,List<Expense__c>>();
//
//        for (Expense__c expense : [SELECT Id, Amount__c, Description__c, Opportunity__c, CreatedDate
//                                    FROM Expense__c
//                                    WHERE Opportunity__c IN :stageHistoriesByIds.keySet()]){
//            String key = expense.Opportunity__c + String.valueOf(expense.CreatedDate.getTime()).substring(0,8);
//            if (!expenseMap.containsKey(key)){
//                expenseMap.put(key, new List<Expense__c>());
//            }
//            expenseMap.get(key).add(expense);
//        }
//
//
//        Map<String,OpportunityFieldHistory> revenueHistoryMap = new Map<String,OpportunityFieldHistory>();
//
//        // derive possible source of profit change as revenue change
//        for (OpportunityFieldHistory ofs :
//                        [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
//                                Opportunity.Amount, Opportunity.Calder_Opportunity__c,
//                                Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
//                                CreatedBy.FirstName, CreatedBy.LastName
//                        FROM OpportunityFieldHistory
//                        WHERE Field = 'Amount'
//                        AND OpportunityId IN :stageHistoriesByIds.keySet()
//                        ORDER BY CreatedDate ASC]){
//            String key = ofs.OpportunityId + String.valueOf(ofs.CreatedDate.getTime()).substring(0,8);
//            revenueHistoryMap.put(key, ofs);
//        }
//
////
////        // detect duplicate entries caused by quote change
////        Map<String,List<Object>> changeTimeMap = new Map<String,List<Object>>();
////
////        for (OpportunityFieldHistory ofs : revenueChanges) {
////            if (changeTimeMap.containsKey(ofs.Opportunity.Filtered_Job_Number__c)) {
////
////                Boolean isDuplicate = false;
////                List<Object> siblings = changeTimeMap.get(ofs.Opportunity.Filtered_Job_Number__c);
////
////                for (Integer x = 0; x < siblings.size(); x++){
////
////                    Map<String,Object> fieldMap = (Map<String, Object>)siblings[x];
////                    String dateString           = (String)fieldMap.get('CreatedDate');
////                    dateString                  = dateString.replace('T',' ');
////                    Datetime siblingCreatedTime = Datetime.valueOf(dateString.substring(0,19));
////
////                    if (siblingCreatedTime <= ofs.CreatedDate.addMinutes(2) && siblingCreatedTime >= ofs.CreatedDate.addMinutes(-2)) {
////
////                        isDuplicate = true;
////                        fieldMap.put('OldValue', ofs.OldValue);
////                        changeTimeMap.get(ofs.Opportunity.Filtered_Job_Number__c).remove(x);
////                        changeTimeMap.get(ofs.Opportunity.Filtered_Job_Number__c).add((Object)fieldMap);
////                    }
////                }
////
////                if (!isDuplicate){
////
////                    String ofsString = JSON.serialize(ofs);
////                    Object ofsObject = JSON.deserializeUntyped(ofsString);
////                    changeTimeMap.get(ofs.Opportunity.Filtered_Job_Number__c).add(ofsObject);
////                }
////            } else {
////
////                String ofsString = JSON.serialize(ofs);
////                Object ofsObject = JSON.deserializeUntyped(ofsString);
////                changeTimeMap.put(ofs.Opportunity.Filtered_Job_Number__c, new List<Object>{ofsObject});
////            }
////        }
//
////        for (String jobNo : changeTimeMap.keySet()) {
////
////            for (Object ofsObject : changeTimeMap.get(jobNo)) {
////
////                Map<String,Object> fieldMap = (Map<String, Object>)ofsObject;
////                Map<String,Object> oppMap = (Map<String,Object>)fieldMap.get('Opportunity');
////
////                String createdString    = (String)fieldMap.get('CreatedDate');
////                createdString           = createdString.replace('T',' ');
////                Date createdDate        = Date.valueOf(createdString);
////                createdDate             = Date.newInstance(createdDate.year(), createdDate.month(), createdDate.day());
////                Datetime createdTime    = Datetime.valueOf(createdString);
////
////                if (stageHistoriesByIds.containsKey((String)fieldMap.get('OpportunityId'))){
////
////                    for (OpportunityFieldHistory stageHistory : stageHistoriesByIds.get((String)fieldMap.get('OpportunityId'))){
////                        if (stageHistory.CreatedDate.getTime() <= createdTime.getTime()){
////                            oppMap.put('StageName', stageHistory.NewValue );
////                        }
////                    }
////                }
////
////                if (oppMap.get('StageName') == (String)'Closed Won'){
////
////                    // get key
////                    String key  = (String)fieldMap.get('OpportunityId') +
////                            String.valueOf(createdTime.getTime()).substring(0,8);
////
////                    // check both maps
////                    if (expenseMap.containsKey(key)){
////
////                        system.debug('found matching expenses');
////                        fieldMap.put('Expenses', expenseMap.get(key));
////                    }
////
////                    if (revenueHistoryMap.containsKey(key)){
////                        system.debug('found revenue changes');
////                        fieldMap.put('Revenue', revenueHistoryMap.get(key));
////                    }
////                    // add values to obj if found in maps
////
////                    fieldMap.put('Opportunity', oppMap);
////                    String newOfsString = JSON.serialize(fieldMap);
////                    Object newOfsObject = JSON.deserializeUntyped(newOfsString);
////                    String dayString    = String.valueOf(createdDate.daysBetween(Date.today()));
////                    changeMap.get(dayString).get('RECORDS').add(newOfsObject);
////                }
////            }
////        }
//
//        // capture stage changes and relevant amounts at time of change
//        List<OpportunityFieldHistory> stageChanges = [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
//                                    Opportunity.Gross_Profit_Field_History__c, Opportunity.Calder_Opportunity__c,
//                                    Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
//                                    CreatedBy.FirstName, CreatedBy.LastName, Opportunity.Gross_profit_2__c
//                            FROM OpportunityFieldHistory
//                            WHERE Opportunity.Event_end__c >= :startDate
//                            AND Opportunity.Event_end__c <= :endDate
//                            AND CreatedDate >= :fallBack
//                            AND Field = 'StageName'
//                            ORDER BY CreatedDate DESC];
//
//        Map<Id,List<OpportunityFieldHistory>> revenueHistoriesByIds   = new Map<Id,List<OpportunityFieldHistory>>();
//
//        for (OpportunityFieldHistory ofs : stageChanges) {
//            // Revenue which has gone out of the current financial year
//            if (ofs.OldValue == 'Closed Won' || ofs.NewValue == 'Closed Won') {
//                revenueHistoriesByIds.put(ofs.OpportunityId, new List<OpportunityFieldHistory>());
//            }
//        }
//
//        for (OpportunityFieldHistory ofs :
//                            [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
//                                    Opportunity.Amount, Opportunity.Calder_Opportunity__c,
//                                    Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
//                                    CreatedBy.FirstName, CreatedBy.LastName
//                            FROM OpportunityFieldHistory
//                            WHERE Field = 'Gross_Profit_Field_History__c'
//                            AND OpportunityId IN :revenueHistoriesByIds.keySet()
//                            ORDER BY CreatedDate ASC]){
//            revenueHistoriesByIds.get(ofs.OpportunityId).add(ofs);
//        }
//
////        for (OpportunityFieldHistory ofs : stageChanges){
////
////            if (revenueHistoriesByIds.containsKey(ofs.OpportunityId)){
////                for (OpportunityFieldHistory revenueHistory : revenueHistoriesByIds.get(ofs.OpportunityId)){
////                    if (revenueHistory.CreatedDate.getTime() <= ofs.CreatedDate.getTime()){
////                        ofs.Opportunity.Gross_Profit_Field_History__c = Decimal.valueOf((String)revenueHistory.NewValue);
////                    }
////                }
////            }
////
////            if (ofs.Opportunity.Gross_Profit_Field_History__c == null){
////                ofs.Opportunity.Gross_Profit_Field_History__c = ofs.Opportunity.Gross_profit_2__c;
////            }
////
////            Date createdDate = Date.newInstance(ofs.CreatedDate.year(), ofs.CreatedDate.month(), ofs.CreatedDate.day());
////            String dayString = String.valueOf(createdDate.daysBetween(Date.today().addDays(0)));
////
////            // Revenue which has gone out of the current financial year
////            if (ofs.OldValue == 'Closed Won' || ofs.NewValue == 'Closed Won') {
////                String ofsString = JSON.serialize(ofs);
////                Object ofsObject = JSON.deserializeUntyped(ofsString);
////                changeMap.get(dayString).get('RECORDS').add(ofsObject);
////            }
////        }
//
//
//        List<Adjustment__c> newCommissions =
//                                [SELECT Profit__c, CreatedDate, Month__c, CreatedBy.FirstName,
//                                        CreatedBy.LastName, EventMonthYear__c
//                                FROM Adjustment__c WHERE Calder__c = TRUE
//                                AND CreatedDate >= :fallBack
//                                AND Month__c >= :startDate
//                                AND Month__c <= :endDate];
//
//        for (Adjustment__c adj : newCommissions){
//            Date createdDate = Date.newInstance(adj.CreatedDate.year(), adj.CreatedDate.month(), adj.CreatedDate.day());
//            String dayString = String.valueOf(createdDate.daysBetween(Date.today()));
//            changeMap.get(dayString).get('RECORDS').add(adj);
//        }
//
//        List<Adjustment__History> changedCommissions =
//                                [SELECT Field, OldValue, NewValue, CreatedDate, CreatedBy.FirstName,
//                                        CreatedBy.LastName, Parent.Calder__c,
//                                        Parent.Month__c, Parent.EventMonthYear__c
//                                FROM Adjustment__History
//                                WHERE CreatedDate >= :fallBack
//                                AND Parent.Calder__c = TRUE
//                                AND Parent.Month__c >= :startDate
//                                AND Parent.Month__c <= :endDate];
//
//        for (Adjustment__History adj : changedCommissions){
//            Date createdDate = Date.newInstance(adj.CreatedDate.year(), adj.CreatedDate.month(), adj.CreatedDate.day());
//            String dayString = String.valueOf(createdDate.daysBetween(Date.today()));
//            changeMap.get(dayString).get('RECORDS').add(adj);
//        }


//        return changeMap;
        return null;

    }

    public class RecordChange {
        DateTime ChangeDate;
        String Description;
        Decimal Revenue;
        Decimal CostOfSale;
        Decimal Profit;
        Decimal Opex;
        String ImageLink;
    }


    @RemoteAction
    public static Map<String,Object> getOpportunityHistory(String oppId){

        Map<String,Decimal> revenueMap     = new Map<String,Decimal>();
        Map<String,Decimal> invoiceMap     = new Map<String,Decimal>();
        Map<String,Decimal> paymentMap     = new Map<String,Decimal>();
        Map<String,Decimal> profitMap      = new Map<String,Decimal>();
        Map<String,Decimal> expenseMap     = new Map<String,Decimal>();
        Map<String,Decimal> expensePaidMap = new Map<String,Decimal>();


        //get opportunity
        Opportunity opp = [SELECT CreatedDate, LastModifiedDate, RecStatus__c, Amount_Calder__c,
                                Amount_Invoiced2__c, Amount_Paid__c, Filtered_Cost_of_Sale__c,
                                Quickbooks_COS__c, Quickbooks_COS_Paid__c, Event_start__c, Event_end__c,
                                Owner.FirstName, Owner.LastName, Owner.ImageLink__c, Project_Manager__r.FirstName,
                                Project_Manager__r.LastName, Project_Manager__r.ImageLink__c, Calder_Opportunity__c
                        FROM Opportunity
                        WHERE Id = :oppId];

        Date lastActivityDate = Date.valueOf(opp.CreatedDate);

        // collect contributing historical values
        for (OpportunityFieldHistory ofs :
                    [SELECT OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
                            Opportunity.Amount, Opportunity.Calder_Opportunity__c,
                            Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
                            CreatedBy.FirstName, CreatedBy.LastName
                        FROM OpportunityFieldHistory
                        WHERE (Field = 'Gross_Profit_Field_History__c' OR Field = 'Amount')
                        AND OpportunityId = :oppId
                        ORDER BY CreatedDate ASC]){

            if (Date.valueOf(ofs.CreatedDate) > lastActivityDate) {
                lastActivityDate = Date.valueOf(ofs.CreatedDate);
            }

            String dateKey = String.valueOf(Date.valueOf(ofs.CreatedDate));

            if (ofs.NewValue != null){
                if (ofs.Field == 'Amount' && Decimal.valueOf((String)ofs.NewValue) != (Decimal.valueOf((String)ofs.NewValue) * 2)){
                    Decimal amount = ofs.Opportunity.Calder_Opportunity__c ?
                            Decimal.valueOf((String)ofs.NewValue) * 0.9 : Decimal.valueOf((String)ofs.NewValue);
                    revenueMap.put(dateKey, amount);
                }
                else if (ofs.Field == 'Gross_Profit_Field_History__c'){

                    system.debug('gross profit was ' + ofs.OldValue + ' and is now ' + ofs.NewValue);

//                    profitMap.put(dateKey, Decimal.valueOf((String)ofs.NewValue));
                }

            }
        }

        for (SBQQ__Quote__c quote : [SELECT Id, SBQQ__NetAmount__c, Gross_Profit__c, Cost_of_sale__c, CreatedDate
                                     FROM SBQQ__Quote__c
                                     WHERE SBQQ__Opportunity2__c = :oppId
                                     ORDER BY CreatedDate ASC]){

            if (Date.valueOf(quote.CreatedDate) > lastActivityDate) {
                lastActivityDate = Date.valueOf(quote.CreatedDate);
            }

            String dateKey = String.valueOf(Date.valueOf(quote.CreatedDate));
            Decimal commission = opp.Calder_Opportunity__c ? quote.SBQQ__NetAmount__c * 0.1 : 0;
            revenueMap.put(dateKey, quote.SBQQ__NetAmount__c - commission);
            profitMap.put(dateKey, quote.Gross_Profit__c);
        }

        for (Invoice_Schedule__c is : [SELECT Amount__c, Invoice_Sent__c, Send_Date__c,
                                              Invoice_Paid__c, Payment_Date__c
                                        FROM Invoice_Schedule__c
                                        WHERE Opportunity__c = :oppId
                                        ORDER BY Send_Date__c ASC]){

            if (Date.valueOf(is.Payment_Date__c) > lastActivityDate) {
                lastActivityDate = Date.valueOf(is.Payment_Date__c);
            }

            if (is.Invoice_Sent__c){
                if (invoiceMap.containsKey(String.valueOf(is.Send_Date__c))){
                    invoiceMap.put(String.valueOf(is.Send_Date__c),invoiceMap.get(String.valueOf(is.Send_Date__c) + is.Amount__c));
                } else {
                    invoiceMap.put(String.valueOf(is.Send_Date__c),is.Amount__c);
                }
            }
            if (is.Invoice_Paid__c){
                if (paymentMap.containsKey(String.valueOf(is.Payment_Date__c))){
                    paymentMap.put(String.valueOf(is.Payment_Date__c),invoiceMap.get(String.valueOf(is.Payment_Date__c) + is.Amount__c));
                } else {
                    paymentMap.put(String.valueOf(is.Payment_Date__c),is.Amount__c);
                }
            }
        }

        for (Expense__c ex : [SELECT Amount__c, Paid__c, Due_Date__c, CreatedDate
                                FROM Expense__c WHERE Opportunity__c = :oppId
                                ORDER BY CreatedDate ASC]){

            if (Date.valueOf(ex.Due_Date__c) > lastActivityDate) {
                lastActivityDate = Date.valueOf(ex.Due_Date__c);
            }

            String createdKey = String.valueOf(Date.valueOf(ex.CreatedDate));
            if (expenseMap.containsKey(createdKey)){
                expenseMap.put(createdKey,expenseMap.get(createdKey) + ex.Amount__c);
            } else {
                expenseMap.put(createdKey,ex.Amount__c);
            }
            if (ex.Paid__c){
                if (expensePaidMap.containsKey(String.valueOf(ex.Due_Date__c))){
                    expensePaidMap.put(String.valueOf(ex.Due_Date__c),expensePaidMap.get(String.valueOf(ex.Due_Date__c)) + ex.Amount__c);
                } else {
                    expensePaidMap.put(String.valueOf(ex.Due_Date__c),ex.Amount__c);
                }
            }
        }

        List<OpportunityHistory> stageHistories = [SELECT Id, StageName, CreatedDate, OpportunityId,
                                                            CreatedBy.FirstName, CreatedBy.LastName,
                                                            CreatedBy.ImageLink__c, Amount
                                                    FROM OpportunityHistory
                                                    WHERE OpportunityId = :oppId
                                                    ORDER BY CreatedDate ASC];

        if (!stageHistories.isEmpty() && stageHistories[0].StageName == 'Repeat Prospect'){

            String dateKey = String.valueOf(Date.valueOf(stageHistories[0].CreatedDate));
            Decimal commission = opp.Calder_Opportunity__c ? stageHistories[0].Amount * 0.1 : 0;
            revenueMap.put(dateKey,  stageHistories[0].Amount  - commission);

        }


        Map<String,List<Decimal>> figuresHistory = new Map<String,List<Decimal>>();
        List<Object> history = new List<Object>();


        Date startingDate   = Date.valueOf(opp.CreatedDate);
        Date endingDate     = opp.RecStatus__c == 'REC COMPLETE' ?
//                                Date.valueOf(opp.LastModifiedDate) :
                                lastActivityDate :
                                Date.today().addDays(-1);

        if (Test.isRunningTest()){
            startingDate = Date.today().addDays(-60);
        }

        Integer totalTime   = startingDate.daysBetween(endingDate);

        Decimal revenue     = 0;
        Decimal invoiced    = 0;
        Decimal paid        = 0;
        Decimal profit      = 0;
        Decimal costOfSale  = 0;
        Decimal spent       = 0;
        Decimal expensePaid = 0;


        while (startingDate < endingDate){
            String dateKey = String.valueOf(startingDate);
            if (revenueMap.containsKey(dateKey)){
                revenue = revenueMap.get(dateKey);
            }
            if (profitMap.containsKey(dateKey)){
                profit = profitMap.get(dateKey);
                costOfSale = revenue - profit;
//                costOfSale = profit;
            }
            if (invoiceMap.containsKey(dateKey)){
                invoiced += invoiceMap.get(dateKey);
            }
            if (paymentMap.containsKey(dateKey)){
                paid += paymentMap.get(dateKey);
            }
            if (expenseMap.containsKey(dateKey)){
                spent += expenseMap.get(dateKey);
            }
            if (expensePaidMap.containsKey(dateKey)){
                expensePaid += expensePaidMap.get(dateKey);
            }
            figuresHistory.put(String.valueOf(dateKey), new List<Decimal>{revenue,invoiced,paid,costOfSale,spent,expensePaid});
            history.add(new List<Object>{dateKey,revenue,invoiced,paid,profit,spent,expensePaid});
            startingDate = startingDate.addDays(1);
        }

        history.add(new List<Object>{String.valueOf(endingDate),opp.Amount_Calder__c,opp.Amount_Invoiced2__c,
                                    opp.Amount_Paid__c, opp.Filtered_Cost_of_Sale__c, opp.Quickbooks_COS__c,
                                    opp.Quickbooks_COS_Paid__c});
        history.add(new List<Object>{String.valueOf(endingDate),opp.Amount_Calder__c,opp.Amount_Invoiced2__c,
                                    opp.Amount_Paid__c, opp.Filtered_Cost_of_Sale__c, opp.Quickbooks_COS__c,
                                    opp.Quickbooks_COS_Paid__c});


        // work out proportion of time spent in each stage of the opportunity


//        Map<String,OpportunityHistory> stageHistoryMap = new Map<String,OpportunityHistory>();
//        Set<String> stages  = new Set<String>();

        String lastStage = '';

        List<Object> stageObjects = new List<Object>();

        for (OpportunityHistory stageHistory : stageHistories) {

            Decimal percent = (Decimal.valueOf(Date.valueOf(stageHistory.CreatedDate).daysBetween(endingDate)) /
                                Decimal.valueOf(totalTime)) * 100;
            if (stageHistory.StageName != lastStage){

                stageObjects.add(
                    JSON.deserializeUntyped(
                            '{' +
                            '   "type" : "stage",' +
                            '   "name" : "' + (stageHistory.StageName != null ? stageHistory.StageName.toUpperCase() :
                                                'UNKNOWN') + '",' +
                            '   "width" : "' + percent + '",' +
                            '   "createdDate" : "' + stageHistory.CreatedDate + '",' +
                            '   "firstName" : "' + stageHistory.CreatedBy.FirstName + '",' +
                            '   "lastName" : "' + stageHistory.CreatedBy.LastName + '",' +
                            '   "imageLink" : "' + stageHistory.CreatedBy.ImageLink__c + '"' +
                            '}'
                    )
                );

                lastStage = stageHistory.StageName;

//                stages.add(stageHistory.StageName);

//                stageHistoryMap.put(percent + ' ' + stageHistory.StageName,stageHistory);
//                stageHistoryMap.put(percent + ' ' + stageHistory.Id,stageHistory);
            }

        }

        // add the opportunity event dates
        if (opp.Event_end__c < endingDate){

            Decimal percent = (Decimal.valueOf(Date.valueOf(opp.Event_end__c).daysBetween(endingDate)) /
                    Decimal.valueOf(totalTime)) * 100;

            stageObjects.add(
                    JSON.deserializeUntyped(
                            '{' +
                                    '   "type" : "stage",' +
                                    '   "name" : "' + ('RECONCILIATION') + '",' +
                                    '   "width" : "' + percent + '",' +
                                    '   "createdDate" : "' + opp.Event_end__c + '",' +
                                    '   "firstName" : "' + opp.Project_Manager__r.FirstName + '",' +
                                    '   "lastName" : "' + opp.Project_Manager__r.LastName + '",' +
                                    '   "imageLink" : "' + opp.Project_Manager__r.ImageLink__c + '"' +
                                    '}'
                    )
            );

            stageObjects.add(
                    JSON.deserializeUntyped(
                            '{' +
                            '   "type" : "eventDate",' +
                            '   "width" : "' + percent + '",' +
                            '   "date" : "' + opp.Event_end__c  + '"' +
                            '}'
                    )
            );

        } else {

            stageObjects.add(
                    JSON.deserializeUntyped(
                            '{' +
                                    '   "type" : "eventDateFuture",' +
                                    '   "width" : "' + 0 + '",' +
                                    '   "days" : "' + Date.today().daysBetween(opp.Event_end__c) + '"' +
                                    '}'
                    )
            );

        }


        for (SBQQ__QuoteDocument__c doc : [SELECT Id, CreatedDate, SBQQ__Version__c
                                            FROM SBQQ__QuoteDocument__c
                                            WHERE SBQQ__Opportunity__c = :opp.Id]){

            Decimal percent = (Decimal.valueOf(Date.valueOf(doc.CreatedDate).daysBetween(endingDate)) /
                    Decimal.valueOf(totalTime)) * 100;
            stageObjects.add(
                    JSON.deserializeUntyped(
                            '{' +
                                    '   "type" : "document",' +
                                    '   "width" : "' + percent + '",' +
                                    '   "date" : "' + doc.CreatedDate + '",' +
                                    '   "name" : "' + doc.SBQQ__Version__c + '"' +
                                    '}'
                    )
            );

        }

//        // track stage at time of change
//        for (OpportunityFieldHistory ofs :
//                                [SELECT Id, OpportunityId, Opportunity.Name, Opportunity.Filtered_Job_Number__c,
//                                        Opportunity.Amount, Opportunity.Calder_Opportunity__c,
//                                        Opportunity.StageName, Field, OldValue, NewValue, CreatedDate,
//                                        CreatedBy.FirstName, CreatedBy.LastName
//                                FROM OpportunityFieldHistory
//                                WHERE Field = 'StageName'
//                                AND OpportunityId = :oppId
//                                ORDER BY CreatedDate ASC]){
//
////            Decimal percent = (Date.valueOf(ofs.CreatedDate).daysBetween(endingDate) / totalTime) * 100;
//            String percent = ofs.Id;
//            stageHistoryMap.put(percent,ofs);
//        }


//        return new Map<String,Object>{'FIGURES' => history, 'HISTORY' => stageHistoryMap};
        return new Map<String,Object>{'FIGURES' => history, 'HISTORY' => stageObjects};
//        return history;
    }
}