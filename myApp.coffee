myApp = angular.module("myApp", [])

MessagesController = ($scope, $http) ->
  $http.get("http://4ab25335.ngrok.com/messages").success((data, status, headers, config) ->
    console.log "Success: ", data
  ).error (data, status, headers, config) ->
    console.log "Error: ", data

myApp.controller('MessagesController', MessagesController)

myApp.config ($routeProvider) ->
  $routeProvider.when("/",
    {
      controller: 'MessagesController',
      templateUrl: 'index.html'
    }
  )

#Time for routes!
