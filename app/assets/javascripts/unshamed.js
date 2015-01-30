'use strict';

Array.prototype.getIndexBy = function (name, value) {
  for (var i = 0; i < this.length; i++) {
    if (this[i][name] == value) {
      return i;
    }
  }
}

// Initialize all modules
angular.module('unshamed.models', ['ngResource']);
angular.module('unshamed.login', ['ng-token-auth']);
angular.module('unshamed.registration', ['ng-token-auth', 'directives.inputMatch']);
angular.module('unshamed.directives', []);
angular.module('unshamed.services', []);

angular.module('unshamed', [
  'angularFileUpload',
  'angular-flippy',
  'angular-medium-editor',
  'ImageCropper',
  'ipCookie',
  'ngSanitize',
  'ngTagsInput',
  'pusher-angular',
  'rorymadden.date-dropdowns',
  'templates',
  'unshamed.directives',
  'unshamed.models',
  'unshamed.registration',
  'unshamed.login',
  'unshamed.services',
  'ui.router'
]);

angular.module('unshamed')
  .config(configureAuthProvider)
  .run(setupRootProperties)
  .run(setupPusher);

configureAuthProvider.$inject = ['$authProvider'];
function configureAuthProvider($authProvider) {
  $authProvider.configure({
    apiUrl: '',
    handleLoginResponse: function(resp) {
      return resp.data;
    },
    handleTokenValidationResponse: function(response) {
      return response.data;
    }
  });
};

setupRootProperties.$inject = ['$rootScope', '$auth', '$state', '$pusher', '$http'];
function setupRootProperties($rootScope, $auth, $state, $pusher, $http) {
  $rootScope.$auth = $auth;
  $rootScope.$state = $state;
  $rootScope.$pusher = $pusher;
};

setupPusher.$inject = ['$rootScope', '$http', '$auth'];
function setupPusher($rootScope, $http, $auth) {
  // Setup the Pusher instance. Pusher Auth happens on chnanel subscription.
  $auth.validateUser().then(function() {
    window.securePusher = new Pusher($rootScope.pusherKey, {
      authEndpoint: '/api/v1/pusher/auth',
      auth: {
        headers: $auth.retrieveData('auth_headers')
      }
    });
    window.securePusher.connection.bind('connected', function() {
      $http.defaults.headers.common.socket_id = window.securePusher.connection.socket_id;
    });

    $rootScope.pusher = $rootScope.$pusher(window.securePusher);
  });
};
