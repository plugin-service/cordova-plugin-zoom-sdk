
// This hook extracts a zipped version of the ZoomAuthentication.framework after the plugin is installed,
// 	allowing us to package a much smaller file.  In the future, when Cocoapods support in Cordova is
//	improved, we can remove this and rely on that.
module.exports = function(ctx) {

	var extractZip = require('extract-zip');
	var fs = ctx.requireCordovaModule('fs'),
        path = ctx.requireCordovaModule('path'),
        Q = ctx.requireCordovaModule('q');

    var deferral = new Q.defer()

    var pluginRoot = path.join(ctx.opts.projectRoot, '/plugins/com.facetec.cordova.ZoomAuthentication');
    var zipPath = path.join(pluginRoot, 'ZoomAuthentication.framework.zip');

		extractZip(zipPath, {dir: pluginRoot}, function(err) {
			deferral.resolve();
		});

   	return deferral.promise;
}
