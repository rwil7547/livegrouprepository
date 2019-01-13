/**
 * Created by Ronan Williams on 09/11/2018.
 */

public with sharing class JSONParserQBOCreditMemoFlow {

    public cls_QueryResponse QueryResponse;
    public String time_Z;	//2018-11-09T06:06:28.601-08:00
    public class cls_QueryResponse {
        public cls_CreditMemo[] CreditMemo;
        public Integer startPosition;	//1
        public Integer maxResults;	//39
    }

    public class cls_CreditMemo {
        public Double RemainingCredit;	//5506.9
        public String domain;	//QBO
        public boolean sparse;
        public String Id;	//22233
        public String SyncToken;	//1
        public cls_MetaData MetaData;
        public cls_CustomField[] CustomField;
        public String DocNumber;	//1235
        public String TxnDate;	//2018-11-01
        public cls_CurrencyRef CurrencyRef;
        public cls_Line[] Line;
        public cls_TxnTaxDetail TxnTaxDetail;
        public cls_CustomerRef CustomerRef;
        public cls_CustomerMemo CustomerMemo;
        public cls_BillAddr BillAddr;
        public String GlobalTaxCalculation;	//TaxExcluded
        public Double TotalAmt;	//5506.9
        public String PrintStatus;	//NotSet
        public String EmailStatus;	//NotSet
        public cls_BillEmail BillEmail;
        public Double Balance;	//5506.9
    }
    public class cls_MetaData {
        public String CreateTime;	//2018-11-08T06:24:52-08:00
        public String LastUpdatedTime;	//2018-11-08T06:25:25-08:00
    }
    public class cls_CustomField {
        public String DefinitionId;	//1
        public String Name;	//Schedule
        public String Type;	//StringType
        public String StringValue;	//SI01259
    }
    public class cls_CurrencyRef {
        public String value;	//GBP
        public String name;	//British Pound Sterling
    }
    public class cls_Line {
        public String Id;	//1
        public Integer LineNum;	//1
        public String Description;	//Commission for invoice 1234
        public Double Amount;	//4589.08
        public String DetailType;	//SalesItemLineDetail
        public cls_SalesItemLineDetail SalesItemLineDetail;
    }
    public class cls_SalesItemLineDetail {
        public cls_ItemRef ItemRef;
        public cls_ClassRef ClassRef;
        public cls_TaxCodeRef TaxCodeRef;
    }

    public class cls_ItemRef {
        public String value;	//36
        public String name;	//Events Income
    }

    public class cls_ClassRef {
        public String value;	//1400000000001125900
        public String name;	//18111 LER events Oct
    }

    public class cls_TaxCodeRef {
        public String value;	//42
    }

    public class cls_TxnTaxDetail {
        public Double TotalTax;	//917.82
        public cls_TaxLine[] TaxLine;
    }

    public class cls_TaxLine {
        public Double Amount;	//917.82
        public String DetailType;	//TaxLineDetail
        public cls_TaxLineDetail TaxLineDetail;
    }
    public class cls_TaxLineDetail {
        public cls_TaxRateRef TaxRateRef;
        public boolean PercentBased;
        public Integer TaxPercent;	//20
        public Double NetAmountTaxable;	//4589.08
    }
    public class cls_TaxRateRef {
        public String value;	//79
    }

    public class cls_CustomerRef {
        public String value;	//1668
        public String name;	//18111 Autumn LER Events - October 2018
    }

    public class cls_CustomerMemo {
        public String value;    //Autumn LER Events - October 2018
    }

    public class cls_BillAddr {
        public String Id;	//1465
        public String Line1;	//Calders
        public String Line2;	//Calders
        public String Line3;	//4 Woodside Court
        public String Line4;	//Clayton Wood Rise
        public String Line5;	//Leeds LS16 6RF
    }

    public class cls_BillEmail {
        public String Address;	//tracy@calders.org.uk
    }

    public static JSONParserQBOCreditMemoFlow parse(String json) {
        return (JSONParserQBOCreditMemoFlow) System.JSON.deserialize(json, JSONParserQBOCreditMemoFlow.class);
    }
}