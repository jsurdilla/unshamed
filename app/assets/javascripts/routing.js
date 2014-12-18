'use strict';

angular.module('unshamed')

  .run(['$rootScope', '$auth', function($rootScope, $auth) {
    $rootScope.$auth = $auth;
  }])

  // TODO: check to see if this can be moved with the rest of the routes.
  .config(['$stateProvider', '$urlRouterProvider', function($stateProvider, $urlRouterProvider) {

    $urlRouterProvider.otherwise("/");

    $stateProvider
      .state('start', {
        url: '/start',
        templateProvider: ['$templateCache', function($templateCache) {
          return $templateCache.get('start.html');
        }],
        controller: 'StartCtrl',
        controllerAs: 'start'
      })

      .state('register', {
        url: '/register',
        templateProvider: ['$templateCache', function($templateCache) {
          return $templateCache.get('register.html');
        }],
        controller: 'RegistrationCtrl',
        controllerAs: 'reg'
      })

      // Parent state for all states that need to be authenticated.
      .state('authenticated', {
        template: '<ui-view/>',
        resolve: {
          auth: ['$auth', '$state', function($auth, $state) {
             return $auth.validateUser().then(function(user) {
               console.log('...', user.onboarded);
               if (!$auth.user.onboarded) {
                 console.log('GO TO ONBOARD');
                 $state.go('onboard', { skipCheck: true });
               }
               return user;
             }, function error() {
               $state.go('start');
             });
          }]
        }
      })

      .state('onboard', {
        url: '/onboard/:alert',
        templateProvider: ['$templateCache', function($templateCache) {
          return $templateCache.get('users/onboard.html');
        }],
        resolve: {
          auth: ['$auth', '$state', function($auth, $state) {
            return $auth.validateUser().then(function() {
              if ($auth.user.onboarded) {
                $state.go('home');
              }
            }, function error() {
              $state.go('start');
            });
          }]
        },
        controller: 'UserOnboardCtrl',
        controllerAs: 'onboard'
      })

      .state('home', {
        url: '/',
        templateProvider: ['$templateCache', function($templateCache) {
          return $templateCache.get('users/index.html');
        }],
        parent: 'authenticated',
        controller: 'UserHomeCtrl',
        controllerAs: 'userHome'
      })

      .state('members', {})

      .state('members.details', {
        url: '/members/:id',
        templateProvider: ['$templateCache', function($templateCache) {
          return $templateCache.get('members/show.html');
        }],
        resolve: {
          member: ['User', '$stateParams', function(User, $stateParams) {
            return User.get({ id: $stateParams.id });
          }],
          timeline: ['Timeline', '$stateParams', function(Timeline, $stateParams) {
            return Timeline.get({ user_id: $stateParams.id });
          }]
        },
        parent: 'authenticated',
        controller: 'MemberDetailsCtrl',
        controllerAs: 'member'
      })

      .state('journalEntries', {
        url: '/journal_entries',
        templateProvider: ['$templateCache', function($templateCache) {
          return $templateCache.get('journal_entries/index.html');
        }],
        parent: 'authenticated',
        controller: 'JournalIndexCtrl',
        controllerAs: 'journalEntries'
      })

      .state('journalEntries.show', {
        url: '/journal_entries/:id',
        templateProvider: ['$templateCache', function($templateCache) {
          return $templateCache.get('journal_entries/show.html');
        }],
        resolve: {
          journalEntry: ['JournalEntry', '$stateParams', '$q', function(JournalEntry, $stateParams, $q) {
            if ($stateParams.id) {
              return JournalEntry.get({ id: $stateParams.id });
            }
            return null;
          }]
        },
        parent: 'authenticated',
        controller: 'JournalEntryShowCtrl',
        controllerAs: 'journalEntry'
      })

      .state('convos', {
        url: '/conversations',
        templateProvider: ['$templateCache', function($templateCache) {
          return $templateCache.get('conversations/index.html');
        }],
        parent: 'authenticated',
        controller: 'ConversationsIndexCtrl',
        controllerAs: 'convos'
      })

      .state('convos.inbox', {
        url: '/inbox',
        views: {
          details: {
            templateProvider: ['$templateCache', function($templateCache) {
              return $templateCache.get('conversations/inbox.html');
            }],
            controller: 'ConversationsInboxCtrl',
            controllerAs: 'inbox'
          }
        }
      })

      .state('convos.inbox.show', {
        url: '/:id',
        views: {
          'details@convos': {
            templateProvider: ['$templateCache', function($templateCache) {
              return $templateCache.get('conversations/show.html');
            }],
            controller: 'ConversationsShowCtrl',
            controllerAs: 'convoShow'
          }
        },
        resolve: {
          convo: ['Conversation', '$stateParams', '$q', function(Conversation, $stateParams, $q) {
            if ($stateParams.id) {
              return Conversation.get({ id: $stateParams.id });
            }
            return null;
          }]
        }
      })

      .state('convos.sentbox', {
        url: '/conversations/sentbox',
        views: {
          details: {
            templateProvider: ['$templateCache', function($templateCache) {
              return $templateCache.get('conversations/sentbox.html');
            }],
            controller: 'ConversationsSentboxCtrl',
            controllerAs: 'sentbox'
          }
        }
      })

      .state('convos.sentbox.show', {
        url: '/:id',
        views: {
          'details@convos': {
            templateProvider: ['$templateCache', function($templateCache) {
              return $templateCache.get('conversations/show.html');
            }],
            controller: 'ConversationsShowCtrl',
            controllerAs: 'convoShow'
          }
        },
        resolve: {
          convo: ['Conversation', '$stateParams', '$q', function(Conversation, $stateParams, $q) {
            if ($stateParams.id) {
              return Conversation.get({ id: $stateParams.id });
            }
            return null;
          }]
        }
      })

  }]);
