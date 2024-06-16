document.addEventListener("DOMContentLoaded", function() {
    var statsLink = document.getElementById("statsLink");
    var usersLink = document.getElementById("usersLink");
    var statsDiv = document.getElementById("stats");
    var usersDiv = document.getElementById("users");

    statsLink.addEventListener("click", function(event) {
        event.preventDefault();
        statsDiv.style.display = "block";
        usersDiv.style.display = "none";
    });

    usersLink.addEventListener("click", function(event) {
        event.preventDefault();
        statsDiv.style.display = "none";
        usersDiv.style.display = "block";
    });
});
