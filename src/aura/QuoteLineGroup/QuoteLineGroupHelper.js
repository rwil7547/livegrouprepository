({
	getTotals : function(component) {

	    console.log('calculating group totals');

        var lines = component.get('v.lines');
        var cosTotal = lines.reduce(function (total, line) {
            var amount = (line.SBQQ__Optional__c) ? 0 : line.Line_cost_total__c;             
            return total + amount;
        },0);
        var revTotal = lines.reduce(function (total, line) {
            var amount = (line.SBQQ__Optional__c) ? 0 : line.SBQQ__NetTotal__c;  
            return total + amount;
        },0);
        // component.set('v.cosTotal', cosTotal);
        // component.set('v.revTotal', revTotal);

        var group = component.get('v.group');
        group.revTotal = revTotal;
        group.cosTotal = cosTotal;
        component.set('v.group',group);
    }
})