/*global angular, logger, window*/
/*exported Circuit, clearInterval, clearTimeout, document, localStorage, location, navigator, Promise, setInterval, setTimeout*/

//---------------------------------------------------------------------------
//  JS initializations required before common business logic is loaded
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
//  Enhance native logger to handle keysToOmitFromLogging
//---------------------------------------------------------------------------
(function () {
    'use strict';
    var OMMIT_KEY = 'keysToOmitFromLogging';

    function shallowCopy(src) {
        if (!src || (typeof src !== 'object')) {
            return src;
        }

        if (Array.isArray(src)) {
            return src.slice();
        }

        var obj = {};
        for (var key in src) {
            if (src.hasOwnProperty(key)) {
                obj[key] = src[key];
            }
        }
        return obj;
    }

    function ommitKeys(obj) {
        if (!obj || typeof obj !== 'object') {
            return obj;
        }
        if (obj.hasOwnProperty(OMMIT_KEY)) {
            var origObj = obj; // Keep a reference to the original object
            obj = shallowCopy(obj);  // Create a shallow copy for the modifications
            obj[OMMIT_KEY].forEach(function (key) {
                var paths = key.split('.');
                var root = obj;
                var origRoot = origObj;
                var lastIdx = paths.length - 1;
                paths.every(function (node, idx) {
                    if (node === '[]') {
                        if (Array.isArray(root)) {
                            var subKey = (idx < lastIdx) ? paths.slice(idx + 1).join('.') : null;
                            root.forEach(function (origElem, elemIdx) {
                                if (!subKey) {
                                    root[elemIdx] = '******';
                                    return;
                                }
                                origElem[OMMIT_KEY] = [subKey];
                                root[elemIdx] = ommitKeys(origElem);
                                delete origElem[OMMIT_KEY];
                            });
                        }
                        return false;
                    }
                    if (!root[node]) {
                        // The key to be omitted does not exist
                        return false;
                    }
                    if (idx === lastIdx) {
                        // This is the last element
                        root[node] = '******';
                    } else {
                        if (typeof root[node] !== 'object') {
                            // Cannot continue
                            return false;
                        }

                        // Shallow copy only if have not done so
                        if (root[node] === origRoot[node]) {
                            root[node] = shallowCopy(root[node]);
                        }
                        // Navigate to the next level
                        origRoot = origRoot[node];
                        root = root[node];
                    }
                    return true;
                });
            });
            // Remove the OMMIT_KEY property from the copy
            delete obj[OMMIT_KEY];
        }
        return obj;
    }

    var methods = ['debug', 'info', 'warning', 'error', 'msgSend', 'msgRcvd'];
    methods.forEach(function (method) {
        var origMethod = logger[method];
        logger[method] = function (txt, obj) {
            origMethod.call(logger, txt, ommitKeys(obj));
        };
    });

})();

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

//---------------------------------------------------------------------------
//  Expose applicable window properties to global namespace
//---------------------------------------------------------------------------

// WebRTC isn't available in iOS version of SDK for now, 
// so we don't introduce navigator and just mock it.
var navigator = {};
navigator.platform = 'iOS';

//---------------------------------------------------------------------------
//  Create global Circuit object
//---------------------------------------------------------------------------
var Circuit = {
    logger: logger
};

// Start by creating the base Angular object
logger.debug('[sdkInterfacePre]: Finished pre initialization.');
