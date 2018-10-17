# flutter_mixed

Flutter entry code, mainly demonstrates how flutter and iOS interact with each other.
Flutter一个超简易的偏新手的入门代码，主要演示了flutter和iOS相互交互的方法。


1. MethodChannel sends a request from flutter, calling the iOS method, in the example requesting the remaining battery power
MethodChannel 从flutter发出请求，调用iOS的方法，示例里为请求电池剩余电量

2. EventChannel flutter starts to monitor after being loaded, sends events from iOS actively, and flutter refreshes the title after receiving the event
EventChannel flutter启动后开始监听，从iOS主动发送事件，flutter接收到事件后刷新标题
