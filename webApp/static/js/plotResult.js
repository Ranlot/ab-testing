$(document).ready(function() {

	$('#params_submit').click(function(event) {
		event.preventDefault();
		var pStar = $('input[name=pStar]').val();
		var pBaseLine = $('input[name=pBaseLine]').val();
		plotResult(pStar, pBaseLine);

	});

});

function addCommas(intNum) {
  return (intNum + '').replace(/(\d)(?=(\d{3})+$)/g, '$1,');
}

var convData = {
	element: 'plotConv',
	xkey: 'x',
	ykeys: ['y'],
	labels: ['y'],
	parseTime: false,
	lineColors: ['#990012'],
	pointSize: 0,
	grid: true,
	gridTextColor: '#000000',
	verticalGrid: true,
	fillOpacity: 0.7,
	yLabelFormat: function (y) { return y.toFixed(1) + "%"; },
	hideHover: false,
	hoverCallBack: function (index, options, content, row) { return content; }
};


var histoData = {
	element: 'plotHisto',
	xkey: 'x',
	ykeys: ['y'],
	labels: ['y'],
	lineColors: ['#0000A0'],
	parseTime: false,
	eventStrokeWidth: 5,
	gridTextColor: '#000000',
	eventLineColors: ['#85BB65'],
	pointSize: 0,
	fillOpacity: 0.7,
	yLabelFormat: function (x) { return x.toFixed(2); },
	xLabelFormat: function (x) { return x['label'].toFixed(4); }
};


function plotResult(pStar, pBaseLine) {

	var guaranteedRateChange = 100. * (pStar - pBaseLine) / pBaseLine

	var queryResult = $.ajax({type:'POST', url:'/res', data:JSON.stringify({'pStar':pStar, 'pBaseLine':pBaseLine}), dataType:"json", contentType: "application/json"})

	queryResult.done(function(data) {

		//console.log(data);

		var maxSampleSize = 5000;  //this value should actually be inherited from the backend....

		var plotData = data['data']
		var sampleSizeCut = data['sampleSizeCut']

		if (pStar === pBaseLine) {
			var text2print = "probability of getting significant p-value even though there is absolutely no difference"
		} else if (pStar < pBaseLine)  {
			var text2print = sampleSizeCut <= maxSampleSize ? "chance of getting significant p-value decreased to about 1% after " + sampleSizeCut + " events; This is despite the fact that we have a guaranteed decrease of " + guaranteedRateChange.toFixed(1) + "%" : "did not converge even after " + maxSampleSize + " events";
		} else {
			var text2print = "Guaranteed increase of " + guaranteedRateChange.toFixed(1) + "%.  You would need about " + addCommas(sampleSizeCut) + " events"
		}

		$('#result').text(text2print);

		convData.data = plotData;

		var histoPlotData = data['normalApprox']['plotData'];
		var baseLineEvent = data['normalApprox']['morrisFlipIndex'];

		histoData.events = [baseLineEvent];
		histoData.data = histoPlotData;

		$('#plotConv').empty();
		$('#plotHisto').empty();	

		new Morris.Area(convData);
		new Morris.Area(histoData);
		});
}
