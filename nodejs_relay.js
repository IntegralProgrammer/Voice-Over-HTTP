var express = require('express');
var app = express();

const config_args = process.argv.slice(2);

if (config_args.length != 3) {
	console.log("Usage: nodejs nodejs_relay.js MAX_BUFFER_LEN, LISTEN_IP, LISTEN_PORT");
	process.exit();
}

const MAX_BUFFER_LEN = parseInt(config_args[0], 10);
const LISTEN_IP = config_args[1];
const LISTEN_PORT = parseInt(config_args[2], 10);

var communications_buffer = [];

app.post('/', function(req, res) {
	var postbuffer = Buffer.from("");
	req.on('data', function(d) {
		postbuffer = Buffer.concat([postbuffer, d]);
	});
	req.on('end', function() {
		communications_buffer.push(postbuffer);
		if (communications_buffer.length > MAX_BUFFER_LEN) {
			//Delete the oldest item
			communications_buffer = communications_buffer.slice(1);
		}
		
		//A write event happened, handle it if necessary
		update_tick();
		
		res.status(200);
		res.send("OK");
	});
});

var output_pipe = undefined;
app.get('/', function(req, res) {
	/*
	 * Respond to this GET request with the oldest item in
	 * communications_buffer. If this is empty, wait for something
	 * to be POSTed to it.
	 */
	
	//Save the `res` object, we will need to write to it.
	output_pipe = res;
	
	//A read event happened, handle it if necessary
	update_tick();
});

function update_tick() {
	if (output_pipe != undefined && communications_buffer.length > 0) {
		var output_item = communications_buffer[0];
		communications_buffer = communications_buffer.slice(1);
		output_pipe.status(200);
		output_pipe.write(output_item, 'binary');
		output_pipe.end(undefined, 'binary');
		output_pipe = undefined;
	}
}

var server = app.listen(LISTEN_PORT, LISTEN_IP, function() {});
