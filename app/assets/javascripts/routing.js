'use strict';

angular.module('unshamed')
  .run(conversationRedirect)

  // TODO: check to see if this can be moved with the rest of the routes.
  .config(['$stateProvider', '$urlRouterProvider', function($stateProvider, $urlRouterProvider) {

    $urlRouterProvider.otherwise("/");

    $stateProvider
      .state('start', {
        url: '/start',
        views: {
          'main@': {
            templateProvider: ['$templateCache', function($templateCache) {
              return $templateCache.get('start.html');
            }],
            controller: 'StartCtrl',
            controllerAs: 'start'
          }
        }
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
          auth: ['$auth', '$state', '$q', function($auth, $state, $q) {
            var deferred = $q.defer();
            $auth.validateUser().then(function(user) {
              if (!$auth.user.onboarded) {
                $state.go('onboard', { skipCheck: true });
              }
              deferred.resolve(user);
            }, function error() {
              deferred.reject();
              $state.go('start');
            });
            return deferred.promise;
          }]
        }
      })

      .state('onboard', {
        url: '/onboard/:alert',
        templateProvider: ['$templateCache', function($templateCache) {
          return $templateCache.get('users/onboard.html');
        }],
        views: {
          'main@': {
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
          }
        }
      })

      .state('withNav', {
        abstract: true,
        views: {
          header: {
            templateProvider: ['$templateCache', function($templateCache) {
              return $templateCache.get('nav.html');
            }],
            controller: 'NavigationCtrl',
            controllerAs: 'nav',
            resolve: {
              auth: ['$auth', '$state', '$q', function($auth, $state, $q) {
                return $auth.validateUser();
              }]
            }

          },
          main: '<ui-view />'
        }
      })

      .state('home', {
        url: '/',
        parent: 'withNav',
        views: {
          'main@': {
            templateProvider: ['$templateCache', function($templateCache) {
              return $templateCache.get('users/index.html');
            }],
            parent: 'authenticated',
            controller: 'UserHomeCtrl',
            controllerAs: 'userHome'
          }
        }
      })

      .state('members', {})

      .state('members.details', {
        url: '/members/:id',
        parent: 'withNav',
        views: {
          'main@': {
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
          }
        }
      })

      .state ('journalEntries', {
        parent: 'withNav'
      })

      .state('journalEntries.new', {
        url: '/journal_entries/new',
        views: {
          'main@': {
            templateProvider: ['$templateCache', '$rootScope', function($templateCache, $rootScope) {
              return $templateCache.get('journal_entries/index.html');
            }],
            parent: 'authenticated',
            controller: 'JournalIndexCtrl',
            controllerAs: 'journalEntries'
          }
        }
      })

      .state('journalEntries.show', {
        url: '/journal_entries/:id',
        views: {
          'main@': {
            templateProvider: ['$templateCache', '$rootScope', function($templateCache, $rootScope) {
              return $templateCache.get('journal_entries/index.html');
            }],
            resolve: {
              journalEntry: ['JournalEntry', '$stateParams', '$q', function(JournalEntry, $stateParams, $q) {
                if ($stateParams.id) {
                  return JournalEntry.get({ id: $stateParams.id }).$promise;
                }
                return null;
              }]
            },
            parent: 'authenticated',
            controller: 'JournalEntryShowCtrl',
            controllerAs: 'journalEntry'
          }
        }
      })

      .state('conversations', {
        url: '/conversations',
        parent: 'withNav',
        views: {
          'main@': {
            templateProvider: ['$templateCache', function($templateCache) {
              return $templateCache.get('conversations/index.html');
            }],
            resolve: {
              conversations: ['convoSvc', function(convoSvc) {
                return convoSvc.getMostRecent();
              }]
            },
            parent: 'authenticated',
            controller: 'ConversationsIndexCtrl',
            controllerAs: 'convos'
          }
        }
      })

      .state('conversations.new', {
        url: '/new',
        views: {
          'details@conversations': {
            templateProvider: ['$templateCache', function($templateCache) {
              return $templateCache.get('conversations/new.html');
            }],
            controller: 'ConversationsNewCtrl',
            controllerAs: 'convoNew'
          }
        }
      })

      .state('conversations.show', {
        url: '/:id',
        views: {
          'details@conversations': {
            templateProvider: ['$templateCache', function($templateCache) {
              return $templateCache.get('conversations/show.html');
            }],
            controller: 'ConversationsShowCtrl',
            controllerAs: 'convoShow'
          },
          resolve: {
            convo: ['Conversation', '$stateParams', '$q', function(Conversation, $stateParams, $q) {
              if ($stateParams.id) {
                return Conversation.get({ id: $stateParams.id }).$promise;
              }
              return null;
            }]
          }
        }
      })

  }]);

conversationRedirect.$inject = ['$rootScope', '$state', 'convoSvc'];
function conversationRedirect($rootScope, $state, convoSvc) {
  $rootScope.$on('$stateChangeStart', function(e, toState, toParams, fromState, fromParams) {
    if (toState.name === 'conversations') {
      e.preventDefault();
      var lastConversationID = convoSvc.lastConversationID();
      if (convoSvc.lastConversationID()) {
        $state.go('conversations.show', { id: lastConversationID });
      } else {
        $state.go('conversations.new', { reload: true });
      }
    }
  });
};
