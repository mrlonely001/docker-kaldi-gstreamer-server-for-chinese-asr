# docker-kaldi-gstreamer-server-for-chinese-asr
Dockerfile for [Multi_CN ASR Model](http://kaldi-asr.org/models/m11).

Synopsis
--------
Using this project you will be able to run an automatic speech recognition (ASR) server for chinese Mandarin in a few minutes.

Attention
---------

The ASR server that will be set up here requires some [kaldi models](http://www.kaldi.org).
There are some kaldi models available for [download](http://kaldi-asr.org/models.html)
I will download this [model](http://kaldi-asr.org/models/m11) in the docker.


Install docker
--------------

Please, refer to https://docs.docker.com/engine/installation/.


Get the image
-------------

* build your own image :

`docker build . -t kaldi_gsserver_multi_cn:v1`


How to use
----------

You may create the master and worker on the same host machine. 

* Instantiate master server and worker server on the same machine:

Assuming that your kaldi models are located at /media/kaldi_models on your host machine, create a container:

```
docker run -it -p 8080:80 kaldi_gsserver_multi_cn:v1 /bin/bash
```

And, inside the container, start the service:

```
 /opt/start.sh -y /opt/models/sample_chinese_nnet3.yaml
```

You will see that 2 .log files (worker.log and master.log) will be created at /opt of your containter. If everything goes ok, you will see some lines indicating that there is a worker available. In this case, you can go back to your host machine (`Ctrl+P and Ctrl+Q` on the container). Your ASR service will be listening on port 8080.

For stopping the servers, you may execute the following command inside your container:
```
 /opt/stop.sh
```


Testing
-------

First of all, please, check if your setup is ok. It can be done using your browser following these steps:

1. Open a websocket client in your browser (e.g: [Simple-WebSocket-Client](https://github.com/hakobera/Simple-WebSocket-Client) or http://www.websocket.org/echo.html).
 
2. Connect to your master server: `ws://MASTER_SERVER/client/ws/status`. If your master is on local host port 8080, you can try: `ws://localhost:8080/client/ws/status`.

3. If your setup is ok, the answer is going to be something like: `RESPONSE: {"num_workers_available": 1, "num_requests_processed": 0}`.

After checking the setup, you should test your speech recognition service. For this, there are several options, and the following list gives some ideas:

1. You can download [this client](https://github.com/alumae/kaldi-gstreamer-server/blob/master/kaldigstserver/client.py) for your host machine and execute it. When the master is on the local host, port 8080 and you have a wav file sampled at 16 kHz located at /home/localhost/audio/, you can type: ```python client.py -u ws://localhost:8080/client/ws/speech -r 32000 /home/localhost/audio/sample16k.wav```

2. You can use [Kõnele](http://kaljurand.github.io/K6nele/) for testing the service. It is an Android app that is freely available for downloading at Google Play. You must configure it to use your ASR service. Below you'll find some screenshots that may help you in this configuration. First, you should click on **Kõnele (fast recognition)**. Then, change the **WebSocket URL**. In my case, I connected to a master server located at ws://192.168.1.10:8080/client/ws/speech. After that, open a **notepad-like** application and change your input method to **Kõnele speech keyboard** and you'll see a **yellow button** instead of your traditional keyboard. Press this button and enjoy!


<img src="img/1.png" alt="Kõnele configuration" width="200px"/>
&nbsp;
<img src="img/2.png" alt="Kõnele configuration" width="200px"/>
&nbsp;
<img src="img/3.png" alt="Kõnele configuration" width="200px"/>
&nbsp;
<img src="img/4.png" alt="Kõnele configuration" width="200px"/>
&nbsp;
<img src="img/5.png" alt="Kõnele configuration" width="200px"/>
&nbsp;
<img src="img/6.png" alt="Kõnele configuration" width="200px"/>


3. A Javascript client is available at http://kaljurand.github.io/dictate.js/. You must configure it to use your ASR service.


Credits
--------
* [docker-kaldi-gstreamer-server](https://github.com/jcsilva/docker-kaldi-gstreamer-server)
* [kaldi](http://www.kaldi.org)
* [gst-kaldi-nnet2-online](https://github.com/alumae/gst-kaldi-nnet2-online)
* [kaldi-gstreamer-server](https://github.com/alumae/kaldi-gstreamer-server)
* [Kõnele](http://kaljurand.github.io/K6nele/)

