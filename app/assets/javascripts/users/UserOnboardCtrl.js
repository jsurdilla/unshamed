'use strict';

angular.module('unshamed')
  .directive('uniqueUsername', uniqueUsername)
  .controller('PhotoPickerModalCtrl', PhotoPickerModalCtrl)
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

PhotoPickerModalCtrl.$inject = ['$scope', '$modalInstance', '$timeout'];
function PhotoPickerModalCtrl($scope, $modalInstance, $timeout) {
  var vm = this;

  $scope.myCroppedImage = '';

  vm.cancel = function() {
    $modalInstance.close(null);
  };

  $scope.$watch('myCroppedImage', function(value) {
    if (value) {
      $modalInstance.close(value);
    }
  });
};

UserOnboardCtrl.$inject = ['$scope', 'User', '$modal', '$templateCache', '$upload', '$stateParams', '$state', '$auth'];
function UserOnboardCtrl($scope, User, $modal, $templateCache, $upload, $stateParams, $state, $auth) {
  var vm = this;

  vm.user = { struggles: [] };
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
      $state.go('home', {}, { reload: true })
    });
  };

  vm.toggleStruggle = function(struggle) {
    var index = vm.user.struggles.indexOf(struggle);
    if (index > -1) {
      vm.user.struggles.splice(index, 1);
    } else {
      vm.user.struggles.push(struggle);
    }
  };

  vm.struggleSelect = function(struggle) {
    return vm.user.struggles.indexOf(struggle) > -1;
  };

  vm.selectPhoto = function() {
    var modalInstance = $modal.open({
      template: $templateCache.get('photoPickerModal.html'),
      controller: 'PhotoPickerModalCtrl',
      controllerAs: 'photoPicker',
      windowClass: 'photo-picker',
      backdropClass: 'photo-picker-backdrop',
      backdrop: 'static'
    });

    modalInstance.result.then(function(croppedPhoto) {
      vm.croppedPhoto = croppedPhoto;
    }, null);
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
