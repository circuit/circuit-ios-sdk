/*global Circuit*/
/*exported sdkClient*/

var sdkClient = new Circuit.Client();


//---------------------------------------------------------------------------
// Inject Promise in non-angular modules
//---------------------------------------------------------------------------
Circuit.CallStatsHandler.overridePromise(Promise);
