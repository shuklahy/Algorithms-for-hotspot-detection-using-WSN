configuration BlinkRadioAppC{
}
implementation{
	
	components MainC, LedsC, BlinkRadioC as App;
	components new TimerMilliC();
	
	components SerialPrintfC;
	components DymoNetworkC;
	
	App.Boot -> MainC;
	App.Leds -> LedsC;
	App.Timer0 -> TimerMilliC;
	
	App.MHControl -> DymoNetworkC;
    App.Packet -> DymoNetworkC;
    App.MHPacket -> DymoNetworkC;
    App.Receive      -> DymoNetworkC.Receive[2];
    App.MHSend       -> DymoNetworkC.MHSend[2];
	
	// Temperature Sensor
	components new SensirionSht11C() as TempSensor;
	App.Temp -> TempSensor.Temperature;
	
	components new VoltageC() as BattVoltage;
	App.Batt -> BattVoltage;
		
	
}