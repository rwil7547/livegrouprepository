({
    doInit: function (component, event, helper) {
        helper.clone(component);
        helper.calculateTotal(component, event);
        component.set('v.optional', component.get('v.line.SBQQ__Optional__c'));
    },
    openEdit: function (component, event, helper) {
        if (!component.get('v.reconciling') && component.get('v.editable') && !component.get('v.editmode')) {
            if (!document.getElementById(component.get('v.line.Id')).classList.contains('selected')) {
                document.getElementById(component.get('v.line.Id')).classList.add('selected');
                component.set('v.editmode', true);
                component.find('line').getElement().setAttribute('draggable', false);
                helper.fireOpenEdit(component.get('v.line.Id'));
            }
        }
    },
    closeEdit: function (component, event, helper) {

        if (event.getParam('Id') !== component.get('v.line.Id') &&
            document.getElementById(component.get('v.line.Id')).classList.contains('selected') &&
            !component.get('v.changed')) {
            helper.closeEdit(component);
        }
    },
    cancelEdit: function (component, event, helper) {
        helper.closeEdit(component);
    },
    setChanged: function (component, event, helper) {
        // if (!component.get('v.changed')  && event.which !== 37 && event.which !== 38
        if (event.which !== 37 && event.which !== 38 && event.which !== 39 && event.which !== 40) {
            component.set('v.changed', true);

            var line = component.get('v.line');

            console.log('before');
            console.log(line.SBQQ__Description__c);

            line.SBQQ__Description__c = line.SBQQ__Description__c.replace(/<\/p><p><br><\/p><p>/g,'\n<br><br>');
            line.SBQQ__Description__c = line.SBQQ__Description__c.replace(/<\/p><p>/g,'\n<br>');
            line.SBQQ__Description__c = line.SBQQ__Description__c.replace(/<p>/g,'');
            line.SBQQ__Description__c = line.SBQQ__Description__c.replace(/<\/p>/g,'');
            console.log('after');
            console.log(line.SBQQ__Description__c);

            helper.fireLineChange(component, line, 'uncommitted');
        }
    },
    formatPaste: function (component, e, helper) {
        e.preventDefault();
        var text = '';
        if (e.clipboardData || e.originalEvent.clipboardData) {
            text = (e.originalEvent || e).clipboardData.getData('text/plain');
        } else if (window.clipboardData) {
            text = window.clipboardData.getData('Text');
        }
        if (document.queryCommandSupported('insertText')) {
            document.execCommand('insertText', false, text);
        } else {
            document.execCommand('paste', false, text);
        }
    },
    undoChanges : function(component, event, helper){
        var line = component.get('v.original');
        component.set('v.line',line);
        component.set('v.changed', false);
        helper.fireLineChange(component, line,'undo');
    },
    save : function(component, event, helper){
        if (!component.get('v.lineUpdatesPending')){
            if (event.which === 13 && component.get('v.changed') && helper.inputValid(component)){
                component.set('v.changed', false);
                helper.closeEdit(component);
                var line = component.get('v.line');

                console.log('before');
                console.log(line.SBQQ__Description__c);

                line.SBQQ__Description__c = line.SBQQ__Description__c.replace(/<\/p><p><br><\/p><p>/g,'\n<br><br>');
                line.SBQQ__Description__c = line.SBQQ__Description__c.replace(/<\/p><p>/g,'\n<br>');
                line.SBQQ__Description__c = line.SBQQ__Description__c.replace(/<p>/g,'');
                line.SBQQ__Description__c = line.SBQQ__Description__c.replace(/<\/p>/g,'');
                console.log('after');
                console.log(line.SBQQ__Description__c);

                helper.fireLineChange(component, line,'save');
            }
        }
    },
    updateLine: function(component, event, helper){
        if (!component.get('v.lineUpdatesPending')){
            event.stopPropagation();
            if (helper.inputValid(component)){
                component.set('v.changed', false);
                helper.closeEdit(component);
                var line = component.get('v.line');

                console.log('before');
                console.log(line.SBQQ__Description__c);

                line.SBQQ__Description__c = line.SBQQ__Description__c.replace(/<\/p><p><br><\/p><p>/g,'\n<br><br>');
                line.SBQQ__Description__c = line.SBQQ__Description__c.replace(/<\/p><p>/g,'\n<br>');
                line.SBQQ__Description__c = line.SBQQ__Description__c.replace(/<p>/g,'');
                line.SBQQ__Description__c = line.SBQQ__Description__c.replace(/<\/p>/g,'');
                console.log('after');
                console.log(line.SBQQ__Description__c);

                helper.fireLineChange(component, line,'save');
            }
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
        component.set('v.changed', false);
        var line = component.get('v.line');
        helper.closeEdit(component);
        helper.fireLineChange(component, line,'optional');
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
                helper.clone(component);
            } else if (operation === 'clone' && response !== 'error'){
                var line = Object.assign({},component.get('v.line'));
                line.Id = event.getParam('response');
                line.SBQQ__Number__c = event.getParam('position');
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
                // if(response !== 'error') {
                //     console.log('destroying a line');
                //     component.destroy();
                // } else {
                //     component.find('line').getElement().style.display = 'block';
                // }
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

        console.log('the line has started dragging');
        event.stopPropagation();

        var family  = component.get('v.line.SBQQ__ProductFamily__c') ? component.get('v.line.SBQQ__ProductFamily__c') : '';
        var groupId = component.get('v.line.SBQQ__Group__c') ? component.get('v.line.SBQQ__Group__c') : family.replace(/ /g, '');
        var origin  = component.get('v.line.SBQQ__Number__c') ? component.get('v.line.SBQQ__Number__c') : 1;
        var transferData = '{"type":"Line", ' +
                            '"id":"' + component.get('v.line.Id') + '",' +
                            '"origin":' + origin + ',' +
                            '"family":"' + family + '",' +
                            '"groupId":"' + groupId + '",' +
                            '"line": ' + JSON.stringify(component.get('v.line')) + '}';
        event.dataTransfer.setData("text/plain", transferData);
    },
    dragOver : function(component, event, helper){
        if (!component.get('v.groupDragging')){
            event.preventDefault();
            component.find('line').getElement().classList.add('dragOver');
        }
     },
    dragLeave : function(component, event, helper){
        if (!component.get('v.groupDragging')) {
            component.find('line').getElement().classList.remove('dragOver');
        }
    },
    drop : function(component, event, helper){
        if (!component.get('v.groupDragging')) {

            event.stopPropagation();
            component.find('line').getElement().classList.remove('dragOver');

            var data = JSON.parse(event.dataTransfer.getData("text"));

            if (data.type === 'Line') {
                if (data.id !== component.get('v.line.Id')) {
                    if (!component.get('v.line.SBQQ__Group__c')) {
                        if (data.family === component.get('v.line.SBQQ__ProductFamily__c')) {
                            var lineOrderChange = $A.get('e.c:LineOrderChange');
                            lineOrderChange.setParams({
                                id: data.id,
                                oldPosition: data.origin,
                                newPosition: component.get('v.line.SBQQ__Number__c'),
                                sourceGroupId: data.groupId,
                                targetGroupId: component.get('v.line.SBQQ__ProductFamily__c').replace(/ /g, ''),
                                line: data.line
                            });
                            lineOrderChange.fire();
                        } else {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": 'Error',
                                "message": 'If you are not using custom groups you cannot move quote lines to another group',
                                "type": 'error'
                            });
                            toastEvent.fire();
                        }
                    } else {
                        var lineOrderChange = $A.get('e.c:LineOrderChange');

                        lineOrderChange.setParams({
                            id: data.id,
                            oldPosition: data.origin,
                            newPosition: component.get('v.line.SBQQ__Number__c'),
                            sourceGroupId: data.groupId,
                            targetGroupId: component.get('v.line.SBQQ__Group__c'),
                            line: data.line
                        });

                        if (component.get('v.line.SBQQ__Group__c') !== data.groupId) {
                            lineOrderChange.setParams({
                                targetGroupId: component.get('v.line.SBQQ__Group__c')
                            });
                        }
                        lineOrderChange.fire();
                    }
                }
            } else if (data.type === 'Expense') {
                var dropEvent = $A.get("e.c:ExpenseDrop");
                var line = component.get('v.line');
                dropEvent.setParams({lineId: line.Id});
                dropEvent.fire();
            }
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
        line.Line_total_cost__c = lineCostTotal;
        component.set('v.line',line);
        helper.fireLineChange(component, line,'save');
    }
})