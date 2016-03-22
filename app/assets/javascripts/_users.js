$(document).on("page:change", function() {
  "use strict";

  var updateUsers = function() {
    var request = new XMLHttpRequest();
    request.onreadystatechange = function() {
      var userCountUnits;

      if (request.readyState === 4 && (request.status == 200 || request.status == 304)) {
        if (request.response === "1") {
          userCountUnits = "computer";
        } else {
          userCountUnits = "computers";
        }
        document.getElementById("user-count").textContent = request.response;
        document.getElementById("user-count-units").textContent = userCountUnits;
      }
    };
    request.open("GET", "./api/v1/users");
    request.send();
  };

  window.addEventListener("DOMContentLoaded", function() {
    setInterval(updateUsers, 5000);
  });
})();
