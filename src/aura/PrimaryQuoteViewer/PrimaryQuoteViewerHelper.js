({
    getQuote : function(component, quoteId, refreshPanel) {

        var action = component.get("c.getQuoteApex");
        action.setParams({
            oppId : component.get("v.recordId"),
            quoteId : quoteId
        });
        action.setCallback(this, function(response){

            if (response.getState() === "SUCCESS"){
                if (response.getReturnValue()[0]){
                    component.set('v.createAllowed',false);

                    var quote = response.getReturnValue()[0];
                    component.set("v.quote", quote);

                    if (quoteId === "default"){
                        var selectEvent = $A.get("e.c:SelectQuoteEvent");
                        selectEvent.setParams({
                            quoteId : component.get('v.quote.Id')
                        });
                        selectEvent.fire();
                    }

                    if (refreshPanel){
                        var refresh = $A.get("e.c:Refresh");
                        refresh.setParams({
                            id : component.get('v.quote.Id')
                        });
                        refresh.fire();
                    }

                    if (!quote.Locked__c){
                        component.set('v.editable',true);
                    } else {
                        component.set('v.editable',false);
                    }

                    if (!quote.HasDocument__c){
                        component.set('v.revEditable',true);
                        this.getProducts(component);
                        this.getDocumentInfo(component);
                    } else {
                        component.set('v.revEditable',false);
                    }

                    if (quote.SBQQ__Status__c !== 'Reconciliation - completed' &&
                        (!quote.SBQQ__Opportunity2__r.Contracted__c &&
                            (!quote.SBQQ__Opportunity2__r.Legacy__c ||
                                (quote.SBQQ__Opportunity2__r.Legacy__c && quote.SBQQ__Primary__c)) ||
                        (quote.SBQQ__Opportunity2__r.Contracted__c && quote.SBQQ__Primary__c))){
                        component.set('v.cloneDisabled',false);
                    } else {
                        component.set('v.cloneDisabled',true);
                    }

                    if (quote.SBQQ__LineItems__r || quote.SBQQ__LineItemGroups__r){
                        this.getGroups(component, response.getReturnValue()[0].Id,
                            response.getReturnValue()[0].SBQQ__LineItemsGrouped__c);
                    } else {
                        component.set('v.responsePending',false);
                        component.set('v.groups',[]);
                    }

                    if (quote.Stage__c  !== 'Estimate' && quote.SBQQ__Primary__c){
                        this.getExpenses(component, component.get('v.recordId'));
                    } else {
                        component.set('v.expenses',[]);
                    }

                    // clear the value of the quote clone opportunity data set
                    if (document.getElementById('opplistInput')){
                        document.getElementById('opplistInput').value = null;
                    }
                } else {
                    component.set('v.quote',null);
                    component.set('v.groups',null);
                    if (refreshPanel){
                        var refresh = $A.get("e.c:Refresh");
                        refresh.setParams({
                            id : ''
                        });
                        refresh.fire();
                    }
                    component.set('v.createAllowed',true);
                }
            }
        });
        $A.enqueueAction(action);


    },
    getGroups : function(component, Id, custom) {

        var getGroups = component.get("c.getQuoteGroups");
        getGroups.setParams({
            Id : Id,
            custom : custom
        });

        getGroups.setCallback(this, function(response){
            component.set('v.responsePending',false);
            if (response.getState() === "SUCCESS"){
                component.set("v.groups", response.getReturnValue());
            }
        });

        $A.enqueueAction(getGroups);
    },
    getProducts : function(component){

        var getProducts = component.get("c.getProductsApex");
        getProducts.setCallback(this, function(response){
            if (response.getState() === "SUCCESS"){
                component.set("v.products", response.getReturnValue());
            }
        });
        $A.enqueueAction(getProducts);
    },
    getExpenses : function(component, oppId){
        var getExpenses = component.get('c.getExpensesApex');
        getExpenses.setParams({ oppId : oppId});
        getExpenses.setCallback(this, function(response){
            if (response.getState() === 'SUCCESS'){
                component.set('v.expenses',response.getReturnValue());
            }
        });
        $A.enqueueAction(getExpenses);
    },
    showToast : function(title, message, type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message : message,
            type : type,
            mode : 'pester'
        });
        toastEvent.fire();
    },
    insertGroupedProducts : function(component, event){

        var insertGroupedLines = component.get('c.insertGroupedLinesApex');
        var groupId = component.get('v.activeGroupId');

        insertGroupedLines.setParams({
            quoteId : component.get('v.quote.Id'),
            groupId : groupId,
            productIds : event.getParam('productIds')
        });
        insertGroupedLines.setCallback(this, function(response){
            if (response.getState() === "SUCCESS"){
                var refresh = $A.get("e.c:Refresh");
                refresh.setParams({
                    id : component.get('v.quote.Id')
                });
                refresh.fire();
                var responseEvent = $A.get("e.c:InsertProductsResponse");
                responseEvent.setParams({
                    groupId : groupId,
                    lines : response.getReturnValue()
                });
                responseEvent.fire();
                this.showToast('Success!', 'New lines inserted.','success');
            } else {
                this.showToast('Error', 'There was an error inserting the lines', 'error');
            }
        });
        $A.enqueueAction(insertGroupedLines);

        var groupResponsePending = $A.get("e.c:GroupResponsePending");
        groupResponsePending.setParams({groupId : groupId});
        groupResponsePending.fire();

        var modal = component.find("selectorModal");
        $A.util.toggleClass(modal, "toggle");
        component.set('v.activeGroupId',null);
    },
    insertUngroupedProducts : function(component, event){
        component.set('v.responsePending', true);
        var insertUngroupedLines = component.get('c.insertUngroupedLinesApex');
        insertUngroupedLines.setParams({
            quoteId : component.get('v.quote.Id'),
            productIds : event.getParam('productIds')
        });
        insertUngroupedLines.setCallback(this, function(response){
            component.set('v.responsePending', false);
            if (response.getState() === "SUCCESS" && response.getReturnValue()){
                var refresh = $A.get("e.c:Refresh");
                refresh.setParams({
                    id : component.get('v.quote.Id')
                });
                refresh.fire();
                this.getGroups(component, component.get('v.quote.Id'), false);
                this.showToast('Success!', 'New lines inserted.','success');
            } else {
                this.showToast('Error', 'There was an error inserting the lines', 'error');
            }
        });
        $A.enqueueAction(insertUngroupedLines);

        var modal = component.find("selectorModal");
        $A.util.toggleClass(modal, "toggle");
        component.set('v.activeGroupId',null);
    },
    deleteQuote : function(component){
        component.set('v.responsePending', true);
        var deleteQuote = component.get('c.deleteQuoteApex');
        deleteQuote.setParams({quoteId : component.get('v.quote.Id')});
        deleteQuote.setCallback(this, function(response){
            component.set('v.responsePending', false);
            if(response.getState() === 'SUCCESS' && response.getReturnValue()){
                this.showToast('Success!', 'Quote deleted','success');
                // this.getQuote(component, 'default', true);
                component.set('v.quote',null);
                this.getQuote(component, response.getReturnValue(), true);
            } else {
                this.showToast('Error', 'There was an error deleting the quote', 'error');
            }
        });
        $A.enqueueAction(deleteQuote);
    },
    getDocumentInfo : function(component){
        var getDocumentInfo = component.get('c.getDocumentInfoApex');
        getDocumentInfo.setParams({ oppId: component.get('v.recordId') });
        getDocumentInfo.setCallback(this, function(response){
            if (response.getState() === 'SUCCESS' && response.getReturnValue()){
                component.set('v.users',response.getReturnValue()['users']);
                var contacts = [];
                var oppContacts = response.getReturnValue()['oppContacts'];
                if (oppContacts){
                    for (var x = 0; x < oppContacts.length; x++){
                        contacts.push({
                            Id : oppContacts[x].ContactId,
                            Name: oppContacts[x].Contact.Name,
                            Title: oppContacts[x].Role
                        });
                    }
                }
                var accountContacts = response.getReturnValue()['accountContacts'];
                if (accountContacts){
                    for (var x = 0; x < accountContacts.length; x++){
                        contacts.push({
                            Id : accountContacts[x].Id,
                            Name: accountContacts[x].Name,
                            Title: accountContacts[x].Title
                        });
                    }
                }
                component.set('v.contacts',contacts);
            }
        });
        $A.enqueueAction(getDocumentInfo);
    },
    loadPreview : function(component, event){
        var quoteId     = component.get('v.quote.Id');
        var userId      = component.find('ourContact').get("v.value");
        var contactId   = component.find('quoteContact').get("v.value");
        var text        = encodeURIComponent(component.find('documentText').get("v.value"));
        var optionals   = document.getElementById('optionalCheckbox').checked;
        var optSummary  = document.getElementById('optionalSummaryCheckbox').checked;
        var breakPage   = document.getElementById('breakPageCheckbox').checked;
        var invoices    = document.getElementById('invoicesCheckbox').checked;
        var vat         = document.getElementById('vatCheckbox').checked;
        var tnc         = document.getElementById('termsAndConditionsCheckbox').checked;
        var signed      = document.getElementById('signatureCheckbox').checked;
        var isSOW       = document.getElementById('sowCheckbox') ? document.getElementById('sowCheckbox').checked : false;
            // component.get('v.quote.SBQQ__Opportunity2__r.Account.SOWRecipient__c')
            //                 && component.get('v.quote.SBQQ__Opportunity2__r.StageName') === 'Closed Won'
            //                 && component.get('v.quote.SBQQ__Opportunity2__r.QuoteType__c') !== 'Reconciliation';

        var SOWEntity   = component.find('sowEntity') ? encodeURIComponent(component.find('sowEntity').get('v.value')) : '';
        var SOWServices = component.find('sowServices') ? encodeURIComponent(component.find('sowServices').get('v.value')) : '';
        var SOWDate     = component.find('sowDate') ? component.find('sowDate').get('v.value') : '';

        console.log('date is ' + SOWDate);


        document.getElementById('quotePreviewIFrame').src = '/apex/QuotePreview?' +
            'id=' + quoteId +
            '&userId=' + userId +
            '&contactId=' + contactId +
            '&text=' + text +
            '&optionals=' + optionals +
            '&optSummary=' + optSummary +
            '&breakPage=' + breakPage +
            '&invoices=' + invoices +
            '&vat=' + vat +
            '&draft=true' +
            '&sla=false' +
            '&tnc=' + tnc +
            '&signed=' + signed +
            '&isSOW=' + isSOW +
            '&SOWEntity=' + SOWEntity +
            '&SOWServices=' + SOWServices +
            '&SOWDate=' + SOWDate;

        component.set('v.previewChanged',false);

    },
    exportQuoteData : function(component){

        var groups = component.get('v.groups');

        var reportData = [];

        groups.forEach(function(element){

            reportData.push({
                Name : '',
                Description : '',
                Days : '',
                Quantity : '',
                UnitCost : '',
                TotalCost : '',
                UnitPrice : '',
                TotalPrice : ''
            });
            reportData.push({
                Name : element.Name.toUpperCase(),
                Description : '',
                Days : '',
                Quantity : '',
                UnitCost : '',
                TotalCost : '',
                UnitPrice : '',
                TotalPrice : ''
            });

            var lines = element.SBQQ__LineItems__r;

            lines.forEach(function(element){
                reportData.push({
                    // Name : '"' + element.SBQQ__Product__r.Name.replace(/(<([^>]+)>)/ig,"").replace(/,/g, "").replace(/\n/g, "") + '"',
                    Name : '\"' + element.SBQQ__Product__r.Name.replace('\'','') + '\"',
                    // Description : '"' + element.SBQQ__Description__c.replace(/(<([^>]+)>)/ig,"").replace(/,/g, "").replace(/\n/g, "") + '"',
                    Description : '\"' + element.SBQQ__Description__c.replace('\'','') + '\"',
                    Days : (element.SBQQ__SubscriptionTerm__c) ? element.SBQQ__SubscriptionTerm__c : ' ',
                    Quantity : element.SBQQ__Quantity__c,
                    UnitCost : element.SBQQ__UnitCost__c,
                    TotalCost : element.Line_total_cost__c,
                    UnitPrice : element.SBQQ__ListPrice__c,
                    TotalPrice : element.SBQQ__NetTotal__c
                });
            });

            reportData.push({
                Name : 'GROUP TOTAL:',
                Description : '',
                Days : '',
                Quantity : '',
                UnitCost : '',
                TotalCost : element.cosTotal,
                UnitPrice : '',
                TotalPrice : element.revTotal
            });
        });

        return reportData;
    },
    convertArrayOfObjectsToCSV : function(args){
        var result, ctr, keys, columnDelimiter, lineDelimiter, data;

        data = args.data || null;
        if (data == null || !data.length) {
            return null;
        }

        columnDelimiter = args.columnDelimiter || ',';
        lineDelimiter = args.lineDelimiter || '\n';

        keys = Object.keys(data[0]);

        result = '';
        result += keys.join(columnDelimiter);
        result += lineDelimiter;

        data.forEach(function(item) {
            ctr = 0;
            keys.forEach(function(key) {
                if (ctr > 0) result += columnDelimiter;

                result += item[key];
                ctr++;
            });
            result += lineDelimiter;
        });

        return result;
    }


})