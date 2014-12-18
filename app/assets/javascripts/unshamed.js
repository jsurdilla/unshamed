'use strict';

// Initialize all modules
angular.module('unshamed.models', ['ngResource']);
angular.module('unshamed.login', ['ng-token-auth']);
angular.module('unshamed.registration', ['ng-token-auth', 'directives.inputMatch']);
angular.module('unshamed.directives', []);
angular.module('unshamed.services', []);

angular.module('unshamed', [
  'angular-flippy',
  'templates',
  'unshamed.directives',
  'unshamed.models',
  'unshamed.registration',
  'unshamed.login',
  'unshamed.services',
  'ui.router',
  'rorymadden.date-dropdowns',
  'infinite-scroll',
  'ui.bootstrap',
  'ImageCropper',
  'angularFileUpload',
  'angular-medium-editor',
  'ngSanitize'
]);

angular.module('unshamed')
  .config(configureAuthProvider);

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
