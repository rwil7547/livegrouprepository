({
	getTotals : function(component) {
        var lines = component.get('v.lines');
        var cosTotal = lines.reduce(function (total, line) {
            var amount = (line.SBQQ__Optional__c) ? 0 : line.Line_total_cost__c;
            return total + amount;
        },0);
        var revTotal = lines.reduce(function (total, line) {
            var amount = (line.SBQQ__Optional__c) ? 0 : line.SBQQ__NetTotal__c;  
            return total + amount;
        },0);

        var group = component.get('v.group');
        group.revTotal = !revTotal ? 0 : revTotal;
        group.cosTotal = !cosTotal ? 0 : cosTotal;
        component.set('v.group',group);
    }
})