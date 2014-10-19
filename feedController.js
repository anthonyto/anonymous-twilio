var AnonTwilioFeed = angular.module("AnonTwilioFeed", []);

var feedController = function($scope, $http) {
  $http.get("/mongodb://anonRead:anonymousRead@linus.mongohq.com:10077/anonymous_twillio/my_app_messages")
  .success(function(data, status, headers, config) {
    return console.log("Success: ", data);
  })
  .error(function(data, status, headers, config) {
    return console.log("Error: ", data);
  });
};

AnonTwilioFeed.controller('feedController', feedController);