public class JSONParserQBOInvoiceCDC{

	public cls_CDCResponse[] CDCResponse;
	public String time_Z;	//2018-03-01T04:35:06.96-08:00
	public class cls_CDCResponse {
		public cls_QueryResponse[] QueryResponse;
	}
	public class cls_QueryResponse {
		public cls_Invoice[] Invoice;
		public Integer startPosition;	
		public Integer maxResults;	
		public Integer totalCount;	
	}
	public class cls_Invoice {
		public Decimal Deposit;	//0
		public boolean AllowIPNPayment;
		public boolean AllowOnlinePayment;
		public boolean AllowOnlineCreditCardPayment;
		public boolean AllowOnlineACHPayment;
		public String status;
		public String domain;	//QBO
		public boolean sparse;
		public String Id;	//3033
		public String SyncToken;	//3
		public cls_MetaData MetaData;
		public cls_CustomField[] CustomField;
		public String DocNumber;	//16080
		public String TxnDate;	//2017-03-01
		public cls_CurrencyRef CurrencyRef;
		public String PrivateNote;	//Payment for event services
		public cls_LinkedTxn[] LinkedTxn;
		public cls_Line[] Line;
		public cls_TxnTaxDetail TxnTaxDetail;
		public cls_CustomerRef CustomerRef;
		public cls_CustomerMemo CustomerMemo;
		public cls_BillAddr BillAddr;
		public String DueDate;	//2017-03-31
		public String GlobalTaxCalculation;	//TaxExcluded
		public Decimal TotalAmt;	//6092.4
		public String PrintStatus;	//NeedToPrint
		public String EmailStatus;	//NotSet
		public Decimal Balance;	//0
	}
	public class cls_MetaData {
		public String CreateTime;	//2018-01-26T08:30:20-08:00
		public String LastUpdatedTime;	//2018-02-27T07:32:34-08:00
	}
	public class cls_CustomField {
		public String DefinitionId;	//1
		public String Name;	//Schedule Number
		public String Type;	//StringType
		public String StringValue;	//16518139
	}
	public class cls_CurrencyRef {
		public String value;	//GBP
		public String name;	//British Pound Sterling
	}
	public class cls_LinkedTxn {
		public String TxnId;	//15890
		public String TxnType;	//Payment
	}
	public class cls_Line {
		public String Id;	//1
		public Integer LineNum;	//1
		public String Description;	//Payment for event services
		public Decimal Amount;	//5077
		public String DetailType;	//SalesItemLineDetail
		public cls_SalesItemLineDetail SalesItemLineDetail;
	}
	public class cls_SalesItemLineDetail {
		public cls_ItemRef ItemRef;
		public Decimal UnitPrice;	//5077
		public Integer Qty;	//1
		public cls_TaxCodeRef TaxCodeRef;
	}
	public class cls_ItemRef {
		public String value;	//21
		public String name;	//Defered income
	}
	public class cls_TaxCodeRef {
		public String value;	//26
	}
	public class cls_TxnTaxDetail {
		public Decimal TotalTax;	//1015.4
		public cls_TaxLine[] TaxLine;
	}
	public class cls_TaxLine {
		public Decimal Amount;	//1015.4
		public String DetailType;	//TaxLineDetail
		public cls_TaxLineDetail TaxLineDetail;
	}
	public class cls_TaxLineDetail {
		public cls_TaxRateRef TaxRateRef;
		public boolean PercentBased;
		public Integer TaxPercent;	//20
		public Decimal NetAmountTaxable;	//5077
	}
	public class cls_TaxRateRef {
		public String value;	//48
	}
	public class cls_CustomerRef {
		public String value;	//687
		public String name;	//Highways England
	}
	public class cls_CustomerMemo {
		public String value;	//Payment for event services
	}
	public class cls_BillAddr {
		public String Id;	//557
		public String Line1;	//Bridge House
		public String Line2;	//Walnut Tree Close
		public String City;	//Guildford
		public String Country;	//United Kingdom
		public String PostalCode;	//GU1 4GA
	}
	public static JSONParserQBOInvoiceCDC parse(String json){
		return (JSONParserQBOInvoiceCDC) System.JSON.deserialize(json, JSONParserQBOInvoiceCDC.class);
	}
}