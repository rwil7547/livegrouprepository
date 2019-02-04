({
	doInit : function(component, event, helper) {
        helper.getQuote(component, 'default');
        component.set('v.ready',true);
    },
    changeQuote : function(component, event, helper){
        component.set('v.responsePending',true);
        helper.getQuote(component, event.getParam('quoteId'));       
    },
    showModal : function(component,event,helper){        
        var modal = component.find("selectorModal");
        $A.util.toggleClass(modal, "toggle");
        
        if (event.getParam("groupId")){
            component.set('v.activeGroupId',event.getParam("groupId"));
        }
    },
    hideModal : function(component,event,helper){        
        var modal = component.find("selectorModal");
        $A.util.toggleClass(modal, "toggle");
		component.set('v.activeGroupId',null);
    },
    editLine : function(component, event, helper){

        if (event.getParam('operation') === 'uncommitted'){
            var pendingChanges = component.get('v.pendingChanges');
            pendingChanges.push(event.getParam('line'));
            component.set('v.pendingChanges',pendingChanges);
        } else {        
            var lineUpdate = component.get('c.changeLineApex');
			var line = event.getParam('line');
            if (line.attributes){
                line = {
                    'sobjectType':'SBQQ__QuoteLine__c',
                    'Id' : line.Id,
                    'SBQQ__SubscriptionTerm__c' : line.SBQQ__SubscriptionTerm__c,
                    'SBQQ__Quantity__c' : line.SBQQ__Quantity__c,
                    'SBQQ__UnitCost__c' : line.SBQQ__UnitCost__c,
                    'SBQQ__ListPrice__c': line.SBQQ__ListPrice__c,
                    'SBQQ__Description__c' : line.SBQQ__Description__c
                 };
            }

            console.log('line is ' + event.getParam('line'));
            console.log('operation is ' + event.getParam('operation'));       
            
            lineUpdate.setParams({
                line : line,
                operation : event.getParam('operation') 
            });
            lineUpdate.setCallback(this, function(response){
				console.log(response.getState() + ' ' + response.getReturnValue());                
                if (response.getState() === "SUCCESS" && response.getReturnValue() !== 'error'){
                    helper.showToast('Success!', 'The quote succesfully updated.','success');
                    var refresh = $A.get("e.c:Refresh");
                	refresh.fire();
                } else {
                    helper.showToast('Error', 'There was an error updating the quote line: ' + response.getState(), 'error');
                }
                var changeResponse = $A.get("e.c:LineChangeResponse");
                changeResponse.setParams({
                    originalId : event.getParam('id'),
                    response : response.getReturnValue(),
                    operation : event.getParam('operation') 
                });
                changeResponse.fire();
                
                var pendingChanges = component.get('v.pendingChanges');
                for (var x = 0; x < pendingChanges.length; x++){
                    if (pendingChanges[x].Id === event.getParam('id')){
                    	pendingChanges.splice([x], 1);
                    }
                }
				component.set('v.pendingChanges',pendingChanges);                
            });
            $A.enqueueAction(lineUpdate);
        }
    },
    saveAll : function(component, event, helper){
        var multipleLineUpdate = $A.get("e.c:MultipleLineUpdate");
        multipleLineUpdate.fire();
        
        component.set('v.responsePending' , true);
        var pendingChanges = component.get('v.pendingChanges');
    	var saveAllLines = component.get('c.saveAllLinesApex');
        saveAllLines.setParams({lines : component.get('v.pendingChanges')});
        saveAllLines.setCallback(this, function(response){
            component.set('v.responsePending' , false);
            if (response.getState() === 'SUCCESS' && response.getReturnValue()){
                helper.showToast('Success!', pendingChanges.length + ' lines updated','success');
                var refresh = $A.get("e.c:Refresh");
                refresh.fire();
                for (var x = 0; x < pendingChanges.length; x++){
                    var changeResponse = $A.get("e.c:LineChangeResponse");
                    changeResponse.setParams({
                        originalId : pendingChanges[x].Id,
                        response : pendingChanges[x].Id,
                        operation : 'save' 
                    });
                    changeResponse.fire();
                    pendingChanges.splice([x], 1);                    
                }
				component.set('v.pendingChanges',pendingChanges);                  
            } else {
                helper.showToast('Error', 'There was an error saving the updates', 'error');                
            }
        });
        $A.enqueueAction(saveAllLines);        
	},
    groupQuote : function(component, event, helper){
        component.set('v.responsePending' , true);
    	var groupQuote = component.get('c.groupLinesApex');
        groupQuote.setParams({ quoteId : component.get('v.quote.Id')});
        groupQuote.setCallback(this, function(response){
            component.set('v.responsePending' , false);
            if (response.getState() === 'SUCCESS' && response.getReturnValue()){
                helper.showToast('Success!', 'The quote has been set to custom groupings','success');
                helper.getQuote(component, component.get('v.quote.Id'));
            } else {
                helper.showToast('Error', 'There was an error grouping the quote', 'error');              	    
            }    
        });
        $A.enqueueAction(groupQuote);        
    },
    changeGroupName : function(component, event, helper){
        var groupNameUpdate = component.get('c.changeGroupNameApex');
        groupNameUpdate.setParams({
            Id : event.getParam('id'),
        	name : event.getParam('name') 
        });
        groupNameUpdate.setCallback(this, function(response){
            if (response.getState() === "SUCCESS" && response.getReturnValue() === true){
                helper.showToast('Success!', 'The group name has been updated.','success');
            } else {
                helper.showToast('Error', 'There was an error saving your change', 'error');
            }
        });
        $A.enqueueAction(groupNameUpdate);                
    },
    addGroup : function(component,event,helper){
        var quote = component.get('v.quote');
        var groups = component.get('v.groups');
        
        var addNewGroup = component.get('c.insertNewGroupApex');
        addNewGroup.setParams({
            quoteId : quote.Id,
            groupCount : groups.length
        });
        addNewGroup.setCallback(this, function(response){
            if (response.getState() === "SUCCESS" && response.getReturnValue()['Id']){
                var groups = component.get('v.groups');
                groups.push(response.getReturnValue());
                component.set('v.groups',groups);
                helper.showToast('Success!', 'New quote group added','success');
            } else {
                helper.showToast('Error', 'There was an error adding a new quote group', 'error');
            }
        });
        $A.enqueueAction(addNewGroup);      
    },
    deleteGroup : function(component, event, helper){
        var deleteGroup = component.get('c.deleteGroupApex');
        deleteGroup.setParams({groupId : event.getParam('groupId')});
        deleteGroup.setCallback(this, function(response){
            var changeResponse = $A.get("e.c:DeleteGroupResponse");            
            if (response.getState() === "SUCCESS" && response.getReturnValue() === true){
                var refresh = $A.get("e.c:Refresh");
                refresh.fire();
                changeResponse.setParams({
                    groupId : event.getParam('groupId'),
                    result : 'success' 
                });
                helper.showToast('Success!', 'Quote group deleted','success');
            } else {
                changeResponse.setParams({
                    groupId : event.getParam('groupId'),
                    result : 'error' 
                });
                helper.showToast('Error', 'There was an error deleting this quote group', 'error');
            }            
            changeResponse.fire();
        });
        $A.enqueueAction(deleteGroup);      
    },
    insertProducts : function(component, event, helper){        
        if (component.get('v.activeGroupId')){
            helper.insertGroupedProducts(component, event);
        } else {
            helper.insertUngroupedProducts(component, event);
        }
    },
    removeGroups: function(component, event, helper){
        component.set('v.responsePending' , true);
        var removeGroups = component.get('c.ungroupLinesApex');
        removeGroups.setParams({quoteId : component.get('v.quote.Id')});
        removeGroups.setCallback(this, function(response){
            component.set('v.responsePending' , false);
            if (response.getState() === "SUCCESS"){
            	helper.getQuote(component, component.get('v.quote.Id'));
                helper.showToast('Success!', 'Custom groupings have been removed from the quote','success');        		
            } else {
                helper.showToast('Error', 'There was an error removing custom groupings from the quote', 'error');
            }
        });
        $A.enqueueAction(removeGroups);        
    },
    previewQuote : function(component, event, helper){
        component.set('v.previewing',true);
        //helper.loadPreview(component);        
        //document.getElementById('quotePreviewIFrame').src = document.getElementById('quotePreviewIFrame').src;
        //document.getElementById('quotePreview').style.display = 'block';
		//reloadPreview(component);        
    },
    hidePreview : function(component, event, helper){
        component.set('v.previewing',false);
        //document.getElementById('quotePreview').style.display = 'none';             
    },
    reloadPreview : function(component, event, helper){
        helper.loadPreview(component);
      /*  var userId 		= component.find('ourContact').get("v.value");
        var contactId 	= component.find('quoteContact').get("v.value");
        
        console.log('user id is ' + userId + ' contact id is ' + contactId);
        
        document.getElementById('quotePreviewIFrame').src = document.getElementById('quotePreviewIFrame').src + 
            '&userId=' + userId + 
            '&contactId=' + contactId; */
    },
    deleteQuote : function(component, event, helper){
		helper.deleteQuote(component);        
    },
    cloneQuote : function(component, event, helper){
        component.set('v.responsePending',true);
        var cloneQuote = component.get('c.cloneEstimateApex');
        cloneQuote.setParams({ 
            quote : component.get('v.quote'),
            oppId : component.get('v.recordId')
        });
        cloneQuote.setCallback(this, function(response){
			component.set('v.responsePending',false);
            if (response.getState() === 'SUCCESS' && response.getReturnValue() !== 'error'){
        		helper.getQuote(component, response.getReturnValue());
                helper.showToast('Success!', 'Quote cloned','success');
                var refresh = $A.get("e.c:Refresh");
                refresh.fire();
            } else {
                helper.showToast('Error', 'There was an error cloning this quote', 'error');                
            }
        });
        $A.enqueueAction(cloneQuote);
    },
    handleRefresh : function(component, event, helper){
        var getRefresh = component.get('c.getRefreshApex');
        getRefresh.setParams({ quoteId : component.get('v.quote.Id')});
        getRefresh.setCallback(this, function(response){
            if (response.getState() === 'SUCCESS'){
                var quote = component.get('v.quote');
                quote.SBQQ__NetAmount__c = response.getReturnValue().SBQQ__NetAmount__c;
                quote.Gross_Profit__c = response.getReturnValue().Gross_Profit__c;
                quote.Gross_Margin__c = response.getReturnValue().Gross_Margin__c;                
                quote.SBQQ__Primary__c = response.getReturnValue().SBQQ__Primary__c;
                component.set('v.quote', component.get('v.quote'));                
            }
        });
        $A.enqueueAction(getRefresh);
    },
    cloneGroup : function(component, event, helper){
        component.set('v.responsePending', true);
        var cloneGroup = component.get('c.cloneGroupApex');
        cloneGroup.setParams({ 
            quoteId : component.get('v.quote.Id'),
            groupId : event.getParam('groupId')
        });
        cloneGroup.setCallback(this, function(response){
			component.set('v.responsePending', false);
            if (response.getState() === 'SUCCESS' && response.getReturnValue()){
                var groups = component.get('v.groups');
                groups.push(response.getReturnValue());
                component.set('v.groups', groups);
                helper.showToast('Success!', 'Group cloned','success');
                var refresh = $A.get("e.c:Refresh");
                refresh.fire();                
            } else {
                helper.showToast('Error', 'There was an error cloning the group', 'error');                     
            }                       
        });
        $A.enqueueAction(cloneGroup);
    },
    openReconcile : function(component, event, helper){
        //document.getElementById('quickbooksCard').style.display = 'block';
        component.set('v.reconciling', true);
    },
    undoAll : function(component, event, helper){
        var pendingChanges = component.get('v.pendingChanges');
        pendingChanges.length = 0;
		component.set('v.pendingChanges', pendingChanges);
        helper.getQuote(component, 'default');    
    },
    setActiveExpenseId : function(component, event, hepler){
    	component.set('v.activeExpenseId', event.getParam('expenseId'));    
    },
    updateLineId : function(component, event, helper) {

        var activeId = component.get('v.activeExpenseId');
        var lineId 	 = event.getParam('lineId');
        var expenses = component.get('v.expenses');
        
        for (var x = 0; x < expenses.length; x++){
            if (expenses[x].Id === component.get('v.activeExpenseId')){
                var expense = Object.assign({},expenses[x]);
                expense.QuoteLine__c = event.getParam('lineId');
                expenses.splice(x,1);
                expenses.push(expense);
                component.set('v.expenses',expenses);
        		break;                                            
            }
        }
        
        var updateExpense = component.get('c.assignExpenseApex');
        updateExpense.setParams({
            lineId : event.getParam('lineId'),
            expenseId : component.get('v.activeExpenseId')
        });
        updateExpense.setCallback(this, function(response){
            if (response.getState() === "SUCCESS" && response.getReturnValue()){
                helper.showToast('Success!', 'Expense updated','success');        		
            } else {
                helper.showToast('Error', 'There was an error updating the expense', 'error');
                
            }
        });
        $A.enqueueAction(updateExpense);     
    },
    togglePrimary : function(component, event, helper){
        
        component.set('v.responsePending',true);

        var isPrimary = (component.get('v.quote.SBQQ__Primary__c')) ? false : true;


		console.log('the value of the quote primary is ' + component.get('v.quote.SBQQ__Primary__c') + ' and we ' +
                    'want to set it to set it to ' + isPrimary);
        
        var togglePrimary = component.get('c.togglePrimaryApex');
        togglePrimary.setParams({
            quoteId : component.get('v.quote.Id'),
            oppId : component.get('v.recordId'),
            isPrimary : isPrimary
        });
        togglePrimary.setCallback(this, function(response){
            component.set('v.responsePending',false);
            if (response.getState() === "SUCCESS" && response.getReturnValue()){
                helper.showToast('Success!', 'Quote updated','success');        		
                var refresh = $A.get("e.c:Refresh");
                refresh.fire(); 
            } else {
                helper.showToast('Error', 'There was an error updating the quote', 'error');                
            }
        });
        $A.enqueueAction(togglePrimary);         
        
        
    }
})