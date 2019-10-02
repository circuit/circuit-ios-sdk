/*global Circuit*/
/*exported sdkClient*/

// Override logger object after circuit.js is loaded
Circuit.logger = logger;

var sdkClient = new Circuit.Client();


//---------------------------------------------------------------------------
// Inject Promise in non-angular modules
//---------------------------------------------------------------------------
Circuit.CallStatsHandler.overridePromise(Promise);
