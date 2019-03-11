({
    doInit : function(component, event, helper){
        if (component.get('v.lines')){
            helper.getTotals(component);
        } else {
            component.set('v.lines', new Array());
            var group = component.get('v.group');
            group.revTotal = 0;
            group.cosTotal = 0;
            component.set('v.group',group);
        }
    },
    preventDefault : function(component, event, helper){
        event.preventDefault();
    },
    dragOver : function(component, event, helper){
        if (component.get('v.groupDragging') || (component.get('v.customGroup') && !component.get('v.reconciling') &&
            !component.get('v.lines').length > 0)){
            event.preventDefault();
            document.getElementById(component.get('v.group.Id')).classList.add('dragOver');
        }
    },
    dragLeave : function(component, event, helper){
        document.getElementById(component.get('v.group.Id')).classList.remove('dragOver');
    },
    startGroupDrag : function(component, event, helper){
        component.set('v.groupDragging',true);
        var origin  = component.get('v.group.SBQQ__Number__c') ? component.get('v.group.SBQQ__Number__c') : 1;
        var transferData = '{"type":"Group", ' +
            '"id":"' + component.get('v.group.Id') + '",' +
            '"origin":' + origin +
            '}';
        event.dataTransfer.setData("text/plain", transferData);
    },
    endGroupDrag : function(component, event, helper){
        component.set('v.groupDragging',false);
    },
    drop : function(component, event, helper){
        document.getElementById(component.get('v.group.Id')).classList.remove('dragOver');
        if (component.get('v.groupDragging') || component.get('v.customGroup') && !component.get('v.reconciling') &&
            !component.get('v.lines').length > 0){

            var data = JSON.parse(event.dataTransfer.getData("text"));

            if (data.type === 'Line'){

                var lineOrderChange = $A.get('e.c:LineOrderChange');

                lineOrderChange.setParams({
                    id : data.id,
                    oldPosition : data.origin,
                    newPosition : null,
                    sourceGroupId : data.groupId,
                    targetGroupId : component.get('v.group.Id'),
                    line : data.line
                });

                lineOrderChange.fire();
            } else if (data.type === 'Group'){
                if (component.get('v.group.Id') !== data.id){
                    var groupOrderChange = $A.get('e.c:GroupOrderChange');

                    var targetPosition = component.get('v.group.SBQQ__Number__c') ? component.get('v.group.SBQQ__Number__c') : 1;

                    groupOrderChange.setParams({
                        sourceId : data.id,
                        sourcePosition : data.origin,
                        targetPosition : targetPosition
                    });

                    groupOrderChange.fire();
                }
            }
        }
    },
    editGroupName : function(component, event, helper){
        if (component.get('v.editable') && component.get('v.customGroup') && !component.get('v.hasDocument')){
        	document.getElementById(component.get('v.group.Id') + 'name').style.display = 'none';
        	document.getElementById(component.get('v.group.Id') + 'nameEdit').style.display = 'block';    
        }
	},
    saveGroupName : function(component, event, helper){
        if (event.keyCode === 13) {
            document.getElementById(component.get('v.group.Id') + 'name').style.display = 'flex';
            document.getElementById(component.get('v.group.Id') + 'nameEdit').style.display = 'none';
            
            var nameChange = component.getEvent('groupNameChangeUp');
            nameChange.setParams({
                id : component.get('v.group.Id'),
                name : component.get('v.group.Name')
            });
            nameChange.fire();
  		}
    },
    showProducts : function(component, event, helper){
        var groupEvent = component.getEvent('addGroupProducts');
        groupEvent.setParams({
            'groupId' : component.get('v.group.Id')
        });
        groupEvent.fire()
    },
    deleteGroup : function(component, event, helper){
        var deleteEvent = component.getEvent('deleteGroup');
        deleteEvent.setParams({groupId : component.get('v.group.Id')});
        deleteEvent.fire();
        component.set('v.responsePending',true);
    },
    handleDeleteResponse : function(component, event, helper){
        if (event.getParam('groupId') === component.get('v.group.Id')){
            component.set('v.responsePending',false);
            if (event.getParam('result') === 'success'){
                component.destroy();
            }
        }
    },
    handleAddLinesResponse : function(component, event, helper){
        if (event.getParam('groupId') === component.get('v.group.Id')){
            component.set('v.responsePending',false);           
            var lines = component.get('v.lines');
            for (var x = 0; x < event.getParam('lines').length; x++){
            	lines.push(event.getParam('lines')[x]);    
            }            
            component.set('v.lines',lines);
        }        
    },
    handleLineCloned : function(component, event, helper){
    	var lines = component.get('v.lines');
        var newLines = [];

        for (var x = 0; x < lines.length; x++){
            newLines.push(lines[x]);
            if (lines[x].Id === event.getParam('originalId')){
                newLines.push(event.getParam('line'));
            }
        }
        component.set('v.lines', newLines);
    },
    handleLineChange : function(component, event, helper){

        console.log('handling a line change');

        if (event.getParam('operation') === 'update'){
            var lines = component.get('v.lines');
            var lineUpdate = event.getParam('line');
            lines.forEach(function(element){
               if (element.Id === lineUpdate.Id){
                   element = lineUpdate;
               }
            });
            component.set('v.lines',lines);

        } else if (event.getParam('operation') === 'delete'){

            console.log('assessing if delete');

            if (!component.get('v.customGroup')){
                if (component.get('v.lines').length === 0){
                    component.destroy();
                }
            }
        }
    },
    handleLineDelete : function(component, event, helper){

        console.log('handling line delete');

        if (event.getParam('operation') === 'delete'){

            var lines = component.get('v.lines');
            var newLines = [];

            for (var x = 0; x < lines.length; x++){
                newLines.push(lines[x]);
                if (lines[x].Id === event.getParam('originalId')){
                    console.log('splicing line');

                    newLines.splice(x,1);

                }
            }
            component.set('v.lines', newLines);


            if (!component.get('v.customGroup') && component.get('v.lines').length === 0){
                component.destroy();
            }

        }
    },
    responsePending : function(component, event, helper){
        if (event.getParam('groupId') === component.get('v.group.Id')){
            component.set('v.responsePending',true);
        }
    },
    cloneGroup : function(component, event, helper){
        var cloneGroup = component.getEvent('cloneGroup');
        cloneGroup.setParams({ groupId : component.get('v.group.Id')});
        cloneGroup.fire();
    },
    orderLines : function(component, event, helper){

        // check if group is target
        if (event.getParam('targetGroupId') === component.get('v.group.Id')){

            var lines = component.get('v.lines');

            // check if line is new to group
            if (event.getParam('targetGroupId') !== event.getParam('sourceGroupId')){
                var newLine = event.getParam('line');
                newLine.SBQQ__Group__c = component.get('v.group.Id');
                lines.push(newLine);
            }

            var oldPosition = event.getParam('oldPosition');
            var newPosition = event.getParam('newPosition');
            var changeId = event.getParam('id');

            if (oldPosition > newPosition) {
                lines.forEach(function(element){
                    if (element.Id === changeId){
                        element.SBQQ__Number__c = newPosition;
                    } else if (element.SBQQ__Number__c <= oldPosition && element.SBQQ__Number__c >= newPosition){
                        element.SBQQ__Number__c = element.SBQQ__Number__c +1;
                    }
                });
            } else {
                lines.forEach(function(element){
                    if (element.Id === changeId){
                        element.SBQQ__Number__c = newPosition;
                    } else if (element.SBQQ__Number__c <= newPosition && element.SBQQ__Number__c >= oldPosition){
                        element.SBQQ__Number__c = element.SBQQ__Number__c -1;
                    }
                });
            }

            lines.sort(function (a, b) {
                return a.SBQQ__Number__c - b.SBQQ__Number__c;
            });

            component.set('v.lines', lines);
            helper.getTotals(component);

        } else if (event.getParam('sourceGroupId') === component.get('v.group.Id')){

            // check if line is new to group
            if (event.getParam('targetGroupId') !== event.getParam('sourceGroupId')){

                var lines = component.get('v.lines');
                for (var x = 0; x < lines.length; x++){
                    if (lines[x].Id === event.getParam('id')){
                        lines.splice([x], 1);
                    }
                }
                component.set('v.lines',lines);
                helper.getTotals(component);
            }
        }
    }
})