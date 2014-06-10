steg-client
===========

Description
-----------
This is the client component of the HTTP Steganography project. The expected usage scenario is the following: You have installed the **'steg-server'** Apache httpd module on a remote server, and now you want to hiddenly communicate with it.

The 'steg-client' component is a command line tool that will act as an HTTP proxy. It will intercept the HTTP requests coming out of your browser, inject the steganograms for the hidden communication, and send them to the server that has 'steg-sevver' running.

When it receives the responses from 'steg-server', it will extract the steganograms and print the information to the console.

The idea is that you generate seemingly normal traffic by browsing the website served by Apache, and 'steg-client' and 'steg-server' work together to establish a hidden communication channel in the HTTP headers.


Quick Start
-----------
The 'steg-client' component is packaged as a Ruby gem. To install it, simply run:

```
$ gem install steg-client
```

The configuration file will be created when you first run 'steg-client', and is called **'~/.stegclient.rc.yaml'**. It's a YAML file with the following defaults:

```
---
:port               :'10001',
:knockcode          :'knock',
:inputmethod        :'Header',
:inputmethodconfig  :'Accept-Encoding',
:outputmethod       :'Header',
:outputmethodconfig :'X-Powered-By',
:logfile            :'/dev/null',
:key                :'1234567890ABCDEF1234567890ABCDEF',
:iv                 :'1234567890ABCDEF',
:verbose            :false,
:lengthsize         :3,
:fieldsize          :256,
```

This is a brief explanation of each configuration option:
* **port**: 
* **knockcode**: 
* **inputmethod**: 
* **inputmethodconfig**: 
* **outputmethod**: 
* **outputmethodconfig**: 
* **logfile**: 
* **key**: 
* **iv**: 
* **verbose**: 
* **lengthsize**: 
* **fieldsize**: 

It's specially important to customize the **knockcode** and the input and output methods of steganography.
Once you've finished customizing the configuration file, **configure your browser to use steg-client as a proxy**. This typically means using **localhost:port** (where port is what you just configured in .stegclient.rc.yaml).

After all these steps are done, you can start the client. There are three ways it can accept your messages and send them to the server:

* **-m MESSAGE**: Just specify the MESSAGE in the command line.
* **-f FILE**: Read the contents of FILE, line by line, and send them to the server.
* **-i**: Start an interactive session, where you can type in the console the messages, and receive the response of the server. 

Examples:

```
 # stegclient -m hello 
 # steglcient -f /path/to/inputfile
 # stegclient -i
```


















