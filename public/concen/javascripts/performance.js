$(function() {
  function plotWithOptions(data) {
    window.plot = $.plot($("#recent-responses"), [{label: "Total Runtime", data: data.total_runtime}, {label: "View Runtime", data: data.view_runtime},{label: "MongoDB Runtime", data: data.mongo_runtime}], {
      xaxis: {
        mode: "time",
        timeformat: "%h:%M %P",
        color: "#141F52",
        tickColor: "#DADCE7",
        tickSize: [5, "minute"]
      },
      yaxis: {
        tickDecimals: 0,
        color: "#141F52",
        tickColor: "#DADCE7"
      },
      grid: {
        hoverable: true,
        clickable: true,
        borderWidth: 1,
        borderColor: "#141F52",
        color: "#fe3145",
        markings: [ { xaxis: { from: 0, to: 2 }, yaxis: { from: 10, to: 10 }, color: "#bb0000" } ]
      },
      legend: {show: true, position: "nw", labelBoxBorderColor: false},
      series: {
        lines: {show: true, fill: false, steps: false, lineWidth: 2, fillColor: {colors: [{opacity: 0.1}, {opacity: 0.1}]}},
        stack: null,
        shadowSize: 0
      },
      colors: ["#F3535C", "#E7C400", "#19c84f"]
    });
  };

  // plotWithOptions({});

  function showTooltip(x, y, contents) {
    $("<div id='tooltip'>" + contents + "</div>").css( {
        position: "absolute",
        display: "none",
        top: y + 5,
        left: x + 5,
        padding: "4px 8px",
        "background-color": "#19c84f",
        opacity: 0.80,
        color: "white",
        "font-size": "12px",
        "font-weight": "bold"
    }).appendTo("body").fadeIn(200);
  };

  var previousPoint = null;
  $("#recent-responses").bind("plothover", function (event, pos, item) {
      $("#x").text(pos.x.toFixed(2));
      $("#y").text(pos.y.toFixed(2));

      if (item) {
        if (previousPoint != item.dataIndex) {
          previousPoint = item.dataIndex;

          $("#tooltip").remove();
          var x = item.datapoint[0].toFixed(2),
              y = item.datapoint[1].toFixed(2);

          showTooltip(item.pageX, item.pageY, "Total Runtime: " + parseInt(y));
        }
      }
      else {
        $("#tooltip").remove();
        previousPoint = null;
      }
  });

  $("#recent-responses").resize(function() {});

  $(window).resize(function() {
    updatePanelTextWidth();
  });

  function updatePanelTextWidth() {
    $("div.panel ul li p.right").each(function(index) {
     $(this).parents("li").eq(0).find("p:not(.right)").width($(this).parents("li").eq(0).width() - $(this).innerWidth());
     $(this).parents("li").eq(0).find("a").width($(this).parents("li").eq(0).width() - $(this).innerWidth());
   });
  }

  function update() {
    $.getJSON("/performance/responses", {"hour": 1}, function(json, textStatus) {
      plotWithOptions(json);
      // window.plot.setData([json.total_runtime, json.view_runtime, json.mongo_runtime]);
      // window.plot.setupGrid();
      // window.plot.draw();
      // console.log(window.plot.getOptions())
    });
    $.get("/performance/runtimes", {"type": "total"}, function(data, textStatus, xhr) {
      $("div.panel.total-runtime").find("ul").replaceWith(data);
      updatePanelTextWidth();
    });
    $.get("/performance/runtimes", {"type": "view"}, function(data, textStatus, xhr) {
      $("div.panel.view-runtime").find("ul").replaceWith(data);
      updatePanelTextWidth();
    });
    $.get("/performance/runtimes", {"type": "mongo"}, function(data, textStatus, xhr) {
      $("div.panel.mongodb-runtime").find("ul").replaceWith(data);
      updatePanelTextWidth();
    });
    setTimeout(update, 5000);
  };

  update();
});
