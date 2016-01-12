# MQTTClient

这是一个iOS平台上的MQTT客户端，仅作测试之用。

该客户端实现了MQTT协议的基本功能，可以完成主题订阅，消息的发布、接收与存储。主要使用了开源的[MQTTKit库](https://github.com/mobile-web-messaging/MQTTKit.git),该库也是对开源MQTT代理[mosquitto](http://mosquitto.org/)中的库代码用Objective-C语言进行了封装。

MQTT协议简单，轻量，后续可拓展用于推送、IM即时聊天、远程控制等领域。

关于MQTT，以下是百度百科的描述：
> MQTT（Message Queuing Telemetry Transport，消息队列遥测传输）是IBM开发的一个即时通讯协议，有可能成为物联网的重要组成部分。该协议支持所有平台，几乎可以把所有联网物品和外部连接起来，被用来当做传感器和致动器（比如通过Twitter让房屋联网）的通信协议。



## Screenshots

![](http://7xjlak.com1.z0.glb.clouddn.com/mqttclientIMG_0762.PNG)  
![](http://7xjlak.com1.z0.glb.clouddn.com/mqttclientIMG_0763.PNG)  
![](http://7xjlak.com1.z0.glb.clouddn.com/mqttclientIMG_0764.PNG)  
![](http://7xjlak.com1.z0.glb.clouddn.com/mqttclientIMG_0766.PNG)
![](http://7xjlak.com1.z0.glb.clouddn.com/mqttclientIMG_0767~~.PNG)


## License


	Copyright (c) 2015-2016 Gu Gaofei (@gydmercy)

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.