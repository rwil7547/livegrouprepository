({
	doInit : function(component, event, helper) {
        helper.getQuote(component, 'default', false);
        component.set('v.ready',true);
    },
    changeQuote : function(component, event, helper){

        if (event.getParam('quoteId') !== component.get('v.quote.Id') && event.getParam('quoteId') !== 'default'){

            console.log('changing quote because id is ' + event.getParam('id') + ' and qquote id is ' + component.get('v.quote.Id'));

            component.set('v.responsePending',true);
            helper.getQuote(component, event.getParam('quoteId'), false);
        }
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

        if (event.getParam('operation') === 'uncommitted'){
            var pendingChanges = component.get('v.pendingChanges');
            pendingChanges.push(line);
            component.set('v.pendingChanges',pendingChanges);
        } else if (event.getParam('operation') === 'undo'){
            var pendingChanges = component.get('v.pendingChanges');
            for (var x = 0; x < pendingChanges.length; x++){
                if (pendingChanges[x].Id === event.getParam('id')){
                    pendingChanges.splice([x], 1);
                }
            }
            component.set('v.pendingChanges',pendingChanges);
        } else {
            component.set('v.lineUpdatesPending',true);
            var lineUpdate = component.get('c.changeLineApex');

            lineUpdate.setParams({
                line : line,
                operation : event.getParam('operation') 
            });
            lineUpdate.setCallback(this, function(response){
				// console.log(response.getState() + ' ' + response.getReturnValue());
                if (response.getState() === "SUCCESS" && response.getReturnValue() !== 'error'){
                    helper.showToast('Success!', 'The quote successfully updated.','success');
                    var refresh = $A.get("e.c:Refresh");
                    refresh.setParams({
                        id : component.get('v.quote.Id'),
                        quote : component.get('v.quote')
                    });
                	refresh.fire();

                    var pendingChanges = component.get('v.pendingChanges');
                    for (var x = 0; x < pendingChanges.length; x++){
                        if (pendingChanges[x].Id === event.getParam('id')){
                            pendingChanges.splice([x], 1);
                        }
                    }
                    component.set('v.pendingChanges',pendingChanges);
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
                
            });
            $A.enqueueAction(lineUpdate);
        }
    },
    saveAll : function(component, event, helper){
        var multipleLineUpdate = $A.get("e.c:MultipleLineUpdate");
        multipleLineUpdate.fire();
        
        component.set('v.responsePending' , true);
        component.set('v.lineUpdatesPending',true);
        var pendingChanges = component.get('v.pendingChanges');
    	var saveAllLines = component.get('c.saveAllLinesApex');
        saveAllLines.setParams({
            lines : component.get('v.pendingChanges')
        });
        saveAllLines.setCallback(this, function(response){
            component.set('v.responsePending' , false);

            if (response.getState() === 'SUCCESS' && response.getReturnValue()){
                helper.showToast('Success!', pendingChanges.length + ' lines updated','success');
                var refresh = $A.get("e.c:Refresh");
                refresh.setParams({
                    id : component.get('v.quote.Id')
                });
                refresh.fire();
                var length = pendingChanges.length;
                for (var x = 0; x < length; x++){
                    var changeResponse = $A.get("e.c:LineChangeResponse");
                    changeResponse.setParams({
                        originalId : pendingChanges[x].Id,
                        response : pendingChanges[x].Id,
                        operation : 'save' 
                    });
                    changeResponse.fire();
                    // pendingChanges.splice([x], 1);
                }
				// component.set('v.pendingChanges',pendingChanges);
				component.set('v.pendingChanges',[]);
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
            // component.set('v.responsePending' , false);
            if (response.getState() === 'SUCCESS' && response.getReturnValue()){
                helper.showToast('Success!', 'The quote has been set to custom groupings','success');
                helper.getQuote(component, component.get('v.quote.Id'), false);
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
        component.set('v.lineUpdatesPending',true);

        var deleteGroup = component.get('c.deleteGroupApex');
        deleteGroup.setParams({
            groupId : event.getParam('groupId'),
            quoteId : component.get('v.quote.Id')
        });
        deleteGroup.setCallback(this, function(response){
            var changeResponse = $A.get("e.c:DeleteGroupResponse");            
            if (response.getState() === "SUCCESS" && response.getReturnValue() === true){
                var refresh = $A.get("e.c:Refresh");
                refresh.setParams({
                    id : component.get('v.quote.Id')
                });
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
        component.set('v.lineUpdatesPending',true);

        if (component.get('v.activeGroupId')){
            helper.insertGroupedProducts(component, event);
        } else {
            helper.insertUngroupedProducts(component, event);
        }
    },
    removeGroups: function(component, event, helper){
        component.set('v.responsePending' , true);
        var removeGroups = component.get('c.ungroupLinesApex');
        removeGroups.setParams({
            quoteId : component.get('v.quote.Id')
        });
        removeGroups.setCallback(this, function(response){
            if (response.getState() === "SUCCESS"){
            	helper.getQuote(component, component.get('v.quote.Id'), false);
                helper.showToast('Success!', 'Custom groupings have been removed from the quote','success');        		
            } else {
                helper.showToast('Error', 'There was an error removing custom groupings from the quote', 'error');
            }
        });
        $A.enqueueAction(removeGroups);        
    },
    previewQuote : function(component, event, helper){
        if (!component.find('ourContact').get('v.value')){
            console.log('user is ' + component.get('v.users')[0]);

            component.find('ourContact').set('v.value', component.get('v.users')[0].Id);

        }
        if (!component.find('quoteContact').get('v.value')) {
            console.log('contact is ' + component.get('v.contacts')[0]);

            component.find('quoteContact').set('v.value', component.get('v.contacts')[0].Id);
        }
        component.find('clonePreviewModal').getElement().classList.toggle('toggle');
        helper.loadPreview(component);
    },
    hidePreview : function(component, event, helper){
        component.find('clonePreviewModal').getElement().classList.toggle('toggle');
    },
    reloadPreview : function(component, event, helper){
        helper.loadPreview(component);
    },
    setPreviewChanged : function(component, event, helper){
	    component.set('v.previewChanged',true);
    },
    selectOption : function(component, event, helper){
	    document.getElementById(event.target.id + 'Checkbox').checked =
            !document.getElementById(event.target.id + 'Checkbox').checked;
        component.set('v.previewChanged',true);
    },
    showDocument : function(component, event, helper){
	    var showDocument = $A.get('e.c:ShowDocument');
	    showDocument.setParams({
            quoteId : component.get('v.quote.Id')
        });
	    showDocument.fire();
    },
    changeTab : function(component, event, helper){
        var selectedId  = component.find('quoteTabs').get('v.selectedTabId');
	    var previewTabs = document.getElementsByClassName('previewTab');
	    for (var x = 0; x <previewTabs.length; x++){
            if (previewTabs[x].id === selectedId){
                previewTabs[x].style.display = 'block';
            } else {
                previewTabs[x].style.display = 'none';
            }
        }
    },
    saveDocument : function(component, event, helper){

	    component.find('docSavePending').getElement().style.display = 'block';

        var userId 		= component.find('ourContact').get("v.value");
        var contactId 	= component.find('quoteContact').get("v.value");

        var saveDocument = component.get('c.saveDocumentApex');
        saveDocument.setParams({
            quoteId : component.get('v.quote.Id'),
            oppId : component.get('v.recordId'),
            userId : userId,
            contactId : contactId
        });
        saveDocument.setCallback(this, function(response){
            component.find('docSavePending').getElement().style.display = 'none';
            if (response.getState() === 'SUCCESS' && response.getReturnValue()){
                // component.set('v.previewing',false);
                component.find('quotePreview').getElement().style.display = 'none';

                var refresh = $A.get("e.c:Refresh");
                refresh.setParams({
                    id : component.get('v.quote.Id')
                });
                refresh.fire();
                helper.showToast('Success!', 'Document created','success');
            } else {
                helper.showToast('Error', 'There was an error creating the document', 'error');
            }
        });
        $A.enqueueAction(saveDocument);

    },
    deleteQuote : function(component, event, helper){
		helper.deleteQuote(component);        
    },
    showCloneModal : function(component){

        var modal = component.find("cloneQuoteModal");
        $A.util.toggleClass(modal, "toggle");

        if (component.get('v.opportunities').length === 0){
            var getOpportunities = component.get('c.getOpportunitiesApex');
            getOpportunities.setParams({
                currentOppId : component.get('v.recordId')
            });
            getOpportunities.setCallback(this, function(response){
                if (response.getState() === 'SUCCESS' && response.getReturnValue()){
                    component.set('v.opportunities', response.getReturnValue());
                }
            });
            $A.enqueueAction(getOpportunities);
        }
    },
    clearOpportunity : function(component, event, helper){
	    document.getElementById('opplistInput').value = null;
        document.getElementById('thisOpportunity').checked = true;
        document.getElementById('otherOpportunity').checked = false;
        document.getElementById('cloneButton').style.display = 'block';
    },
    deselectThisOpportunity : function(component, event, helper){

        document.getElementById('thisOpportunity').checked = false;
        document.getElementById('otherOpportunity').checked = true;

        if (document.getElementById('opplistInput').value ){
            // document.getElementById('thisOpportunity').checked = false;
            // document.getElementById('otherOpportunity').checked = true;
            document.getElementById('cloneButton').style.display = 'block';
        } else if (document.getElementById('otherOpportunity').checked === true){
            document.getElementById('cloneButton').style.display = 'none';
            document.getElementById('thisOpportunity').checked = false;
        }
    },

    cloneQuote : function(component, event, helper){

        var modal = component.find("cloneQuoteModal");
        $A.util.toggleClass(modal, "toggle");
        var oppId;
        var type;

        if (document.getElementById('opplistInput').value){
            var jobNumber = document.getElementById('opplistInput').value.toString().substring(0,5);
            var opps = component.get('v.opportunities');
            opps.forEach(function(element){
               if (element.Filtered_Job_Number__c == jobNumber){
                   oppId = element.Id;
                   type = 'Estimate';
               }
            });
        } else {
            oppId = component.get('v.recordId');
            type = component.get('v.quote.Stage__c');
        }

        component.set('v.responsePending',true);
        var cloneQuote = component.get('c.cloneEstimateApex');
        cloneQuote.setParams({
            quote : component.get('v.quote'),
            oppId : oppId,
            type : type
        });
        cloneQuote.setCallback(this, function(response){
            component.set('v.responsePending',false);
            if (response.getState() === 'SUCCESS' && response.getReturnValue() !== 'error'){
                if (oppId !== component.get('v.recordId')){
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": oppId
                    });
                    navEvt.fire();
                    $A.get('e.force:refreshView').fire();
                } else {
                    helper.getQuote(component, response.getReturnValue(), true);
                    helper.showToast('Success!', 'Quote cloned','success');
                }
            } else {
                helper.showToast('Error', 'There was an error cloning this quote', 'error');
            }
        });
        $A.enqueueAction(cloneQuote);
    },
    hideCloneModal : function(component,event,helper){
        var modal = component.find("cloneQuoteModal");
        $A.util.toggleClass(modal, "toggle");
    },
    createNewEstimate : function(component, event, helper){
        component.set('v.responsePending',true);
        var newQuote = component.get('c.createNewEstimateApex');
        newQuote.setParams({
            oppId : component.get('v.recordId')
        });
        newQuote.setCallback(this, function(response){
            component.set('v.responsePending',false);

            if (response.getState() === 'SUCCESS' && response.getReturnValue() !== 'error'){
                helper.getQuote(component, response.getReturnValue(), true);
                helper.showToast('Success!', 'New estimate created','success');
            } else {
                helper.showToast('Error', 'There was an error creating a new estimate', 'error');
            }
        });
        $A.enqueueAction(newQuote);
    },
    handleRefresh : function(component, event, helper){
        var getRefresh = component.get('c.getRefreshApex');
        getRefresh.setParams({
            quoteId : component.get('v.quote.Id'),
            customGroups : component.get('v.customGroups')
        });
        getRefresh.setCallback(this, function(response){
            if (response.getState() === 'SUCCESS'){

                var quote = component.get('v.quote');
                quote.SBQQ__NetAmount__c = response.getReturnValue()['SBQQ__NetAmount__c'];
                quote.Cost_of_sale__c = response.getReturnValue()['Cost_of_sale__c'];
                quote.Gross_Profit__c = response.getReturnValue()['Gross_Profit__c'];
                quote.Gross_Margin__c = response.getReturnValue()['Gross_Margin__c'];
                quote.SBQQ__Primary__c = response.getReturnValue()['SBQQ__Primary__c'];
                component.set('v.quote', component.get('v.quote'));

                var groups = component.get('v.groups');
                if (groups){
                    groups.forEach(function(group){

                        console.log('total for group returned is ' + response.getReturnValue()['rev' + group.Id]);

                        group.revTotal = !response.getReturnValue()['rev' + group.Id] ? 0 :
                            response.getReturnValue()['rev' + group.Id];
                        group.cosTotal = !response.getReturnValue()['cos' + group.Id] ? 0 :
                            response.getReturnValue()['cos' + group.Id];
                    });
                }

                component.set('v.groups',groups);
                component.set('v.lineUpdatesPending',false);
            }
        });
        $A.enqueueAction(getRefresh);
    },
    cloneGroup : function(component, event, helper){
        component.set('v.responsePending', true);
        component.set('v.lineUpdatesPending',true);
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
                refresh.setParams({
                    id : component.get('v.quote.Id')
                });
                refresh.fire();                
            } else {
                helper.showToast('Error', 'There was an error cloning the group', 'error');                     
            }                       
        });
        $A.enqueueAction(cloneGroup);
    },
    openReconcile : function(component, event, helper){
        component.set('v.reconciling', true);
        var selectEvt = $A.get("e.c:LineSelected");
        selectEvt.setParams({ "Id" : '' });
        selectEvt.fire();
    },
    closeReconcile : function(component, event, helper){
        component.set('v.reconciling', false);
    },
    undoAll : function(component, event, helper){
        var pendingChanges = component.get('v.pendingChanges');
        pendingChanges.length = 0;
		component.set('v.pendingChanges', pendingChanges);
        helper.getQuote(component, 'default', false);
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
        var isPrimary = (component.get('v.quote.SBQQ__Primary__c')) ? false : true;

        var togglePrimary = component.get('c.togglePrimaryApex');
        togglePrimary.setParams({
            quoteId : component.get('v.quote.Id'),
            oppId : component.get('v.recordId'),
            isPrimary : isPrimary
        });
        togglePrimary.setCallback(this, function(response){
            if (response.getState() === "SUCCESS" && response.getReturnValue()){
                helper.showToast('Success!', 'Quote updated','success');
                component.set('v.quote.SBQQ__Primary__c', isPrimary);
                console.log('firing refresh event');
                var refresh = $A.get("e.c:Refresh");
                refresh.setParams({
                    id : component.get('v.quote.Id')
                });
                refresh.fire(); 
            } else {
                helper.showToast('Error', 'There was an error updating the quote', 'error');                
            }
        });
        $A.enqueueAction(togglePrimary);         
    },
    orderLines : function(component, event, helper){

        var changeSortOrder = component.get('c.changeSortOrderApex');
        changeSortOrder.setParams({
            quoteId : component.get('v.quote.Id'),
            lineId : event.getParam('id'),
            oldPosition : event.getParam('oldPosition'),
            newPosition : event.getParam('newPosition'),
            targetGroupId : event.getParam('targetGroupId')
        });
        changeSortOrder.setCallback(this, function(response){
            if (response.getState() === "SUCCESS" && response.getReturnValue() === 'success'){
                helper.showToast('Success!', 'Line order changed','success');
                // if (event.getParam('targetGroupId') !== 'none'){
                //     helper.getQuote(component, component.get('v.quote.Id'), false);
                // }
            } else {
                helper.showToast('Error', 'There was an error changing the line order', 'error');
            }
        });
        $A.enqueueAction(changeSortOrder);
    },
    exportQuote : function(component, event, helper){

        var args = helper.exportQuoteData(component);
        var data, filename, link;
        var csv = helper.convertArrayOfObjectsToCSV({
            data: args
        });
        if (csv == null) return;

        filename = args.filename || 'QuoteExport.csv';

        if (!csv.match(/^data:text\/csv/i)) {
            csv = 'data:text/csv;charset=utf-8,' + csv;
        }
        data = encodeURI(csv);

        link = document.createElement('a');
        link.setAttribute('href', data);
        link.setAttribute('download', filename);
        link.click();
    }
})