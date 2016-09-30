/* while sensing - red Led on/led 0
 * while sending - yellow led on /led 2
 * Receiving the message - green toggle led 1
 * 
 */

#include <Timer.h>
#include <string.h>
#include <stdio.h>
#include "BlinkRadio.h"

module BlinkRadioC {
	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli> as Timer0;

	// Radio Interface
	uses interface Packet;
	uses interface SplitControl as MHControl;
	uses interface AMPacket as MHPacket;
	uses interface AMSend as MHSend;
	uses interface Receive;

	// Temperature interface
	uses interface Read<uint16_t> as Temp;
	// Voltage interface
	uses interface Read<uint16_t> as Batt;

}
implementation {
	//bool busy = FALSE;
	message_t pkt;
	bool sensing;

	uint8_t first;
	uint16_t group;
	uint16_t send_type;
	uint16_t mean_val;
	uint16_t centiG;
	uint16_t voltage;
	void init() {
		sensing = FALSE;
		send_type = RESET;
		mean_val = 0;
		//first = 0;
	}

	event void Boot.booted() {
		init();
		call MHControl.start();

	}

	event void Timer0.fired() {

		if( ! sensing) {
			if(call Temp.read() == SUCCESS) {
				call Leds.led0On();
				sensing = TRUE;
			}
		}
	}

	event void MHControl.startDone(error_t error) {
		if(error == SUCCESS) {
			call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
		}
		else {
			call MHControl.start();
		}
	}

	event void MHControl.stopDone(error_t error) {
	}
	event void MHSend.sendDone(message_t * msg, error_t error) {
		call Leds.led2Off();
		if(&pkt == msg) {
			BlinkToRadioMsg * btrpkt = (BlinkToRadioMsg * )(call Packet.getPayload(msg,
					sizeof(BlinkToRadioMsg)));
			if(btrpkt->type == EM_PING) 
				mean_val = btrpkt->temp;
			sensing = FALSE;
			send_type = RESET;
		}
	}

	error_t send_packet(uint16_t val, uint16_t type) {

		BlinkToRadioMsg * btrpkt = (BlinkToRadioMsg * )(call Packet.getPayload(&pkt,
				sizeof(BlinkToRadioMsg)));
		btrpkt->nodeid = TOS_NODE_ID;
		btrpkt->temp = val;
		btrpkt->type = type;
		btrpkt->mean = mean_val;
		btrpkt->volt = voltage;
		
		return call MHSend.send(20, &pkt, sizeof(BlinkToRadioMsg));
	}

	event void Temp.readDone(error_t result, uint16_t val) {
		call Leds.led0Off();
		if(result == SUCCESS) {
			centiG = (-39.6 + 0.01 * val);
			call Batt.read();
		}
		else {
			sensing = FALSE;
		}

	}

	event message_t * Receive.receive(message_t * msg, void * payload,
			uint8_t len) {

		if(len == sizeof(BlinkToRadioMsg)) {
			BlinkToRadioMsg * btrpkt = (BlinkToRadioMsg * ) payload;

			call Leds.led1Toggle();
			if(btrpkt->type == POLL) {
				send_type = POLL_REPLY;
				// Code does not enter here
			}
			if(btrpkt->type == MEAN) {

				mean_val = btrpkt->	mean;
			}

		}
		return msg;
	}

	event void Batt.readDone(error_t result, uint16_t val) {
		// TODO Auto-generated method stub
		if(result == SUCCESS) {
			//Working Formula 
			voltage = (uint16_t)((uint32_t) 1100 * (uint32_t) 1024 / (uint32_t) val);

			if(((centiG > (mean_val + 2)) || (centiG < (mean_val - 2)))&&(send_type != POLL_REPLY)) 
				send_type = EM_PING;
			// Giving priority to POLL Reply    

			if(send_type == EM_PING || send_type == POLL_REPLY) {
				if(send_packet(centiG, send_type) == SUCCESS) 
					call Leds.led2On();
			}

			else {
				sensing = FALSE;
			}

		}
	}
}
