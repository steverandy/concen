$(function() {
  function update() {
    $.getJSON("/status/counts", function(json, textStatus) {
      $("div.panel.pages").find("p.big-number").html(json.pages);
      $("div.panel.users").find("p.big-number").html(json.users);
    });

    $.get("/status/server", function(data, textStatus, xhr) {
      $("div.panel.server").find("ul").replaceWith(data);
    });

    setTimeout(update, 5000);
  };
  update();
});
