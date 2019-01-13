/**
 * Created by Ronan Williams on 20/06/2018.
 */


public class JSONParserQBOBillFlow {
    public cls_QueryResponse QueryResponse;
    public String time_Z;    //2018-06-20T04:21:40.128-07:00
    public class cls_QueryResponse {
        public cls_Bill[] Bill;
        public Integer startPosition;    //1
        public Integer maxResults;    //28
        public Integer totalCount;    //28
    }
    public   class cls_Bill {
        public cls_SalesTermRef SalesTermRef;
        public String DueDate;    //2018-06-25
        public Decimal Balance;    //4992.36
        public String domain;    //QBO
        public boolean sparse;
        public String Id;    //20118
        public String SyncToken;    //2
        public cls_MetaData MetaData;
        public String DocNumber;    //147717
        public String TxnDate;    //2018-06-01
        public cls_CurrencyRef CurrencyRef;
        public cls_LinkedTxn[] LinkedTxn;
        public cls_Line[] Line;
        public cls_TxnTaxDetail TxnTaxDetail;
        public cls_VendorRef VendorRef;
        public cls_APAccountRef APAccountRef;
        public Decimal TotalAmt;    //11372.16
        public String GlobalTaxCalculation;    //TaxExcluded
    }
    public    class cls_SalesTermRef {
        public String value;    //11
    }
    public    class cls_MetaData {
        public String CreateTime;    //2018-06-07T02:30:36-07:00
        public String LastUpdatedTime;    //2018-06-20T02:41:22-07:00
    }
    public   class cls_CurrencyRef {
        public String value;    //GBP
        public String name;    //British Pound Sterling
    }
    public    class cls_LinkedTxn {
        public String TxnId;    //20245
        public String TxnType;    //BillPaymentCheck
    }
    public    class cls_Line {
        public String Id;    //1
        public String Description;    //Crew & Equipment for event
        public Double Amount;    //9476.8
        public String DetailType;    //AccountBasedExpenseLineDetail
        public cls_AccountBasedExpenseLineDetail AccountBasedExpenseLineDetail;
    }
    public    class cls_AccountBasedExpenseLineDetail {
        public cls_CustomerRef CustomerRef;
        public cls_AccountRef AccountRef;
        public String BillableStatus;    //Billable
        public cls_TaxCodeRef TaxCodeRef;
        public cls_ClassRef ClassRef;
    }
    public    class cls_CustomerRef {
        public String value;    //1529
        public String name;    //Ernst & Young LLP:18169 EY Edge 2018
    }
    public   class cls_AccountRef {
        public String value;    //646
        public String name;    //5000 Cost of sales:Events COS
    }
    public class cls_ClassRef {
        public String value;    //646
        public String name;    //5000 Cost of sales:Events COS
    }
    public  class cls_TaxCodeRef {
        public String value;    //42
    }
    public   class cls_TxnTaxDetail {
        public Double TotalTax;    //1895.36
        public cls_TaxLine[] TaxLine;
    }
    public  class cls_TaxLine {
        public Double Amount;    //1895.36
        public String DetailType;    //TaxLineDetail
        public cls_TaxLineDetail TaxLineDetail;
    }
    public  class cls_TaxLineDetail {
        public cls_TaxRateRef TaxRateRef;
        public boolean PercentBased;
        public Integer TaxPercent;    //20
        public Double NetAmountTaxable;    //9476.8
    }
    public class cls_TaxRateRef {
        public String value;    //78
    }
    public class cls_VendorRef {
        public String value;    //1418
        public String name;    //Terry Tew Sound and Light Ltd
    }
    public class cls_APAccountRef {
        public String value;    //802
        public String name;    //Creditors
    }
    public static JSONParserQBOBillFlow parse(String json) {
        return (JSONParserQBOBillFlow) System.JSON.deserialize(json, JSONParserQBOBillFlow.class);
    }
}