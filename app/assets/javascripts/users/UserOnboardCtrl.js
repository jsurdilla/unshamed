'use strict';

angular.module('unshamed')
  .directive('uniqueUsername', uniqueUsername)
  .controller('UserOnboardCtrl', UserOnboardCtrl);

uniqueUsername.$inject = ['User', '$q'];
function uniqueUsername(User, $q) {
  return {
    require: 'ngModel',
    link: function(scope, elem, attrs, ngModel) {
      ngModel.$asyncValidators.username = function(modelValue, viewValue) {
        if (ngModel.$isEmpty(modelValue)) {
          return $q.when();
        }

        var def = $q.defer();
        User.checkUsername({ username: modelValue }).$promise.then(function(data) {
          data.exists ? def.reject() : def.resolve();
        }, function(data) {
          def.reject();
        });

        return def.promise;
      };
    }
  };
};

UserOnboardCtrl.$inject = ['$scope', 'User', '$modal', '$templateCache', '$upload', '$stateParams', '$state', '$auth'];
function UserOnboardCtrl($scope, User, $modal, $templateCache, $upload, $stateParams, $state, $auth) {
  var vm = this;

  vm.user = { member_profile_attributes: { struggles: [] } };
  vm.justVerified = $stateParams.alert === 'verified';

  vm.genders = [
    { title: 'Male', value: 'm' },
    { title: 'Female', value: 'f' }
  ];

  vm.onboardUser = function() {
    if ($scope.onboardingForm.$invalid) return;

    $upload.upload({
      url: '/api/v1/me/onboard',
      method: 'PUT',
      file: dataURItoBlob(vm.croppedPhoto),
      fileName: 'profile.png',
      data: { user: vm.user }
    }).success(function(data) {
      $auth.user = data.user;
      debugger
      $state.go('home', {}, { reload: true })
    });
  };

  vm.toggleStruggle = function(struggle) {
    var index = vm.user.member_profile_attributes.struggles.indexOf(struggle);
    if (index > -1) {
      vm.user.member_profile_attributes.struggles.splice(index, 1);
    } else {
      vm.user.member_profile_attributes.struggles.push(struggle);
    }
  };

  vm.struggleSelect = function(struggle) {
    return vm.user.member_profile_attributes.struggles.indexOf(struggle) > -1;
  };

  vm.selectPhoto = function() {
    var scope = $scope.$new();

    var modalInstance = $modal({
      template: 'photoPickerModal.html',
      show: true,
      scope: scope,
      backdrop: 'static'
    });

    scope.$on('modal.hide', function() {
      vm.croppedPhoto = scope.myCroppedImage;
      $scope.$apply();
    });
  };

  var dataURItoBlob = function(dataURI) {
    if (dataURI) {
      var binary = atob(dataURI.split(',')[1]);
      var mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0];
      var array = [];
      for(var i = 0; i < binary.length; i++) {
        array.push(binary.charCodeAt(i));
      }
      return new Blob([new Uint8Array(array)], {type: mimeString});
    }
    return null;
  };

};
