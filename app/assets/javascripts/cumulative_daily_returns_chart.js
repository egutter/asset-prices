$(function () {

    var options = {
        chart: {
            renderTo: 'cumulative_daily_returns',
            type: 'line',
            height: 600,
            zoomType: 'x',
            spacingRight: 20
        },
        title: {
            text: 'Cumulative Daily Returns'
        },
        xAxis: {
            type: 'datetime',
            maxZoom: 5 * 24 * 3600000, // fourteen days
            dateTimeLabelFormats: { // don't display the dummy year
                month: '%e. %b',
                year: '%b'
            },
        },
        yAxis: {
            title: {
                text: 'Returns'
            }
        }
    };
    var seriesChart = new Highcharts.Chart(options);
    _.each(gon.cumulative_daily_return_series, function(daily_return_series) {
       dailySeries = {name: daily_return_series.name, data:[]};
       _.each(daily_return_series.data, function(daily_returns) {
            aDate = Date.parse(daily_returns[0]);
            aValue = daily_returns[1];
            dailySeries.data.push([aDate, aValue]);
       });
       seriesChart.addSeries(dailySeries);
    });
});
