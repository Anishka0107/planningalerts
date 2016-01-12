function barGraph(selector, url, title) {

  // Add the title
  var wrapper_element = document.querySelectorAll(selector)[0];

  var title_element = document.createElement('h4');
  title_element.textContent = title;

  wrapper_element.insertBefore(title_element, wrapper_element.firstChild);

  // Add the chart
  d3.json(url, function(data) {

    data = data.map(function(d, i) {
      return {key: new Date(d[0]), values: d[1]};
    });

    var width = 800;
    var barWidth = 5;
    var height = 200;
    var margin = { top: 20, right: 50, bottom: 20, left: 50 };

    var maxYValue = d3.max(data, function(datum) { return datum.values; });

    var x = d3.time.scale()
      .domain(
        d3.extent(data, function(datum) { return datum.key; })
      )
      .range([0, width]);

    var y = d3.scale
      .linear()
      .domain([0, maxYValue])
      .rangeRound([height, 0]);

    var yTickCount;
    if (maxYValue < 2) {
      yTickCount = 1;
    } else if (maxYValue < 5) {
      yTickCount = 2;
    } else  {
      yTickCount = 5;
    }

    // add the canvas to the DOM
    var chart = d3.select(selector)
      .append("svg:svg")
      .attr("width", margin.left + width + margin.right)
      .attr("height", margin.top + height + margin.bottom)
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    chart.selectAll(".xTicks")
      .data(x.ticks(d3.time.months.utc, 1))
      .enter().append("svg:line")
      .attr("class", "xTicks")
      .attr("x1", x)
      .attr("y1", height)
      .attr("x2", x)
      .attr("y2", height + 5)
      .attr("stroke", "#888")
      .attr("stroke-width", "2px");

    chart.selectAll("text.xAxisMonth")
      .data(x.ticks(d3.time.months.utc, 3))
      .enter().append("text")
      .attr("class", "xAxisMonth")
      .attr("x", x)
      .attr("y", height)
      .attr("dy", "20")
      .attr("text-anchor", "middle")
      .text(d3.time.format("%b"));

    chart.selectAll("text.xAxisYear")
      .data(x.ticks(d3.time.years.utc, 1))
      .enter().append("text")
      .attr("class", "xAxisYear")
      .attr("x", x)
      .attr("y", height + 8)
      .attr("dy", "30")
      .attr("text-anchor", "middle")
      .text(d3.time.format("%Y"));

    chart.selectAll("text.yAxis")
      .data(y.ticks(yTickCount))
      .enter().append("text")
      .attr("class", "yAxis")
      .attr("x", 0)
      .attr("y", y)
      .attr("dx", "-8")
      .attr("dy", "3")
      .attr("text-anchor", "end")
      .text(y.tickFormat(0));

    var areaValues = d3.svg.area()
      .x(function(d) { return x(d.key); })
      .y0(height)
      .y1(function(d) { return y(d.values); })
      .interpolate("monotone");

    var lineValues = d3.svg.line()
      .x(function(d) { return x(d.key); })
      .y(function(d) { return y(d.values); })
      .interpolate("monotone");

    chart.append("svg:path")
      .attr("d", areaValues(data))
      .attr("class", "chart-area");

    chart.append("svg:path")
      .datum(data)
      .attr("d", lineValues)
      .attr("class", "chart-line");

    var yGridTickCount;
    if (yTickCount === 5) { yGridTickCount = 10 } else { yGridTickCount = yTickCount };
    chart.selectAll(".yTicks")
      .data(y.ticks(yGridTickCount))
      .enter().append("svg:line")
      .attr("class", "yTicks")
      .attr("x1", 0)
      .attr("y1", y)
      .attr("x2", width)
      .attr("y2", y)
      .attr("stroke", function(d, i) {
        if ( i === 0 ) { return "#888"; } else { return "rgba(255,255,255,.4)"; }
      })
      .attr("stroke-width", function(d, i) {
        if ( i === 0 ) { return "4px"; } else { return "2px"; }
      });
  });

}
