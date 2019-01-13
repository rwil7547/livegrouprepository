public class JSONParserQBOCreditMemoCDC{
	public cls_CDCResponse[] CDCResponse;
	public String time_Z;	//2018-03-02T02:57:21.088-08:00
	public class cls_CDCResponse {
		public cls_QueryResponse[] QueryResponse;
	}
	public class cls_QueryResponse {
		public cls_CreditMemo[] CreditMemo;
		public Integer startPosition;	//1
		public Integer maxResults;	//2
		public Integer totalCount;	//2
	}
	public class cls_CreditMemo {
		public Decimal RemainingCredit;	//90
		public String domain;	//QBO
		public boolean sparse;
		public String status;		
		public String Id;	//18974
		public String SyncToken;	//1
		public cls_MetaData MetaData;
		public cls_CustomField[] CustomField;
		public String DocNumber;	//1019
		public String TxnDate;	//2018-03-01
		public cls_CurrencyRef CurrencyRef;
		public cls_Line[] Line;
		public cls_TxnTaxDetail TxnTaxDetail;
		public cls_CustomerRef CustomerRef;
		public cls_BillAddr BillAddr;
		public String GlobalTaxCalculation;	//TaxExcluded
		public Decimal TotalAmt;	//90
		public String PrintStatus;	//NotSet
		public String EmailStatus;	//NotSet
		public cls_BillEmail BillEmail;
		public Decimal Balance;	//90
	}
	public class cls_MetaData {
		public String CreateTime;	//2018-03-01T02:26:54-08:00
		public String LastUpdatedTime;	//2018-03-01T02:28:18-08:00
	}
	public class cls_CustomField {
		public String DefinitionId;	//1
		public String Name;	//Schedule Number
		public String Type;	//StringType
		public String StringValue;
	}
	public class cls_CurrencyRef {
		public String value;	//GBP
		public String name;	//British Pound Sterling
	}
	public class cls_Line {
		public String Id;	//1
		public Integer LineNum;	//1
		public String Description;	//This
		public Decimal Amount;	//90
		public String DetailType;	//SalesItemLineDetail
		public cls_SalesItemLineDetail SalesItemLineDetail;
	}
	public class cls_SalesItemLineDetail {
		public String ServiceDate;	//2018-03-01
		public cls_ItemRef ItemRef;
		public cls_TaxCodeRef TaxCodeRef;
	}
	public class cls_ItemRef {
		public String value;	//18
		public String name;	//_EXISTING_Services
	}
	public class cls_TaxCodeRef {
		public String value;	//35
	}
	public class cls_TxnTaxDetail {
		public Decimal TotalTax;	//0
		public cls_TaxLine[] TaxLine;
	}
	public class cls_TaxLine {
		public Decimal Amount;	//0
		public String DetailType;	//TaxLineDetail
		public cls_TaxLineDetail TaxLineDetail;
	}
	public class cls_TaxLineDetail {
		public cls_TaxRateRef TaxRateRef;
		public boolean PercentBased;
		public Integer TaxPercent;	//0
		public Decimal NetAmountTaxable;	//90
	}
	public class cls_TaxRateRef {
		public Decimal value;	//66
	}
	public class cls_CustomerRef {
		public String value;	//687
		public String name;	//Highways England
	}
	public class cls_BillAddr {
		public String Id;	//557
		public String Line1;	//Bridge House
		public String Line2;	//Walnut Tree Close
		public String City;	//Guildford
		public String Country;	//United Kingdom
		public String PostalCode;	//GU1 4GA
	}
	public class cls_BillEmail {
		public String Address;	//INVOICES@highwaysengland.co.uk
	}
	public static JSONParserQBOCreditMemoCDC parse(String json){
		return (JSONParserQBOCreditMemoCDC) System.JSON.deserialize(json, JSONParserQBOCreditMemoCDC.class);
	}
}