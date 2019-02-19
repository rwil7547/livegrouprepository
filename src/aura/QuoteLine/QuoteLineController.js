({
    doInit : function(component, event, helper){

		// helper.clone(component);
        helper.calculateTotal(component, event);




    },
    openEdit : function(component, event, helper) {
        if (!component.get('v.reconciling') && component.get('v.editable') && !component.get('v.editmode')){
            if (!document.getElementById(component.get('v.line.Id')).classList.contains('selected')){
                document.getElementById(component.get('v.line.Id')).classList.add('selected');
                component.set('v.editmode', true);
                helper.fireOpenEdit(component.get('v.line.Id'));
            }
        }
    },
    closeEdit: function(component, event, helper) {

        console.log('line is ' + component.get('v.line'));

        if(event.getParam('Id') !== component.get('v.line.Id') &&
            document.getElementById(component.get('v.line.Id')).classList.contains('selected') &&
            !component.get('v.changed')){
            helper.closeEdit(component);
        }
    },
    cancelEdit: function(component, event, helper){
        helper.closeEdit(component);
    },
    setChanged: function(component, event, helper){
        if (!component.get('v.changed')){
            if (event.getParam("oldValue") !== event.getParam("value") &&
                event.getParam('index')){
                component.set('v.changed',true);
                helper.fireLineChange(component, component.get('v.line'),'uncommitted');
            }
        }
    },
    undoChanges : function(component, event, helper){
        var clone = JSON.parse(JSON.stringify(component.get('v.original')));
        component.set('v.line',clone);
        component.set('v.changed', false);
    },
    save : function(component, event, helper){

        if (event.which === 13 && helper.inputValid(component)){
            // component.set('v.responsePending',true);
            component.set('v.changed', false);
            helper.closeEdit(component);
            var line = component.get('v.line');
            line.SBQQ__Description__c = helper.formatDescription(line.SBQQ__Description__c);
            helper.fireLineChange(component, line,'save');

        }  
    },
    updateLine: function(component, event, helper){
        event.stopPropagation();
        if (helper.inputValid(component)){
            // component.set('v.responsePending',true);
            component.set('v.changed', false);
            helper.closeEdit(component);
            var line = component.get('v.line');
            line.SBQQ__Description__c = helper.formatDescription(line.SBQQ__Description__c);
            helper.fireLineChange(component, line,'save');
        }

    },  
    cloneLine: function(component, event, helper){
        event.stopPropagation();
        component.set('v.responsePending',true);
        component.set('v.changed', false);
        helper.closeEdit(component);
        helper.fireLineChange(component, component.get('v.line'),'clone');
    },
    toggleLineOptional: function(component, event, helper){
        event.stopPropagation();
        // component.set('v.responsePending',true);
        component.set('v.changed', false);
        var line = component.get('v.line');
        helper.closeEdit(component);
        helper.fireLineChange(component, component.get('v.line'),'optional');
        component.set('v.optional', !component.get('v.optional'));
    },
    deleteLine: function(component, event, helper){
        event.stopPropagation();
        component.find('line').getElement().style.display = 'none';
        component.set('v.changed', false);
        helper.closeEdit(component);
        helper.fireLineChange(component, component.get('v.line'),'delete');
    },
    processChangeResponse : function(component, event, helper){
        if (component.get('v.line.Id') === event.getParam('originalId')){
            component.set('v.responsePending',false);
            var operation = event.getParam('operation');
            var response = event.getParam('response');
            if (operation === 'save' && response !== 'error'){   
                var clone = JSON.parse(JSON.stringify(component.get('v.line')));
                component.set('v.original',clone);
                component.set('v.changed', false);           
            } else if (operation === 'clone' && response !== 'error'){
                var line = Object.assign({},component.get('v.line'));
                line.Id = event.getParam('response');
                var clonedLine = component.getEvent('clonedLine');
                clonedLine.setParams({
                    line : line,
                    originalId : component.get('v.line.Id')
                });
                clonedLine.fire();
            } else if (operation === 'optional'){
                if (response !== 'error') {
                    var line = component.get('v.line');
                    if (line.SBQQ__Optional__c) {
                        line.SBQQ__Optional__c = false;
                    } else {
                        line.SBQQ__Optional__c = true;
                    }
                    component.set('v.line', line);
                } else {
                    component.set('v.optional', !component.get('v.optional'));
                }
            } else if (operation === 'delete'){
                if(response !== 'error') {
                    component.destroy();
                } else {
                    component.find('line').getElement().style.display = 'block';
                }
            }
        }
    },
    handleMultiLineUpdate : function(component, event, helper){
        if (component.get('v.changed')){
            component.set('v.responsePending',true);
            component.set('v.changed', false);
            helper.closeEdit(component); 
        }
    },
    startLineDrag : function(component, event, helper){
        var family = component.get('v.line.SBQQ__ProductFamily__c') ? component.get('v.line.SBQQ__ProductFamily__c') : '';
        var transferData = '{"type":"Line", ' +
                            '"id":"' + component.get('v.line.Id') + '",' +
                            '"origin":' + component.get('v.line.SBQQ__Number__c') + ',' +
                            '"family":"' + family + '",' +
                            '"groupId":"' + component.get('v.line.SBQQ__Group__c') + '"}';
        event.dataTransfer.setData("text/plain", transferData);
    },
    dragOver : function(component, event, helper){
        event.preventDefault();
        component.find('line').getElement().classList.add('dragOver');
    },
    dragLeave : function(component, event, helper){
        component.find('line').getElement().classList.remove('dragOver');
    },
    drop : function(component, event, helper){
        event.stopPropagation();
        component.find('line').getElement().classList.remove('dragOver');


        console.log(event.dataTransfer.getData("text"));

        var data = JSON.parse(event.dataTransfer.getData("text"));

        if (data.type === 'Line'){
            if (data.id !== component.get('v.line.Id')){
                if (!component.get('v.line.SBQQ__Group__c')){
                    if (data.family === component.get('v.line.SBQQ__ProductFamily__c')){
                        var lineOrderChange = component.getEvent('lineOrderChange');
                        lineOrderChange.setParams({
                            id : data.id,
                            oldPosition : data.origin,
                            newPosition : component.get('v.line.SBQQ__Number__c'),
                            targetGroupId : 'none'
                        });
                        lineOrderChange.fire();
                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": 'Error',
                            "message": 'If you are not using custom groups you cannot move quote lines to another group',
                            "type" : 'error'
                        });
                        toastEvent.fire();
                    }

                } else {

                    var lineOrderChange = component.getEvent('lineOrderChange');
                    lineOrderChange.setParams({
                        id : data.id,
                        oldPosition : data.origin,
                        newPosition : component.get('v.line.SBQQ__Number__c'),
                        targetGroupId : 'none'
                    });

                    if (component.get('v.line.SBQQ__Group__c') !== data.groupId){
                        lineOrderChange.setParams({
                            targetGroupId : component.get('v.line.SBQQ__Group__c')
                        });
                    }
                    lineOrderChange.fire();
                }
            }
        } else if (data.type === 'Expense'){
            var dropEvent = $A.get("e.c:ExpenseDrop");
            var line = component.get('v.line');
            dropEvent.setParams({ lineId : line.Id});
            dropEvent.fire();
        }


    },
    changeSortOrder : function(component, event, helper){
        var line = component.get('v.line');
        line.SBQQ__Number__c = component.get('v.sortOrder');
        component.set('v.line', line);
    },
    calculateTotal : function(component, event, helper){
        helper.calculateTotal(component, event);
    },
    reconcileLine : function(component, event, helper){

        var line = component.get('v.line');
        var expensesTotal = component.get('v.expensesTotal');
        
        var unitCost = (!line.SBQQ__SubscriptionTerm__c) ?
            expensesTotal / line.SBQQ__Quantity__c :
        	expensesTotal / line.SBQQ__Quantity__c / line.SBQQ__SubscriptionTerm__c;

        var lineCostTotal = (!line.SBQQ__SubscriptionTerm__c) ?
            unitCost * line.SBQQ__Quantity__c :
            unitCost * line.SBQQ__Quantity__c * line.SBQQ__SubscriptionTerm__c;

        line.SBQQ__UnitCost__c = unitCost;
        line.Line_cost_total__c = lineCostTotal;
        component.set('v.line',line);
        helper.fireLineChange(component, line,'save');
    }
})