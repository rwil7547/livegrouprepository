({
    getQuote : function(component, quoteId, refreshPanel) {

        console.log('get quote method on pcv called');

        var action = component.get("c.getQuoteApex");
        action.setParams({ 
            oppId : component.get("v.recordId"),
            quoteId : quoteId
        });
        action.setCallback(this, function(response){

            if (response.getState() === "SUCCESS"){
                if (response.getReturnValue()[0]){
                    component.set("v.quote", response.getReturnValue()[0]);
                    
                    // if (quoteId === "default" || refreshPanel){
                    if (quoteId === "default"){
                        var selectEvent = $A.get("e.c:SelectQuoteEvent");
                        selectEvent.setParams({
                            quoteId : component.get('v.quote.Id')
                        });
                        selectEvent.fire();
                    }

                    if (refreshPanel){
                        console.log('refresh fired');

                        var refresh = $A.get("e.c:Refresh");
                        refresh.setParams({
                            id : component.get('v.quote.Id')
                        });
                        refresh.fire();
                    }
                    
                    if (!response.getReturnValue()[0].Locked__c){
                        console.log('unlocking quote');
                        component.set('v.editable',true);
                    } else {
                        component.set('v.editable',false);
                    }

                    if (!response.getReturnValue()[0].HasDocument__c){
                        component.set('v.revEditable',true);
                        this.getDocumentInfo(component);
                    } else {
                        component.set('v.revEditable',false);
                    }

                    this.getGroups(component, response.getReturnValue()[0].Id,
                        response.getReturnValue()[0].SBQQ__LineItemsGrouped__c);
                    // need to add more conditions to determine if quote is editable 
                    if (component.get("v.quote.SBQQ__R00N70000001lX7YEAU__r")){
                        // component.set('v.editable', false);
                        var quoteDocs = component.get("v.quote.SBQQ__R00N70000001lX7YEAU__r");
                        for (var x = 0; x < quoteDocs.length; x++){
                            if (quoteDocs[x].SBQQ__OutputFormat__c === 'PDF'){
                                component.set("v.pdf", quoteDocs[x].Id);
                            } else {
                                component.set("v.word", quoteDocs[x].Id);
                            }    
                        }
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
                }
                component.set('v.createAllowed',true);
            }
        });
        $A.enqueueAction(action);  
        
        this.getProducts(component);
		this.getExpenses(component, component.get('v.recordId'));        
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
            "title": title,
            "message": message,
            "type" : type
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

        var optionals   = document.getElementById('optionalCheckbox').checked;
        var invoices    = document.getElementById('invoicesCheckbox').checked;
        var vat         = document.getElementById('vatCheckbox').checked;

        // console.log('quote id is ' + quoteId);
        // console.log('user id is ' + userId);
        // console.log('contact id is ' + contactId);
        
        document.getElementById('quotePreviewIFrame').src = '/apex/QuotePreview?' +
            'id=' + quoteId +
            '&userId=' + userId + 
            '&contactId=' + contactId +
            '&optionals=' + optionals +
            '&invoices=' + invoices +
            '&vat=' + vat;

        console.log('should be loading the preview');

    },
    exportQuoteData : function(component){

        var groups = component.get('v.groups');

        var reportData = [];

        groups.forEach(function(element){

            var lines = element.SBQQ__LineItems__r;

            lines.forEach(function(element){
                reportData.push({Name : element.Id});
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