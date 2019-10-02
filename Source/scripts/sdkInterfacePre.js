/*global angular, logger, window*/
/*exported Circuit, clearInterval, clearTimeout, document, localStorage, location, navigator, Promise, setInterval, setTimeout*/

//---------------------------------------------------------------------------
//  Create Promise object
//---------------------------------------------------------------------------
var Promise = function Promise(resolver) {
    'use strict';

    if (typeof resolver !== 'function') {
        throw new Error('Promise resolver is not a function');
    }
    var deferred = angular.defer();

    resolver(deferred.resolve.bind(deferred), deferred.reject.bind(deferred));

    if (this instanceof Promise) {
        // Promise invoked as constructor
        var promise = deferred.promise;
        this.then = promise.then.bind(promise);
        this.catch = promise.catch.bind(promise);
        if (window.navigator.platform === 'iOS') {
            // We need to include the native Objective-C Promise object in the response
            // so iOS can handle chained promises correctly.
            this.__nativePromise = promise;
        }
        return this;
    }

    // Promise invoked as function
    return deferred.promise;
};

Promise.defer = angular.defer.bind(angular);

Promise.all = function (promises) {
    'use strict';
    var deferred = angular.defer();

    if (!Array.isArray(promises)) {
        // We only support Array of promises for mobile. Resolve immediately.
        logger.debug('[webInterface]: Promise.all invoked with invalid input');
        deferred.reject('Invalid input to Promise.all');
        return deferred.promise;
    }
    logger.debug('[webInterface]: Promise.all invoked with ' + promises.length + ' deferred promises');
    if (promises.length === 0) {
        // Immediately resolve with empty array
        deferred.resolve([]);
        return deferred.promise;
    }

    var resolved = false;
    var rejected = false;
    var results = Array.apply(null, new Array(promises.length));
    var completed = Array.apply(null, new Array(promises.length));

    var checkForCompletion = function () {
        if (!resolved && !rejected) {
            // Check if all promises have been resolved
            var done = completed.every(function (res) { return res; });
            if (done) {
                resolved = true;
                deferred.resolve(results);
            }
        }
    };

    promises.forEach(function (promise, idx) {
        if (!promise || (typeof promise.then !== 'function')) {
            // Not a Promise. Just add it to the results array.
            results[idx] = promise;
            completed[idx] = true;
            return;
        }
        promise.then(function (result) {
            results[idx] = result;
            completed[idx] = true;
            checkForCompletion();
        }, function (error) {
            if (!rejected) {
                logger.debug('[webInterface]: Promise.all - Promise rejected. Reject all.');
                rejected = true;
                deferred.reject(error);
            }
        });
    });

    checkForCompletion();

    return deferred.promise;
};

Promise.resolve = function (result) {
    'use strict';
    var deferred = angular.defer();
    deferred.resolve(result);
    return deferred.promise;
};

Promise.reject = function (error) {
    'use strict';
    var deferred = angular.defer();
    deferred.reject(error);
    return deferred.promise;
};

window.Promise = Promise;

//---------------------------------------------------------------------------
//  Expose applicable window properties to global namespace
//---------------------------------------------------------------------------
var setTimeout = window.setTimeout;
var clearTimeout = window.clearTimeout;
var setInterval = window.setInterval;
var clearInterval = window.clearInterval;
var navigator = window.navigator;

//---------------------------------------------------------------------------
//  Expose logger object for SDK
//---------------------------------------------------------------------------
var Circuit = {
    logger: logger
};




logger.debug('[sdkInterfacePre]: Finished pre initialization.');
