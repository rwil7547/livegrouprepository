/**
 * Created by Ronan Williams on 26/02/2019.
 */
@IsTest
public class QuoteInterfaceTest {

    @TestSetup
    public static void doSetup(){

        // insert one account
        Account acc = new Account();
        acc.Name = 'QuoteTestAccount';

        insert acc;

        // insert one unconfirmed Opportunity
        Opportunity opp         = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp.Name                = 'QuoteTestOpportunity';
        opp.AccountId           = acc.Id;
        opp.Amount              = 4000;
        opp.Forecast_COS__c     = 1000;
        opp.Calder_Opportunity__c = true;
        opp.StageName           = 'Costed prospect';
        opp.Invoice_Schedule__c = 'Single up-front invoice';
        opp.Event_start__c      = Date.today();
        opp.Event_end__c        = Date.today().addDays(1);
        insert opp;

        // insert default pricebook
        Pricebook2 defaultPricebook = new Pricebook2();
        defaultPricebook.Name       = 'Default';
        insert defaultPricebook;

        // insert 6 products with prices and unit costs
        List<Product2> products     = new List<Product2>();
        List<PricebookEntry> prices = new List<PricebookEntry>();
        List<SBQQ__Cost__c> costs   = new List<SBQQ__Cost__c>();

        for (Integer x = 0; x < 6; x++){
            Product2 product       = new Product2();
            product.Name           = 'product' + x;
            product.Description    = 'product' + x;
            product.Family         = 'Management & planning';
            product.IsActive       = true;
            products.add(product);
        }

        insert products;

        for (Integer x = 0; x < 6; x++){
            PricebookEntry standardEntry   = new PricebookEntry();
            standardEntry.UnitPrice        = 100;
            standardEntry.Pricebook2Id     = Test.getStandardPricebookId();
            standardEntry.Product2Id       = products[x].Id;
            prices.add(standardEntry);

            PricebookEntry defaultEntry   = new PricebookEntry();
            defaultEntry.UnitPrice        = 100;
            defaultEntry.Pricebook2Id     = defaultPricebook.Id;
            defaultEntry.Product2Id       = products[x].Id;
            defaultEntry.UseStandardPrice = false;
            prices.add(defaultEntry);

            SBQQ__Cost__c cost     = new SBQQ__Cost__c();
            cost.SBQQ__UnitCost__c = 50;
            cost.SBQQ__Active__c   = true;
            cost.SBQQ__Product__c  = products[x].Id;
            costs.add(cost);
        }

        insert prices;
        insert costs;

        // insert 5 expenses assigned to the opportunity
        for (Integer x = 0; x < 5; x++){
            insert new Expense__c(
                Name            = 'expense' + x,
                Amount__c       = 100,
                Opportunity__c  = opp.Id
            );
        }

        // insert one contact
        Contact con     = new Contact();
        con.AccountId   = acc.Id;
        con.FirstName   = 'Test';
        con.LastName    = 'Contact';
        con.Email       = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx@gmail.com';
        con.Title       = 'Test Title';
        con.MailingStreet = '1 Street Name';
        con.MailingCity = 'City';
        con.MailingCountry = 'Country';
        insert con;
    }

    @IsTest
    public static void testGetGenericCollections(){

        String oppId = [SELECT Id FROM Opportunity WHERE Name = 'QuoteTestOpportunity' LIMIT 1].Id;

        // retrieve products available
        List<Product2> products = PrimaryQuoteController.getProductsApex();
        System.assertEquals(6, products.size());

        // retrieve families available
        List<String> families = PrimaryQuoteController.getFamilies();
        System.assertEquals(17, families.size());

        // retrieve all opportunities available
        List<Opportunity> opportunities = PrimaryQuoteController.getOpportunitiesApex('undefined');
        System.assertEquals(1, opportunities.size());

        // retrieve all expenses
        List<Expense__c> expenses = PrimaryQuoteController.getExpensesApex(oppId);
        System.assertEquals(5, expenses.size());


    }

    @IsTest
    public static void testGroupedOperations(){

        String oppId = [SELECT Id FROM Opportunity WHERE Name = 'QuoteTestOpportunity' LIMIT 1].Id;

        // attempt to insert a new quote
        String quoteId = PrimaryQuoteController.createNewEstimateApex(oppId);
        System.assertEquals(1,[SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :oppId].size());
        System.assertNotEquals('error',quoteId);

        // attempt to make the quote primary
        Boolean quoteInsertSuccess = PrimaryQuoteController.togglePrimaryApex(quoteId, oppId, true);
        System.assertEquals(true, quoteInsertSuccess);
        System.assertEquals(true, [SELECT SBQQ__Primary__c FROM SBQQ__Quote__c
                                   WHERE SBQQ__Opportunity2__c = :oppId].SBQQ__Primary__c);

        // test grouping lines
        Boolean groupQuoteSuccess = PrimaryQuoteController.groupLinesApex(quoteId);
        System.assertEquals(true, groupQuoteSuccess);
        System.assertEquals(true, [SELECT SBQQ__LineItemsGrouped__c FROM SBQQ__Quote__c
                                   WHERE SBQQ__Opportunity2__c = :oppId].SBQQ__LineItemsGrouped__c);

        // test insert new group
        SBQQ__QuoteLineGroup__c group1 = PrimaryQuoteController.insertNewGroupApex(quoteId,0);
        System.assertEquals(1,[SELECT Id FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :quoteId].size());

        // test set group name
        Boolean groupNameSuccess = PrimaryQuoteController.changeGroupNameApex(group1.Id,'FirstGroup');
        System.assertEquals(true, groupNameSuccess);
        System.assertEquals(1,[SELECT Id FROM SBQQ__QuoteLineGroup__c WHERE Name = 'FirstGroup'].size());

        // test insert one grouped line
        List<String> productIds = new List<String>{[SELECT Id FROM Product2 LIMIT 1].Id};
        List<SBQQ__QuoteLine__c> lineInsertResponse =
                PrimaryQuoteController.insertGroupedLinesApex(quoteId,group1.Id,productIds);
        System.assertEquals(1, lineInsertResponse.size());

        // check that the call to get quote groups returns one group with two lines
        List<SBQQ__QuoteLineGroup__c> quoteGroups = (List<SBQQ__QuoteLineGroup__c>)PrimaryQuoteController.getQuoteGroups(quoteId,true);
        System.assertEquals(1,quoteGroups.size());
        System.assertEquals(1,quoteGroups[0].SBQQ__LineItems__r.size());

        // test cloning the group, check that the quote now has two groups and four products
        SBQQ__QuoteLineGroup__c clonedGroup = PrimaryQuoteController.cloneGroupApex(quoteId, group1.Id);
        System.assertNotEquals(null, clonedGroup);
        System.assertEquals(2,[SELECT Id FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :quoteId].size());
        System.assertEquals(2,[SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId].size());

        // test deleting the group, check that the quote now has 1 group and two products
        Boolean deleteGroupSuccess = PrimaryQuoteController.deleteGroupApex(clonedGroup.Id,quoteId);
        System.assertEquals(true, deleteGroupSuccess);
        System.assertEquals(1,[SELECT Id FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :quoteId].size());
        System.assertEquals(1,[SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId].size());

        // test removing groups from the quote
        Boolean ungroupSuccess = PrimaryQuoteController.ungroupLinesApex(quoteId);
        System.assertEquals(true, ungroupSuccess);
        System.assertEquals(0,[SELECT Id FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :quoteId].size());

        // test deleting the quote
        String deleteQuoteResponse = PrimaryQuoteController.deleteQuoteApex(quoteId);
        System.assertEquals('default',deleteQuoteResponse);

    }

    @IsTest
    public static void testUnGroupedAndCloneOperations() {

        String oppId = [SELECT Id FROM Opportunity WHERE Name = 'QuoteTestOpportunity' LIMIT 1].Id;

        // attempt to insert a new quote
        String quoteId = PrimaryQuoteController.createNewEstimateApex(oppId);
        System.assertEquals(1,[SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :oppId].size());
        System.assertNotEquals('error',quoteId);

        // test insert one ungrouped line
        List<String> productIds = new List<String>{[SELECT Id FROM Product2 LIMIT 1].Id};

        // test insert two ungrouped lines and verify that there are now 4 quote lines
        Boolean ungroupedLineInsertResponse = PrimaryQuoteController.insertUngroupedLinesApex(quoteId,productIds);
        System.assertEquals(true, ungroupedLineInsertResponse);
        System.assertEquals(1,[SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId].size());

        // check that the call to get quote groups returns one group with two lines
        List<Object> quoteGroups = PrimaryQuoteController.getQuoteGroups(quoteId,false);
        System.assertEquals(1,quoteGroups.size());

        // obtain a copy of the quote as it stands as the default quote
        SBQQ__Quote__c quote = PrimaryQuoteController.getQuoteApex(oppId, 'default')[0];

        // clone the estimate, verify it exists with the right number of products but is not primary
        String clonedEstimateId = PrimaryQuoteController.cloneEstimateApex(quote,oppId,'Estimate');
        System.assertNotEquals('error',clonedEstimateId);
        System.assertEquals(1,[SELECT Id FROM SBQQ__Quote__c WHERE Id = :clonedEstimateId].size());

    }

    @IsTest
    public static void testLineUpdateOperations(){

        String oppId = [SELECT Id FROM Opportunity WHERE Name = 'QuoteTestOpportunity' LIMIT 1].Id;

        // attempt to insert a new quote
        String quoteId = PrimaryQuoteController.createNewEstimateApex(oppId);
        System.assertEquals(1,[SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :oppId].size());
        System.assertNotEquals('error',quoteId);

        // test insert four ungrouped lines
        List<Product2> products = [SELECT Id FROM Product2];
        List<String> productIds = new List<String>{products[0].Id,products[1].Id};
        Boolean ungroupedLineInsertResponse = PrimaryQuoteController.insertUngroupedLinesApex(quoteId,productIds);
        List<SBQQ__QuoteLine__c> returnedLines = [SELECT Id, SBQQ__UnitCost__c, SBQQ__Optional__c, SBQQ__Number__c
                                                    FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId];

        System.assertEquals(true, ungroupedLineInsertResponse);
        System.assertEquals(2,returnedLines.size());

        // test multiline update
        Boolean multiUpdateResponse = PrimaryQuoteController.saveAllLinesApex(returnedLines);
        System.assertEquals(true, multiUpdateResponse);

        // test change sort order up
        String orderUpResponse =
                PrimaryQuoteController.changeSortOrderApex(quoteId, returnedLines[0].Id, 1,2, 'undefined');
        System.assertNotEquals('error',orderUpResponse);

        // test change sort down
        String orderDownResponse =
                PrimaryQuoteController.changeSortOrderApex(quoteId, returnedLines[0].Id, 2,1, 'undefined');
        System.assertNotEquals('error',orderDownResponse);

        // test update the unit cost on a line
        returnedLines[0].SBQQ__UnitCost__c = 0;
        String lineUpdateResponse = PrimaryQuoteController.changeLineApex(returnedLines[0], 'save',0.5);
        System.assertEquals(returnedLines[0].Id, lineUpdateResponse);

        // test set line optional
        returnedLines[0].SBQQ__Optional__c = true;
        String lineOptionalResponse = PrimaryQuoteController.changeLineApex(returnedLines[0], 'optional',0.5);
        System.assertEquals(returnedLines[0].Id, lineOptionalResponse);

        // test clone line
        String lineCloneResponse = PrimaryQuoteController.changeLineApex(returnedLines[0], 'clone',0.5);
        System.assertNotEquals('error', lineCloneResponse);

        // test delete line
        String lineDeleteResponse = PrimaryQuoteController.changeLineApex(returnedLines[1], 'delete',0.5);
        System.assertEquals(returnedLines[1].Id, lineDeleteResponse);

        // test get quote value refresh
        Map<String,Object> refreshMap = PrimaryQuoteController.getRefreshApex(quoteId);
        System.assertEquals(9,refreshMap.size());


    }

    @IsTest
    public static void testCreateAndCloneContract(){

        String oppId = [SELECT Id FROM Opportunity WHERE Name = 'QuoteTestOpportunity' LIMIT 1].Id;

        // attempt to insert a new quote
        String quoteId = PrimaryQuoteController.createNewEstimateApex(oppId);

        // make the quote primary
        PrimaryQuoteController.togglePrimaryApex(quoteId, oppId, true);

        // test insert four ungrouped lines
        List<Product2> products = [SELECT Id FROM Product2];
        List<String> productIds = new List<String>{products[0].Id,products[1].Id};
        PrimaryQuoteController.insertUngroupedLinesApex(quoteId,productIds);

        Opportunity convertedOpp = new Opportunity();
        convertedOpp.Id = oppId;
        convertedOpp.StageName = 'Closed Won';
        update convertedOpp;

        System.assertEquals(1,[SELECT Id FROM SBQQ__Quote__c WHERE Stage__c = 'Contract'].size());

        // test that the quore default is now the contract
        // obtain a copy of the quote as it stands as the default quote
        SBQQ__Quote__c quote = PrimaryQuoteController.getQuoteApex(oppId, 'default')[0];
        System.assertEquals(true, quote.SBQQ__Primary__c);

        // test cloning a contract to create an amendment
        // clone the estimate, verify it exists with the right number of products
        String clonedEstimateId = PrimaryQuoteController.cloneEstimateApex(quote,oppId,'Contract');
        System.assertNotEquals('error',clonedEstimateId);
        System.assertEquals(1,[SELECT Id FROM SBQQ__Quote__c WHERE Id = :clonedEstimateId].size());

    }

    @IsTest
    public static void testDocPreviewEstimateOptionals(){
        String oppId = [SELECT Id FROM Opportunity WHERE Name = 'QuoteTestOpportunity' LIMIT 1].Id;

        // attempt to insert a new quote
        String quoteId = PrimaryQuoteController.createNewEstimateApex(oppId);

        // test insert four ungrouped lines
        List<Product2> products = [SELECT Id FROM Product2];
        List<String> productIds = new List<String>{products[0].Id,products[1].Id};
        PrimaryQuoteController.insertUngroupedLinesApex(quoteId,productIds);

        List<SBQQ__QuoteLine__c> returnedLines = [SELECT Id, SBQQ__UnitCost__c, SBQQ__Optional__c, SBQQ__Number__c
                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId];

        PrimaryQuoteController.changeLineApex(returnedLines[0],'optional',0.5);

        PageReference pdf = Page.QuotePreview;

        // add parent id to the parameters for standardcontroller
        pdf.getParameters().put('Id',quoteId);
        pdf.getParameters().put('userId',UserInfo.getUserId());
        pdf.getParameters().put('contactId',[SELECT Id FROM Contact LIMIT 1].Id);
        pdf.getParameters().put('text',EncodingUtil.urlDecode('proposal intro','UTF-8'));
        pdf.getParameters().put('optionals','true');
        pdf.getParameters().put('invoices','false');
        pdf.getParameters().put('vat','false');
        pdf.getParameters().put('sla','false');
        pdf.getParameters().put('tnc','false');
        Test.setCurrentPage(pdf);

        QuotePreviewController qpc = new QuotePreviewController();


    }

    @IsTest
    public static void testDocPreviewContractAmendmentOptionals(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'QuoteTestOpportunity' LIMIT 1];

        // attempt to insert a new quote
        String quoteId = PrimaryQuoteController.createNewEstimateApex(opp.Id);
        PrimaryQuoteController.togglePrimaryApex(quoteId,opp.Id, true);

        // test insert four ungrouped lines
        List<Product2> products = [SELECT Id FROM Product2];
        List<String> productIds = new List<String>{products[0].Id,products[1].Id,products[2].Id,products[3].Id,products[4].Id};
        PrimaryQuoteController.insertUngroupedLinesApex(quoteId,productIds);

        opp.StageName = 'Closed Won';
        update opp;

        List<SBQQ__Quote__c> contracts = PrimaryQuoteController.getQuoteApex(opp.Id, 'default');

        PrimaryQuoteController.cloneEstimateApex(contracts[0], opp.Id, 'Contract');

        List<SBQQ__Quote__c> amendments = PrimaryQuoteController.getQuoteApex(opp.Id, 'default');

//        Test.startTest();
        PrimaryQuoteController.insertUngroupedLinesApex(amendments[0].Id,productIds);

        Test.startTest();

        List<SBQQ__QuoteLine__c> returnedLines = [SELECT Id, SBQQ__UnitCost__c, SBQQ__Optional__c, SBQQ__Number__c
                                                    FROM SBQQ__QuoteLine__c
                                                    WHERE SBQQ__Quote__c = :amendments[0].Id
                                                    ORDER BY CreatedDate ASC];


        PageReference pdf = Page.QuotePreview;

        // add parent id to the parameters for standardcontroller
        pdf.getParameters().put('Id',amendments[0].Id);
        pdf.getParameters().put('userId',UserInfo.getUserId());
        pdf.getParameters().put('contactId',[SELECT Id FROM Contact LIMIT 1].Id);
        pdf.getParameters().put('text',EncodingUtil.urlDecode('proposal intro','UTF-8'));
        pdf.getParameters().put('optionals','true');
        pdf.getParameters().put('invoices','true');
        pdf.getParameters().put('vat','false');
        pdf.getParameters().put('sla','false');
        pdf.getParameters().put('tnc','false');
        Test.setCurrentPage(pdf);

//        QuotePreviewController qpcUngrouped = new QuotePreviewController();

        PrimaryQuoteController.groupLinesApex(amendments[0].Id);
        returnedLines[0].SBQQ__Group__c         = null;
        PrimaryQuoteController.changeLineApex(returnedLines[0],'save',0.5);
        returnedLines[3].SBQQ__Optional__c      = true;
        PrimaryQuoteController.changeLineApex(returnedLines[1],'delete',0.5);
        PrimaryQuoteController.changeLineApex(returnedLines[2],'clone',0.5);
        PrimaryQuoteController.changeLineApex(returnedLines[3],'optional',0.5);
        returnedLines[4].SBQQ__Description__c   = 'xxx';
        returnedLines[4].SBQQ__Quantity__c      = 50;
        PrimaryQuoteController.changeLineApex(returnedLines[4],'save',0.5);

        QuotePreviewController qpcGrouped = new QuotePreviewController();

        Test.stopTest();

    }

    @IsTest
    public static void testDocPreviewContractAmendmentOptional(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'QuoteTestOpportunity' LIMIT 1];

        // attempt to insert a new quote
        String quoteId = PrimaryQuoteController.createNewEstimateApex(opp.Id);
        PrimaryQuoteController.togglePrimaryApex(quoteId,opp.Id, true);

        // test insert four ungrouped lines
        List<Product2> products = [SELECT Id FROM Product2];
        List<String> productIds = new List<String>{products[0].Id,products[1].Id};
        PrimaryQuoteController.insertUngroupedLinesApex(quoteId,productIds);

        opp.StageName = 'Closed Won';
        update opp;

        List<SBQQ__Quote__c> contracts = PrimaryQuoteController.getQuoteApex(opp.Id, 'default');

        PrimaryQuoteController.cloneEstimateApex(contracts[0], opp.Id, 'Contract');

        List<SBQQ__Quote__c> amendments = PrimaryQuoteController.getQuoteApex(opp.Id, 'default');

        Test.startTest();
        PrimaryQuoteController.insertUngroupedLinesApex(amendments[0].Id,productIds);

        List<SBQQ__QuoteLine__c> returnedLines = [SELECT Id, SBQQ__UnitCost__c, SBQQ__Optional__c, SBQQ__Number__c
        FROM SBQQ__QuoteLine__c
        WHERE SBQQ__Quote__c = :quoteId
        ORDER BY CreatedDate ASC];

        PrimaryQuoteController.changeLineApex(returnedLines[0],'optional',0.5);
        PrimaryQuoteController.changeLineApex(returnedLines[1],'optional',0.5);

        PageReference pdf = Page.QuotePreview;

        // add parent id to the parameters for standardcontroller
        pdf.getParameters().put('Id',amendments[0].Id);
        pdf.getParameters().put('userId',UserInfo.getUserId());
        pdf.getParameters().put('contactId',[SELECT Id FROM Contact LIMIT 1].Id);
        pdf.getParameters().put('text',EncodingUtil.urlDecode('proposal intro','UTF-8'));
        pdf.getParameters().put('optionals','true');
        pdf.getParameters().put('invoices','true');
        pdf.getParameters().put('vat','false');
        pdf.getParameters().put('sla','false');
        pdf.getParameters().put('tnc','false');
        Test.setCurrentPage(pdf);

        QuotePreviewController qpcUngrouped = new QuotePreviewController();

        PrimaryQuoteController.groupLinesApex(amendments[0].Id);
        QuotePreviewController qpcGrouped = new QuotePreviewController();

        Test.stopTest();

    }

    @IsTest
    public static void testDocumentSaveAndDelete(){
        String oppId = [SELECT Id FROM Opportunity WHERE Name = 'QuoteTestOpportunity' LIMIT 1].Id;

        // attempt to insert a new quote
        String quoteId = PrimaryQuoteController.createNewEstimateApex(oppId);

        // test insert four ungrouped lines
        List<Product2> products = [SELECT Id FROM Product2];
        List<String> productIds = new List<String>{products[0].Id,products[1].Id};
        PrimaryQuoteController.insertUngroupedLinesApex(quoteId,productIds);

        // test get document information
        Map<String,List<Object>> documentInfoMap = PrimaryQuoteController.getDocumentInfoApex(oppId);

        String userId       = UserInfo.getUserId();
        String contactId    = [SELECT Id FROM Contact LIMIT 1].Id;

        // test save document
        Boolean saveDocumentResponse = PrimaryQuoteController.saveDocumentApex(quoteId, oppId,
                                        userId, contactId,'proposal text', 'false', 'false','false','false', 'false',
                                        'false', 'false', 'false','false','','','');

        List<SBQQ__Quote__c> listViewResponse = QuoteListViewController.getQuotes(oppId);

        Boolean deleteDocumentResponse = QuoteListViewController.deleteDocumentApex(listViewResponse[0].SBQQ__R00N70000001lX7YEAU__r[0].SBQQ__DocumentId__c);

    }

    @IsTest
    public static void testQuoteListViewGetQuotes() {

        String oppId = [SELECT Id FROM Opportunity WHERE Name = 'QuoteTestOpportunity' LIMIT 1].Id;

        // attempt to insert a new quote
        PrimaryQuoteController.createNewEstimateApex(oppId);

        // attempt to insert a new quote
        PrimaryQuoteController.createNewEstimateApex(oppId);

        List<SBQQ__Quote__c> listViewResponse = QuoteListViewController.getQuotes(oppId);
        System.assertEquals(2,listViewResponse.size());

    }

    @IsTest
    public static void testExpenseAssignment(){

        String oppId = [SELECT Id FROM Opportunity WHERE Name = 'QuoteTestOpportunity' LIMIT 1].Id;

        // attempt to insert a new quote
        String quoteId = PrimaryQuoteController.createNewEstimateApex(oppId);

        // test insert four ungrouped lines
        List<Product2> products = [SELECT Id FROM Product2];
        List<String> productIds = new List<String>{products[0].Id,products[1].Id};
        PrimaryQuoteController.insertUngroupedLinesApex(quoteId,productIds);

        Expense__c expense      = [SELECT Id FROM Expense__c LIMIT 1];
        SBQQ__QuoteLine__c line = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];

        // test assign the expense
        Boolean assignResult = PrimaryQuoteController.assignExpenseApex(line.Id, expense.Id);
        System.assertEquals(true,assignResult);


        // test unassign the expense
        Boolean unassignResult = PrimaryQuoteController.assignExpenseApex(null, expense.Id);
        System.assertEquals(true,unassignResult);


    }
}