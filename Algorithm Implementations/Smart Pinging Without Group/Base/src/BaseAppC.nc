configuration BaseAppC{
}
implementation{
	
	components MainC, BaseC as App;
	components LedsC;
	components new TimerMilliC() as group1;
	components new TimerMilliC() as group1_poll;
	
	components DymoNetworkC;  // Multihop Components
	components SerialPrintfC; // Printf Components
	
	
	App.Boot -> MainC;
	App.Leds -> LedsC;
	App.group1 -> group1;
	
	App.Packet -> DymoNetworkC;
    App.MHControl -> DymoNetworkC;
    App.MHPacket -> DymoNetworkC;
    App.Receive -> DymoNetworkC.Receive[2];
	App.MHSend -> DymoNetworkC.MHSend[2];	
	
}