'use strict';

var data = {"Master":{"id":null,"st":"A","t":"0","perefer":"PT000101","pefecha":"2014-02-09","pefvence":"2014-02-09","vendedor_id":4002,"cliente_id":11803},"Details":[],"masterModel":"Pedido","detailModel":"Pedidodet"};

var title_for_layout = "Pedido :: Nuevo";

angular.module('axDatamineApp')
  .controller('ReportsCtrl', function ($scope, User, Auth) {
    $scope.errors = {};

	$scope.getReportData = function() {
		alert('Un click');
	}
	
    $scope.setParameters = function(form) {
      	$scope.submitted = true;
    	if(form.$valid) {
 			alert("Forma Valida");
     	}
	};
  });
