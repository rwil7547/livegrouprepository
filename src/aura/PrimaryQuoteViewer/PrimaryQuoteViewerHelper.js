({
    getQuote : function(component, quoteId) {
        var action = component.get("c.getQuote"); 
        action.setParams({ 
            oppId : component.get("v.recordId"),
            quoteId : quoteId
        });
        action.setCallback(this, function(response){
            if (response.getState() === "SUCCESS"){
                if (response.getReturnValue()[0]){
                    component.set("v.quote", response.getReturnValue()[0]);
                    
                    if (quoteId === "default"){
                        var selectEvent = $A.get("e.c:SelectQuoteEvent");
                        selectEvent.setParams({
                            quoteId : component.get('v.quote.Id')
                        });
                        selectEvent.fire();
                    }
                    
                    //if (response.getReturnValue()[0].SBQQ__Primary__c &&
                    //    !response.getReturnValue()[0].SBQQ__R00N70000001lX7YEAU__r){
                    if (!response.getReturnValue()[0].Locked__c){
                        component.set('v.editable',true);
                        this.getDocumentInfo(component);
                    }
                    
                    this.getGroups(component, response.getReturnValue()[0].Id, response.getReturnValue()[0].SBQQ__LineItemsGrouped__c);
                    // need to add more conditions to determine if quote is editable 
                    if (component.get("v.quote.SBQQ__R00N70000001lX7YEAU__r")){
                        component.set('v.editable', false);
                        var quoteDocs = component.get("v.quote.SBQQ__R00N70000001lX7YEAU__r");
                        for (var x = 0; x < quoteDocs.length; x++){
                            if (quoteDocs[x].SBQQ__OutputFormat__c === 'PDF'){
                                component.set("v.pdf", quoteDocs[x].Id);
                            } else {
                                component.set("v.word", quoteDocs[x].Id);
                            }    
                        }
                    }
                } else {
                    component.set('v.quote',null);
                }
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
                
        var getProducts = component.get("c.getProducts"); 
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
        
        console.log('pending event fired');
        
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
                this.getQuote(component, 'default'); 
                var refresh = $A.get("e.c:Refresh");
                refresh.fire();
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
                var contacts = new Array();
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
        var userId 		= component.find('ourContact').get("v.value");
        var contactId 	= component.find('quoteContact').get("v.value");
        
        console.log('user id is ' + userId + ' contact id is ' + contactId);
        
        document.getElementById('quotePreviewIFrame').src = document.getElementById('quotePreviewIFrame').src + 
            '&userId=' + userId + 
            '&contactId=' + contactId;
    }
    
 
})