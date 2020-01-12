#!/usr/bin/env python
# -*- coding: utf-8 -*-

from BaseHTTPServer import HTTPServer, BaseHTTPRequestHandler
from SocketServer import ThreadingMixIn
import threading
import sys

BIND_PORT = int(sys.argv[1])

"""
Hold up to a maximum of MAX_BUFFER_LEN POSTings. If the number of unsent
POSTings exceeds MAX_BUFFER_LEN, delete the oldest one.
"""
MAX_BUFFER_LEN = 4

communications_buffer = []
communications_lock = threading.Lock()

class Handler(BaseHTTPRequestHandler):
	def do_GET(self):
		#Wait for at least one object in the buffer list
		while len(communications_buffer) == 0:
			pass
		
		communications_lock.acquire()
		tx_item = communications_buffer[0]
		del communications_buffer[0]
		communications_lock.release()
		
		self.send_response(200)
		self.end_headers()
		self.wfile.write(tx_item)
		return
	
	def do_POST(self):
		self.send_response(200)
		self.end_headers()
		content_len = int(self.headers.getheader('content-length', 0))
		post_body = self.rfile.read(content_len)
		#print "POST body was: {}".format(post_body) #Un-comment for debug
		communications_lock.acquire()
		communications_buffer.append(post_body)
		if len(communications_buffer) > MAX_BUFFER_LEN:
			del communications_buffer[0]
		communications_lock.release()
		return

class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
	"""Handle requests in a separate thread."""

if __name__ == '__main__':
	server = ThreadedHTTPServer(('127.0.0.1', BIND_PORT), Handler)
	print "Started server on port {}, use <Ctrl-C> to stop".format(BIND_PORT)
	try:
		server.serve_forever()
	except KeyboardInterrupt:
		print "Stopping gracefully..."
		sys.exit(0)
