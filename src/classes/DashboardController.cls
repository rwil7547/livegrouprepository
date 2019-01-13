public class DashboardController {

        Confirmed_Revenue_Snapshot__c priorSnapshot = new Confirmed_Revenue_Snapshot__c();
        Confirmed_Revenue_Snapshot__c currentSnapshot = new Confirmed_Revenue_Snapshot__c();
        
        private string financialYear = 'FY16/17/18 Snapshot';

        private Decimal priorRevenue = 0;
        private Decimal priorGrossProfit = 0;
        private Decimal priorNetProfit = 0;

        private Decimal currentRevenue = 0;
        private Decimal currentGrossProfit = 0;
        private Decimal currentNetProfit = 0;

        public Decimal getCurrentRevenue() {
                return currentRevenue;
        }

        public Decimal getCurrentGrossProfit() {
                return currentGrossProfit;
        }

        public Decimal getCurrentNetProfit() {
                return currentNetProfit;
        }

        public Decimal getRevenueChange() {
                decimal revenueChange = currentRevenue - priorRevenue;
                return revenueChange;
        }

        public Decimal getGrossProfitChange() {
                decimal grossProfitChange = currentGrossProfit - priorGrossProfit;
                return grossProfitChange;
        }

        public Decimal getNetProfitChange() {
                decimal netProfitChange = currentNetProfit - priorNetProfit;
                return netProfitChange;
        }

        public DashboardController() {

                priorSnapshot = [SELECT Id, Net_Amount__c, Gross_Profit__c, Net_Profit__c
                                FROM Confirmed_Revenue_Snapshot__c
                                WHERE Financial_Year__c = :financialYear
                                ORDER BY CreatedDate DESC LIMIT 7][6];

                if (priorSnapshot !=null) {
                        priorRevenue = priorSnapshot.Net_Amount__c;
                        priorGrossProfit = priorSnapshot.Gross_Profit__c;
                        priorNetProfit = priorSnapshot.Net_Profit__c;
                }

                currentSnapshot = [SELECT Id, Net_Amount__c, Gross_Profit__c, Net_Profit__c
                                FROM Confirmed_Revenue_Snapshot__c
                                WHERE Financial_Year__c = :financialYear
                                ORDER BY CreatedDate DESC
                                LIMIT 1];

                if (currentSnapshot !=null) {
                        currentRevenue = currentSnapshot.Net_Amount__c;
                        currentGrossProfit = currentSnapshot.Gross_Profit__c;
                        currentNetProfit = currentSnapshot.Net_Profit__c;
                }

        }
}