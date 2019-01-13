/**
 * Created by Ronan Williams on 15/11/2018.
 */

public class JSONParserQBOVendorCreditFlow {

    public cls_QueryResponse QueryResponse;
    public String time_Z;	//2018-11-15T01:51:09.348-08:00
    public class cls_QueryResponse {
        public cls_VendorCredit[] VendorCredit;
        public Integer startPosition;	//1
        public Integer maxResults;	//41
        public Integer totalCount;	//41
    }
    public class cls_VendorCredit {
        public String domain;	//QBO
        public Boolean sparse;
        public String Id;	//22304
        public String SyncToken;	//0
        public cls_MetaData MetaData;
        public String DocNumber;	//CN099 31.10.18
        public String TxnDate;	//2018-11-01
        public cls_CurrencyRef CurrencyRef;
        public cls_Line[] Line;
        public cls_TxnTaxDetail TxnTaxDetail;
        public cls_VendorRef VendorRef;
        public cls_APAccountRef APAccountRef;
        public Decimal TotalAmt;	//194.4
        public String GlobalTaxCalculation;	//TaxExcluded
    }
    public class cls_MetaData {
        public String CreateTime;	//2018-11-14T04:47:59-08:00
        public String LastUpdatedTime;	//2018-11-14T04:47:59-08:00
    }
    public class cls_CurrencyRef {
        public String value;	//GBP
        public String name;	//British Pound Sterling
    }
    public class cls_Line {
        public String Id;	//1
        public Integer LineNum;	//1
        public String Description;	//Credit re invoice 3611
        public Decimal Amount;	//162
        public String DetailType;	//AccountBasedExpenseLineDetail
        public cls_AccountBasedExpenseLineDetail AccountBasedExpenseLineDetail;
    }
    public class cls_AccountBasedExpenseLineDetail {
        public cls_CustomerRef CustomerRef;
        public cls_ClassRef ClassRef;
        public cls_AccountRef AccountRef;
        public String BillableStatus;	//Billable
        public cls_TaxCodeRef TaxCodeRef;
    }
    public class cls_CustomerRef {
        public String value;	//1652
        public String name;	//Highways England:18148 Highways UK 2018
    }
    public class cls_ClassRef {
        public String value;	//1400000000001111219
        public String name;	//18148 Highways 18
    }
    public class cls_AccountRef {
        public String value;	//646
        public String name;	//5000 Cost of sales:Events COS
    }
    public class cls_TaxCodeRef {
        public String value;	//42
    }
    public class cls_TxnTaxDetail {
        public Decimal TotalTax;	//32.4
        public cls_TaxLine[] TaxLine;
    }
    public class cls_TaxLine {
        public Decimal Amount;	//32.4
        public String DetailType;	//TaxLineDetail
        public cls_TaxLineDetail TaxLineDetail;
    }
    public class cls_TaxLineDetail {
        public cls_TaxRateRef TaxRateRef;
        public boolean PercentBased;
        public Integer TaxPercent;	//20
        public Decimal NetAmountTaxable;	//162
    }
    public class cls_TaxRateRef {
        public String value;	//78
    }
    public class cls_VendorRef {
        public String value;	//1364
        public String name;	//Inspire Displays Ltd
    }
    public class cls_APAccountRef {
        public String value;	//802
        public String name;	//2100 Trade Creditors
    }
    public static JSONParserQBOVendorCreditFlow parse(String json){
        return (JSONParserQBOVendorCreditFlow) System.JSON.deserialize(json, JSONParserQBOVendorCreditFlow.class);
    }
}