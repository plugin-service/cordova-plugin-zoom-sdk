module.exports = function(ctx) {

	var extractZip = require('extract-zip');
	var fs = require('fs'),
        path = require('path'),
        Q = require('q');

    var deferral = new Q.defer()

    var pluginRoot = path.join(ctx.opts.projectRoot, '/plugins/cordova-plugin-sc-zoomautheval');
    var zipPath = path.join(pluginRoot, 'ZoomAuthentication.framework.zip');

		extractZip(zipPath, {dir: pluginRoot}, function(err) {
			deferral.resolve();
		});

   	return deferral.promise;
}
