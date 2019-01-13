/**
 * Created by Ronan Williams on 20/06/2018.
 */

public class JSONParserQBOInvoiceFlow {
    public cls_QueryResponse QueryResponse;
    public String time_Z;    //2018-06-20T03:15:49.682-07:00
    public class cls_QueryResponse {
        public cls_Invoice[] Invoice;
        public Integer startPosition;    //1
        public Integer maxResults;    //25
        public Integer totalCount;    //25
    }
    public class cls_Invoice {
        public Integer Deposit; //0
        public boolean AllowIPNPayment;
        public boolean AllowOnlinePayment;
        public boolean AllowOnlineCreditCardPayment;
        public boolean AllowOnlineACHPayment;
        public String domain; //QBO
        public boolean sparse;
        public String Id;    //19961
        public String SyncToken;    //4
        public cls_MetaData MetaData;
        public cls_CustomField[] CustomField;
        public String DocNumber;    //1111
        public String TxnDate; //2018-05-29
        public cls_CurrencyRef CurrencyRef;
        public cls_LinkedTxn[] LinkedTxn;
        public cls_Line[] Line;
        public cls_TxnTaxDetail TxnTaxDetail;
        public cls_CustomerRef CustomerRef;
        public cls_CustomerMemo CustomerMemo;
        public cls_BillAddr BillAddr;
        public cls_SalesTermRef SalesTermRef;
        public String DueDate; //2018-06-12
        public String GlobalTaxCalculation;    //TaxExcluded
        public Double TotalAmt;    //45763.62
        public String PrintStatus;    //NotSet
        public String EmailStatus;    //NeedToSend
        public cls_BillEmail BillEmail;
        public Double Balance;    //45763.62
        public cls_DeliveryInfo DeliveryInfo;
    }
    public class cls_MetaData {
        public String CreateTime;    //2018-05-29T03:10:36-07:00
        public String LastUpdatedTime; //2018-06-20T02:01:08-07:00
    }
    public class cls_CustomField {
        public String DefinitionId;    //1
        public String Name;    //Schedule
        public String Type;    //StringType
        public String StringValue;	//16518139
    }
    public class cls_CurrencyRef {
        public String value;    //GBP
        public String name;    //British Pound Sterling
    }
    public class cls_LinkedTxn {
    }
    public class cls_Line {
        public String Id; //1
        public Integer LineNum;    //1
        public String Description;    //Request for payment for event services
        public Double Amount; //38136.35
        public String DetailType;    //SalesItemLineDetail
        public cls_SalesItemLineDetail SalesItemLineDetail;
    }
    public class cls_SalesItemLineDetail {
        public cls_ItemRef ItemRef;
        public cls_TaxCodeRef TaxCodeRef;
        public cls_ClassRef ClassRef;
    }
    public class cls_ItemRef {
        public String value;    //39
        public String name;    //Other Income
    }
    public class cls_ClassRef {
        public String value;    //39
        public String name;    //Other Income
    }
    public class cls_TaxCodeRef {
        public String value; //42
    }
    public class cls_TxnTaxDetail {
        public Double TotalTax;    //7627.27
        public cls_TaxLine[] TaxLine;
    }
    public class cls_TaxLine {
        public Double Amount;    //7627.27
        public String DetailType;    //TaxLineDetail
        public cls_TaxLineDetail TaxLineDetail;
    }
    public class cls_TaxLineDetail {
        public cls_TaxRateRef TaxRateRef;
        public boolean PercentBased;
        public Integer TaxPercent;    //20
        public Double NetAmountTaxable; //38136.35
    }
    public class cls_TaxRateRef {
        public String value;    //79
    }
    public class cls_CustomerRef {
        public String value;    //1389
        public String name; //17617 Teacher Workload Events
    }
    public class cls_CustomerMemo {
        public String value;    //Teacher Workload Events

    }
    public class cls_BillAddr {
        public String Id;    //1264
        public String Line1;    //Department for Education
        public String Line2;    //NEWPORT SSCL - DEPARTMENT FOR EDUCATION
        public String Line3;    //PO BOX 407
        public String Line4;    //Newport
        public String Line5;    //NP10 8FZ
    }
    public class cls_SalesTermRef {
        public String value;    //10
    }
    public class cls_BillEmail {
        public String Address;    //APinvoices-DFE-U@sscl.gse.gov.uk
    }
    public class cls_DeliveryInfo {
        public String DeliveryType;    //Email
    }
    public static JSONParserQBOInvoiceFlow parse(String json) {
        return (JSONParserQBOInvoiceFlow) System.JSON.deserialize(json, JSONParserQBOInvoiceFlow.class);
    }
}